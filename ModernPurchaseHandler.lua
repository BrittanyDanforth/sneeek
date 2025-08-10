--[[
	Ultra-Modern Purchase Handler (2025 Standards)
	Features: Smooth animations, magnet collection, visual effects, optimized performance
--]]

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get settings and references
local Settings = require(script.Parent.Parent.Parent.Settings)
local Objects = {}
local TeamColor = script.Parent:WaitForChild("TeamColor").Value
local Money = script.Parent:WaitForChild("CurrencyToCollect")
local Stealing = Settings.StealSettings
local CanSteal = true

-- Configuration
local MAGNET_RANGE = 15 -- Range for magnet effect
local COLLECTION_SPEED = 8 -- Speed of orb movement to collector
local FADE_TIME = 0.5 -- Time for orb to fade out
local FLOAT_TEXT_DURATION = 2 -- Duration of floating text
local PARTICLE_BURST_COUNT = 10 -- Particles on collection

-- Set spawn colors
local essentials = script.Parent:WaitForChild("Essentials")
local spawn = essentials:WaitForChild("Spawn")
spawn.TeamColor = TeamColor
spawn.BrickColor = TeamColor

-- Cache for performance
local collectedParts = {}
local activeOrbTweens = {}
local floatingTexts = {}

-- Create collection effects folder
local effectsFolder = workspace:FindFirstChild("TycoonEffects") or Instance.new("Folder")
effectsFolder.Name = "TycoonEffects"
effectsFolder.Parent = workspace

-- Modern sound function with pitch variation
local function playSound(part, soundId, pitchVariation)
	if part:FindFirstChild("Sound") then return end

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. tostring(soundId)
	sound.Volume = 0.5
	sound.PlaybackSpeed = pitchVariation and (0.9 + math.random() * 0.2) or 1
	sound.Parent = part

	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

-- Create floating text effect
local function createFloatingText(position, text, color)
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Size = UDim2.new(0, 100, 0, 50)
	billboardGui.StudsOffset = Vector3.new(0, 2, 0)
	billboardGui.AlwaysOnTop = true
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text
	textLabel.TextColor3 = color or Color3.new(0, 1, 0)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.SourceSansBold
	textLabel.Parent = billboardGui
	
	-- Add stroke for visibility
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.new(0, 0, 0)
	stroke.Thickness = 2
	stroke.Parent = textLabel
	
	-- Create attachment for position
	local part = Instance.new("Part")
	part.Size = Vector3.new(1, 1, 1)
	part.Position = position
	part.Transparency = 1
	part.CanCollide = false
	part.Anchored = true
	part.Parent = effectsFolder
	
	billboardGui.Parent = part
	
	-- Animate floating up and fading
	local startTime = tick()
	local connection
	connection = RunService.Heartbeat:Connect(function()
		local elapsed = tick() - startTime
		local progress = elapsed / FLOAT_TEXT_DURATION
		
		if progress >= 1 then
			connection:Disconnect()
			part:Destroy()
			return
		end
		
		-- Float up and fade
		part.Position = position + Vector3.new(0, 3 * progress, 0)
		textLabel.TextTransparency = progress
		stroke.Transparency = progress
	end)
end

-- Create particle burst effect
local function createParticleBurst(position, color)
	for i = 1, PARTICLE_BURST_COUNT do
		local particle = Instance.new("Part")
		particle.Size = Vector3.new(0.2, 0.2, 0.2)
		particle.Position = position
		particle.BrickColor = BrickColor.new(color or "Lime green")
		particle.Material = Enum.Material.Neon
		particle.CanCollide = false
		particle.Parent = effectsFolder
		
		-- Random velocity
		local velocity = Instance.new("BodyVelocity")
		velocity.MaxForce = Vector3.new(4000, 4000, 4000)
		velocity.Velocity = Vector3.new(
			math.random(-10, 10),
			math.random(5, 15),
			math.random(-10, 10)
		)
		velocity.Parent = particle
		
		-- Fade out
		TweenService:Create(particle, TweenInfo.new(0.5), {
			Transparency = 1,
			Size = Vector3.new(0.05, 0.05, 0.05)
		}):Play()
		
		Debris:AddItem(particle, 0.5)
	end
end

-- Smooth orb collection with magnet effect
local function collectOrb(orb, collector, cashValue)
	if collectedParts[orb] then return end
	collectedParts[orb] = true
	
	-- Stop any existing physics
	orb.Anchored = true
	orb.CanCollide = false
	orb.CanTouch = false
	orb.CanQuery = false
	
	-- Calculate collection point (center of collector)
	local targetPosition = collector.Position
	
	-- Create smooth movement to collector
	local moveTween = TweenService:Create(orb, 
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
		{
			Position = targetPosition,
			Size = orb.Size * 0.5
		}
	)
	
	-- Create fade effect
	local fadeTween = TweenService:Create(orb,
		TweenInfo.new(FADE_TIME, Enum.EasingStyle.Linear),
		{
			Transparency = 1
		}
	)
	
	-- Store tween reference
	activeOrbTweens[orb] = {moveTween, fadeTween}
	
	-- Play collection sound with pitch variation
	playSound(collector, Settings.Sounds.Collect, true)
	
	-- Start movement
	moveTween:Play()
	
	-- When orb reaches collector, trigger effects
	moveTween.Completed:Connect(function()
		-- Add money
		Money.Value = Money.Value + cashValue.Value
		
		-- Create visual effects
		createFloatingText(targetPosition, "+$" .. cashValue.Value, Color3.new(0, 1, 0))
		createParticleBurst(targetPosition)
		
		-- Start fade
		fadeTween:Play()
		
		-- Disable any effects on the orb
		for _, child in ipairs(orb:GetDescendants()) do
			if child:IsA("ParticleEmitter") then
				child.Enabled = false
			elseif child:IsA("PointLight") or child:IsA("SpotLight") then
				child.Enabled = false
			elseif child:IsA("Trail") then
				child.Enabled = false
			end
		end
	end)
	
	-- Clean up after fade
	fadeTween.Completed:Connect(function()
		activeOrbTweens[orb] = nil
		orb:Destroy()
		task.wait(1)
		collectedParts[orb] = nil
	end)
end

-- Set up part collectors with magnet effect
for _, collector in ipairs(essentials:GetChildren()) do
	if collector.Name == "PartCollector" then
		-- Make collector non-collidable
		collector.CanCollide = false
		collector.CanQuery = true
		collector.CanTouch = true
		
		-- Add visual indicator (optional)
		local selectionBox = Instance.new("SelectionBox")
		selectionBox.Color3 = Color3.new(0, 1, 0)
		selectionBox.Transparency = 0.8
		selectionBox.LineThickness = 0.05
		selectionBox.Adornee = collector
		selectionBox.Parent = collector
		
		-- Touch detection for close orbs
		collector.Touched:Connect(function(part)
			local cashValue = part:FindFirstChild("Cash")
			if cashValue and not collectedParts[part] then
				collectOrb(part, collector, cashValue)
			end
		end)
	end
end

-- Magnet effect system
local magnetConnections = {}
for _, collector in ipairs(essentials:GetChildren()) do
	if collector.Name == "PartCollector" then
		-- Create magnet effect
		local magnetConnection = RunService.Heartbeat:Connect(function()
			-- Find nearby orbs
			for _, part in ipairs(workspace:GetPartBoundsInRadius(collector.Position, MAGNET_RANGE)) do
				local cashValue = part:FindFirstChild("Cash")
				if cashValue and not collectedParts[part] and part.Parent then
					-- Calculate distance
					local distance = (part.Position - collector.Position).Magnitude
					
					if distance <= MAGNET_RANGE then
						-- Pull orb towards collector
						if not part.Anchored then
							local direction = (collector.Position - part.Position).Unit
							local pullStrength = (1 - distance / MAGNET_RANGE) * 50
							
							-- Apply force
							local bodyVelocity = part:FindFirstChild("MagnetVelocity")
							if not bodyVelocity then
								bodyVelocity = Instance.new("BodyVelocity")
								bodyVelocity.Name = "MagnetVelocity"
								bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
								bodyVelocity.Parent = part
							end
							bodyVelocity.Velocity = direction * pullStrength
						end
						
						-- Collect if very close
						if distance <= 3 then
							collectOrb(part, collector, cashValue)
						end
					end
				end
			end
		end)
		
		table.insert(magnetConnections, magnetConnection)
	end
end

-- Modern player collector with visual feedback
local collectorDebounce = {}
local giver = essentials:WaitForChild("Giver")

-- Add hover effect to giver
local giverSelection = Instance.new("SelectionBox")
giverSelection.Color3 = Color3.new(0, 1, 0)
giverSelection.Transparency = 0.9
giverSelection.LineThickness = 0.1
giverSelection.Adornee = giver
giverSelection.Parent = giver

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
		giverSelection.Color3 = Color3.new(1, 0, 0)
		
		-- Pulse effect
		local pulseTween = TweenService:Create(giver, 
			TweenInfo.new(0.2, Enum.EasingStyle.Elastic),
			{Size = giver.Size * 1.1}
		)
		pulseTween:Play()
		pulseTween.Completed:Connect(function()
			TweenService:Create(giver, TweenInfo.new(0.2), {Size = giver.Size / 1.1}):Play()
		end)

		local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
		if playerStats and Money.Value > 0 then
			playSound(giver, Settings.Sounds.Collect)
			
			-- Show collection amount
			createFloatingText(giver.Position + Vector3.new(0, 3, 0), 
				"+$" .. Money.Value, Color3.new(0, 1, 0))
			
			-- Create collection particles
			createParticleBurst(giver.Position, "Lime green")
			
			playerStats.Value = playerStats.Value + Money.Value
			Money.Value = 0
		end

		task.wait(1)
		giver.BrickColor = originalColor
		giverSelection.Color3 = Color3.new(0, 1, 0)
		collectorDebounce[player] = nil

	-- Stealing mechanic with visual feedback
	elseif Stealing.Stealing and CanSteal then
		CanSteal = false

		task.delay(Stealing.PlayerProtection, function()
			CanSteal = true
		end)

		local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
		if playerStats and Money.Value > 0 then
			local stealAmount = math.floor(Money.Value * Stealing.StealPrecent)
			if stealAmount > 0 then
				playSound(giver, Settings.Sounds.Collect)
				
				-- Show steal amount in red
				createFloatingText(giver.Position + Vector3.new(0, 3, 0), 
					"-$" .. stealAmount, Color3.new(1, 0, 0))
				
				-- Red particles for stealing
				createParticleBurst(giver.Position, "Really red")
				
				playerStats.Value = playerStats.Value + stealAmount
				Money.Value = Money.Value - stealAmount
			end
		end
	else
		playSound(giver, Settings.Sounds.ErrorBuy)
		
		-- Show error feedback
		createFloatingText(hit.Parent.HumanoidRootPart.Position + Vector3.new(0, 3, 0), 
			"Protected!", Color3.new(1, 0.5, 0))
	end
end)

-- Modern button setup with enhanced visuals
local buttons = script.Parent:WaitForChild("Buttons")
local purchases = script.Parent:WaitForChild("Purchases")
local purchasedObjects = script.Parent:WaitForChild("PurchasedObjects")

-- Enhanced tween settings
local fadeInInfo = TweenInfo.new(
	Settings.FadeInTime or 0.5,
	Enum.EasingStyle.Back,
	Enum.EasingDirection.Out
)

local fadeOutInfo = TweenInfo.new(
	Settings.FadeOutTime or 0.5,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.In
)

-- Button hover effects
local function addButtonEffects(button)
	local head = button:FindFirstChild("Head")
	if not head then return end
	
	-- Add selection box for hover effect
	local selection = Instance.new("SelectionBox")
	selection.Color3 = Color3.new(0, 0.5, 1)
	selection.Transparency = 0.8
	selection.LineThickness = 0.05
	selection.Adornee = head
	selection.Parent = head
	selection.Visible = false
	
	-- Price display
	local price = button:FindFirstChild("Price")
	if price then
		local billboard = Instance.new("BillboardGui")
		billboard.Size = UDim2.new(0, 200, 0, 50)
		billboard.StudsOffset = Vector3.new(0, 3, 0)
		billboard.AlwaysOnTop = false
		
		local priceLabel = Instance.new("TextLabel")
		priceLabel.Size = UDim2.new(1, 0, 1, 0)
		priceLabel.BackgroundTransparency = 1
		priceLabel.Text = "$" .. tostring(price.Value)
		priceLabel.TextColor3 = Color3.new(1, 1, 1)
		priceLabel.TextScaled = true
		priceLabel.Font = Enum.Font.SourceSansBold
		priceLabel.Parent = billboard
		
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.new(0, 0, 0)
		stroke.Thickness = 2
		stroke.Parent = priceLabel
		
		billboard.Parent = head
	end
	
	return selection
end

-- Process each button with enhanced features
for _, button in ipairs(buttons:GetChildren()) do
	task.spawn(function()
		local head = button:FindFirstChild("Head")
		if not head then return end

		-- Add visual effects
		local selection = addButtonEffects(button)

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

		-- Handle dependencies with smooth animation
		local dependency = button:FindFirstChild("Dependency")
		if dependency then
			head.CanCollide = false
			head.Transparency = 1

			-- Wait for dependency
			purchasedObjects:WaitForChild(dependency.Value)

			-- Fade in button with bounce effect
			if Settings.ButtonsFadeIn then
				head.Transparency = 0.99 -- Start nearly invisible
				local tween = TweenService:Create(head, fadeInInfo, {
					Transparency = 0,
					Size = head.Size * 1.1
				})
				tween:Play()
				tween.Completed:Connect(function()
					TweenService:Create(head, TweenInfo.new(0.1), {
						Size = head.Size / 1.1
					}):Play()
				end)
			else
				head.Transparency = 0
			end

			head.CanCollide = true
		end

		-- Handle button touches with enhanced feedback
		local purchaseDebounce = {}

		head.Touched:Connect(function(hit)
			if not head.CanCollide then return end

			local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
			if not humanoid or humanoid.Health <= 0 then return end

			local player = Players:GetPlayerFromCharacter(hit.Parent)
			if not player or player ~= script.Parent.Owner.Value then return end

			-- Show hover effect
			if selection then
				selection.Visible = true
				task.delay(0.5, function()
					if selection.Parent then
						selection.Visible = false
					end
				end)
			end

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

			-- Handle regular purchases with visual feedback
			local price = button:WaitForChild("Price").Value
			if playerStats.Value >= price then
				processPurchase(button, playerStats)
				playSound(head, Settings.Sounds.Purchase)
				
				-- Success effect
				createFloatingText(head.Position + Vector3.new(0, 2, 0), 
					"Purchased!", Color3.new(0, 1, 0))
			else
				playSound(head, Settings.Sounds.ErrorBuy)
				
				-- Error effect with shake
				createFloatingText(head.Position + Vector3.new(0, 2, 0), 
					"Need $" .. (price - playerStats.Value), Color3.new(1, 0, 0))
				
				-- Shake effect
				local originalCFrame = head.CFrame
				task.spawn(function()
					for i = 1, 10 do
						head.CFrame = originalCFrame * CFrame.new(
							math.random(-1, 1) * 0.1,
							0,
							math.random(-1, 1) * 0.1
						)
						task.wait(0.05)
					end
					head.CFrame = originalCFrame
				end)
			end
		end)
	end)
end

-- Enhanced purchase function with effects
function processPurchase(button, playerStats)
	local price = button.Price.Value
	local objectName = button.Object.Value

	-- Deduct cost and spawn object
	playerStats.Value = playerStats.Value - price

	if Objects[objectName] then
		local newObject = Objects[objectName]:Clone()
		newObject.Parent = purchasedObjects
		
		-- Add spawn effect to new object
		if newObject:IsA("Model") then
			local primary = newObject.PrimaryPart or newObject:FindFirstChildWhichIsA("BasePart")
			if primary then
				-- Spawn animation
				newObject:SetPrimaryPartCFrame(primary.CFrame + Vector3.new(0, 10, 0))
				TweenService:Create(primary, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), {
					CFrame = primary.CFrame - Vector3.new(0, 10, 0)
				}):Play()
				
				-- Particles on spawn
				createParticleBurst(primary.Position, "Bright blue")
			end
		end
	end

	-- Enhanced fade out button
	local head = button:FindFirstChild("Head")
	if head then
		head.CanCollide = false

		if Settings.ButtonsFadeOut then
			-- Shrink and fade
			local tween = TweenService:Create(head, fadeOutInfo, {
				Transparency = 1,
				Size = head.Size * 0.5
			})
			tween:Play()
			
			-- Particle effect on purchase
			createParticleBurst(head.Position, "Bright yellow")
		else
			head.Transparency = 1
		end
		
		-- Remove any UI elements
		for _, child in ipairs(head:GetChildren()) do
			if child:IsA("BillboardGui") or child:IsA("SelectionBox") then
				child:Destroy()
			end
		end
	end
end

-- Handle BuyObject folder with enhanced feedback
local buyObject = script.Parent:WaitForChild("BuyObject")

buyObject.ChildAdded:Connect(function(child)
	task.wait(0.1)

	local cost = child:FindFirstChild("Cost")
	local button = child:FindFirstChild("Button")
	local stats = child:FindFirstChild("Stats")

	if cost and button and stats then
		processPurchase(button.Value, stats.Value)
	end

	-- Clean up
	task.wait(10)
	if child.Parent then
		child:Destroy()
	end
end)

-- Enhanced gamepass purchase handling
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
	if not wasPurchased then return end

	-- Find the button for this gamepass
	for _, button in ipairs(buttons:GetChildren()) do
		local gamepass = button:FindFirstChild("Gamepass")
		if gamepass and gamepass.Value == gamePassId then
			local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
			if playerStats then
				processPurchase(button, playerStats)
				
				-- Celebration effect
				if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					createFloatingText(
						player.Character.HumanoidRootPart.Position + Vector3.new(0, 5, 0),
						"Gamepass Unlocked!",
						Color3.new(1, 0.8, 0)
					)
				end
			end
			break
		end
	end
end)

-- Cleanup on script removal
script.AncestryChanged:Connect(function()
	if not script.Parent then
		-- Disconnect all connections
		for _, connection in ipairs(magnetConnections) do
			connection:Disconnect()
		end
		
		-- Cancel all active tweens
		for orb, tweens in pairs(activeOrbTweens) do
			for _, tween in ipairs(tweens) do
				tween:Cancel()
			end
			if orb.Parent then
				orb:Destroy()
			end
		end
	end
end)