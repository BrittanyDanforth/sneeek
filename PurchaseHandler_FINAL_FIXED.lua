--[[
	✨ FINAL FIXED Purchase Handler (2025 Standards)
	Handles tycoon purchases with polished effects
	
	FIXES:
	- Removed old dependency system that causes infinite yields
	- Integrated PROGRESSION_DATA for proper unlock flow  
	- Removed pulsing green light on collector
	- Removed golden glow on special items
	- Changed button disappear to fade up (no spiral)
	- Removed purchase sound, kept only decline sound
	- Fixed invalid collect sound ID
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

-- 🎯 PROGRESSION DATA - Defines unlock flow
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

-- 🔧 Fix floating/underground buttons on startup
local function fixButtonPositions()
	print("🔧 Fixing button positions...")
	local buttons = script.Parent:WaitForChild("Buttons")
	local fixedCount = 0
	
	for _, button in ipairs(buttons:GetChildren()) do
		local head = button:FindFirstChild("Head")
		if head and head:IsA("BasePart") then
			-- Cast a ray downward to find the ground
			local raycast = workspace:Raycast(
				head.Position + Vector3.new(0, 10, 0), -- Start above the button
				Vector3.new(0, -50, 0), -- Cast downward
				RaycastParams.new()
			)
			
			if raycast then
				-- Calculate proper height (button height/2 + small offset)
				local groundY = raycast.Position.Y
				local buttonHeight = head.Size.Y
				local properY = groundY + (buttonHeight / 2) + 0.1 -- 0.1 stud offset
				
				-- Check if button needs adjustment
				local currentY = head.Position.Y
				if math.abs(currentY - properY) > 0.5 then -- If more than 0.5 studs off
					-- Smooth position correction
					local targetPosition = Vector3.new(head.Position.X, properY, head.Position.Z)
					
					-- Instant fix for large discrepancies
					if math.abs(currentY - properY) > 5 then
						head.CFrame = CFrame.new(targetPosition) * (head.CFrame - head.CFrame.Position)
						fixedCount = fixedCount + 1
						print("  Fixed button:", button.Name, "was", math.floor(currentY - properY), "studs off")
					else
						-- Smooth animation for small adjustments
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
		print("✅ Fixed", fixedCount, "button positions!")
	else
		print("✅ All buttons were already properly positioned!")
	end
end

-- Fix buttons on startup
task.defer(fixButtonPositions)

-- Modern sound function
local function playSound(part, soundId, volume)
	if not soundId or soundId == 0 then return end
	
	-- Skip invalid sound IDs (like the broken collect sound)
	if soundId == 131961136 or soundId == 131886985 then
		return -- These IDs are invalid, skip them
	end
	
	if part:FindFirstChild("Sound") then return end
	
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. tostring(soundId)
	sound.Volume = volume or 0.3 -- Reduced volume, especially for error sounds
	sound.Parent = part
	sound:Play()
	
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

-- 🎯 Helper function to check if player can afford a button
local function canAfford(player, price)
	local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
	return playerStats and playerStats.Value >= price
end

-- 🎯 Update button visibility based on progression
local function updateButtonVisibility(buttons, playerMoney)
	for _, button in ipairs(buttons:GetChildren()) do
		local head = button:FindFirstChild("Head")
		if not head then continue end
		
		local buttonName = button.Name
		local price = button:FindFirstChild("Price")
		price = price and price.Value or 0
		
		-- Check if button should be visible based on progression
		local shouldShow = false
		
		-- Always show the first button
		if buttonName == "Begin Working! - [$0]" and not purchasedItems[buttonName] then
			shouldShow = true
		elseif purchasedItems[buttonName] then
			-- Already purchased, keep hidden
			shouldShow = false
		else
			-- Check if requirements are met
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
				-- Not in progression data, check if it's unlocked by something
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
		
		-- Apply visibility
		if shouldShow then
			head.Transparency = 0
			head.CanCollide = true
			
			-- Color based on affordability
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

-- 🎨 Add hover effect to buttons
local function addButtonHoverEffect(head)
	local originalSize = head.Size
	local hoverConnection
	
	-- Create hover detection part (slightly larger)
	local hoverPart = Instance.new("Part")
	hoverPart.Name = "HoverDetector"
	hoverPart.Size = originalSize * 1.2
	hoverPart.Transparency = 1
	hoverPart.CanCollide = false
	hoverPart.Anchored = true
	hoverPart.CFrame = head.CFrame
	hoverPart.Parent = head
	
	-- Weld to head
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = head
	weld.Part1 = hoverPart
	weld.Parent = head
	
	local isHovering = false
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	
	hoverPart.Touched:Connect(function(hit)
		local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		if humanoid and not isHovering then
			isHovering = true
			-- Scale up slightly
			TweenService:Create(head, tweenInfo, {Size = originalSize * 1.1}):Play()
			-- Add subtle glow
			local selectionBox = Instance.new("SelectionBox")
			selectionBox.Adornee = head
			selectionBox.Color3 = Color3.new(0, 1, 0)
			selectionBox.LineThickness = 0.1
			selectionBox.Transparency = 0.5
			selectionBox.Parent = head
			selectionBox.Name = "HoverGlow"
		end
	end)
	
	-- Check when player leaves
	task.spawn(function()
		while head.Parent do
			task.wait(0.1)
			if isHovering then
				local touching = false
				for _, part in ipairs(workspace:GetPartBoundsInBox(hoverPart.CFrame, hoverPart.Size)) do
					if part.Parent:FindFirstChildOfClass("Humanoid") then
						touching = true
						break
					end
				end
				
				if not touching then
					isHovering = false
					-- Scale back down
					TweenService:Create(head, tweenInfo, {Size = originalSize}):Play()
					-- Remove glow
					local glow = head:FindFirstChild("HoverGlow")
					if glow then glow:Destroy() end
				end
			end
		end
	end)
end

-- 🎆 Create purchase particles
local function createPurchaseParticles(position)
	local attachment = Instance.new("Attachment")
	attachment.Position = position
	attachment.Parent = workspace.Terrain
	
	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Rate = 100
	emitter.Lifetime = NumberRange.new(0.5, 1)
	emitter.VelocityInheritance = 0
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.Speed = NumberRange.new(5, 10)
	emitter.SpreadAngle = Vector2.new(30, 30)
	emitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(0, 1, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 0)),
		ColorSequenceKeypoint.new(1, Color3.new(1, 0.5, 0))
	})
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.5, 1),
		NumberSequenceKeypoint.new(1, 0)
	})
	emitter.Parent = attachment
	
	-- Stop after burst
	task.wait(0.2)
	emitter.Enabled = false
	Debris:AddItem(attachment, 2)
end

-- MODERNIZED PART COLLECTOR WITH SMOOTH FADE
local collectedParts = {}

for _, collector in ipairs(essentials:GetChildren()) do
	if collector.Name == "PartCollector" then
		collector.CanCollide = false
		
		collector.Touched:Connect(function(part)
			if collectedParts[part] then return end
			
			local cashValue = part:FindFirstChild("Cash")
			if cashValue then
				collectedParts[part] = true
				
				-- Add money with visual feedback
				Money.Value = Money.Value + cashValue.Value
				
				-- 💰 Money collection effects
				-- Scale pop
				if part:IsA("BasePart") then
					local originalSize = part.Size
					TweenService:Create(part,
						TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
						{Size = originalSize * 1.3}
					):Play()
				end
				
				-- Particles
				local attachment = Instance.new("Attachment")
				attachment.Parent = part
				
				local emitter = Instance.new("ParticleEmitter")
				emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
				emitter.Rate = 50
				emitter.Lifetime = NumberRange.new(0.5)
				emitter.VelocityInheritance = 0
				emitter.Speed = NumberRange.new(3)
				emitter.SpreadAngle = Vector2.new(180, 180)
				emitter.Parent = attachment
				
				-- 💵 Floating money text
				local billboardGui = Instance.new("BillboardGui")
				billboardGui.Size = UDim2.new(0, 100, 0, 50)
				billboardGui.StudsOffset = Vector3.new(0, 2, 0)
				billboardGui.Parent = part
				
				local textLabel = Instance.new("TextLabel")
				textLabel.Size = UDim2.new(1, 0, 1, 0)
				textLabel.BackgroundTransparency = 1
				textLabel.Text = "+$" .. tostring(cashValue.Value)
				textLabel.TextColor3 = Color3.new(0, 1, 0)
				textLabel.TextScaled = true
				textLabel.Font = Enum.Font.SourceSansBold
				textLabel.Parent = billboardGui
				
				-- Float up and fade
				TweenService:Create(billboardGui,
					TweenInfo.new(1, Enum.EasingStyle.Linear),
					{StudsOffset = Vector3.new(0, 5, 0)}
				):Play()
				
				TweenService:Create(textLabel,
					TweenInfo.new(1, Enum.EasingStyle.Linear),
					{TextTransparency = 1}
				):Play()
				
				-- Stop part movement
				part.Anchored = true
				part.CanCollide = false
				part.CanTouch = false
				part.CanQuery = false
				
				-- Fade out
				task.wait(0.1)
				emitter.Enabled = false
				
				if part:IsA("BasePart") then
					local fadeTween = TweenService:Create(part,
						TweenInfo.new(0.5, Enum.EasingStyle.Linear),
						{Transparency = 1}
					)
					
					for _, child in ipairs(part:GetDescendants()) do
						if child:IsA("Decal") or child:IsA("Texture") then
							TweenService:Create(child, TweenInfo.new(0.5), {Transparency = 1}):Play()
						elseif child:IsA("ParticleEmitter") and child ~= emitter then
							child.Enabled = false
						elseif child:IsA("PointLight") or child:IsA("SpotLight") then
							TweenService:Create(child, TweenInfo.new(0.5), {Brightness = 0}):Play()
						end
					end
					
					fadeTween:Play()
					fadeTween.Completed:Connect(function()
						part:Destroy()
					end)
				else
					part:Destroy()
				end
				
				task.delay(1, function()
					collectedParts[part] = nil
				end)
			end
		end)
	end
end

-- 💎 Enhanced money collector (NO PULSING LIGHT)
local collectorDebounce = {}
local giver = essentials:WaitForChild("Giver")

-- Add visual enhancements to collector
local collectorPart = giver
if collectorPart then
	-- Subtle scaling animation (no light)
	task.spawn(function()
		local originalSize = collectorPart.Size
		while collectorPart.Parent do
			TweenService:Create(collectorPart,
				TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Size = originalSize * 1.05}
			):Play()
			task.wait(2)
			TweenService:Create(collectorPart,
				TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Size = originalSize}
			):Play()
			task.wait(2)
		end
	end)
end

giver.Touched:Connect(function(hit)
	local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end
	
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player then return end
	
	if script.Parent.Owner.Value == player then
		if collectorDebounce[player] then return end
		collectorDebounce[player] = true
		
		-- Visual feedback
		giver.BrickColor = BrickColor.new("Bright red")
		TweenService:Create(giver,
			TweenInfo.new(0.1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
			{Size = giver.Size * 1.2}
		):Play()
		
		local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
		if playerStats and Money.Value > 0 then
			-- No collect sound (it's broken)
			-- Create collection particles
			local attachment = Instance.new("Attachment")
			attachment.Parent = giver
			
			local emitter = Instance.new("ParticleEmitter")
			emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
			emitter.Rate = 100
			emitter.Lifetime = NumberRange.new(0.5)
			emitter.VelocityInheritance = 0
			emitter.Speed = NumberRange.new(10)
			emitter.SpreadAngle = Vector2.new(360, 360)
			emitter.Parent = attachment
			
			playerStats.Value = playerStats.Value + Money.Value
			Money.Value = 0
			
			task.wait(0.1)
			emitter.Enabled = false
			Debris:AddItem(attachment, 2)
		end
		
		task.wait(0.5)
		TweenService:Create(giver,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad),
			{Size = giver.Size / 1.2}
		):Play()
		task.wait(0.5)
		giver.BrickColor = BrickColor.new("Sea green")
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
				-- No collect sound
				playerStats.Value = playerStats.Value + stealAmount
				Money.Value = Money.Value - stealAmount
			end
		end
	else
		playSound(essentials, Settings.Sounds.ErrorBuy, 0.3) -- Quiet error sound
	end
end)

-- Modern button setup with async loading
local buttons = script.Parent:WaitForChild("Buttons")
local purchases = script.Parent:WaitForChild("Purchases")
local purchasedObjects = script.Parent:WaitForChild("PurchasedObjects")

-- Tween settings for fading
local fadeInInfo = TweenInfo.new(
	Settings.FadeInTime or 0.5,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.Out
)

local fadeOutInfo = TweenInfo.new(
	Settings.FadeOutTime or 0.5,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.In
)

-- Initial visibility update
updateButtonVisibility(buttons, ServerStorage.PlayerMoney:FindFirstChild(script.Parent.Owner.Value and script.Parent.Owner.Value.Name))

-- Process each button
for _, button in ipairs(buttons:GetChildren()) do
	task.spawn(function()
		local head = button:FindFirstChild("Head")
		if not head then return end
		
		-- Load the object for this button
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
		
		-- Add hover effect
		addButtonHoverEffect(head)
		
		-- Handle button touches
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
			
			-- 🎯 Button press animation
			local originalCFrame = head.CFrame
			TweenService:Create(head,
				TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{CFrame = originalCFrame * CFrame.new(0, -0.2, 0)}
			):Play()
			
			task.wait(0.1)
			TweenService:Create(head,
				TweenInfo.new(0.1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
				{CFrame = originalCFrame}
			):Play()
			
			-- Handle gamepass purchases
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
			
			-- Handle dev product purchases
			local devProduct = button:FindFirstChild("DevProduct")
			if devProduct and devProduct.Value >= 1 then
				MarketplaceService:PromptProductPurchase(player, devProduct.Value)
				return
			end
			
			-- Handle regular purchases
			local price = button:FindFirstChild("Price")
			price = price and price.Value or 0
			
			if playerStats.Value >= price then
				processPurchase(button, playerStats)
				-- NO PURCHASE SOUND
			else
				-- 🚫 Error feedback
				playSound(head, Settings.Sounds.ErrorBuy, 0.3) -- Quiet error sound
				
				-- Shake animation
				local shakeAmount = 0.2
				local originalPos = head.Position
				for i = 1, 5 do
					head.CFrame = head.CFrame * CFrame.new(
						math.random() * shakeAmount - shakeAmount/2,
						0,
						math.random() * shakeAmount - shakeAmount/2
					)
					task.wait(0.05)
				end
				head.CFrame = CFrame.new(originalPos) * (head.CFrame - head.CFrame.Position)
				
				-- Red flash
				local originalColor = head.BrickColor
				head.BrickColor = BrickColor.new("Really red")
				task.wait(0.2)
				head.BrickColor = originalColor
			end
		end)
	end)
end

-- Modern purchase function with smooth animations
function processPurchase(button, playerStats)
	local price = button:FindFirstChild("Price")
	price = price and price.Value or 0
	
	local objectName = button:FindFirstChild("Object")
	objectName = objectName and objectName.Value
	
	-- Deduct cost
	playerStats.Value = playerStats.Value - price
	
	-- Mark as purchased
	purchasedItems[button.Name] = true
	
	-- Create particles at button location
	local head = button:FindFirstChild("Head")
	if head then
		createPurchaseParticles(head.Position)
	end
	
	-- Spawn object if it exists
	if objectName and Objects[objectName] then
		local newObject = Objects[objectName]:Clone()
		newObject.Parent = purchasedObjects
		
		-- 🎆 Epic spawn animation (NO GOLDEN GLOW)
		if newObject:IsA("Model") and newObject.PrimaryPart then
			local primaryPart = newObject.PrimaryPart
			local originalCFrame = primaryPart.CFrame
			
			-- Start high and drop
			primaryPart.CFrame = originalCFrame + Vector3.new(0, 15, 0)
			
			-- Drop with bounce
			TweenService:Create(primaryPart,
				TweenInfo.new(0.8, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
				{CFrame = originalCFrame}
			):Play()
			
			-- Spawn particles
			local attachment = Instance.new("Attachment")
			attachment.Parent = primaryPart
			
			local emitter = Instance.new("ParticleEmitter")
			emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
			emitter.Rate = 100
			emitter.Lifetime = NumberRange.new(1)
			emitter.VelocityInheritance = 0
			emitter.EmissionDirection = Enum.NormalId.Top
			emitter.Speed = NumberRange.new(5, 15)
			emitter.SpreadAngle = Vector2.new(180, 180)
			emitter.Parent = attachment
			
			task.wait(0.5)
			emitter.Enabled = false
			Debris:AddItem(attachment, 3)
			
			-- Camera shake (if local)
			local owner = script.Parent.Owner.Value
			if owner and owner.Character then
				local humanoid = owner.Character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					local camera = workspace.CurrentCamera
					if camera then
						local originalCFrame = camera.CFrame
						for i = 1, 10 do
							camera.CFrame = originalCFrame * CFrame.Angles(
								math.rad(math.random(-2, 2)),
								math.rad(math.random(-2, 2)),
								0
							)
							task.wait(0.03)
						end
						camera.CFrame = originalCFrame
					end
				end
			end
		end
		
		-- Enable scripts in spawned object
		for _, descendant in ipairs(newObject:GetDescendants()) do
			if descendant:IsA("Script") then
				descendant.Disabled = false
			end
		end
	end
	
	-- 🎯 Button disappear animation (FADE UP, NO SPIRAL)
	if head then
		head.CanCollide = false
		
		if Settings.ButtonsFadeOut then
			-- Fade up instead of spiral
			local fadeUpTween = TweenService:Create(head,
				TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{
					CFrame = head.CFrame + Vector3.new(0, 10, 0),
					Transparency = 1,
					Size = head.Size * 0.5
				}
			)
			
			-- Add disappear particles
			local attachment = Instance.new("Attachment")
			attachment.Parent = head
			
			local emitter = Instance.new("ParticleEmitter")
			emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
			emitter.Rate = 50
			emitter.Lifetime = NumberRange.new(0.5, 1)
			emitter.VelocityInheritance = 0
			emitter.Speed = NumberRange.new(2, 5)
			emitter.SpreadAngle = Vector2.new(360, 360)
			emitter.Parent = attachment
			
			fadeUpTween:Play()
			
			task.wait(0.2)
			emitter.Enabled = false
			
			fadeUpTween.Completed:Connect(function()
				head.Transparency = 1
			end)
		else
			head.Transparency = 1
		end
	end
	
	-- Update visibility for other buttons
	updateButtonVisibility(buttons, playerStats)
end

-- Handle BuyObject folder (for dev products)
local buyObject = script.Parent:WaitForChild("BuyObject")
buyObject.ChildAdded:Connect(function(child)
	task.wait(0.1)
	
	local cost = child:FindFirstChild("Cost")
	local button = child:FindFirstChild("Button")
	local stats = child:FindFirstChild("Stats")
	
	if cost and button and stats then
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
				local tempButton = {
					Price = {Value = 0},
					Object = button:FindFirstChild("Object"),
					Name = button.Name
				}
				processPurchase(tempButton, playerStats)
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

print("✅ FINAL FIXED Purchase Handler loaded successfully!")
print("✨ Features: PROGRESSION_DATA, button fixing, reduced effects, quiet sounds!")