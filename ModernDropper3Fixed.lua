--[[
	Modern Cinnamoroll Dropper v3 - Premium Tier (FIXED)
	Creates premium glowing orbs with rainbow effects and advanced physics
--]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

-- Wait for PartStorage
local PartStorage = workspace:WaitForChild("PartStorage")

-- Configuration
local DROP_RATE = 0.8 -- Fastest drops
local DROP_VALUE = 30 -- Highest value
local DROP_LIFETIME = 30 -- Longer lifetime
local ORB_SIZE = Vector3.new(1.8, 1.8, 1.8) -- Largest size

-- Premium Cinnamoroll rainbow colors
local RAINBOW_COLORS = {
	Color3.fromRGB(135, 206, 250), -- Sky blue
	Color3.fromRGB(221, 160, 221), -- Plum
	Color3.fromRGB(255, 182, 193), -- Light pink
	Color3.fromRGB(176, 224, 230), -- Powder blue
	Color3.fromRGB(255, 218, 185), -- Peach
	Color3.fromRGB(230, 230, 250), -- Lavender
}

-- Advanced anti-stacking system
local lastDropPositions = {}
local MAX_POSITION_MEMORY = 5

local function getSmartOffset()
	local baseOffset = Vector3.new(
		math.random(-10, 10) * 0.1,
		0,
		math.random(-10, 10) * 0.1
	)
	
	-- Check against recent positions
	for _, pos in ipairs(lastDropPositions) do
		local dist = (baseOffset - pos).Magnitude
		if dist < 0.5 then
			-- Too close, recalculate
			baseOffset = baseOffset + Vector3.new(
				math.random(-5, 5) * 0.2,
				0,
				math.random(-5, 5) * 0.2
			)
		end
	end
	
	-- Remember this position
	table.insert(lastDropPositions, baseOffset)
	if #lastDropPositions > MAX_POSITION_MEMORY then
		table.remove(lastDropPositions, 1)
	end
	
	return baseOffset
end

-- Create premium orb
local function createPremiumOrb()
	-- Main orb
	local orb = Instance.new("Part")
	orb.Name = "CinnamorollOrbPremium"
	orb.Shape = Enum.PartType.Ball
	orb.Material = Enum.Material.ForceField
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	orb.Size = ORB_SIZE
	orb.Transparency = 0
	
	-- Anti-stack physics
	orb.CustomPhysicalProperties = PhysicalProperties.new(
		0.5, -- Very light
		0.3, -- Low friction
		0.4, -- Very bouncy
		1,
		1
	)
	
	-- Inner core
	local core = Instance.new("Part")
	core.Name = "Core"
	core.Shape = Enum.PartType.Ball
	core.Material = Enum.Material.Neon
	core.Size = ORB_SIZE * 0.7
	core.Color = Color3.fromRGB(255, 255, 255)
	core.Transparency = 0.3
	core.CanCollide = false
	core.Massless = true
	core.Parent = orb
	
	local coreWeld = Instance.new("WeldConstraint")
	coreWeld.Part0 = orb
	coreWeld.Part1 = core
	coreWeld.Parent = orb
	
	-- Premium lighting
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 4
	pointLight.Range = 12
	pointLight.Color = Color3.fromRGB(255, 255, 255)
	pointLight.Parent = core
	
	-- Outer aura
	local aura = Instance.new("Part")
	aura.Name = "Aura"
	aura.Shape = Enum.PartType.Ball
	aura.Material = Enum.Material.ForceField
	aura.Size = ORB_SIZE * 1.5
	aura.Color = RAINBOW_COLORS[1]
	aura.Transparency = 0.8
	aura.CanCollide = false
	aura.Massless = true
	aura.Parent = orb
	
	local auraWeld = Instance.new("WeldConstraint")
	auraWeld.Part0 = orb
	auraWeld.Part1 = aura
	auraWeld.Parent = orb
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = DROP_VALUE
	cash.Parent = orb
	
	-- Premium particles
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkle.Rate = 30
	sparkle.Lifetime = NumberRange.new(1, 2)
	sparkle.SpreadAngle = Vector2.new(360, 360)
	sparkle.VelocityInheritance = 0.2
	sparkle.Speed = NumberRange.new(3, 6)
	sparkle.LightEmission = 1
	sparkle.LightInfluence = 0
	sparkle.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.5, 0.8),
		NumberSequenceKeypoint.new(1, 0)
	})
	sparkle.Color = ColorSequence.new(RAINBOW_COLORS[1]) -- Initial color
	sparkle.Parent = orb
	
	-- Star particles
	local stars = Instance.new("ParticleEmitter")
	stars.Texture = "rbxasset://textures/particles/star.png"
	stars.Rate = 5
	stars.Lifetime = NumberRange.new(2, 3)
	stars.SpreadAngle = Vector2.new(360, 360)
	stars.Speed = NumberRange.new(1, 2)
	stars.LightEmission = 1
	stars.Size = NumberSequence.new(0.5)
	stars.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	stars.Parent = core
	
	-- Multiple trails
	for i = 1, 3 do
		local a0 = Instance.new("Attachment")
		a0.Position = Vector3.new(0, -ORB_SIZE.Y/2, 0) * (1 - i * 0.2)
		a0.Parent = orb
		
		local a1 = Instance.new("Attachment")
		a1.Position = Vector3.new(0, ORB_SIZE.Y/2, 0) * (1 - i * 0.2)
		a1.Parent = orb
		
		local trail = Instance.new("Trail")
		trail.Attachment0 = a0
		trail.Attachment1 = a1
		trail.Lifetime = 0.5
		trail.FaceCamera = true
		trail.Color = ColorSequence.new(RAINBOW_COLORS[1]) -- Initial color
		trail.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3 + i * 0.2),
			NumberSequenceKeypoint.new(1, 1)
		})
		trail.Parent = orb
	end
	
	-- Position with smart offset
	local dropPart = script.Parent:WaitForChild("Drop")
	local offset = getSmartOffset()
	orb.CFrame = dropPart.CFrame - Vector3.new(0, 1.5, 0) + offset
	
	-- Burst velocity
	local angle = math.random() * math.pi * 2
	orb.AssemblyLinearVelocity = Vector3.new(
		math.cos(angle) * 6,
		math.random(-2, 2),
		math.sin(angle) * 6
	)
	
	-- Complex rotation
	local bodyVel = Instance.new("BodyVelocity")
	bodyVel.MaxForce = Vector3.new(0, math.huge, 0)
	bodyVel.Velocity = Vector3.new(0, -10, 0)
	bodyVel.Parent = orb
	
	local spin = Instance.new("BodyAngularVelocity")
	spin.AngularVelocity = Vector3.new(
		math.random(-5, 5),
		math.random(5, 10),
		math.random(-5, 5)
	)
	spin.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	spin.Parent = orb
	
	-- Spawn
	orb.Parent = PartStorage
	
	-- Grand entrance
	orb.Size = Vector3.new(0.1, 0.1, 0.1)
	core.Size = Vector3.new(0.1, 0.1, 0.1)
	aura.Size = Vector3.new(0.1, 0.1, 0.1)
	
	TweenService:Create(orb,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = ORB_SIZE}
	):Play()
	
	TweenService:Create(core,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = ORB_SIZE * 0.7}
	):Play()
	
	TweenService:Create(aura,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = ORB_SIZE * 1.5}
	):Play()
	
	-- Rainbow animation
	task.spawn(function()
		local colorIndex = 1
		while orb.Parent do
			local nextColor = RAINBOW_COLORS[colorIndex]
			colorIndex = (colorIndex % #RAINBOW_COLORS) + 1
			
			-- Tween the part colors
			TweenService:Create(orb,
				TweenInfo.new(2, Enum.EasingStyle.Linear),
				{Color = nextColor}
			):Play()
			
			TweenService:Create(aura,
				TweenInfo.new(2, Enum.EasingStyle.Linear),
				{Color = nextColor}
			):Play()
			
			-- Update particle colors directly (can't tween ColorSequence)
			sparkle.Color = ColorSequence.new(nextColor)
			
			-- Update trail colors
			for _, trail in ipairs(orb:GetDescendants()) do
				if trail:IsA("Trail") then
					trail.Color = ColorSequence.new(nextColor)
				end
			end
			
			task.wait(2)
		end
	end)
	
	-- Pulse animation
	task.spawn(function()
		while orb.Parent do
			TweenService:Create(aura,
				TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Size = ORB_SIZE * 1.7, Transparency = 0.9}
			):Play()
			task.wait(1.5)
			TweenService:Create(aura,
				TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Size = ORB_SIZE * 1.5, Transparency = 0.8}
			):Play()
			task.wait(1.5)
		end
	end)
	
	-- Set spawn time
	orb:SetAttribute("SpawnTime", tick())
	
	-- Cleanup
	Debris:AddItem(orb, DROP_LIFETIME)
	
	-- Epic fade out
	task.delay(DROP_LIFETIME - 5, function()
		if orb.Parent then
			sparkle.Enabled = false
			stars.Enabled = false
			if bodyVel and bodyVel.Parent then
				bodyVel:Destroy()
			end
			
			-- Spiral up effect
			local floatUp = Instance.new("BodyPosition")
			floatUp.MaxForce = Vector3.new(0, math.huge, 0)
			floatUp.Position = orb.Position + Vector3.new(0, 20, 0)
			floatUp.Parent = orb
			
			TweenService:Create(orb,
				TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{Transparency = 1, Size = ORB_SIZE * 2}
			):Play()
			
			TweenService:Create(core,
				TweenInfo.new(5, Enum.EasingStyle.Quad),
				{Transparency = 1, Size = ORB_SIZE * 0.1}
			):Play()
			
			TweenService:Create(aura,
				TweenInfo.new(5, Enum.EasingStyle.Quad),
				{Transparency = 1, Size = ORB_SIZE * 3}
			):Play()
			
			TweenService:Create(pointLight,
				TweenInfo.new(5, Enum.EasingStyle.Linear),
				{Brightness = 0, Range = 0}
			):Play()
		end
	end)
end

-- Main premium dropper loop
while true do
	createPremiumOrb()
	task.wait(DROP_RATE)
end