--[[
	Cinnamoroll Dropper 13 - ULTIMATE Magical Orb Style
	Drops legendary Cinnamoroll magical orbs
	NO CLEANUP - Orbs stay until collected
--]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local PhysicsService = game:GetService("PhysicsService")

-- Wait for PartStorage
task.wait(2)
local PartStorage = workspace:WaitForChild("PartStorage")

-- Find the Drop part
local dropPart = script.Parent:WaitForChild("Drop")

-- Create collision groups
local ORB_GROUP = "CinnamorollOrbs"
local PLAYER_GROUP = "Players"

pcall(function()
	PhysicsService:RegisterCollisionGroup(ORB_GROUP)
	PhysicsService:RegisterCollisionGroup(PLAYER_GROUP)
	PhysicsService:CollisionGroupSetCollidable(ORB_GROUP, PLAYER_GROUP, false)
	PhysicsService:CollisionGroupSetCollidable(ORB_GROUP, ORB_GROUP, false)
end)

-- Setup player collision groups
local function setupPlayer(character)
	task.wait(0.1)
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			pcall(function()
				part.CollisionGroup = PLAYER_GROUP
			end)
		end
	end
end

game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(setupPlayer)
end)

for _, player in ipairs(game.Players:GetPlayers()) do
	if player.Character then
		setupPlayer(player.Character)
	end
end

-- Ultimate effects
local masterHue = 0
local dropCount = 0

while true do
	task.wait(1.5) -- Drop rate
	dropCount = dropCount + 1
	
	-- Create LEGENDARY orb
	local orb = Instance.new("Part")
	orb.Name = "LegendaryMagicalOrb"
	orb.Shape = Enum.PartType.Ball
	orb.Size = Vector3.new(1.8, 1.8, 1.8)
	orb.Material = Enum.Material.ForceField
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	
	-- Cinnamoroll signature colors
	masterHue = (masterHue + 20) % 360
	local primaryColor = Color3.fromHSV(0.55, 0.3, 1) -- Soft blue base
	local accentColor = Color3.fromHSV((masterHue/360), 0.2, 1) -- Shifting pastels
	orb.Color = primaryColor
	
	-- Collision settings
	orb.CanCollide = true
	orb.CanTouch = true
	orb.CanQuery = true
	
	-- Set collision group
	pcall(function()
		orb.CollisionGroup = ORB_GROUP
	end)
	
	-- Magical physics
	orb.CustomPhysicalProperties = PhysicalProperties.new(
		0.1,  -- Ultra light
		0.5,  -- Medium friction
		0.5,  -- Magical bounce
		1, 1
	)
	
	-- Cash value (ULTIMATE!)
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 100
	cash.Parent = orb
	
	-- ULTIMATE magical glow
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 1
	pointLight.Range = 12
	pointLight.Color = primaryColor
	pointLight.Parent = orb
	
	-- Triple magical sphere layers
	for i = 1, 3 do
		local sphere = Instance.new("SelectionSphere")
		sphere.Adornee = orb
		sphere.Color3 = Color3.fromHSV((0.55 + i*0.1) % 1, 0.3 - i*0.1, 1)
		sphere.SurfaceTransparency = 1
		sphere.Transparency = 0.3 + (i * 0.2)
		sphere.Parent = orb
	end
	
	-- Cinnamoroll ear attachments
	local leftEar = Instance.new("Attachment")
	leftEar.Position = Vector3.new(-0.6, 0.7, 0)
	leftEar.Parent = orb
	
	local rightEar = Instance.new("Attachment")
	rightEar.Position = Vector3.new(0.6, 0.7, 0)
	rightEar.Parent = orb
	
	-- Magical ear particles
	for _, ear in pairs({leftEar, rightEar}) do
		local magic = Instance.new("ParticleEmitter")
		magic.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		magic.Rate = 20
		magic.Lifetime = NumberRange.new(0.5, 1)
		magic.Speed = NumberRange.new(1, 2)
		magic.SpreadAngle = Vector2.new(45, 45)
		magic.Size = NumberSequence.new(0.3)
		magic.Color = ColorSequence.new(Color3.fromRGB(173, 216, 230)) -- Light blue
		magic.LightEmission = 1
		magic.Parent = ear
	end
	
	-- ULTIMATE particle system
	local stars = Instance.new("ParticleEmitter")
	stars.Texture = "rbxasset://textures/particles/star.dds"
	stars.Rate = 30
	stars.Lifetime = NumberRange.new(1, 2)
	stars.Speed = NumberRange.new(2, 4)
	stars.SpreadAngle = Vector2.new(360, 360)
	stars.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.5, 0.7),
		NumberSequenceKeypoint.new(1, 0)
	}
	stars.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 250, 250)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(173, 216, 230)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 192, 203))
	}
	stars.LightEmission = 1
	stars.VelocityInheritance = 0.3
	stars.Parent = orb
	
	-- Hearts and clouds
	local hearts = Instance.new("ParticleEmitter")
	hearts.Texture = "rbxasset://textures/particles/heart.dds"
	hearts.Rate = 5
	hearts.Lifetime = NumberRange.new(2, 3)
	hearts.Speed = NumberRange.new(1)
	hearts.SpreadAngle = Vector2.new(180, 180)
	hearts.Size = NumberSequence.new(0.4)
	hearts.Color = ColorSequence.new(Color3.fromRGB(255, 182, 193)) -- Light pink
	hearts.LightEmission = 0.8
	hearts.Parent = orb
	
	-- Magical trails
	local centerAttach = Instance.new("Attachment")
	centerAttach.Position = Vector3.new(0, 0, 0)
	centerAttach.Parent = orb
	
	-- Create swirling beam crown
	for i = 1, 6 do
		local angle = (i-1) * 60
		local attach = Instance.new("Attachment")
		attach.Position = Vector3.new(
			math.cos(math.rad(angle)) * 0.9,
			0,
			math.sin(math.rad(angle)) * 0.9
		)
		attach.Parent = orb
		
		local beam = Instance.new("Beam")
		beam.Attachment0 = centerAttach
		beam.Attachment1 = attach
		beam.Color = ColorSequence.new(Color3.fromHSV((0.55 + i*0.1) % 1, 0.3, 1))
		beam.Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(0.5, 0.3),
			NumberSequenceKeypoint.new(1, 0.8)
		}
		beam.Width0 = 0.3
		beam.Width1 = 0.1
		beam.FaceCamera = true
		beam.Parent = orb
	end
	
	-- LEGENDARY spawn position
	local spawnAngle = dropCount * 0.3
	local spawnRadius = 0.5
	orb.CFrame = dropPart.CFrame * CFrame.new(
		math.cos(spawnAngle) * spawnRadius,
		-5,
		math.sin(spawnAngle) * spawnRadius
	)
	
	-- Magical float
	orb.AssemblyLinearVelocity = Vector3.new(
		math.sin(spawnAngle) * 2,
		-8,
		math.cos(spawnAngle) * 2
	)
	orb.AssemblyAngularVelocity = Vector3.new(0, 3, 0)
	
	-- Parent to storage
	orb.Parent = PartStorage
	
	-- LEGENDARY spawn animation
	orb.Transparency = 1
	orb.Size = Vector3.new(0, 0, 0)
	
	-- Magical appearance
	local spawnEffect = Instance.new("ParticleEmitter")
	spawnEffect.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	spawnEffect.Rate = 0
	spawnEffect.Speed = NumberRange.new(5, 10)
	spawnEffect.SpreadAngle = Vector2.new(360, 360)
	spawnEffect.Lifetime = NumberRange.new(0.5)
	spawnEffect.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 2),
		NumberSequenceKeypoint.new(1, 0)
	}
	spawnEffect.Color = ColorSequence.new(Color3.fromRGB(173, 216, 230))
	spawnEffect.LightEmission = 1
	spawnEffect.Parent = orb
	spawnEffect:Emit(100)
	Debris:AddItem(spawnEffect, 1)
	
	-- Epic materialization
	TweenService:Create(orb,
		TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Transparency = 0, Size = Vector3.new(1.8, 1.8, 1.8)}
	):Play()
	
	-- MEGA flash
	pointLight.Brightness = 3
	pointLight.Range = 25
	TweenService:Create(pointLight,
		TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Brightness = 1, Range = 12}
	):Play()
	
	-- Continuous ULTIMATE animations
	task.spawn(function()
		local localHue = 0.55
		local pulseTime = 0
		while orb.Parent do
			-- Gentle color shift
			localHue = (localHue + 0.001) % 1
			local newColor = Color3.fromHSV(localHue, 0.3, 1)
			pointLight.Color = newColor
			
			-- Magical pulsing
			pulseTime = pulseTime + 0.05
			local pulse = math.sin(pulseTime) * 0.1 + 1
			orb.Size = Vector3.new(1.8 * pulse, 1.8 * pulse, 1.8 * pulse)
			pointLight.Brightness = 1 * pulse
			
			-- Slow magical rotation
			orb.AssemblyAngularVelocity = Vector3.new(
				math.sin(pulseTime * 0.5) * 2,
				3,
				math.cos(pulseTime * 0.5) * 2
			)
			
			task.wait(0.05)
		end
	end)
	
	-- Aura effect
	task.spawn(function()
		while orb.Parent do
			local aura = Instance.new("ParticleEmitter")
			aura.Texture = "rbxasset://textures/particles/smoke_main.dds"
			aura.Rate = 0
			aura.Speed = NumberRange.new(1)
			aura.SpreadAngle = Vector2.new(360, 360)
			aura.Lifetime = NumberRange.new(1)
			aura.Size = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 2),
				NumberSequenceKeypoint.new(1, 3)
			}
			aura.Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0.9),
				NumberSequenceKeypoint.new(1, 1)
			}
			aura.Color = ColorSequence.new(Color3.fromRGB(173, 216, 230))
			aura.VelocityInheritance = 0
			aura.Parent = orb
			aura:Emit(5)
			Debris:AddItem(aura, 2)
			task.wait(1)
		end
	end)
	
	-- NO CLEANUP - LEGENDARY orbs stay until collected!
end