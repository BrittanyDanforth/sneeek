--[[
	✨ MyMelody Purchase Handler - ULTIMATE FIXED Version
	Properly handles tycoon resets and dependency system
	
	FIXES:
	- Dependencies now properly check for spawned objects
	- Monitors owner changes and resets everything
	- Re-initializes all systems after reset
	- Properly tracks purchased items
--]]

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

-- Get settings and references
local Settings = require(script.Parent.Parent.Parent.Settings) 
local Objects = {}
local TeamColor = script.Parent:WaitForChild("TeamColor").Value
local Money = script.Parent:WaitForChild("CurrencyToCollect")
local Stealing = Settings.StealSettings
local CanSteal = true

-- Track purchased items PER PLAYER
local purchasedItems = {}
local currentOwner = nil

-- Store original button states for reset
local originalButtonStates = {}

-- Track dependency connections
local dependencyConnections = {}

-- Track collected parts to prevent double collection
local collectedParts = {}

-- Set spawn colors
local essentials = script.Parent:WaitForChild("Essentials")
local spawn = essentials:WaitForChild("Spawn")
spawn.TeamColor = TeamColor
spawn.BrickColor = TeamColor

-- Get references
local buttons = script.Parent:WaitForChild("Buttons")
local purchases = script.Parent:WaitForChild("Purchases")
local purchasedObjects = script.Parent:WaitForChild("PurchasedObjects")
local tycoonOwner = script.Parent:WaitForChild("Owner")

-- Simple sound function (using old system for compatibility)
local function Sound(part, id, volume)
	if not id or id == 0 then return end
	if part:FindFirstChild('Sound') then return end
	
	local sound = Instance.new('Sound', part)
	sound.SoundId = "rbxassetid://" .. tostring(id)
	sound.Volume = volume or 0.5
	sound:Play()
	
	delay(sound.TimeLength, function()
		sound:Destroy()
	end)
end

-- Store original button states
local function storeOriginalButtonStates()
	for _, button in ipairs(buttons:GetChildren()) do
		local head = button:FindFirstChild("Head")
		if head then
			originalButtonStates[button.Name] = {
				Transparency = head.Transparency,
				CanCollide = head.CanCollide,
				BrickColor = head.BrickColor
			}
		end
	end
	print("📸 [MyMelody] Stored original states for", #buttons:GetChildren(), "buttons")
end

-- Fix button positions
local function fixButtonPositions()
	local fixedCount = 0

	for _, button in ipairs(buttons:GetChildren()) do
		local head = button:FindFirstChild("Head")
		if head and head:IsA("BasePart") then
			local raycast = workspace:Raycast(
				head.Position + Vector3.new(0, 10, 0),
				Vector3.new(0, -50, 0),
				RaycastParams.new()
			)

			if raycast then
				local groundY = raycast.Position.Y
				local buttonHeight = head.Size.Y
				local properY = groundY + (buttonHeight / 2) + 0.1

				-- ALWAYS fix position
				local targetPosition = Vector3.new(head.Position.X, properY, head.Position.Z)
				head.CFrame = CFrame.new(targetPosition) * (head.CFrame - head.CFrame.Position)
				fixedCount = fixedCount + 1
			end
		end
	end

	if fixedCount > 0 then
		print("✅ [MyMelody] Fixed", fixedCount, "button positions")
	end
end

-- Update button colors based on money
local function updateButtonColors()
	if not currentOwner then return end
	
	local playerStats = ServerStorage.PlayerMoney:FindFirstChild(currentOwner.Name)
	if not playerStats then return end

	for _, button in ipairs(buttons:GetChildren()) do
		local head = button:FindFirstChild("Head")
		if not head or head.Transparency > 0 or not head.CanCollide then continue end

		local price = button:FindFirstChild("Price")
		price = price and price.Value or 0

		if price > 0 then
			if playerStats.Value >= price then
				head.BrickColor = BrickColor.new("Lime green")
			else
				head.BrickColor = BrickColor.new("Really red")
			end
		end
	end
end

-- Load all objects at start
local function loadAllObjects()
	for _, button in ipairs(buttons:GetChildren()) do
		local objectName = button:FindFirstChild("Object")
		if objectName and objectName.Value then
			local purchaseObject = purchases:FindFirstChild(objectName.Value)
			if purchaseObject then
				Objects[objectName.Value] = purchaseObject:Clone()
				purchaseObject:Destroy()
			else
				warn("[MyMelody] Object missing for button:", button.Name, "- Object:", objectName.Value)
			end
		end
	end
	print("📦 [MyMelody] Loaded", #Objects, "objects")
end

-- Setup button dependency system
local function setupButtonDependency(button)
	local head = button:FindFirstChild("Head")
	if not head then return end

	local dependency = button:FindFirstChild("Dependency")
	if dependency and dependency.Value and dependency.Value ~= "" then
		-- Initially hide dependent button
		head.CanCollide = false
		head.Transparency = 1

		-- Check if dependency is already met
		local function checkDependency()
			for _, obj in ipairs(purchasedObjects:GetChildren()) do
				if obj.Name == dependency.Value then
					return true
				end
			end
			return false
		end

		-- If dependency already met, show button
		if checkDependency() then
			-- Fix position before showing
			local raycast = workspace:Raycast(
				head.Position + Vector3.new(0, 10, 0),
				Vector3.new(0, -50, 0),
				RaycastParams.new()
			)

			if raycast then
				local groundY = raycast.Position.Y
				local buttonHeight = head.Size.Y
				local properY = groundY + (buttonHeight / 2) + 0.1
				head.CFrame = CFrame.new(head.Position.X, properY, head.Position.Z) * (head.CFrame - head.CFrame.Position)
			end

			if Settings.ButtonsFadeIn then
				head.Transparency = 0.7
				TweenService:Create(head,
					TweenInfo.new(Settings.FadeInTime or 0.5, Enum.EasingStyle.Quad),
					{Transparency = 0}
				):Play()
			else
				head.Transparency = 0
			end
			head.CanCollide = true
			updateButtonColors()
			return
		end

		-- Otherwise, wait for dependency
		local connection = purchasedObjects.ChildAdded:Connect(function(child)
			if child.Name == dependency.Value then
				-- Dependency met!
				print("✅ [MyMelody] Dependency met for", button.Name, "- Required object spawned:", dependency.Value)

				-- Fix position before showing
				local raycast = workspace:Raycast(
					head.Position + Vector3.new(0, 10, 0),
					Vector3.new(0, -50, 0),
					RaycastParams.new()
				)

				if raycast then
					local groundY = raycast.Position.Y
					local buttonHeight = head.Size.Y
					local properY = groundY + (buttonHeight / 2) + 0.1
					head.CFrame = CFrame.new(head.Position.X, properY, head.Position.Z) * (head.CFrame - head.CFrame.Position)
				end

				if Settings.ButtonsFadeIn then
					head.Transparency = 0.7
					TweenService:Create(head,
						TweenInfo.new(Settings.FadeInTime or 0.5, Enum.EasingStyle.Quad),
						{Transparency = 0}
					):Play()
				else
					head.Transparency = 0
				end
				head.CanCollide = true
				updateButtonColors()
			end
		end)

		-- Store connection for cleanup
		if not dependencyConnections[button] then
			dependencyConnections[button] = {}
		end
		table.insert(dependencyConnections[button], connection)

		print("📎 [MyMelody] Set up dependency for", button.Name, "waiting for", dependency.Value)
	end
end

-- COMPLETE RESET FUNCTION
local function resetTycoonPurchases()
	print("🔄 [MyMelody] RESETTING TYCOON...")

	-- Clear purchased items tracking
	purchasedItems = {}
	
	-- Clear collected parts table
	collectedParts = {}

	-- Destroy all existing cash parts
	local destroyedParts = 0
	for _, descendant in pairs(workspace:GetDescendants()) do
		if descendant:FindFirstChild("Cash") then
			if descendant:IsA("BasePart") then
				local distance = (descendant.Position - script.Parent:GetPivot().Position).Magnitude
				if distance < 100 then
					descendant:Destroy()
					destroyedParts = destroyedParts + 1
				end
			end
		end
	end
	print("  ✓ [MyMelody] Destroyed", destroyedParts, "cash parts")

	-- Reset money
	Money.Value = 0

	-- Destroy all purchased objects
	local objectCount = #purchasedObjects:GetChildren()
	for _, obj in pairs(purchasedObjects:GetChildren()) do
		obj:Destroy()
	end
	print("  ✓ [MyMelody] Destroyed", objectCount, "purchased objects")

	-- Disconnect all dependency connections
	for button, connections in pairs(dependencyConnections) do
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end
	end
	dependencyConnections = {}

	-- Reset all buttons to original state
	for _, button in pairs(buttons:GetChildren()) do
		local head = button:FindFirstChild("Head")
		if head and originalButtonStates[button.Name] then
			local originalState = originalButtonStates[button.Name]

			-- Check for dependency
			local dependency = button:FindFirstChild("Dependency")
			if dependency and dependency.Value and dependency.Value ~= "" then
				-- Dependent button - hide it
				head.CanCollide = false
				head.Transparency = 1
			else
				-- Base button - restore to original
				head.CanCollide = originalState.CanCollide
				head.Transparency = originalState.Transparency
				head.BrickColor = BrickColor.new("Really red")
			end
		end
	end

	-- Re-setup dependency system for all buttons
	for _, button in pairs(buttons:GetChildren()) do
		setupButtonDependency(button)
	end

	-- Reset money collector color
	local giver = essentials:FindFirstChild("Giver")
	if giver then
		giver.BrickColor = BrickColor.new("Sea green")
	end

	-- Clear any BuyObject entries
	local buyObject = script.Parent:FindFirstChild("BuyObject")
	if buyObject then
		for _, child in pairs(buyObject:GetChildren()) do
			child:Destroy()
		end
	end

	-- Reset steal protection
	CanSteal = true

	-- Fix button positions after reset
	task.wait(0.1)
	fixButtonPositions()

	print("✅ [MyMelody] Tycoon fully reset!")
end

-- Monitor owner changes
tycoonOwner.Changed:Connect(function()
	local newOwner = tycoonOwner.Value

	if newOwner == nil and currentOwner ~= nil then
		-- Owner left - reset everything
		print("👋 [MyMelody] Owner left, resetting...")
		resetTycoonPurchases()
		currentOwner = nil
	elseif newOwner ~= nil and currentOwner == nil then
		-- New owner claimed
		currentOwner = newOwner
		print("👤 [MyMelody] New owner:", currentOwner.Name)
		updateButtonColors()
	end
end)

-- PART COLLECTOR
for _, collector in ipairs(essentials:GetChildren()) do
	if collector.Name == "PartCollector" then
		collector.Touched:Connect(function(part)
			if collectedParts[part] then return end
			if not currentOwner then return end

			local cashValue = part:FindFirstChild("Cash")
			if cashValue then
				collectedParts[part] = true
				Money.Value = Money.Value + cashValue.Value
				Debris:AddItem(part, 0.1)

				task.delay(1, function()
					collectedParts[part] = nil
				end)
			end
		end)
	end
end

-- MONEY COLLECTOR
local deb = false
local giver = essentials:WaitForChild("Giver")

giver.Touched:Connect(function(hit)
	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	if player ~= nil then
		if script.Parent.Owner.Value == player then
			if hit.Parent:FindFirstChild("Humanoid") then
				if hit.Parent.Humanoid.Health > 0 then
					if deb == false then
						deb = true
						giver.BrickColor = BrickColor.new("Bright red")
						local Stats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
						if Stats ~= nil then 
							Sound(script.Parent.Essentials, Settings.Sounds.Collect)
							Stats.Value = Stats.Value + Money.Value
							Money.Value = 0
							wait(1)
							giver.BrickColor = BrickColor.new("Sea green")
							deb = false
						end
					end
				end
			end
		elseif Stealing.Stealing and CanSteal then
			CanSteal = false
			delay(Stealing.PlayerProtection, function()
				CanSteal = true
			end)
			if hit.Parent:FindFirstChild("Humanoid") then
				if hit.Parent.Humanoid.Health > 0 then
					local Stats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
					if Stats ~= nil then
						local Difference = math.floor(Money.Value * Stealing.StealPrecent)
						Sound(script.Parent.Essentials, Settings.Sounds.Collect)
						Stats.Value = Stats.Value + Difference
						Money.Value = Money.Value - Difference
					end
				end
			end
		else
			Sound(script.Parent.Essentials, Settings.Sounds.Error)
		end
	end
end)

-- Initialize
task.defer(function()
	storeOriginalButtonStates()
	fixButtonPositions()
	loadAllObjects()

	-- Setup all button dependencies
	for _, button in ipairs(buttons:GetChildren()) do
		setupButtonDependency(button)
	end
	
	-- Initial button color update
	updateButtonColors()
end)

-- Process each button for touch handling
for _, button in ipairs(buttons:GetChildren()) do
	spawn(function()
		local head = button:FindFirstChild("Head")
		if not head then return end

		head.Touched:Connect(function(hit)
			if not head.CanCollide or head.Transparency > 0 then return end
			if not currentOwner then return end

			local player = game.Players:GetPlayerFromCharacter(hit.Parent)
			if player ~= nil and player == currentOwner then
				if hit.Parent:FindFirstChild("Humanoid") then
					if hit.Parent.Humanoid.Health > 0 then
						local PlayerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
						if PlayerStats ~= nil then
							local price = button:FindFirstChild("Price")
							price = price and price.Value or 0
							
							if (button:FindFirstChild('Gamepass')) and (button.Gamepass.Value >= 1) then
								if game:GetService("MarketplaceService"):UserOwnsGamePassAsync(player.UserId, button.Gamepass.Value) then
									Purchase({[1] = price,[2] = button,[3] = PlayerStats})
								else
									game:GetService('MarketplaceService'):PromptGamePassPurchase(player, button.Gamepass.Value)
								end
							elseif (button:FindFirstChild('DevProduct')) and (button.DevProduct.Value >= 1) then
								game:GetService('MarketplaceService'):PromptProductPurchase(player, button.DevProduct.Value)
							elseif PlayerStats.Value >= price then
								Purchase({[1] = price,[2] = button,[3] = PlayerStats})
								Sound(button, Settings.Sounds.Purchase)
							else
								Sound(button, Settings.Sounds.ErrorBuy)
							end
						end
					end
				end
			end
		end)
	end)
end

-- PURCHASE FUNCTION
function Purchase(tbl)
	local cost = tbl[1]
	local item = tbl[2]
	local stats = tbl[3]
	
	stats.Value = stats.Value - cost
	
	local objectName = item:FindFirstChild("Object")
	if objectName and objectName.Value and Objects[objectName.Value] then
		local newObject = Objects[objectName.Value]:Clone()
		newObject.Parent = purchasedObjects
		print("🎁 [MyMelody] Spawned:", objectName.Value)
		
		-- Enable any scripts in the object
		for _, descendant in ipairs(newObject:GetDescendants()) do
			if descendant:IsA("Script") then
				descendant.Disabled = false
			end
		end
	end
	
	-- Handle button animation
	if Settings['ButtonsFadeOut'] then
		item.Head.CanCollide = false
		coroutine.resume(coroutine.create(function()
			for i=1,20 do
				wait(Settings['FadeOutTime']/20)
				item.Head.Transparency = item.Head.Transparency + 0.05
			end
		end))
	else
		item.Head.CanCollide = false
		item.Head.Transparency = 1
	end
	
	updateButtonColors()
end

-- Handle BuyObject folder
script.Parent:WaitForChild('BuyObject').ChildAdded:Connect(function(child)
	local tab = {}
	tab[1] = child.Cost.Value
	tab[2] = child.Button.Value
	tab[3] = child.Stats.Value
	Purchase(tab)
	wait(10)
	child:Destroy()
end)

-- Handle gamepass purchases
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
	if not wasPurchased or player ~= currentOwner then return end

	for _, button in ipairs(buttons:GetChildren()) do
		local gamepass = button:FindFirstChild("Gamepass")
		if gamepass and gamepass.Value == gamePassId then
			local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
			if playerStats then
				Purchase({[1] = button.Price.Value,[2] = button,[3] = playerStats})
			end
			break
		end
	end
end)

-- Handle dev product purchases  
MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player or player ~= currentOwner then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	for _, button in ipairs(buttons:GetChildren()) do
		local devProduct = button:FindFirstChild("DevProduct")
		if devProduct and devProduct.Value == receiptInfo.ProductId then
			local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
			if playerStats then
				Purchase({[1] = button.Price.Value,[2] = button,[3] = playerStats})
				return Enum.ProductPurchaseDecision.PurchaseGranted
			end
		end
	end

	return Enum.ProductPurchaseDecision.NotProcessedYet
end

-- Update colors when money changes
script.Parent.Owner.Changed:Connect(function()
	local owner = script.Parent.Owner.Value
	if owner then
		local playerStats = ServerStorage.PlayerMoney:FindFirstChild(owner.Name)
		if playerStats then
			playerStats.Changed:Connect(function()
				updateButtonColors()
			end)
		end
	end
end)

-- Initial setup
local initialOwner = script.Parent.Owner.Value
if initialOwner then
	currentOwner = initialOwner
	updateButtonColors()
end

print("✅ [MyMelody] Purchase Handler ULTIMATE FIXED loaded!")
print("🔄 [MyMelody] Dependencies check for spawned objects")
print("📋 [MyMelody] Properly resets and re-initializes everything")