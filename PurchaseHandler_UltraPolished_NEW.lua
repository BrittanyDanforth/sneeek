--[[
	ULTRA POLISHED Purchase Handler with Progression System
	Enhanced with satisfying visual and audio feedback
	"The Juice" 🧃 - Every action feels impactful!
--]]

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

-- Get settings and references
local Settings = require(script.Parent.Parent.Parent.Settings)
local Objects = {}
local TeamColor = script.Parent:WaitForChild("TeamColor").Value
local Money = script.Parent:WaitForChild("CurrencyToCollect")
local Stealing = Settings.StealSettings
local CanSteal = true

-- PROGRESSION DATA - Define what unlocks what
local PROGRESSION_DATA = {
	-- Starting item (FREE!)
	["Begin Working! - [$0]"] = {
		unlocks = {"Buy Dropper - [$10,000]", "Buy Conveyer - [$8,000]"}
	},
	["Buy Dropper - [$10,000]"] = {
		requires = {"Begin Working! - [$0]"},
		unlocks = {"Buy Dropper - [$20,000]"}
	},
	["2"] = { -- Buy Dropper - [$20,000]
		requires = {"1"},
		unlocks = {"3", "4"}
	},
	["3"] = { -- Buy Dropper - [$12,000]
		requires = {"2"},
		unlocks = {"5", "16"}
	},
	["4"] = { -- Buy Dropper - [$70]
		requires = {"2"},
		unlocks = {"7"}
	},
	["5"] = { -- Buy Extra - [$35,000]
		requires = {"3"},
		unlocks = {"11"} -- Unlocks MEGA Dropper!
	},
	["7"] = { -- Buy Floor - [$1,500]
		requires = {"4"},
		unlocks = {"18"}
	},
	["8"] = { -- Buy Conveyer - [$8,000]
		requires = {"1"},
		unlocks = {"9"}
	},
	["9"] = { -- Buy CORE Dropper - [$5,000]
		requires = {"8"},
		unlocks = {"10"}
	},
	["10"] = { -- Buy POWER CORE Dropper - [$2,000]
		requires = {"9"},
		unlocks = {"14"}
	},
	["11"] = { -- Buy MEGA Dropper - [$300] ⭐ KEY ITEM
		requires = {"5"},
		unlocks = {"12", "19", "13"} -- Unlocks Super, Walls, and Mega $7k
	},
	["12"] = { -- Buy Super Dropper - [$1,000]
		requires = {"11"},
		unlocks = {"15"}
	},
	["13"] = { -- Buy a Mega Dropper - [$7,000]
		requires = {"11"},
		unlocks = {"40"}
	},
	["14"] = { -- Buy a Omega Dropper - [$15,000]
		requires = {"10"},
		unlocks = {"39"}
	},
	["15"] = { -- Buy a Omega Dropper - [$9,000]
		requires = {"12"},
		unlocks = {"30"}
	},
	["16"] = { -- Buy Path - [$10,000]
		requires = {"3"},
		unlocks = {"17"}
	},
	["17"] = { -- Buy Path - [$10,000] (second one)
		requires = {"16"},
		unlocks = {"20"}
	},
	["18"] = { -- Buy Path - [$250]
		requires = {"7"},
		unlocks = {"19"}
	},
	["19"] = { -- Buy Walls - [$100]
		requires = {"18", "11"}, -- Requires both Path AND MEGA Dropper
		unlocks = {"21"}
	},
	["20"] = { -- Buy Stair - [$2500]
		requires = {"17"},
		unlocks = {"21"}
	},
	-- Wall upgrades chain
	["21"] = { -- Upgrade Walls - [$1,000]
		requires = {"19"},
		unlocks = {"25"}
	},
	["25"] = { -- Upgrade Walls - [$12,000]
		requires = {"21"},
		unlocks = {"26"}
	},
	["26"] = { -- Upgrade Walls - [$20,000]
		requires = {"25"},
		unlocks = {"27"}
	},
	["27"] = { -- Upgrade Walls - [$28,000]
		requires = {"26"},
		unlocks = {"31"}
	},
	["31"] = { -- Upgrade Walls - [$350]
		requires = {"27"},
		unlocks = {"35"}
	},
	["35"] = { -- Upgrade Walls - [$7,000]
		requires = {"31"},
		unlocks = {"38"}
	},
	["38"] = { -- Upgrade Walls - [$700]
		requires = {"35"},
		unlocks = {"30"}
	},
	["30"] = { -- Upgrade Wall - [$35,000]
		requires = {"15", "38"},
		unlocks = {"32"}
	},
	["32"] = { -- Upgrade Wall - [$45,000]
		requires = {"30"},
		unlocks = {"39"}
	},
	["39"] = { -- Upgrade Roof - [$40,000]
		requires = {"14", "32"},
		unlocks = {}
	},
	["40"] = { -- Buy an OwnerDoor - [$1,500]
		requires = {"13"},
		unlocks = {}
	}
}

-- Track purchased items
local purchasedItems = {}

-- Set spawn colors
local essentials = script.Parent:WaitForChild("Essentials")
local spawn = essentials:WaitForChild("Spawn")
spawn.TeamColor = TeamColor
spawn.BrickColor = TeamColor

-- 🎵 ENHANCED SOUND SYSTEM with pitch variation for variety
local function playSound(part, soundId, pitchVariation)
	if part:FindFirstChild("Sound") then
		return
	end

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. tostring(soundId)
	sound.Volume = 0.5
	sound.Parent = part
	
	-- Add pitch variation for more dynamic sounds
	if pitchVariation then
		sound.PlaybackSpeed = 1 + (math.random(-10, 10) / 100) -- ±10% pitch variation
	end

	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

-- 🌟 PARTICLE EFFECT for purchases
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
	emitter.Color = ColorSequence.new(Color3.new(1, 0.8, 0))
	emitter.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.1, 1),
		NumberSequenceKeypoint.new(1, 0)
	}
	emitter.Parent = attachment
	
	-- Stop emitting after 0.2 seconds
	task.wait(0.2)
	emitter.Enabled = false
	
	-- Clean up after particles fade
	game.Debris:AddItem(attachment, 2)
end

-- 💫 BUTTON HOVER EFFECT
local function addButtonHoverEffect(button)
	local head = button:FindFirstChild("Head")
	if not head then return end
	
	-- Create hover light
	local light = Instance.new("PointLight")
	light.Brightness = 0
	light.Range = 10
	light.Parent = head
	
	-- Mouse detection part (slightly larger than button)
	local hoverPart = Instance.new("Part")
	hoverPart.Name = "HoverDetector"
	hoverPart.Size = head.Size * 1.2
	hoverPart.Transparency = 1
	hoverPart.CanCollide = false
	hoverPart.CFrame = head.CFrame
	hoverPart.Parent = button
	
	-- Weld to head
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = head
	weld.Part1 = hoverPart
	weld.Parent = hoverPart
	
	-- Track hover state
	local isHovering = false
	local originalSize = head.Size
	
	-- Hover animation
	local function animateHover(hovering)
		if hovering then
			-- Grow and glow
			TweenService:Create(head, 
				TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{Size = originalSize * 1.1}
			):Play()
			
			TweenService:Create(light,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Brightness = 2}
			):Play()
		else
			-- Shrink back
			TweenService:Create(head,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Size = originalSize}
			):Play()
			
			TweenService:Create(light,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Brightness = 0}
			):Play()
		end
	end
	
	-- Hover detection
	hoverPart.Touched:Connect(function(hit)
		local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		if humanoid and not isHovering then
			isHovering = true
			animateHover(true)
		end
	end)
	
	-- Simple hover end detection
	task.spawn(function()
		while button.Parent do
			if isHovering then
				local nearbyPlayers = false
				for _, player in pairs(Players:GetPlayers()) do
					if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
						local distance = (player.Character.HumanoidRootPart.Position - head.Position).Magnitude
						if distance < 15 then
							nearbyPlayers = true
							break
						end
					end
				end
				
				if not nearbyPlayers then
					isHovering = false
					animateHover(false)
				end
			end
			task.wait(0.5)
		end
	end)
end

-- Check if button requirements are met
local function hasRequirements(buttonNumber)
	local data = PROGRESSION_DATA[tostring(buttonNumber)]
	if not data then return true end -- No data = always available

	if not data.requires then
		return true -- No requirements
	end

	-- Check all requirements
	for _, reqNum in pairs(data.requires) do
		if not purchasedItems[reqNum] then
			return false
		end
	end

	return true
end

-- 🎨 ENHANCED button visibility with smooth animations
local function updateButtonVisibility()
	local buttons = script.Parent:WaitForChild("Buttons")

	for _, button in pairs(buttons:GetChildren()) do
		local head = button:FindFirstChild("Head")
		if head then
			local buttonNum = button.Name:match("%d+")

			if buttonNum then
				-- Already purchased - hide it
				if purchasedItems[buttonNum] then
					head.Transparency = 1
					head.CanCollide = false
					local gui = head:FindFirstChildOfClass("SurfaceGui") or head:FindFirstChildOfClass("BillboardGui")
					if gui then gui.Enabled = false end
					
				-- Not purchased - check if it should be visible
				else
					local data = PROGRESSION_DATA[buttonNum]
					
					-- Special case: Only button 1 starts visible
					if buttonNum == "1" and next(purchasedItems) == nil then
						showButtonWithAnimation(button)
						
					-- Check if this button has data and requirements are met
					elseif data and hasRequirements(buttonNum) then
						showButtonWithAnimation(button)
						
					else
						-- Hide button - not in progression data or requirements not met
						head.Transparency = 1
						head.CanCollide = false
						local gui = head:FindFirstChildOfClass("SurfaceGui") or head:FindFirstChildOfClass("BillboardGui")
						if gui then gui.Enabled = false end
					end
				end
			else
				-- No number in button name - hide it
				head.Transparency = 1
				head.CanCollide = false
				local gui = head:FindFirstChildOfClass("SurfaceGui") or head:FindFirstChildOfClass("BillboardGui")
				if gui then gui.Enabled = false end
			end
		end
	end
end

-- 🌈 SHOW BUTTON WITH ANIMATION
function showButtonWithAnimation(button)
	local head = button:FindFirstChild("Head")
	if not head then return end
	
	-- Check if already visible
	if head.Transparency == 0 then return end
	
	-- Prepare for animation
	head.CanCollide = true
	local gui = head:FindFirstChildOfClass("SurfaceGui") or head:FindFirstChildOfClass("BillboardGui")
	if gui then gui.Enabled = true end
	
	-- Start small and transparent
	local originalSize = head.Size
	head.Size = originalSize * 0.5
	head.Transparency = 1
	
	-- Pop in animation
	TweenService:Create(head,
		TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{Size = originalSize, Transparency = 0}
	):Play()
	
	-- Add hover effect
	addButtonHoverEffect(button)
	
	-- Spawn particles for new button
	createPurchaseParticles(head.Position)
	
	-- Play a subtle "new button" sound
	playSound(head, 1238528678, true) -- Pop sound
end

-- 💰 MONEY COLLECTION WITH EXTRA JUICE
local collectedParts = {} -- Prevent double collection

for _, collector in ipairs(essentials:GetChildren()) do
	if collector.Name == "PartCollector" then
		-- Fix flinging by making collector non-collidable
		collector.CanCollide = false

		collector.Touched:Connect(function(part)
			-- Skip if already collected
			if collectedParts[part] then return end

			local cashValue = part:FindFirstChild("Cash")
			if cashValue then
				-- Mark as collected immediately
				collectedParts[part] = true

				-- Add money
				Money.Value = Money.Value + cashValue.Value

				-- Stop the part in its tracks
				part.Anchored = true
				part.CanCollide = false
				part.CanTouch = false
				part.CanQuery = false
				
				-- 💫 COLLECTION EFFECT
				-- Scale up briefly before fading
				local originalSize = part.Size
				TweenService:Create(part,
					TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{Size = originalSize * 1.5}
				):Play()
				
				-- Create collection particles
				local attachment = Instance.new("Attachment")
				attachment.Parent = part
				
				local emitter = Instance.new("ParticleEmitter")
				emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
				emitter.Rate = 50
				emitter.Lifetime = NumberRange.new(0.3)
				emitter.Speed = NumberRange.new(5)
				emitter.SpreadAngle = Vector2.new(180, 180)
				emitter.Color = ColorSequence.new(Color3.new(0, 1, 0))
				emitter.Size = NumberSequence.new(0.5)
				emitter.Parent = attachment
				
				-- Play collection sound with pitch variation
				playSound(part, 131961136, true) -- Coin sound

				-- Smooth fade animation
				task.wait(0.1)
				emitter.Enabled = false
				
				if part:IsA("BasePart") then
					-- Create fade tween
					local fadeTween = TweenService:Create(part, 
						TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{Transparency = 1, Size = originalSize * 0.5}
					)

					-- Fade any visual elements
					for _, child in ipairs(part:GetDescendants()) do
						if child:IsA("Decal") or child:IsA("Texture") then
							TweenService:Create(child,
								TweenInfo.new(0.4, Enum.EasingStyle.Linear),
								{Transparency = 1}
							):Play()
						elseif child:IsA("ParticleEmitter") and child ~= emitter then
							child.Enabled = false
						elseif child:IsA("PointLight") or child:IsA("SpotLight") then
							TweenService:Create(child,
								TweenInfo.new(0.4, Enum.EasingStyle.Linear),
								{Brightness = 0}
							):Play()
						end
					end

					-- Play fade animation
					fadeTween:Play()

					-- Destroy after fade
					fadeTween.Completed:Connect(function()
						part:Destroy()
					end)
				else
					-- Non-basepart, just destroy
					part:Destroy()
				end

				-- Clean tracking table
				task.delay(1, function()
					collectedParts[part] = nil
				end)
			end
		end)
	end
end

-- 🎯 ENHANCED COLLECTOR with visual feedback
local collectorDebounce = {}
local giver = essentials:WaitForChild("Giver")

-- Add glow effect to collector
local collectorLight = Instance.new("PointLight")
collectorLight.Brightness = 1
collectorLight.Range = 15
collectorLight.Color = Color3.new(0.3, 1, 0.3)
collectorLight.Parent = giver

-- Pulse animation for collector
task.spawn(function()
	while giver.Parent do
		TweenService:Create(collectorLight,
			TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{Brightness = 2}
		):Play()
		task.wait(1)
		TweenService:Create(collectorLight,
			TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{Brightness = 1}
		):Play()
		task.wait(1)
	end
end)

giver.Touched:Connect(function(hit)
	local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player then return end

	-- Owner collecting money
	if script.Parent.Owner.Value == player then
		if collectorDebounce[player] then return end
		collectorDebounce[player] = true

		-- Visual feedback
		local originalColor = giver.BrickColor
		giver.BrickColor = BrickColor.new("Bright red")
		
		-- Pulse effect
		local originalSize = giver.Size
		TweenService:Create(giver,
			TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{Size = originalSize * 1.2}
		):Play()

		local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
		if playerStats and Money.Value > 0 then
			playSound(essentials, Settings.Sounds.Collect, true)
			
			-- Show money collected feedback
			local moneyCollected = Money.Value
			playerStats.Value = playerStats.Value + moneyCollected
			Money.Value = 0
			
			-- Create floating text
			local billboardGui = Instance.new("BillboardGui")
			billboardGui.Size = UDim2.new(0, 100, 0, 50)
			billboardGui.StudsOffset = Vector3.new(0, 5, 0)
			billboardGui.Parent = giver
			
			local textLabel = Instance.new("TextLabel")
			textLabel.Size = UDim2.new(1, 0, 1, 0)
			textLabel.BackgroundTransparency = 1
			textLabel.Text = "+$" .. tostring(moneyCollected)
			textLabel.TextScaled = true
			textLabel.TextColor3 = Color3.new(0, 1, 0)
			textLabel.Font = Enum.Font.SourceSansBold
			textLabel.Parent = billboardGui
			
			-- Float up and fade
			TweenService:Create(billboardGui,
				TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{StudsOffset = Vector3.new(0, 10, 0)}
			):Play()
			
			TweenService:Create(textLabel,
				TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{TextTransparency = 1}
			):Play()
			
			game.Debris:AddItem(billboardGui, 1)
		end

		task.wait(0.1)
		TweenService:Create(giver,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Size = originalSize}
		):Play()
		
		task.wait(0.9)
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
				playSound(essentials, Settings.Sounds.Collect, true)
				playerStats.Value = playerStats.Value + stealAmount
				Money.Value = Money.Value - stealAmount
			end
		end
	else
		playSound(essentials, Settings.Sounds.ErrorBuy)
		
		-- Red flash for error
		local originalColor = giver.Color
		giver.Color = Color3.new(1, 0, 0)
		task.wait(0.1)
		giver.Color = originalColor
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
updateButtonVisibility()

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

		-- Handle dependencies (keep existing functionality but respect progression)
		local dependency = button:FindFirstChild("Dependency")
		if dependency then
			-- Skip dependency handling - let progression system control visibility
			-- This prevents buttons from showing up just because their dependency exists
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

			-- 🎯 BUTTON PRESS ANIMATION
			local originalCFrame = head.CFrame
			TweenService:Create(head,
				TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{CFrame = originalCFrame * CFrame.new(0, -0.2, 0)}
			):Play()
			
			task.wait(0.05)
			TweenService:Create(head,
				TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{CFrame = originalCFrame}
			):Play()

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
				playSound(head, Settings.Sounds.Purchase, true)
			else
				playSound(head, Settings.Sounds.ErrorBuy)
				
				-- ❌ ERROR FEEDBACK
				-- Shake animation
				local shakes = 5
				local shakeAmount = 0.1
				local originalPos = head.Position
				
				task.spawn(function()
					for i = 1, shakes do
						head.CFrame = head.CFrame * CFrame.new(shakeAmount, 0, 0)
						task.wait(0.05)
						head.CFrame = head.CFrame * CFrame.new(-shakeAmount * 2, 0, 0)
						task.wait(0.05)
						head.CFrame = head.CFrame * CFrame.new(shakeAmount, 0, 0)
					end
				end)
				
				-- Red flash
				local originalColor = head.Color
				head.Color = Color3.new(1, 0, 0)
				task.wait(0.2)
				head.Color = originalColor
			end
		end)
	end)
end

-- 🎆 ULTRA POLISHED purchase function with maximum juice
function processPurchase(button, playerStats)
	local price = button.Price.Value
	local objectName = button.Object.Value

	-- Deduct cost and spawn object
	playerStats.Value = playerStats.Value - price

	if Objects[objectName] then
		local newObject = Objects[objectName]:Clone()
		newObject.Parent = purchasedObjects

		-- 🌟 EPIC SPAWN ANIMATION
		if newObject:IsA("Model") and newObject.PrimaryPart then
			local originalCFrame = newObject:GetPrimaryPartCFrame()
			
			-- Start high and invisible
			newObject:SetPrimaryPartCFrame(originalCFrame + Vector3.new(0, 20, 0))
			
			-- Make all parts transparent
			local parts = {}
			for _, part in pairs(newObject:GetDescendants()) do
				if part:IsA("BasePart") then
					parts[part] = part.Transparency
					part.Transparency = 1
				end
			end
			
			-- Fade in while dropping
			for _, part in pairs(newObject:GetDescendants()) do
				if part:IsA("BasePart") then
					TweenService:Create(part,
						TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{Transparency = parts[part] or 0}
					):Play()
				end
			end
			
			-- Drop with bounce
			local primary = newObject.PrimaryPart
			local dropTween = TweenService:Create(primary, 
				TweenInfo.new(0.8, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
				{CFrame = originalCFrame}
			)
			dropTween:Play()
			
			-- Impact particles when it lands
			dropTween.Completed:Connect(function()
				createPurchaseParticles(originalCFrame.Position)
				
				-- Impact sound
				playSound(primary, 2767090, true) -- Thud sound
				
				-- Small camera shake (if player is nearby)
				local player = script.Parent.Owner.Value
				if player and player.Character and player.Character:FindFirstChild("Humanoid") then
					local humanoid = player.Character.Humanoid
					local distance = (player.Character.HumanoidRootPart.Position - originalCFrame.Position).Magnitude
					
					if distance < 30 then
						-- Simple camera shake
						for i = 1, 3 do
							humanoid.CameraOffset = Vector3.new(
								math.random(-10, 10) / 100,
								math.random(-10, 10) / 100,
								0
							)
							task.wait(0.05)
						end
						humanoid.CameraOffset = Vector3.new(0, 0, 0)
					end
				end
			end)
			
			-- Glow effect for special items
			if objectName:match("MEGA") or objectName:match("Omega") or objectName:match("Super") then
				local light = Instance.new("PointLight")
				light.Brightness = 3
				light.Range = 20
				light.Color = Color3.new(1, 0.8, 0)
				light.Parent = primary
				
				-- Fade out glow
				task.wait(1)
				TweenService:Create(light,
					TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{Brightness = 0}
				):Play()
			end
		end
	end

	-- Mark button as purchased
	local buttonNum = button.Name:match("%d+")
	if buttonNum then
		purchasedItems[buttonNum] = true
	end

	-- 💥 EPIC BUTTON DISAPPEAR ANIMATION
	local head = button:FindFirstChild("Head")
	if head then
		head.CanCollide = false
		
		-- Success particles
		createPurchaseParticles(head.Position)
		
		-- Spiral out animation
		local originalCFrame = head.CFrame
		task.spawn(function()
			local spiralTime = 0
			while spiralTime < 0.5 do
				spiralTime = spiralTime + task.wait()
				local progress = spiralTime / 0.5
				
				head.CFrame = originalCFrame * 
					CFrame.new(math.sin(spiralTime * 20) * 2, progress * 5, math.cos(spiralTime * 20) * 2) *
					CFrame.Angles(0, spiralTime * 10, 0)
				
				head.Transparency = progress
			end
			
			head.Transparency = 1
		end)
		
		-- Disable any GUIs
		for _, gui in pairs(head:GetDescendants()) do
			if gui:IsA("SurfaceGui") or gui:IsA("BillboardGui") then
				gui.Enabled = false
			end
		end
	end

	-- Update visibility for newly unlocked buttons with delay for dramatic effect
	task.wait(0.5)
	updateButtonVisibility()
	
	-- Play unlock sound for new buttons
	playSound(workspace, 421058925, true) -- Achievement sound
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

-- Handle dev product purchases properly
MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Find button with this dev product
	for _, button in ipairs(buttons:GetChildren()) do
		local devProduct = button:FindFirstChild("DevProduct")
		if devProduct and devProduct.Value == receiptInfo.ProductId then
			local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
			if playerStats then
				-- Create temp button for processPurchase
				local tempButton = {
					Price = {Value = 0}, -- Already paid
					Object = button.Object
				}
				processPurchase(tempButton, playerStats)
				return Enum.ProductPurchaseDecision.PurchaseGranted
			end
		end
	end

	return Enum.ProductPurchaseDecision.NotProcessedYet
end

-- Debug function to see button states
local function debugButtonStates()
	print("=== BUTTON VISIBILITY DEBUG ===")
	local buttons = script.Parent:WaitForChild("Buttons")
	
	for _, button in pairs(buttons:GetChildren()) do
		local head = button:FindFirstChild("Head")
		if head then
			local visible = head.Transparency == 0 and head.CanCollide
			local buttonNum = button.Name:match("%d+")
			local status = visible and "VISIBLE" or "HIDDEN"
			
			if visible then
				print("Button " .. button.Name .. " is " .. status)
				if buttonNum and PROGRESSION_DATA[buttonNum] then
					local data = PROGRESSION_DATA[buttonNum]
					if data.requires then
						print("  Requires: " .. table.concat(data.requires, ", "))
					end
				end
			end
		end
	end
	print("===============================")
end

-- Call debug after initial setup
task.wait(2)
debugButtonStates()

print("✅ ULTRA POLISHED Purchase Handler loaded! 🧃 Maximum juice activated!")