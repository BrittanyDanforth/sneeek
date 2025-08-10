--[[
	Modernized Purchase Handler (2025 Standards)
	Handles tycoon purchases and money collection
--]]

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

-- Get settings and references
local Settings = require(script.Parent.Parent.Parent.Settings)
local Objects = {}
local TeamColor = script.Parent:WaitForChild("TeamColor").Value
local Money = script.Parent:WaitForChild("CurrencyToCollect")
local Stealing = Settings.StealSettings
local CanSteal = true

-- Set spawn colors
local essentials = script.Parent:WaitForChild("Essentials")
local spawn = essentials:WaitForChild("Spawn")
spawn.TeamColor = TeamColor
spawn.BrickColor = TeamColor

-- Modern sound function
local function playSound(part, soundId)
	if part:FindFirstChild("Sound") then
		return
	end
	
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. tostring(soundId)
	sound.Volume = 0.5
	sound.Parent = part
	
	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

-- Set up part collectors with modern practices
for _, collector in ipairs(essentials:GetChildren()) do
	if collector.Name == "PartCollector" then
		collector.Touched:Connect(function(part)
			local cashValue = part:FindFirstChild("Cash")
			if cashValue then
				Money.Value = Money.Value + cashValue.Value
				Debris:AddItem(part, 0.1)
			end
		end)
	end
end

-- Modern player collector with debounce
local collectorDebounce = {}
local giver = essentials:WaitForChild("Giver")

giver.Touched:Connect(function(hit)
	local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end
	
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player then return end
	
	-- Owner collecting money
	if script.Parent.Owner.Value == player then
		if collectorDebounce[player] then return end
		collectorDebounce[player] = true
		
		giver.BrickColor = BrickColor.new("Bright red")
		
		local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
		if playerStats then
			playSound(essentials, Settings.Sounds.Collect)
			playerStats.Value = playerStats.Value + Money.Value
			Money.Value = 0
		end
		
		task.wait(1)
		giver.BrickColor = BrickColor.new("Sea green")
		collectorDebounce[player] = nil
		
	-- Stealing mechanic
	elseif Stealing.Stealing and CanSteal then
		CanSteal = false
		
		task.delay(Stealing.PlayerProtection, function()
			CanSteal = true
		end)
		
		local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
		if playerStats then
			local stealAmount = math.floor(Money.Value * Stealing.StealPrecent)
			if stealAmount > 0 then
				playSound(essentials, Settings.Sounds.Collect)
				playerStats.Value = playerStats.Value + stealAmount
				Money.Value = Money.Value - stealAmount
			end
		end
	else
		playSound(essentials, Settings.Sounds.ErrorBuy)
	end
end)

-- Modern button setup with async loading
local buttons = script.Parent:WaitForChild("Buttons")
local purchases = script.Parent:WaitForChild("Purchases")
local purchasedObjects = script.Parent:WaitForChild("PurchasedObjects")

-- Tween settings for fading
local fadeInfo = TweenInfo.new(
	Settings.FadeOutTime,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.Out
)

-- Process each button
for _, button in ipairs(buttons:GetChildren()) do
	task.spawn(function()
		local head = button:FindFirstChild("Head")
		if not head then return end
		
		-- Load the object for this button
		local objectName = button:WaitForChild("Object").Value
		local purchaseObject = purchases:FindFirstChild(objectName)
		
		if purchaseObject then
			Objects[objectName] = purchaseObject:Clone()
			purchaseObject:Destroy()
		else
			warn("Object missing for button:", button.Name)
			head.CanCollide = false
			head.Transparency = 1
			return
		end
		
		-- Handle dependencies
		local dependency = button:FindFirstChild("Dependency")
		if dependency then
			head.CanCollide = false
			head.Transparency = 1
			
			-- Wait for dependency
			purchasedObjects:WaitForChild(dependency.Value)
			
			-- Fade in button
			if Settings.ButtonsFadeIn then
				local tween = TweenService:Create(head, fadeInfo, {Transparency = 0})
				tween:Play()
				tween.Completed:Wait()
			end
			
			head.CanCollide = true
			head.Transparency = 0
		end
		
		-- Handle button touches
		local purchaseDebounce = {}
		
		head.Touched:Connect(function(hit)
			if not head.CanCollide then return end
			
			local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
			if not humanoid or humanoid.Health <= 0 then return end
			
			local player = Players:GetPlayerFromCharacter(hit.Parent)
			if not player or player ~= script.Parent.Owner.Value then return end
			
			-- Prevent spam clicking
			if purchaseDebounce[player] then return end
			purchaseDebounce[player] = true
			
			task.defer(function()
				task.wait(0.5)
				purchaseDebounce[player] = nil
			end)
			
			local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
			if not playerStats then return end
			
			-- Handle gamepass purchases
			local gamepass = button:FindFirstChild("Gamepass")
			if gamepass and gamepass.Value >= 1 then
				local hasPass = false
				local success, result = pcall(function()
					return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepass.Value)
				end)
				
				if success then
					hasPass = result
				end
				
				if hasPass then
					processPurchase(button, playerStats)
				else
					MarketplaceService:PromptGamePassPurchase(player, gamepass.Value)
				end
				return
			end
			
			-- Handle dev product purchases
			local devProduct = button:FindFirstChild("DevProduct")
			if devProduct and devProduct.Value >= 1 then
				MarketplaceService:PromptProductPurchase(player, devProduct.Value)
				return
			end
			
			-- Handle regular purchases
			local price = button:WaitForChild("Price").Value
			if playerStats.Value >= price then
				processPurchase(button, playerStats)
				playSound(head, Settings.Sounds.Purchase)
			else
				playSound(head, Settings.Sounds.ErrorBuy)
			end
		end)
	end)
end

-- Modern purchase function
function processPurchase(button, playerStats)
	local price = button.Price.Value
	local objectName = button.Object.Value
	
	-- Deduct cost and spawn object
	playerStats.Value = playerStats.Value - price
	
	if Objects[objectName] then
		local newObject = Objects[objectName]:Clone()
		newObject.Parent = purchasedObjects
	end
	
	-- Fade out button
	local head = button:FindFirstChild("Head")
	if head then
		head.CanCollide = false
		
		if Settings.ButtonsFadeOut then
			local tween = TweenService:Create(head, fadeInfo, {Transparency = 1})
			tween:Play()
		else
			head.Transparency = 1
		end
	end
end

-- Handle BuyObject folder (for dev products and special purchases)
local buyObject = script.Parent:WaitForChild("BuyObject")

buyObject.ChildAdded:Connect(function(child)
	task.wait(0.1) -- Small delay to ensure values are set
	
	local cost = child:FindFirstChild("Cost")
	local button = child:FindFirstChild("Button")
	local stats = child:FindFirstChild("Stats")
	
	if cost and button and stats then
		processPurchase(button.Value, stats.Value)
	end
	
	-- Clean up after 10 seconds
	task.wait(10)
	if child.Parent then
		child:Destroy()
	end
end)

-- Handle gamepass purchases
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
	if not wasPurchased then return end
	
	-- Find the button for this gamepass
	for _, button in ipairs(buttons:GetChildren()) do
		local gamepass = button:FindFirstChild("Gamepass")
		if gamepass and gamepass.Value == gamePassId then
			local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
			if playerStats then
				processPurchase(button, playerStats)
			end
			break
		end
	end
end)