--[[
	✨ Modernized Purchase Handler with Dependency System
	Uses the old reliable dependency system that actually works
	Clean, modern code with proper effects
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

-- Sound function
local function playSound(part, soundId, volume)
	if not soundId or soundId == 0 then return end
	if part:FindFirstChild("Sound") then return end
	
	-- Skip broken sound IDs
	if soundId == 131961136 or soundId == 131886985 then return end
	
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. tostring(soundId)
	sound.Volume = volume or 0.3
	sound.Parent = part
	sound:Play()
	
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

-- PART COLLECTOR - Simple and clean
local collectedParts = {}
for _, collector in ipairs(essentials:GetChildren()) do
	if collector.Name == "PartCollector" then
		collector.CanCollide = false
		
		collector.Touched:Connect(function(part)
			if collectedParts[part] then return end
			
			local cashValue = part:FindFirstChild("Cash")
			if cashValue then
				collectedParts[part] = true
				Money.Value = Money.Value + cashValue.Value
				
				-- Stop part movement
				part.Anchored = true
				part.CanCollide = false
				part.CanTouch = false
				part.CanQuery = false
				
				-- Simple fade
				if part:IsA("BasePart") then
					TweenService:Create(part,
						TweenInfo.new(0.3, Enum.EasingStyle.Linear),
						{Transparency = 1}
					):Play()
					
					-- Fade children
					for _, child in ipairs(part:GetDescendants()) do
						if child:IsA("Decal") or child:IsA("Texture") then
							TweenService:Create(child, TweenInfo.new(0.3), {Transparency = 1}):Play()
						end
					end
				end
				
				task.wait(0.3)
				part:Destroy()
				
				task.delay(1, function()
					collectedParts[part] = nil
				end)
			end
		end)
	end
end

-- MONEY COLLECTOR
local collectorDebounce = false
local giver = essentials:WaitForChild("Giver")

giver.Touched:Connect(function(hit)
	local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end
	
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player then return end
	
	if script.Parent.Owner.Value == player then
		if collectorDebounce then return end
		collectorDebounce = true
		
		giver.BrickColor = BrickColor.new("Bright red")
		
		local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
		if playerStats and Money.Value > 0 then
			playSound(essentials, Settings.Sounds.Collect, 0.5)
			playerStats.Value = playerStats.Value + Money.Value
			Money.Value = 0
		end
		
		task.wait(1)
		giver.BrickColor = BrickColor.new("Sea green")
		collectorDebounce = false
		
	elseif Stealing.Stealing and CanSteal then
		CanSteal = false
		task.delay(Stealing.PlayerProtection, function()
			CanSteal = true
		end)
		
		local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
		if playerStats then
			local stealAmount = math.floor(Money.Value * Stealing.StealPrecent)
			if stealAmount > 0 then
				playSound(essentials, Settings.Sounds.Collect, 0.5)
				playerStats.Value = playerStats.Value + stealAmount
				Money.Value = Money.Value - stealAmount
			end
		end
	else
		playSound(essentials, Settings.Sounds.Error or Settings.Sounds.ErrorBuy, 0.3)
	end
end)

-- BUTTON SETUP WITH DEPENDENCY SYSTEM
local buttons = script.Parent:WaitForChild("Buttons")
local purchases = script.Parent:WaitForChild("Purchases")
local purchasedObjects = script.Parent:WaitForChild("PurchasedObjects")

for _, button in ipairs(buttons:GetChildren()) do
	task.spawn(function()
		local head = button:FindFirstChild("Head")
		if not head then return end
		
		-- Load the object for this button
		local objectName = button:FindFirstChild("Object")
		if objectName and objectName.Value then
			local purchaseObject = purchases:FindFirstChild(objectName.Value)
			if purchaseObject then
				Objects[objectName.Value] = purchaseObject:Clone()
				purchaseObject:Destroy()
			else
				warn("Object missing for button:", button.Name)
				head.CanCollide = false
				head.Transparency = 1
				return
			end
		end
		
		-- DEPENDENCY SYSTEM - This is the key!
		local dependency = button:FindFirstChild("Dependency")
		if dependency and dependency.Value then
			-- Hide button until dependency is purchased
			head.CanCollide = false
			head.Transparency = 1
			
			-- Wait for dependency to be purchased
			task.spawn(function()
				purchasedObjects:WaitForChild(dependency.Value)
				
				-- Fade in button
				if Settings.ButtonsFadeIn then
					for i = 1, 20 do
						task.wait((Settings.FadeInTime or 0.5) / 20)
						head.Transparency = head.Transparency - 0.05
					end
				else
					head.Transparency = 0
				end
				head.CanCollide = true
			end)
		end
		
		-- Button touch handler
		head.Touched:Connect(function(hit)
			if not head.CanCollide or head.Transparency > 0.5 then return end
			
			local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
			if not humanoid or humanoid.Health <= 0 then return end
			
			local player = Players:GetPlayerFromCharacter(hit.Parent)
			if not player or player ~= script.Parent.Owner.Value then return end
			
			local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
			if not playerStats then return end
			
			-- Handle different purchase types
			local gamepass = button:FindFirstChild("Gamepass")
			local devProduct = button:FindFirstChild("DevProduct")
			local price = button:FindFirstChild("Price")
			price = price and price.Value or 0
			
			if gamepass and gamepass.Value >= 1 then
				-- Gamepass purchase
				local hasPass = false
				pcall(function()
					hasPass = MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepass.Value)
				end)
				
				if hasPass then
					processPurchase(button, playerStats, price)
				else
					MarketplaceService:PromptGamePassPurchase(player, gamepass.Value)
				end
			elseif devProduct and devProduct.Value >= 1 then
				-- Dev product purchase
				MarketplaceService:PromptProductPurchase(player, devProduct.Value)
			elseif playerStats.Value >= price then
				-- Regular purchase
				processPurchase(button, playerStats, price)
				playSound(head, Settings.Sounds.Purchase, 0.5)
			else
				-- Not enough money
				playSound(head, Settings.Sounds.ErrorBuy, 0.3)
			end
		end)
	end)
end

-- Process purchase function
function processPurchase(button, playerStats, price)
	-- Deduct money
	playerStats.Value = playerStats.Value - price
	
	-- Spawn object
	local objectName = button:FindFirstChild("Object")
	if objectName and objectName.Value and Objects[objectName.Value] then
		local newObject = Objects[objectName.Value]:Clone()
		newObject.Parent = purchasedObjects
		
		-- White doors for Cinnamoroll theme
		if objectName.Value:find("Door") or objectName.Value:find("door") then
			for _, part in ipairs(newObject:GetDescendants()) do
				if part:IsA("BasePart") then
					part.BrickColor = BrickColor.new("White")
				end
			end
		end
		
		-- Enable scripts
		for _, script in ipairs(newObject:GetDescendants()) do
			if script:IsA("Script") then
				script.Disabled = false
			end
		end
	end
	
	-- Hide button
	local head = button:FindFirstChild("Head")
	if head then
		head.CanCollide = false
		
		if Settings.ButtonsFadeOut then
			-- Fade out
			task.spawn(function()
				for i = 1, 20 do
					task.wait((Settings.FadeOutTime or 0.5) / 20)
					head.Transparency = head.Transparency + 0.05
				end
				head.Transparency = 1
			end)
		else
			head.Transparency = 1
		end
	end
end

-- Handle BuyObject system (for special purchases)
local buyObject = script.Parent:WaitForChild("BuyObject")
buyObject.ChildAdded:Connect(function(child)
	task.wait(0.1)
	
	local cost = child:FindFirstChild("Cost")
	local button = child:FindFirstChild("Button")
	local stats = child:FindFirstChild("Stats")
	
	if cost and button and button.Value and stats and stats.Value then
		processPurchase(button.Value, stats.Value, cost.Value)
	end
	
	task.wait(10)
	if child.Parent then
		child:Destroy()
	end
end)

-- Handle gamepass purchases
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
	if not wasPurchased then return end
	
	for _, button in ipairs(buttons:GetChildren()) do
		local gamepass = button:FindFirstChild("Gamepass")
		if gamepass and gamepass.Value == gamePassId then
			local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
			if playerStats then
				local price = button:FindFirstChild("Price")
				processPurchase(button, playerStats, price and price.Value or 0)
			end
			break
		end
	end
end)

print("✅ Modernized Purchase Handler with Dependency System loaded!")
print("✨ Buttons will appear based on Dependency objects, not PROGRESSION_DATA!")