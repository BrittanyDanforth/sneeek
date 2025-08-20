--[[
	Fully Polished Purchase Handler - Complete Version (with 2x Cash)
--]]

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")

local Settings = require(script.Parent.Parent.Parent.Settings)
local Objects = {}
local TeamColor = script.Parent:WaitForChild("TeamColor").Value
local Money = script.Parent:WaitForChild("CurrencyToCollect")

local essentials = script.Parent:WaitForChild("Essentials")
local spawn = essentials:WaitForChild("Spawn")
spawn.TeamColor = TeamColor
spawn.BrickColor = TeamColor

local function playSound(part, soundId)
	if not part or not soundId then return end
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://" .. tostring(soundId)
	s.Volume = 0.5
	s.Parent = part
	s:Play()
	s.Ended:Connect(function() s:Destroy() end)
end

-- Part collector (2x)
local collectedParts = {}
for _, collector in ipairs(essentials:GetChildren()) do
	if collector.Name == "PartCollector" then
		collector.CanCollide = false
		collector.CanTouch = true
		collector.CanQuery = false
		collector.Touched:Connect(function(part)
			if collectedParts[part] or not part:IsDescendantOf(workspace) then return end
			local cashValue = part:FindFirstChild("Cash")
			if cashValue and cashValue:IsA("IntValue") then
				collectedParts[part] = true
				local owner = script.Parent.Owner.Value
				local grant = cashValue.Value
				if owner then
					local has2x = false
					pcall(function()
						has2x = MarketplaceService:UserOwnsGamePassAsync(owner.UserId, 1398974710)
					end)
					if has2x then grant = grant * 2 end
				end
				Money.Value = Money.Value + grant
				if part:IsA("BasePart") then
					local tween = TweenService:Create(part, TweenInfo.new(0.3), {Transparency = 1})
					tween:Play()
					tween.Completed:Connect(function()
						if part and part.Parent then part:Destroy() end
					end)
				else
					part:Destroy()
				end
				collectedParts[part] = nil
			end
		end)
	end
end

-- Player collector
local collectorDebounce = {}
local giver = essentials:WaitForChild("Giver")

giver.Touched:Connect(function(hit)
	local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player then return end
	if script.Parent.Owner.Value == player then
		if collectorDebounce[player] then return end
		collectorDebounce[player] = true
		giver.BrickColor = BrickColor.new("Bright red")
		local stats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
		if stats and Money.Value > 0 then
			playSound(essentials, Settings.Sounds.Collect)
			stats.Value = stats.Value + Money.Value
			Money.Value = 0
		end
		task.wait(1)
		giver.BrickColor = BrickColor.new("Sea green")
		collectorDebounce[player] = nil
	end
end)

-- Buttons
local buttons = script.Parent:WaitForChild("Buttons")
local purchases = script.Parent:WaitForChild("Purchases")
local purchasedObjects = script.Parent:WaitForChild("PurchasedObjects")

for _, button in ipairs(buttons:GetChildren()) do
	local head = button:FindFirstChild("Head")
	if not head then continue end
	local objectValue = button:FindFirstChild("Object")
	if not objectValue or not objectValue.Value then continue end
	local purchaseObject = purchases:FindFirstChild(objectValue.Value)
	if purchaseObject then
		Objects[objectValue.Value] = purchaseObject:Clone()
		purchaseObject:Destroy()
	end
	head.Touched:Connect(function(hit)
		if not head.CanCollide or head.Transparency >= 1 then return end
		local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then return end
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player or script.Parent.Owner.Value ~= player then return end
		local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
		if not playerStats then return end
		local price = button.Price.Value
		local gamepass = button:FindFirstChild("Gamepass")
		if gamepass and gamepass.Value > 0 then
			local hasPass = false
			pcall(function()
				hasPass = MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepass.Value)
			end)
			if hasPass then
				processPurchase(button, playerStats)
			else
				MarketplaceService:PromptGamePassPurchase(player, gamepass.Value)
			end
			return
		end
		local devProduct = button:FindFirstChild("DevProduct")
		if devProduct and devProduct.Value > 0 then
			MarketplaceService:PromptProductPurchase(player, devProduct.Value)
			return
		end
		if price and playerStats.Value >= price then
			processPurchase(button, playerStats)
			playSound(head, Settings.Sounds.Purchase)
		else
			playSound(head, Settings.Sounds.ErrorBuy)
		end
	end)
end

function processPurchase(button, playerStats)
	local price = button.Price.Value
	local objectName = button.Object.Value
	playerStats.Value -= price
	if Objects[objectName] then
		local newObject = Objects[objectName]:Clone()
		newObject.Parent = purchasedObjects
	end
	local head = button:FindFirstChild("Head")
	if head then
		head.CanCollide = false
		TweenService:Create(head, TweenInfo.new(Settings.FadeOutTime or 0.5, Enum.EasingStyle.Quad), {Transparency = 1}):Play()
	end
end

print("✅ Fully Polished Purchase Handler loaded!")

