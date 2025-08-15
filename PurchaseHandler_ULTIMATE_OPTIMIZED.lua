--[[
	🚀 ULTIMATE OPTIMIZED Purchase Handler
	
	Advanced optimizations:
	- Raycast filtering for accurate ground detection
	- Tiered color update system for performance
	- Configuration table for easy customization
	- Enhanced UX with success sounds
	- Robust error handling
	- Event-driven architecture
--]]

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

-- CONFIGURATION TABLE - Easy to modify!
local CONFIG = {
	-- Colors
	CAN_AFFORD_COLOR = BrickColor.new("Lime green"),
	CANNOT_AFFORD_COLOR = BrickColor.new("Really red"),
	COLLECTOR_READY_COLOR = BrickColor.new("Bright green"),
	COLLECTOR_ACTIVE_COLOR = BrickColor.new("Bright red"),
	DOOR_COLOR = BrickColor.new("White"),
	
	-- Timings
	FADE_IN_TIME = 0.5,
	FADE_OUT_TIME = 0.4,
	COLOR_TRANSITION_TIME = 0.3,
	BUTTON_PRESS_TIME = 0.05,
	HOVER_SCALE = 1.02,
	
	-- Sounds
	SUCCESS_SOUND_ID = "rbxassetid://128506762153961", -- Cha-ching!
	SUCCESS_SOUND_VOLUME = 0.4, -- Not too loud
	ERROR_SOUND_VOLUME = 0.2,
	
	-- Performance
	COLOR_UPDATE_DEBOUNCE = 0.1,
	MAX_CASH_COLLECT_DISTANCE = 100,
	BUTTON_HOVER_DISTANCE = 8,
	
	-- Raycast
	FLOOR_TAG = "TycoonFloor", -- Tag floor parts with this
	RAYCAST_DISTANCE = 50,
	BUTTON_HEIGHT_OFFSET = 0.05,
	
	-- Initialization
	SETUP_DELAY = 1, -- Wait for tycoon to settle
}

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

-- Store original button states AND positions
local originalButtonStates = {}

-- Track dependency connections
local dependencyConnections = {}

-- Track money update connections
local moneyUpdateConnection = nil

-- Declare collectedParts at top level
local collectedParts = {}

-- Price tier system for efficient color updates
local priceTiers = {}
local nextAffordableTier = {}

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

-- Setup raycast params for floor detection
local floorRaycastParams = RaycastParams.new()
floorRaycastParams.FilterType = Enum.RaycastFilterType.Whitelist
floorRaycastParams.FilterDescendantsInstances = {}

-- Tag all floor parts for raycast filtering
local function setupFloorTags()
	-- Tag the main floor/baseplate of the tycoon
	for _, part in ipairs(script.Parent:GetDescendants()) do
		if part:IsA("BasePart") and (part.Name:lower():find("floor") or part.Name:lower():find("base")) then
			CollectionService:AddTag(part, CONFIG.FLOOR_TAG)
			table.insert(floorRaycastParams.FilterDescendantsInstances, part)
		end
	end
	print("🏷️ Tagged", #floorRaycastParams.FilterDescendantsInstances, "floor parts for accurate raycasting")
end

-- Sound management
local function playSound(part, soundId, volume)
	if not soundId or soundId == 0 then return end
	if part:FindFirstChild("Sound") then return end

	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = volume or 0.3
	sound.Parent = part
	sound:Play()

	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

-- Enhanced particle effect
local function createMinimalParticles(position)
	local attachment = Instance.new("Attachment")
	attachment.Position = position
	attachment.Parent = workspace.Terrain

	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Rate = 30
	emitter.Lifetime = NumberRange.new(0.3, 0.5)
	emitter.VelocityInheritance = 0
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.Speed = NumberRange.new(3, 5)
	emitter.SpreadAngle = Vector2.new(15, 15)
	emitter.Color = ColorSequence.new(Color3.new(1, 1, 0.8))
	emitter.Size = NumberSequence.new(0.3)
	emitter.Parent = attachment

	task.wait(0.1)
	emitter.Enabled = false
	Debris:AddItem(attachment, 1)
end

-- Initialize price tier system
local function initializePriceTiers()
	local prices = {}
	
	-- Collect all button prices
	for _, button in ipairs(buttons:GetChildren()) do
		local price = button:FindFirstChild("Price")
		if price and price.Value > 0 then
			table.insert(prices, {button = button, price = price.Value})
		end
	end
	
	-- Sort by price
	table.sort(prices, function(a, b) return a.price < b.price end)
	
	-- Create tiers (groups of 5-10 buttons)
	local tierSize = math.max(5, math.floor(#prices / 10))
	local currentTier = {}
	local tierIndex = 1
	
	for i, data in ipairs(prices) do
		table.insert(currentTier, data)
		
		if #currentTier >= tierSize or i == #prices then
			priceTiers[tierIndex] = {
				minPrice = currentTier[1].price,
				maxPrice = currentTier[#currentTier].price,
				buttons = currentTier
			}
			tierIndex = tierIndex + 1
			currentTier = {}
		end
	end
	
	print("💰 Initialized", #priceTiers, "price tiers for optimized color updates")
end

-- Calculate and store proper ground position for button
local function calculateGroundPosition(button)
	local head = button:FindFirstChild("Head")
	if not head or not head:IsA("BasePart") then return end
	
	-- Use filtered raycast for accurate floor detection
	local raycast = workspace:Raycast(
		head.Position + Vector3.new(0, 10, 0),
		Vector3.new(0, -CONFIG.RAYCAST_DISTANCE, 0),
		floorRaycastParams
	)
	
	if raycast then
		local groundY = raycast.Position.Y
		local buttonHeight = head.Size.Y
		local properY = groundY + (buttonHeight / 2) + CONFIG.BUTTON_HEIGHT_OFFSET
		return properY, raycast.Instance
	end
	
	return head.Position.Y, nil
end

-- Store original button states with delay for tycoon settling
local function storeOriginalButtonStates()
	-- Wait for tycoon to fully settle
	task.wait(CONFIG.SETUP_DELAY)
	
	for _, button in ipairs(buttons:GetChildren()) do
		local head = button:FindFirstChild("Head")
		if head then
			local groundY, floorPart = calculateGroundPosition(button)
			
			-- Store original state including the proper CFrame
			originalButtonStates[button.Name] = {
				Transparency = head.Transparency,
				CanCollide = head.CanCollide,
				BrickColor = head.BrickColor,
				CFrame = CFrame.new(head.Position.X, groundY, head.Position.Z) * (head.CFrame - head.CFrame.Position),
				FloorPart = floorPart -- Store which floor part this button belongs to
			}
			
			-- Actually set the button to ground position
			head.CFrame = originalButtonStates[button.Name].CFrame
		end
	end
	print("📸 Stored original states for", #buttons:GetChildren(), "buttons after settlement delay")
end

-- Smooth color transition
local function smoothColorTransition(head, targetColor)
	local tween = TweenService:Create(
		head,
		TweenInfo.new(CONFIG.COLOR_TRANSITION_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Color = targetColor.Color}
	)
	
	tween:Play()
	tween.Completed:Connect(function()
		head.BrickColor = targetColor
	end)
end

-- Efficient tiered color update system
local function updateButtonColorsEfficient(playerMoney)
	if not currentOwner or not playerMoney then return end
	
	local moneyValue = playerMoney.Value
	
	-- Find which tier we should check
	for tierIndex, tier in ipairs(priceTiers) do
		-- Skip tiers that are way above player's money
		if tier.minPrice > moneyValue * 2 then
			break
		end
		
		-- Check buttons in this tier
		for _, data in ipairs(tier.buttons) do
			local button = data.button
			local head = button:FindFirstChild("Head")
			
			if head and head.Transparency == 0 and head.CanCollide then
				local targetColor = moneyValue >= data.price and CONFIG.CAN_AFFORD_COLOR or CONFIG.CANNOT_AFFORD_COLOR
				
				if head.BrickColor ~= targetColor then
					smoothColorTransition(head, targetColor)
				end
			end
		end
	end
end

-- Enhanced hover effect
local function addSimpleHoverEffect(button)
	local head = button:FindFirstChild("Head")
	if not head then return end

	-- Remove existing hover detector if any
	local existingDetector = button:FindFirstChild("HoverDetector")
	if existingDetector then
		existingDetector:Destroy()
	end

	local originalSize = head.Size
	local isHovering = false

	local detector = Instance.new("Part")
	detector.Name = "HoverDetector"
	detector.Size = head.Size * 1.3
	detector.Transparency = 1
	detector.CanCollide = false
	detector.CFrame = head.CFrame
	detector.Parent = button

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = head
	weld.Part1 = detector
	weld.Parent = detector

	detector.Touched:Connect(function(hit)
		local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		if humanoid and not isHovering then
			isHovering = true

			TweenService:Create(head,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Size = originalSize * CONFIG.HOVER_SCALE}
			):Play()

			task.spawn(function()
				while isHovering do
					task.wait(0.1)
					local stillNear = false
					for _, player in pairs(Players:GetPlayers()) do
						if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
							local distance = (player.Character.HumanoidRootPart.Position - head.Position).Magnitude
							if distance < CONFIG.BUTTON_HOVER_DISTANCE then
								stillNear = true
								break
							end
						end
					end

					if not stillNear then
						isHovering = false
						TweenService:Create(head,
							TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{Size = originalSize}
						):Play()
					end
				end
			end)
		end
	end)
end

-- Load all objects with error handling
local function loadAllObjects()
	local loadedCount = 0
	local criticalErrors = {}
	
	for _, button in ipairs(buttons:GetChildren()) do
		local objectName = button:FindFirstChild("Object")
		objectName = objectName and objectName.Value
		
		if objectName then
			local purchaseObject = purchases:FindFirstChild(objectName)
			if purchaseObject then
				Objects[objectName] = purchaseObject:Clone()
				purchaseObject:Destroy()
				loadedCount = loadedCount + 1
			else
				warn("⚠️ Object missing for button:", button.Name, "- Object:", objectName)
				
				-- Check if this is a critical object (has dependencies)
				local isCritical = false
				for _, otherButton in ipairs(buttons:GetChildren()) do
					local dep = otherButton:FindFirstChild("Dependency")
					if dep and dep.Value == objectName then
						isCritical = true
						table.insert(criticalErrors, {
							button = button.Name,
							object = objectName,
							dependent = otherButton.Name
						})
					end
				end
				
				if isCritical then
					-- Disable the button if its object is missing
					local head = button:FindFirstChild("Head")
					if head then
						head.CanCollide = false
						head.Transparency = 0.8
						head.BrickColor = BrickColor.new("Really black")
					end
				end
			end
		end
	end
	
	print("📦 Loaded", loadedCount, "objects successfully")
	
	if #criticalErrors > 0 then
		warn("❌ CRITICAL: Missing objects that other buttons depend on:")
		for _, error in ipairs(criticalErrors) do
			warn("  -", error.object, "needed by", error.dependent)
		end
	end
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
			-- Use stored ground position
			if originalButtonStates[button.Name] then
				head.CFrame = originalButtonStates[button.Name].CFrame
			end
			
			-- Show button with fade
			if Settings.ButtonsFadeIn then
				head.Transparency = 0.7
				TweenService:Create(head,
					TweenInfo.new(CONFIG.FADE_IN_TIME, Enum.EasingStyle.Quad),
					{Transparency = 0}
				):Play()
			else
				head.Transparency = 0
			end
			
			head.CanCollide = true
			head.BrickColor = CONFIG.CANNOT_AFFORD_COLOR
			
			-- Delay color update to prevent flash
			task.defer(function()
				if currentOwner then
					local stats = ServerStorage.PlayerMoney:FindFirstChild(currentOwner.Name)
					if stats then
						updateButtonColorsEfficient(stats)
					end
				end
			end)
			
			addSimpleHoverEffect(button)
			return
		end

		-- Otherwise, wait for dependency
		local connection = purchasedObjects.ChildAdded:Connect(function(child)
			if child.Name == dependency.Value then
				print("✅ Dependency met for", button.Name, "- Required object spawned:", dependency.Value)

				-- Use stored ground position
				if originalButtonStates[button.Name] then
					head.CFrame = originalButtonStates[button.Name].CFrame
				end

				-- Show button with fade
				if Settings.ButtonsFadeIn then
					head.Transparency = 0.7
					TweenService:Create(head,
						TweenInfo.new(CONFIG.FADE_IN_TIME, Enum.EasingStyle.Quad),
						{Transparency = 0}
					):Play()
				else
					head.Transparency = 0
				end
				
				head.CanCollide = true
				head.BrickColor = CONFIG.CANNOT_AFFORD_COLOR

				-- Delay color update to prevent flash
				task.defer(function()
					if currentOwner then
						local stats = ServerStorage.PlayerMoney:FindFirstChild(currentOwner.Name)
						if stats then
							updateButtonColorsEfficient(stats)
						end
					end
				end)

				addSimpleHoverEffect(button)
			end
		end)

		-- Store connection for cleanup
		if not dependencyConnections[button] then
			dependencyConnections[button] = {}
		end
		table.insert(dependencyConnections[button], connection)

		print("📎 Set up dependency for", button.Name, "waiting for", dependency.Value)
	else
		-- No dependency - button is immediately available
		head.BrickColor = CONFIG.CANNOT_AFFORD_COLOR
		addSimpleHoverEffect(button)
		
		-- Update color after a frame
		task.defer(function()
			if currentOwner then
				local stats = ServerStorage.PlayerMoney:FindFirstChild(currentOwner.Name)
				if stats then
					updateButtonColorsEfficient(stats)
				end
			end
		end)
	end
end

-- COMPLETE RESET FUNCTION
local function resetTycoonPurchases()
	print("🔄 RESETTING PURCHASE HANDLER...")

	-- Clear purchased items tracking
	purchasedItems = {}

	-- Destroy all existing cash parts that might be falling
	local destroyedParts = 0
	for _, descendant in pairs(workspace:GetDescendants()) do
		if descendant:FindFirstChild("Cash") then
			if descendant:IsA("BasePart") then
				local distance = (descendant.Position - script.Parent:GetPivot().Position).Magnitude
				if distance < CONFIG.MAX_CASH_COLLECT_DISTANCE then
					descendant:Destroy()
					destroyedParts = destroyedParts + 1
				end
			end
		end
	end
	print("  ✓ Destroyed", destroyedParts, "cash parts")

	-- Reset money to 0
	Money.Value = 0

	-- Destroy all purchased objects
	local objectCount = #purchasedObjects:GetChildren()
	for _, obj in pairs(purchasedObjects:GetChildren()) do
		obj:Destroy()
	end
	print("  ✓ Destroyed", objectCount, "purchased objects")

	-- Clear the collectedParts table
	collectedParts = {}

	-- Disconnect all dependency connections
	for button, connections in pairs(dependencyConnections) do
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end
	end
	dependencyConnections = {}
	
	-- Disconnect money update connection
	if moneyUpdateConnection then
		moneyUpdateConnection:Disconnect()
		moneyUpdateConnection = nil
	end

	-- Reset all buttons to original state
	for _, button in ipairs(buttons:GetChildren()) do
		local head = button:FindFirstChild("Head")
		if head and originalButtonStates[button.Name] then
			local originalState = originalButtonStates[button.Name]

			-- Remove hover detector if exists
			local hoverDetector = button:FindFirstChild("HoverDetector")
			if hoverDetector then
				hoverDetector:Destroy()
			end

			-- Restore exact original position
			head.CFrame = originalState.CFrame

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
				head.BrickColor = CONFIG.CANNOT_AFFORD_COLOR
				
				-- Re-add hover effect for base buttons
				addSimpleHoverEffect(button)
			end
		end
	end

	-- Re-setup dependency system for all buttons
	for _, button in ipairs(buttons:GetChildren()) do
		setupButtonDependency(button)
	end

	-- Reset money collector color
	local giver = essentials:FindFirstChild("Giver")
	if giver then
		giver.BrickColor = CONFIG.COLLECTOR_READY_COLOR
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

	print("✅ Purchase handler fully reset!")
end

-- Monitor owner changes
tycoonOwner.Changed:Connect(function()
	local newOwner = tycoonOwner.Value

	if newOwner == nil and currentOwner ~= nil then
		-- Owner left - reset everything
		print("👋 Owner left, resetting purchases...")
		resetTycoonPurchases()
		currentOwner = nil
	elseif newOwner ~= nil and currentOwner == nil then
		-- New owner claimed
		currentOwner = newOwner
		print("👤 New owner:", currentOwner.Name)

		-- Setup money change listener
		local playerStats = ServerStorage.PlayerMoney:FindFirstChild(newOwner.Name)
		if playerStats then
			-- Initial color update
			updateButtonColorsEfficient(playerStats)
			
			-- Listen for money changes
			if moneyUpdateConnection then
				moneyUpdateConnection:Disconnect()
			end
			
			moneyUpdateConnection = playerStats.Changed:Connect(function()
				updateButtonColorsEfficient(playerStats)
			end)
		end
	end
end)

-- PART COLLECTOR
for _, collector in ipairs(essentials:GetChildren()) do
	if collector.Name == "PartCollector" then
		collector.CanCollide = false

		collector.Touched:Connect(function(part)
			if collectedParts[part] then return end
			if not currentOwner then return end

			local cashValue = part:FindFirstChild("Cash")
			if cashValue then
				collectedParts[part] = true

				Money.Value = Money.Value + cashValue.Value

				part.Anchored = true
				part.CanCollide = false
				part.CanTouch = false
				part.CanQuery = false

				if part:IsA("BasePart") then
					TweenService:Create(part,
						TweenInfo.new(0.3, Enum.EasingStyle.Linear),
						{Transparency = 1}
					):Play()

					for _, child in ipairs(part:GetDescendants()) do
						if child:IsA("Decal") or child:IsA("Texture") then
							TweenService:Create(child, TweenInfo.new(0.3), {Transparency = 1}):Play()
						elseif child:IsA("ParticleEmitter") then
							child.Enabled = false
						elseif child:IsA("PointLight") or child:IsA("SpotLight") then
							TweenService:Create(child, TweenInfo.new(0.3), {Brightness = 0}):Play()
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

		local originalColor = giver.BrickColor
		giver.BrickColor = CONFIG.COLLECTOR_ACTIVE_COLOR

		local originalSize = giver.Size
		TweenService:Create(giver,
			TweenInfo.new(0.1, Enum.EasingStyle.Quad),
			{Size = originalSize * 1.05}
		):Play()

		local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
		if playerStats and Money.Value > 0 then
			local moneyCollected = Money.Value
			playerStats.Value = playerStats.Value + moneyCollected
			Money.Value = 0
			
			-- Play collection sound
			playSound(giver, Settings.Sounds.Collect, 0.4)

			local billboardGui = Instance.new("BillboardGui")
			billboardGui.Size = UDim2.new(0, 80, 0, 40)
			billboardGui.StudsOffset = Vector3.new(0, 3, 0)
			billboardGui.Parent = giver

			local textLabel = Instance.new("TextLabel")
			textLabel.Size = UDim2.new(1, 0, 1, 0)
			textLabel.BackgroundTransparency = 1
			textLabel.Text = "+$" .. tostring(moneyCollected)
			textLabel.TextScaled = true
			textLabel.TextColor3 = Color3.new(0, 1, 0)
			textLabel.Font = Enum.Font.SourceSans
			textLabel.Parent = billboardGui

			TweenService:Create(billboardGui,
				TweenInfo.new(0.8, Enum.EasingStyle.Linear),
				{StudsOffset = Vector3.new(0, 6, 0)}
			):Play()

			TweenService:Create(textLabel,
				TweenInfo.new(0.8, Enum.EasingStyle.Linear),
				{TextTransparency = 1}
			):Play()

			Debris:AddItem(billboardGui, 0.8)
		end

		task.wait(0.1)
		TweenService:Create(giver,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad),
			{Size = originalSize}
		):Play()

		task.wait(0.4)
		giver.BrickColor = originalColor
		collectorDebounce[player] = nil

	elseif Stealing.Stealing and CanSteal then
		CanSteal = false
		task.delay(Stealing.PlayerProtection, function()
			CanSteal = true
		end)

		local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
		if playerStats then
			local stealAmount = math.floor(Money.Value * Stealing.StealPrecent)
			if stealAmount > 0 then
				playerStats.Value = playerStats.Value + stealAmount
				Money.Value = Money.Value - stealAmount
			end
		end
	else
		playSound(essentials, Settings.Sounds.ErrorBuy, CONFIG.ERROR_SOUND_VOLUME)
	end
end)

-- Initialize
task.defer(function()
	setupFloorTags()
	storeOriginalButtonStates()
	loadAllObjects()
	initializePriceTiers()

	-- Setup all button dependencies
	for _, button in ipairs(buttons:GetChildren()) do
		setupButtonDependency(button)
	end
end)

-- Process each button for touch handling
for _, button in ipairs(buttons:GetChildren()) do
	task.spawn(function()
		local head = button:FindFirstChild("Head")
		if not head then return end

		-- Handle touches
		local purchaseDebounce = {}
		head.Touched:Connect(function(hit)
			if not head.CanCollide or head.Transparency > 0 then return end
			if not currentOwner then return end

			local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
			if not humanoid or humanoid.Health <= 0 then return end

			local player = Players:GetPlayerFromCharacter(hit.Parent)
			if not player or player ~= currentOwner then return end

			if purchaseDebounce[player] then return end
			purchaseDebounce[player] = true

			task.defer(function()
				task.wait(0.5)
				purchaseDebounce[player] = nil
			end)

			local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
			if not playerStats then return end

			-- Get stored original position
			local originalCFrame = originalButtonStates[button.Name] and originalButtonStates[button.Name].CFrame or head.CFrame

			-- Button press animation
			TweenService:Create(head,
				TweenInfo.new(CONFIG.BUTTON_PRESS_TIME, Enum.EasingStyle.Linear),
				{CFrame = originalCFrame * CFrame.new(0, -0.05, 0)}
			):Play()

			task.wait(CONFIG.BUTTON_PRESS_TIME)
			TweenService:Create(head,
				TweenInfo.new(CONFIG.BUTTON_PRESS_TIME, Enum.EasingStyle.Linear),
				{CFrame = originalCFrame}
			):Play()

			-- Handle gamepass
			local gamepass = button:FindFirstChild("Gamepass")
			if gamepass and gamepass.Value >= 1 then
				local hasPass = false
				local success, result = pcall(function()
					return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepass.Value)
				end)

				if success then hasPass = result end

				if hasPass then
					processPurchase(button, playerStats)
				else
					MarketplaceService:PromptGamePassPurchase(player, gamepass.Value)
				end
				return
			end

			-- Handle dev product
			local devProduct = button:FindFirstChild("DevProduct")
			if devProduct and devProduct.Value >= 1 then
				MarketplaceService:PromptProductPurchase(player, devProduct.Value)
				return
			end

			-- Regular purchase
			local price = button:FindFirstChild("Price")
			price = price and price.Value or 0

			if playerStats.Value >= price then
				processPurchase(button, playerStats)
			else
				playSound(head, Settings.Sounds.ErrorBuy, CONFIG.ERROR_SOUND_VOLUME)

				-- Flash red effect
				local originalColor = head.BrickColor
				head.BrickColor = CONFIG.CANNOT_AFFORD_COLOR
				task.wait(0.15)
				head.BrickColor = originalColor
			end
		end)
	end)
end

-- PURCHASE FUNCTION
function processPurchase(button, playerStats)
	if not button or not playerStats then
		warn("processPurchase called with nil arguments")
		return
	end

	local price = button:FindFirstChild("Price")
	price = price and price.Value or 0

	local objectName = button:FindFirstChild("Object")
	objectName = objectName and objectName.Value

	playerStats.Value = playerStats.Value - price

	purchasedItems[button.Name] = true
	if objectName then
		purchasedItems[objectName] = true
	end

	-- Play success sound!
	local head = button:FindFirstChild("Head")
	if head then
		playSound(head, CONFIG.SUCCESS_SOUND_ID, CONFIG.SUCCESS_SOUND_VOLUME)
	end

	if objectName and Objects[objectName] then
		local newObject = Objects[objectName]:Clone()
		newObject.Parent = purchasedObjects

		print("🎁 Spawned: " .. objectName .. " (from button: " .. button.Name .. ")")

		if objectName:find("Door") or objectName:find("door") then
			for _, part in ipairs(newObject:GetDescendants()) do
				if part:IsA("BasePart") then
					part.BrickColor = CONFIG.DOOR_COLOR
					if part.Material == Enum.Material.Neon then
						part.Material = Enum.Material.SmoothPlastic
					end
				end
			end
		end

		if newObject:IsA("Model") and newObject.PrimaryPart then
			for _, part in ipairs(newObject:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Size = part.Size * 0.95
				end
			end

			for _, part in ipairs(newObject:GetDescendants()) do
				if part:IsA("BasePart") then
					TweenService:Create(part,
						TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{Size = part.Size / 0.95}
					):Play()
				end
			end

			createMinimalParticles(newObject.PrimaryPart.Position)
		end

		for _, descendant in ipairs(newObject:GetDescendants()) do
			if descendant:IsA("Script") then
				descendant.Disabled = false
			end
		end
	end

	if head then
		-- Store the original position
		local storedCFrame = originalButtonStates[button.Name] and originalButtonStates[button.Name].CFrame or head.CFrame
		
		head.CanCollide = false

		-- Fade out animation
		TweenService:Create(head,
			TweenInfo.new(CONFIG.FADE_OUT_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				CFrame = head.CFrame + Vector3.new(0, 3, 0),
				Transparency = 1
			}
		):Play()

		createMinimalParticles(head.Position)
		
		-- After fade out, snap back to original position
		task.wait(CONFIG.FADE_OUT_TIME)
		head.CFrame = storedCFrame
	end

	-- Update colors immediately
	updateButtonColorsEfficient(playerStats)
end

-- Handle BuyObject folder
local buyObject = script.Parent:WaitForChild("BuyObject")
buyObject.ChildAdded:Connect(function(child)
	task.wait(0.1)

	local cost = child:FindFirstChild("Cost")
	local button = child:FindFirstChild("Button")
	local stats = child:FindFirstChild("Stats")

	if cost and button and stats and button.Value and stats.Value then
		processPurchase(button.Value, stats.Value)
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
				processPurchase(button, playerStats)
			end
			break
		end
	end
end)

-- Handle dev product purchases
MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	for _, button in ipairs(buttons:GetChildren()) do
		local devProduct = button:FindFirstChild("DevProduct")
		if devProduct and devProduct.Value == receiptInfo.ProductId then
			local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
			if playerStats then
				processPurchase(button, playerStats)
				return Enum.ProductPurchaseDecision.PurchaseGranted
			end
		end
	end

	return Enum.ProductPurchaseDecision.NotProcessedYet
end

-- Initial setup
local initialOwner = script.Parent.Owner.Value
if initialOwner then
	currentOwner = initialOwner
	local initialStats = ServerStorage.PlayerMoney:FindFirstChild(initialOwner.Name)
	if initialStats then
		updateButtonColorsEfficient(initialStats)
		
		-- Setup money change listener
		if moneyUpdateConnection then
			moneyUpdateConnection:Disconnect()
		end
		
		moneyUpdateConnection = initialStats.Changed:Connect(function()
			updateButtonColorsEfficient(initialStats)
		end)
	end
end

print("🚀 ULTIMATE OPTIMIZED Purchase Handler loaded!")
print("🎯 Advanced raycast filtering for perfect button positioning")
print("💰 Tiered color system for maximum performance")
print("🎵 Success sounds for satisfying purchases")
print("⚙️ Configuration table for easy customization")

-- Debug: Print configuration
print("\n⚙️ Configuration:")
print("  - Floor Tag:", CONFIG.FLOOR_TAG)
print("  - Setup Delay:", CONFIG.SETUP_DELAY, "seconds")
print("  - Success Sound:", CONFIG.SUCCESS_SOUND_ID)
print("  - Color Transition:", CONFIG.COLOR_TRANSITION_TIME, "seconds")