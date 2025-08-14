--[[
	✨ Clean Purchase Handler - RESET FIXED Version
	Properly handles tycoon resets and dependency system
	
	FIXES:
	- Monitors owner changes and resets everything
	- Properly tracks purchased items per player
	- Resets buttons to original state
	- Clears all purchase tracking on owner change
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

-- Simple sound function
local function playSound(part, soundId, volume)
	if not soundId or soundId == 0 then return end
	if soundId == 131961136 or soundId == 131886985 then return end
	if part:FindFirstChild("Sound") then return end

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. tostring(soundId)
	sound.Volume = volume or 0.3
	sound.Parent = part
	sound:Play()

	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

-- Minimal particle effect
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

-- Store original button states
local function storeOriginalButtonStates()
	for _, button in ipairs(buttons:GetChildren()) do
		local head = button:FindFirstChild("Head")
		if head then
			originalButtonStates[button.Name] = {
				Transparency = head.Transparency,
				CanCollide = head.CanCollide,
				BrickColor = head.BrickColor,
				CFrame = head.CFrame
			}
		end
	end
	print("📸 Stored original states for", #buttons:GetChildren(), "buttons")
end

-- COMPLETE RESET FUNCTION
local function resetTycoonPurchases()
	print("🔄 RESETTING PURCHASE HANDLER...")
	
	-- Clear purchased items tracking
	purchasedItems = {}
	
	-- Reset money collector
	Money.Value = 0
	
	-- Destroy all purchased objects
	for _, obj in pairs(purchasedObjects:GetChildren()) do
		obj:Destroy()
	end
	
	-- Reset all buttons to original state
	for _, button in pairs(buttons:GetChildren()) do
		local head = button:FindFirstChild("Head")
		if head and originalButtonStates[button.Name] then
			local originalState = originalButtonStates[button.Name]
			
			-- Remove hover detector if exists
			local hoverDetector = button:FindFirstChild("HoverDetector")
			if hoverDetector then
				hoverDetector:Destroy()
			end
			
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
				head.CFrame = originalState.CFrame
			end
		end
	end
	
	-- Reset money collector color
	local giver = essentials:FindFirstChild("Giver")
	if giver then
		giver.BrickColor = BrickColor.new("Bright green")
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
		
		-- Update button colors for new owner
		local playerStats = ServerStorage.PlayerMoney:FindFirstChild(newOwner.Name)
		if playerStats then
			updateButtonColors(buttons, playerStats)
		end
	end
end)

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

				local currentY = head.Position.Y
				if math.abs(currentY - properY) > 0.5 then
					local targetPosition = Vector3.new(head.Position.X, properY, head.Position.Z)

					if math.abs(currentY - properY) > 5 then
						head.CFrame = CFrame.new(targetPosition) * (head.CFrame - head.CFrame.Position)
						fixedCount = fixedCount + 1
					else
						TweenService:Create(head,
							TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{CFrame = CFrame.new(targetPosition) * (head.CFrame - head.CFrame.Position)}
						):Play()
						fixedCount = fixedCount + 1
					end
				end
			end
		end
	end

	if fixedCount > 0 then
		print("✅ Fixed", fixedCount, "button positions")
	end
end

-- Update button colors based on money
function updateButtonColors(buttonFolder, playerMoney)
	if not currentOwner then return end
	
	for _, button in ipairs(buttonFolder:GetChildren()) do
		local head = button:FindFirstChild("Head")
		if not head or head.Transparency > 0 then continue end

		local price = button:FindFirstChild("Price")
		price = price and price.Value or 0

		if head.CanCollide and price > 0 and playerMoney then
			if playerMoney.Value >= price then
				head.BrickColor = BrickColor.new("Lime green")
			else
				head.BrickColor = BrickColor.new("Really red")
			end
		end
	end
end

-- Simple hover effect
local function addSimpleHoverEffect(button)
	local head = button:FindFirstChild("Head")
	if not head then return end

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
				{Size = originalSize * 1.02}
			):Play()

			task.spawn(function()
				while isHovering do
					task.wait(0.1)
					local stillNear = false
					for _, player in pairs(Players:GetPlayers()) do
						if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
							local distance = (player.Character.HumanoidRootPart.Position - head.Position).Magnitude
							if distance < 8 then
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

-- PART COLLECTOR
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
		giver.BrickColor = BrickColor.new("Bright red")

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
		playSound(essentials, Settings.Sounds.ErrorBuy, 0.2)
	end
end)

-- Initialize
task.defer(function()
	storeOriginalButtonStates()
	fixButtonPositions()
	
	-- Load all objects
	for _, button in ipairs(buttons:GetChildren()) do
		local objectName = button:FindFirstChild("Object")
		objectName = objectName and objectName.Value
		if objectName then
			local purchaseObject = purchases:FindFirstChild(objectName)
			if purchaseObject then
				Objects[objectName] = purchaseObject:Clone()
				purchaseObject:Destroy()
			end
		end
	end
end)

-- Process each button
for _, button in ipairs(buttons:GetChildren()) do
	task.spawn(function()
		local head = button:FindFirstChild("Head")
		if not head then return end

		-- DEPENDENCY SYSTEM
		local dependency = button:FindFirstChild("Dependency")
		if dependency and dependency.Value and dependency.Value ~= "" then
			head.CanCollide = false
			head.Transparency = 1

			task.spawn(function()
				local dependencyMet = false

				if purchasedObjects:FindFirstChild(dependency.Value) then
					dependencyMet = true
				else
					for _, obj in ipairs(purchasedObjects:GetChildren()) do
						local objButton = buttons:FindFirstChild(dependency.Value)
						if objButton then
							local objName = objButton:FindFirstChild("Object")
							if objName and objName.Value and obj.Name == objName.Value then
								dependencyMet = true
								break
							end
						end
					end
				end

				if not dependencyMet then
					local connection
					connection = purchasedObjects.ChildAdded:Connect(function(child)
						local depButton = buttons:FindFirstChild(dependency.Value)
						if depButton then
							local depObjName = depButton:FindFirstChild("Object")
							if depObjName and depObjName.Value == child.Name then
								dependencyMet = true
								connection:Disconnect()
							end
						elseif child.Name == dependency.Value then
							dependencyMet = true
							connection:Disconnect()
						end
					end)

					local waited = 0
					while not dependencyMet and waited < 300 do
						task.wait(0.5)
						waited = waited + 0.5
					end

					if connection then
						connection:Disconnect()
					end
				end

				if dependencyMet then
					if Settings.ButtonsFadeIn then
						head.Transparency = 0.7
						TweenService:Create(head,
							TweenInfo.new(Settings.FadeInTime or 0.5, Enum.EasingStyle.Quad),
							{Transparency = 0}
						):Play()
						task.wait(Settings.FadeInTime or 0.5)
					else
						head.Transparency = 0
					end
					head.CanCollide = true

					local owner = script.Parent.Owner.Value
					if owner then
						local stats = ServerStorage.PlayerMoney:FindFirstChild(owner.Name)
						updateButtonColors(buttons, stats)
					end

					addSimpleHoverEffect(button)
				end
			end)
		else
			addSimpleHoverEffect(button)
		end

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

			local originalCFrame = head.CFrame
			TweenService:Create(head,
				TweenInfo.new(0.05, Enum.EasingStyle.Linear),
				{CFrame = originalCFrame * CFrame.new(0, -0.05, 0)}
			):Play()

			task.wait(0.05)
			TweenService:Create(head,
				TweenInfo.new(0.05, Enum.EasingStyle.Linear),
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
				playSound(head, Settings.Sounds.ErrorBuy, 0.2)

				local originalColor = head.BrickColor
				head.BrickColor = BrickColor.new("Really red")
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

	if objectName and Objects[objectName] then
		local newObject = Objects[objectName]:Clone()
		newObject.Parent = purchasedObjects

		print("🎁 Spawned: " .. objectName .. " (from button: " .. button.Name .. ")")

		if objectName:find("Door") or objectName:find("door") then
			for _, part in ipairs(newObject:GetDescendants()) do
				if part:IsA("BasePart") then
					part.BrickColor = BrickColor.new("White")
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

	local head = button:FindFirstChild("Head")
	if head then
		head.CanCollide = false

		TweenService:Create(head,
			TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				CFrame = head.CFrame + Vector3.new(0, 3, 0),
				Transparency = 1
			}
		):Play()

		createMinimalParticles(head.Position)
	end

	updateButtonColors(buttons, playerStats)
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

-- Update button colors when money changes
script.Parent.Owner.Changed:Connect(function()
	local owner = script.Parent.Owner.Value
	if owner then
		local playerStats = ServerStorage.PlayerMoney:FindFirstChild(owner.Name)
		if playerStats then
			playerStats.Changed:Connect(function()
				updateButtonColors(buttons, playerStats)
			end)
		end
	end
end)

print("✅ Purchase Handler RESET FIXED loaded!")
print("🔄 Will properly reset when owner changes")
print("📋 Monitors tycoon ownership and clears everything")