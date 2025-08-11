--!strict

-- PurchaseServer.server.lua
-- Server-side validator for tycoon purchases. Validates cost and dependencies,
-- decrements currency, marks item owned, and triggers product activation/building.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

local function findLeaderstatCurrency(player: Player)
	local ls = player:FindFirstChild("leaderstats")
	if not ls then return nil end
	for _, name in ipairs({"Cash", "Coins", "Money", "Gold"}) do
		local v = ls:FindFirstChild(name)
		if v and (v:IsA("IntValue") or v:IsA("NumberValue")) then
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

local function getButtonId(buttonModel: Instance): string
	local idAttr = buttonModel:GetAttribute("Id")
	if typeof(idAttr) == "string" and idAttr ~= "" then return idAttr end
	return (buttonModel:GetFullName()):gsub("%s+", "_")
end

local function gatherButtons(root: Instance)
	local map = {}
	for _, inst in ipairs(root:GetDescendants()) do
		if inst:IsA("Model") or inst:IsA("BasePart") then
			local hasClick = inst:FindFirstChildOfClass("ClickDetector") ~= nil
			local hasPrice = readNumberAttributeOrChild(inst, {"Cost", "Price"}, -1) >= 0
			if hasClick or hasPrice then
				local id = getButtonId(inst)
				local cost = readNumberAttributeOrChild(inst, {"Cost", "Price"}, 0)
				map[id] = inst
			end
		end
	end
	return map
end

local function findPlayersTycoon(player: Player)
	local tycoonsFolder = workspace:FindFirstChild("Tycoons") or workspace
	for _, m in ipairs(tycoonsFolder:GetDescendants()) do
		if m:IsA("Model") then
			local ownerAttr = m:GetAttribute("OwnerUserId")
			if typeof(ownerAttr) == "number" and ownerAttr == player.UserId then return m end
			local ownerObj = m:FindFirstChild("Owner")
			if ownerObj and ownerObj:IsA("ObjectValue") and ownerObj.Value == player then return m end
			if string.find(m.Name, player.Name, 1, true) then return m end
		end
	end
	return nil
end

local function dependenciesSatisfied(button: Instance, buttonMap)
	local function resolveDepends(target: Instance)
		local deps = {}
		local attr = target:GetAttribute("DependsOn")
		if typeof(attr) == "string" and attr ~= "" then
			local p = target.Parent
			if p then
				local inst = p:FindFirstChild(attr)
				if inst then table.insert(deps, inst) end
			end
		end
		local child = target:FindFirstChild("DependsOn")
		if child then
			if child:IsA("ObjectValue") and child.Value then
				table.insert(deps, child.Value)
			elseif child:IsA("Folder") then
				for _, v in ipairs(child:GetChildren()) do
					if v:IsA("ObjectValue") and v.Value then table.insert(deps, v.Value) end
				end
			elseif child:IsA("StringValue") and child.Value ~= "" then
				local p = target.Parent
				if p then
					local inst = p:FindFirstChild(child.Value)
					if inst then table.insert(deps, inst) end
				end
			end
		end
		return deps
	end
	for _, dep in ipairs(resolveDepends(button)) do
		local id = getButtonId(dep)
		local owned = dep:GetAttribute("Owned") == true
		if not owned then return false end
	end
	return true
end

local function activateProduct(button: Instance)
	-- Common patterns: set product visible, clone model, enable dropper, etc.
	button:SetAttribute("Owned", true)
	-- Reveal any product child
	local product = button:FindFirstChild("Product")
	if product then
		for _, d in ipairs(product:GetDescendants()) do
			if d:IsA("BasePart") then
				d.Transparency = 0
				d.CanCollide = true
			end
		end
	end
end

RequestPurchase.OnServerEvent:Connect(function(player: Player, buttonId: string)
	if typeof(buttonId) ~= "string" then return end
	local tycoon = findPlayersTycoon(player)
	if not tycoon then return end
	local buttonsRoot = tycoon:FindFirstChild("Buttons") or tycoon:FindFirstChild("Purchases") or tycoon
	local buttonMap = gatherButtons(buttonsRoot)
	local target = buttonMap[buttonId]
	if not target then return end

	if target:GetAttribute("Owned") == true then return end
	if not dependenciesSatisfied(target, buttonMap) then return end

	local cost = readNumberAttributeOrChild(target, {"Cost", "Price"}, 0)
	local currency = findLeaderstatCurrency(player)
	if not currency then return end
	local current = currency.Value
	if typeof(current) ~= "number" then
		current = tonumber(current) or 0
	end
	if current < cost then return end

	currency.Value = (current :: number) - cost
	activateProduct(target)

	-- Notify client(s)
	local id = getButtonId(target)
	PurchaseSuccess:FireClient(player, id)
end)