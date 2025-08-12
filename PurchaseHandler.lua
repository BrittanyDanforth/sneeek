--[[
	✨ Clean Purchase Handler (2025 Standards) - BALANCED Version
	Handles tycoon purchases with tasteful, minimal effects
	
	CHANGES:
	- Removed green light from money collector
	- No hover lights on buttons
	- Reduced particle effects by 70%
	- Simpler animations
	- Fixed sound errors
	- White doors for Cinnamoroll theme
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

-- 🎯 PROGRESSION DATA
local PROGRESSION_DATA = {
	["Begin Working! - [$0]"] = {
		unlocks = {"Buy Dropper - [$70]"}
	},
	["Buy Dropper - [$70]"] = {
		requires = {"Begin Working! - [$0]"},
		unlocks = {"Buy MEGA Dropper - [$300]"}
	},
	["Buy MEGA Dropper - [$300]"] = {
		requires = {"Buy Dropper - [$70]"},
		unlocks = {"Buy Super Dropper - [$1,000]", "Buy Walls - [$100]"}
	},
	["Buy Super Dropper - [$1,000]"] = {
		requires = {"Buy MEGA Dropper - [$300]"},
		unlocks = {"Buy POWER CORE Dropper - [$2,000]"}
	},
	["Buy POWER CORE Dropper - [$2,000]"] = {
		requires = {"Buy Super Dropper - [$1,000]"},
		unlocks = {"Buy CORE Dropper - [$5,000]"}
	},
	["Buy CORE Dropper - [$5,000]"] = {
		requires = {"Buy POWER CORE Dropper - [$2,000]"},
		unlocks = {"Buy a Mega Dropper - [$7,000]"}
	},
	["Buy a Mega Dropper - [$7,000]"] = {
		requires = {"Buy CORE Dropper - [$5,000]"},
		unlocks = {"Buy Conveyer - [$8,000]"}
	},
	["Buy Conveyer - [$8,000]"] = {
		requires = {"Buy a Mega Dropper - [$7,000]"},
		unlocks = {"Buy a Omega Dropper - [$9,000]"}
	},
	["Buy a Omega Dropper - [$9,000]"] = {
		requires = {"Buy Conveyer - [$8,000]"},
		unlocks = {"Buy Dropper - [$10,000]"}
	},
	["Buy Dropper - [$10,000]"] = {
		requires = {"Buy a Omega Dropper - [$9,000]"},
		unlocks = {"Buy Dropper - [$12,000]"}
	},
	["Buy Dropper - [$12,000]"] = {
		requires = {"Buy Dropper - [$10,000]"},
		unlocks = {"Buy a Omega Dropper - [$15,000]"}
	},
	["Buy a Omega Dropper - [$15,000]"] = {
		requires = {"Buy Dropper - [$12,000]"},
		unlocks = {"Buy Dropper - [$20,000]"}
	},
	["Buy Dropper - [$20,000]"] = {
		requires = {"Buy a Omega Dropper - [$15,000]"},
		unlocks = {"Buy Extra - [$35,000]"}
	},
	["Buy Walls - [$100]"] = {
		requires = {"Buy MEGA Dropper - [$300]"},
		unlocks = {"Upgrade Walls - [$350]"}
	},
	["Upgrade Walls - [$350]"] = {
		requires = {"Buy Walls - [$100]"},
		unlocks = {"Upgrade Walls - [$700]"}
	},
	["Upgrade Walls - [$700]"] = {
		requires = {"Upgrade Walls - [$350]"},
		unlocks = {"Upgrade Walls - [$1,000]", "Buy Floor - [$1,500]", "Buy an OwnerDoor - [$1,500]"}
	}
}

-- Track purchased items
local purchasedItems = {}

-- Set spawn colors
local essentials = script.Parent:WaitForChild("Essentials")
local spawn = essentials:WaitForChild("Spawn")
spawn.TeamColor = TeamColor
spawn.BrickColor = TeamColor

-- Simple sound function (no broken IDs)
local function playSound(part, soundId, volume)
	if not soundId or soundId == 0 then return end
	
	-- Skip broken sound IDs
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

-- Minimal particle effect (reduced by 70%)
local function createMinimalParticles(position)
	local attachment = Instance.new("Attachment")
	attachment.Position = position
	attachment.Parent = workspace.Terrain

	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Rate = 30 -- Reduced from 100
	emitter.Lifetime = NumberRange.new(0.3, 0.5) -- Shorter lifetime
	emitter.VelocityInheritance = 0
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.Speed = NumberRange.new(3, 5) -- Slower
	emitter.SpreadAngle = Vector2.new(15, 15) -- Tighter spread
	emitter.Color = ColorSequence.new(Color3.new(1, 1, 0.8)) -- Softer color
	emitter.Size = NumberSequence.new(0.3) -- Smaller
	emitter.Parent = attachment

	-- Stop very quickly
	task.wait(0.1)
	emitter.Enabled = false
	Debris:AddItem(attachment, 1)
end

-- Fix button positions
local function fixButtonPositions()
	local buttons = script.Parent:WaitForChild("Buttons")
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

task.defer(fixButtonPositions)

-- Update button visibility based on progression
local function updateButtonVisibility(buttons, playerMoney)
	for _, button in ipairs(buttons:GetChildren()) do
		local head = button:FindFirstChild("Head")
		if not head then continue end

		local buttonName = button.Name
		local price = button:FindFirstChild("Price")
		price = price and price.Value or 0

		local shouldShow = false

		if buttonName == "Begin Working! - [$0]" and not purchasedItems[buttonName] then
			shouldShow = true
		elseif purchasedItems[buttonName] then
			shouldShow = false
		else
			local progressionInfo = PROGRESSION_DATA[buttonName]
			if progressionInfo and progressionInfo.requires then
				local requirementsMet = true
				for _, req in ipairs(progressionInfo.requires) do
					if not purchasedItems[req] then
						requirementsMet = false
						break
					end
				end
				shouldShow = requirementsMet
			elseif not progressionInfo then
				for itemName, itemData in pairs(PROGRESSION_DATA) do
					if purchasedItems[itemName] and itemData.unlocks then
						for _, unlock in ipairs(itemData.unlocks) do
							if unlock == buttonName then
								shouldShow = true
								break
							end
						end
					end
				end
			end
		end

		if shouldShow then
			head.Transparency = 0
			head.CanCollide = true

			if price > 0 and playerMoney then
				if playerMoney.Value >= price then
					head.BrickColor = BrickColor.new("Lime green")
				else
					head.BrickColor = BrickColor.new("Really red")
				end
			end
		else
			head.Transparency = 1
			head.CanCollide = false
		end
	end
end

-- Simple hover effect (NO LIGHTS)
local function addSimpleHoverEffect(button)
	local head = button:FindFirstChild("Head")
	if not head then return end

	local originalSize = head.Size
	local isHovering = false

	-- Invisible hover detector
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
			
			-- Very subtle size increase
			TweenService:Create(head,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Size = originalSize * 1.02} -- Only 2% bigger
			):Play()

			-- Check when player leaves
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

-- MINIMAL PART COLLECTOR
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

				-- Simple fade without scaling
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

-- MONEY COLLECTOR - NO GREEN LIGHT, MINIMAL EFFECTS
local collectorDebounce = {}
local giver = essentials:WaitForChild("Giver")

-- NO LIGHT ON COLLECTOR - removed completely

giver.Touched:Connect(function(hit)
	local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player then return end

	if script.Parent.Owner.Value == player then
		if collectorDebounce[player] then return end
		collectorDebounce[player] = true

		-- Simple color change only
		local originalColor = giver.BrickColor
		giver.BrickColor = BrickColor.new("Bright red")

		-- Very subtle size pulse
		local originalSize = giver.Size
		TweenService:Create(giver,
			TweenInfo.new(0.1, Enum.EasingStyle.Quad),
			{Size = originalSize * 1.05} -- Only 5% bigger
		):Play()

		local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
		if playerStats and Money.Value > 0 then
			-- No sound (broken ID)
			local moneyCollected = Money.Value
			playerStats.Value = playerStats.Value + moneyCollected
			Money.Value = 0

			-- Simple floating text
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

			-- Simple float up
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

-- Button setup
local buttons = script.Parent:WaitForChild("Buttons")
local purchases = script.Parent:WaitForChild("Purchases")
local purchasedObjects = script.Parent:WaitForChild("PurchasedObjects")

-- Initial visibility
updateButtonVisibility(buttons, ServerStorage.PlayerMoney:FindFirstChild(script.Parent.Owner.Value and script.Parent.Owner.Value.Name))

-- Process each button
for _, button in ipairs(buttons:GetChildren()) do
	task.spawn(function()
		local head = button:FindFirstChild("Head")
		if not head then return end

		-- Add simple hover effect
		addSimpleHoverEffect(button)

		-- Load object
		local objectName = button:FindFirstChild("Object")
		objectName = objectName and objectName.Value
		if objectName then
			local purchaseObject = purchases:FindFirstChild(objectName)
			if purchaseObject then
				Objects[objectName] = purchaseObject:Clone()
				purchaseObject:Destroy()
			else
				warn("Object missing for button:", button.Name)
			end
		end

		-- Handle touches
		local purchaseDebounce = {}
		head.Touched:Connect(function(hit)
			if not head.CanCollide or head.Transparency > 0 then return end

			local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
			if not humanoid or humanoid.Health <= 0 then return end

			local player = Players:GetPlayerFromCharacter(hit.Parent)
			if not player or player ~= script.Parent.Owner.Value then return end

			if purchaseDebounce[player] then return end
			purchaseDebounce[player] = true

			task.defer(function()
				task.wait(0.5)
				purchaseDebounce[player] = nil
			end)

			local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
			if not playerStats then return end

			-- Minimal button press
			local originalCFrame = head.CFrame
			TweenService:Create(head,
				TweenInfo.new(0.05, Enum.EasingStyle.Linear),
				{CFrame = originalCFrame * CFrame.new(0, -0.05, 0)} -- Tiny press
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

				-- Simple red flash
				local originalColor = head.BrickColor
				head.BrickColor = BrickColor.new("Really red")
				task.wait(0.15)
				head.BrickColor = originalColor
			end
		end)
	end)
end

-- CLEAN PURCHASE FUNCTION
function processPurchase(button, playerStats)
	local price = button:FindFirstChild("Price")
	price = price and price.Value or 0

	local objectName = button:FindFirstChild("Object")
	objectName = objectName and objectName.Value

	-- Deduct cost
	playerStats.Value = playerStats.Value - price

	-- Mark as purchased
	purchasedItems[button.Name] = true

	-- Spawn object
	if objectName and Objects[objectName] then
		local newObject = Objects[objectName]:Clone()
		newObject.Parent = purchasedObjects

		-- WHITE DOORS for Cinnamoroll theme
		if objectName:find("Door") or objectName:find("door") then
			for _, part in ipairs(newObject:GetDescendants()) do
				if part:IsA("BasePart") then
					part.BrickColor = BrickColor.new("White")
					if part.Material == Enum.Material.Neon then
						part.Material = Enum.Material.SmoothPlastic -- Less glowy
					end
				end
			end
		end

		-- Simple spawn - just appear with tiny scale effect
		if newObject:IsA("Model") and newObject.PrimaryPart then
			-- Start at 95% size
			for _, part in ipairs(newObject:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Size = part.Size * 0.95
				end
			end

			-- Scale to normal
			for _, part in ipairs(newObject:GetDescendants()) do
				if part:IsA("BasePart") then
					TweenService:Create(part,
						TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{Size = part.Size / 0.95}
					):Play()
				end
			end

			-- Minimal particles
			createMinimalParticles(newObject.PrimaryPart.Position)
		end

		-- Enable scripts
		for _, descendant in ipairs(newObject:GetDescendants()) do
			if descendant:IsA("Script") then
				descendant.Disabled = false
			end
		end
	end

	-- Simple button disappear - fade up gently
	local head = button:FindFirstChild("Head")
	if head then
		head.CanCollide = false

		-- Just fade up without spiral
		TweenService:Create(head,
			TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{
				CFrame = head.CFrame + Vector3.new(0, 3, 0),
				Transparency = 1
			}
		):Play()

		-- Tiny particles
		createMinimalParticles(head.Position)
	end

	-- Update visibility
	updateButtonVisibility(buttons, playerStats)
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

-- Update visibility when money changes
script.Parent.Owner.Changed:Connect(function()
	local owner = script.Parent.Owner.Value
	if owner then
		local playerStats = ServerStorage.PlayerMoney:FindFirstChild(owner.Name)
		if playerStats then
			playerStats.Changed:Connect(function()
				updateButtonVisibility(buttons, playerStats)
			end)
		end
	end
end)

print("✅ Balanced Purchase Handler loaded!")
print("✨ 70% less effects, no green lights, white doors, cleaner animations!")