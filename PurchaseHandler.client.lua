--!strict

-- PurchaseHandler.client.lua
-- Client-side handler for tycoon purchase buttons with robust dependency tracking,
-- affordability gating, and button position fixing.

-- How it works (high level):
-- - Discovers the local player's tycoon automatically
-- - Indexes all buttons, reading Cost, DependsOn (single or multiple), and the Product to spawn
-- - Only shows a small set of upcoming buttons (configurable) prioritizing affordable ones
-- - When a button is purchased, reveals all buttons that depend on it (supports multiple next buttons)
-- - Continuously updates button UI based on player's currency
-- - Safely repositions floating/underground buttons at startup via fixButtonPosition

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local localPlayer = Players.LocalPlayer

-- Remote wiring
local RemoteFolder = ReplicatedStorage:FindFirstChild("RemoteEvents") or Instance.new("Folder")
RemoteFolder.Name = "RemoteEvents"
RemoteFolder.Parent = ReplicatedStorage

local RequestPurchase = RemoteFolder:FindFirstChild("RequestPurchase")
if not RequestPurchase then
	RequestPurchase = Instance.new("RemoteEvent")
	RequestPurchase.Name = "RequestPurchase"
	RequestPurchase.Parent = RemoteFolder
end

local PurchaseSuccess = RemoteFolder:FindFirstChild("PurchaseSuccess")
if not PurchaseSuccess then
	PurchaseSuccess = Instance.new("RemoteEvent")
	PurchaseSuccess.Name = "PurchaseSuccess"
	PurchaseSuccess.Parent = RemoteFolder
end

-- Configuration
local MAX_VISIBLE_PER_CHAIN = 2 -- shows up to this many next buttons per dependency chain
local AFFORDABLE_FIRST = true   -- prioritize showing affordable buttons
local BUTTON_RAYCAST_DISTANCE = 200
local BUTTON_RAISE_OFFSET = 1.0
local BUTTON_MIN_Y = -1000 -- clamp bad Y
local BUTTON_MAX_Y = 10000
local UPDATE_UI_INTERVAL = 0.25

export type ButtonInfo = {
	buttonModel: Instance,
	id: string,
	name: string,
	cost: number,
	dependsOnIds: {string},
	dependents: {string},
	owned: boolean,
	visible: boolean,
	productRef: Instance?,
	billboard: BillboardGui?,
}

type ButtonId = string

type TycoonData = {
	model: Model,
	buttonsFolder: Instance,
	buttons: {[ButtonId]: ButtonInfo},
	rootButtons: {ButtonId},
	owned: {[ButtonId]: boolean},
}

local function findLeaderstatCurrency(player: Player): (StringValue | IntValue | NumberValue)?
	local ls = player:FindFirstChild("leaderstats")
	if not ls then return nil end
	local currencyNames = {"Cash", "Coins", "Money", "Gold"}
	for _, name in ipairs(currencyNames) do
		local v = ls:FindFirstChild(name)
		if v and (v:IsA("IntValue") or v:IsA("NumberValue") or v:IsA("StringValue")) then
			return v
		end
	end
	return nil
end

local function readNumberAttributeOrChild(instance: Instance, keys: {string}, defaultValue: number): number
	for _, key in ipairs(keys) do
		local attr = instance:GetAttribute(key)
		if typeof(attr) == "number" then return attr end
	end
	for _, key in ipairs(keys) do
		local child = instance:FindFirstChild(key)
		if child and child:IsA("NumberValue") then return child.Value end
		if child and child:IsA("IntValue") then return child.Value end
		if child and child:IsA("StringValue") then
			local n = tonumber(child.Value)
			if n then return n end
		end
	end
	return defaultValue
end

local function readStringOrRefDependency(instance: Instance): {Instance}
	local out: {Instance} = {}
	-- Attribute: DependsOn may be a path-like string or a name
	local attr = instance:GetAttribute("DependsOn")
	if typeof(attr) == "string" then
		local parent = instance.Parent
		if parent then
			local ref = parent:FindFirstChild(attr)
			if ref then table.insert(out, ref) end
		end
	end
	-- Child ObjectValue or StringValue
	local dependsChild = instance:FindFirstChild("DependsOn")
	if dependsChild then
		if dependsChild:IsA("ObjectValue") and dependsChild.Value then
			table.insert(out, dependsChild.Value)
		elseif dependsChild:IsA("Folder") then
			for _, v in ipairs(dependsChild:GetChildren()) do
				if v:IsA("ObjectValue") and v.Value then table.insert(out, v.Value) end
				if v:IsA("StringValue") and v.Value ~= "" then
					local p = instance.Parent
					if p then
						local r = p:FindFirstChild(v.Value)
						if r then table.insert(out, r) end
					end
				end
			end
		elseif dependsChild:IsA("StringValue") and dependsChild.Value ~= "" then
			local p = instance.Parent
			if p then
				local r = p:FindFirstChild(dependsChild.Value)
				if r then table.insert(out, r) end
			end
		end
	end
	return out
end

local function getPrimaryButtonPart(buttonModel: Instance): BasePart?
	if buttonModel:IsA("BasePart") then return buttonModel end
	if buttonModel:IsA("Model") then
		local model = buttonModel :: Model
		if model.PrimaryPart then return model.PrimaryPart end
		local commonNames = {"Button", "Head", "Part", "Base", "Primary"}
		for _, name in ipairs(commonNames) do
			local p = model:FindFirstChild(name)
			if p and p:IsA("BasePart") then return p end
		end
		for _, d in ipairs(model:GetDescendants()) do
			if d:IsA("BasePart") then return d end
		end
	end
	return nil
end

local function fixButtonPosition(buttonModel: Instance)
	local part = getPrimaryButtonPart(buttonModel)
	if not part then return end
	local w = workspace
	local origin = part.Position + Vector3.new(0, 2, 0)
	local direction = Vector3.new(0, -BUTTON_RAYCAST_DISTANCE, 0)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {buttonModel}
	params.FilterType = Enum.RaycastFilterType.Exclude
	local result = w:Raycast(origin, direction, params)
	if result then
		local hitY = result.Position.Y
		local newY = math.clamp(hitY + BUTTON_RAISE_OFFSET, BUTTON_MIN_Y, BUTTON_MAX_Y)
		local cf = part.CFrame
		local newPos = Vector3.new(cf.X, newY, cf.Z)
		part.Anchored = true
		part.CFrame = CFrame.new(newPos, newPos + Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z))
	else
		-- If no ground hit, gently bring it up to reasonable height
		local cf = part.CFrame
		local newY = math.clamp(cf.Y + 1, BUTTON_MIN_Y, BUTTON_MAX_Y)
		part.Anchored = true
		part.CFrame = CFrame.new(Vector3.new(cf.X, newY, cf.Z))
	end
end

local function ensureClickDetector(buttonModel: Instance): ClickDetector
	local primary = getPrimaryButtonPart(buttonModel)
	if not primary then
		local cd = Instance.new("ClickDetector")
		cd.MaxActivationDistance = 32
		cd.Name = "ClickDetector"
		cd.Parent = buttonModel
		return cd
	end
	local cd = primary:FindFirstChildOfClass("ClickDetector")
	if not cd then
		cd = Instance.new("ClickDetector")
		cd.MaxActivationDistance = 32
		cd.Parent = primary
	end
	return cd
end

local function ensureBillboard(buttonModel: Instance): BillboardGui
	local primary = getPrimaryButtonPart(buttonModel)
	local bb = primary and primary:FindFirstChild("PriceBillboard")
	if bb and bb:IsA("BillboardGui") then return bb end
	bb = Instance.new("BillboardGui")
	bb.Name = "PriceBillboard"
	bb.Size = UDim2.new(0, 0, 0, 0)
	bb.StudsOffset = Vector3.new(0, 3, 0)
	bb.AlwaysOnTop = true
	bb.MaxDistance = 100
	bb.LightInfluence = 0
	bb.Parent = primary or buttonModel

	local frame = Instance.new("Frame")
	frame.Name = "Frame"
	frame.Size = UDim2.new(0, 160, 0, 42)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	frame.BackgroundTransparency = 0.2
	frame.Parent = bb

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1.5
	stroke.Color = Color3.fromRGB(90, 90, 90)
	stroke.Parent = frame

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(1, -10, 1, -10)
	label.Position = UDim2.new(0, 5, 0, 5)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0.5
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Text = ""
	label.Parent = frame

	return bb
end

local function getAncestorModelName(instance: Instance): string
	local model = instance:IsA("Model") and instance or instance:FindFirstAncestorOfClass("Model")
	return model and model.Name or instance.Name
end

local function getButtonId(buttonModel: Instance): string
	local idAttr = buttonModel:GetAttribute("Id")
	if typeof(idAttr) == "string" and idAttr ~= "" then return idAttr end
	local name = getAncestorModelName(buttonModel)
	-- Use a stable, unique-ish id from full path
	return (buttonModel:GetFullName()):gsub("%s+", "_") .. "#" .. name
end

local function tryFindProduct(buttonModel: Instance): Instance?
	-- Common patterns: ObjectValue Product, child named Product/Item/Model, or attribute ProductPath
	local ov = buttonModel:FindFirstChild("Product")
	if ov and ov:IsA("ObjectValue") and ov.Value then return ov.Value end
	local attr = buttonModel:GetAttribute("ProductPath")
	if typeof(attr) == "string" and attr ~= "" then
		local node = game
		for match in string.gmatch(attr, "[^/]+") do
			node = (node :: any)[match]
			if not node then break end
		end
		if typeof(node) == "Instance" then return node :: any end
	end
	for _, n in ipairs({"Product", "Item", "Model", "Build", "Giver"}) do
		local c = buttonModel:FindFirstChild(n)
		if c then return c end
	end
	return nil
end

local function gatherButtons(buttonsFolder: Instance): {[ButtonId]: ButtonInfo}
	local map: {[ButtonId]: ButtonInfo} = {}
	for _, inst in ipairs(buttonsFolder:GetDescendants()) do
		if inst:IsA("Model") or inst:IsA("BasePart") then
			-- Heuristic: consider only those with a ClickDetector or Cost/Price data
			local hasClick = inst:FindFirstChildOfClass("ClickDetector") ~= nil
			local hasPrice = readNumberAttributeOrChild(inst, {"Cost", "Price"}, -1) >= 0
			if hasClick or hasPrice then
				local id = getButtonId(inst)
				local cost = readNumberAttributeOrChild(inst, {"Cost", "Price"}, 0)
				local depsInsts = readStringOrRefDependency(inst)
				local deps: {string} = {}
				for _, d in ipairs(depsInsts) do
					deps[#deps+1] = getButtonId(d)
				end
				local info: ButtonInfo = {
					buttonModel = inst,
					id = id,
					name = getAncestorModelName(inst),
					cost = cost,
					dependsOnIds = deps,
					dependents = {},
					owned = inst:GetAttribute("Owned") == true,
					visible = inst:GetAttribute("Visible") ~= false,
					productRef = tryFindProduct(inst),
					billboard = nil,
				}
				map[id] = info
			end
		end
	end
	-- Build reverse edges
	for _, info in pairs(map) do
		for _, depId in ipairs(info.dependsOnIds) do
			if map[depId] then
				table.insert(map[depId].dependents, info.id)
			end
		end
	end
	return map
end

local function findTycoonForPlayer(player: Player): TycoonData?
	local tycoonsFolder = workspace:FindFirstChild("Tycoons") or workspace:FindFirstChild("Tycoon") or workspace
	local candidates: {Model} = {}
	for _, m in ipairs(tycoonsFolder:GetDescendants()) do
		if m:IsA("Model") then
			local ownerAttr = m:GetAttribute("OwnerUserId")
			if typeof(ownerAttr) == "number" and ownerAttr == player.UserId then
				table.insert(candidates, m)
			else
				local ownerObj = m:FindFirstChild("Owner")
				if ownerObj and ownerObj:IsA("ObjectValue") and ownerObj.Value == player then
					table.insert(candidates, m)
				elseif string.find(m.Name, player.Name, 1, true) then
					table.insert(candidates, m)
				end
			end
		end
	end
	local chosen: Model? = candidates[1]
	if not chosen then return nil end
	local buttonsFolder = chosen:FindFirstChild("Buttons") or chosen:FindFirstChild("Purchases") or chosen
	local buttons = gatherButtons(buttonsFolder)
	-- Root buttons are those with no dependencies
	local roots: {ButtonId} = {}
	for id, info in pairs(buttons) do
		if #info.dependsOnIds == 0 then table.insert(roots, id) end
	end
	return {
		model = chosen,
		buttonsFolder = buttonsFolder,
		buttons = buttons,
		rootButtons = roots,
		owned = {},
	}
end

local function setButtonVisible(info: ButtonInfo, visible: boolean)
	if info.visible == visible then return end
	info.visible = visible
	info.buttonModel:SetAttribute("Visible", visible)
	for _, d in ipairs(info.buttonModel:GetDescendants()) do
		if d:IsA("BasePart") or d:IsA("Decal") or d:IsA("Texture") then
			d.Transparency = visible and 0 or 1
			if d:IsA("BasePart") then d.CanCollide = visible end
		end
	end
	local cd = ensureClickDetector(info.buttonModel)
	cd.MaxActivationDistance = visible and 32 or 0
end

local function computeUnlockable(tycoon: TycoonData, ownedSet: {[ButtonId]: boolean}): {ButtonId}
	local unlockable: {ButtonId} = {}
	for id, info in pairs(tycoon.buttons) do
		if not info.owned then
			local ok = true
			for _, dep in ipairs(info.dependsOnIds) do
				if not ownedSet[dep] then ok = false break end
			end
			if ok then table.insert(unlockable, id) end
		end
	end
	return unlockable
end

local function pickVisibleSet(tycoon: TycoonData, currency: number): {[ButtonId]: boolean}
	-- Strategy: per immediate chain endpoint, show up to MAX_VISIBLE_PER_CHAIN.
	-- For simplicity, globally we pick up to N among unlockable, prioritizing affordability
	local unlockable = computeUnlockable(tycoon, tycoon.owned)
	table.sort(unlockable, function(a, b)
		local ia = tycoon.buttons[a]
		local ib = tycoon.buttons[b]
		if AFFORDABLE_FIRST then
			local aa = ia.cost <= currency
			local bb = ib.cost <= currency
			if aa ~= bb then return aa and not bb end
		end
		if ia.cost ~= ib.cost then return ia.cost < ib.cost end
		return ia.name < ib.name
	end)
	local visible: {[ButtonId]: boolean} = {}
	local shown = 0
	for _, id in ipairs(unlockable) do
		if shown >= math.max(MAX_VISIBLE_PER_CHAIN, 1) then break end
		visible[id] = true
		shown += 1
	end
	-- Always ensure at least one next is visible even if unaffordable
	if shown == 0 and #unlockable > 0 then
		visible[unlockable[1]] = true
	end
	return visible
end

local function updateBillboard(info: ButtonInfo, currency: number)
	local bb = info.billboard or ensureBillboard(info.buttonModel)
	info.billboard = bb
	local label = bb:FindFirstChild("Frame") and (bb.Frame:FindFirstChild("Label") :: TextLabel?)
	if not label then return end
	local ownedText = info.owned and "OWNED" or "BUY" 
	label.Text = string.format("%s - %s$%s", info.name, info.owned and "" or "", tostring(info.cost))
	if info.owned then
		label.Text = string.format("%s ✔", info.name)
		label.TextColor3 = Color3.fromRGB(90, 220, 120)
	else
		local affordable = currency >= info.cost
		label.Text = string.format("%s  |  $%d", info.name, info.cost)
		label.TextColor3 = affordable and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(220, 120, 120)
	end
end

local function wireClick(tycoon: TycoonData, info: ButtonInfo, currencyValue: ValueBase)
	local cd = ensureClickDetector(info.buttonModel)
	cd.MouseClick:Connect(function(player)
		if player ~= localPlayer then return end
		if info.owned then return end
		local currency = tonumber(currencyValue.Value) or 0
		if currency < info.cost then return end
		-- Client request to server
		RequestPurchase:FireServer(info.id)
	end)
end

local function applyVisibilityFromSet(tycoon: TycoonData, visibleSet: {[ButtonId]: boolean})
	for _, info in pairs(tycoon.buttons) do
		local shouldShow = visibleSet[info.id] == true
		setButtonVisible(info, shouldShow)
	end
end

local function bootstrapButtons(tycoon: TycoonData, currencyValue: ValueBase)
	-- Fix positions, attach click, and hide everything first
	for _, info in pairs(tycoon.buttons) do
		fixButtonPosition(info.buttonModel)
		setButtonVisible(info, false)
		wireClick(tycoon, info, currencyValue)
	end
	-- Initial visible set
	local currency = tonumber(currencyValue.Value) or 0
	local visible = pickVisibleSet(tycoon, currency)
	applyVisibilityFromSet(tycoon, visible)
	-- Periodic UI updates
	task.spawn(function()
		while task.wait(UPDATE_UI_INTERVAL) do
			local cash = tonumber(currencyValue.Value) or 0
			for _, info in pairs(tycoon.buttons) do
				if info.visible then updateBillboard(info, cash) end
			end
		end
	end)
end

local function onPurchaseSuccess(tycoon: TycoonData, boughtId: ButtonId)
	local info = tycoon.buttons[boughtId]
	if not info then return end
	info.owned = true
	tycoon.owned[boughtId] = true
	-- Hide purchased button
	setButtonVisible(info, false)
	-- Reveal new set based on dependencies
	local currencyValue = findLeaderstatCurrency(localPlayer)
	local cash = currencyValue and tonumber(currencyValue.Value) or 0
	local visible = pickVisibleSet(tycoon, cash)
	applyVisibilityFromSet(tycoon, visible)
end

local function init()
	local currencyValue = findLeaderstatCurrency(localPlayer)
	if not currencyValue then
		warn("PurchaseHandler: No leaderstats currency found. Expected 'Cash'/'Coins' etc.")
		return
	end
	local tycoon = findTycoonForPlayer(localPlayer)
	if not tycoon then
		warn("PurchaseHandler: Could not find player's tycoon.")
		return
	end
	bootstrapButtons(tycoon, currencyValue)
	PurchaseSuccess.OnClientEvent:Connect(function(purchasedId)
		onPurchaseSuccess(tycoon, purchasedId)
	end)
end

if RunService:IsClient() then
	init()
end