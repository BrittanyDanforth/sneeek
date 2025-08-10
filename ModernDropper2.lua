--[[
	Modern Cinnamoroll Dropper v2 - Mid Tier
	Creates glowing blue orbs with trails and enhanced effects
--]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

-- Wait for PartStorage
local PartStorage = workspace:WaitForChild("PartStorage")

-- Configuration
local DROP_RATE = 1 -- Slightly faster drops
local DROP_VALUE = 15 -- Higher cash value
local DROP_LIFETIME = 25 -- Seconds before despawn
local ORB_SIZE = Vector3.new(1.6, 1.6, 1.6) -- Slightly larger

-- Enhanced Cinnamoroll colors
local COLORS = {
	Color3.fromRGB(135, 206, 250), -- Light sky blue
	Color3.fromRGB(100, 149, 237), -- Cornflower blue
	Color3.fromRGB(176, 196, 222), -- Light steel blue
}

-- Anti-stacking with more variation
local function getRandomOffset()
	return Vector3.new(
		math.random(-5, 5) * 0.1,
		0,
		math.random(-5, 5) * 0.1
	)
end

-- Create enhanced orb
local function createEnhancedOrb()
	-- Main orb part
	local orb = Instance.new("Part")
	orb.Name = "CinnamorollOrbPlus"
	orb.Shape = Enum.PartType.Ball
	orb.Material = Enum.Material.Neon
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	orb.Size = ORB_SIZE
	orb.Color = COLORS[math.random(1, #COLORS)]
	orb.Transparency = 0.1
	
	-- Better physics
	orb.CustomPhysicalProperties = PhysicalProperties.new(
		0.6, -- Less dense
		0.4, -- Less friction
		0.3, -- More bouncy
		1,
		1
	)
	
	-- Enhanced glow
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 3
	pointLight.Range = 8
	pointLight.Color = orb.Color
	pointLight.Parent = orb
	
	-- Outer glow part
	local glowPart = Instance.new("Part")
	glowPart.Name = "Glow"
	glowPart.Shape = Enum.PartType.Ball
	glowPart.Material = Enum.Material.ForceField
	glowPart.Size = ORB_SIZE * 1.3
	glowPart.Color = orb.Color
	glowPart.Transparency = 0.7
	glowPart.CanCollide = false
	glowPart.Massless = true
	glowPart.Parent = orb
	
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = orb
	weld.Part1 = glowPart
	weld.Parent = orb
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = DROP_VALUE
	cash.Parent = orb
	
	-- Enhanced particles
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkle.Rate = 20
	sparkle.Lifetime = NumberRange.new(0.5, 1.5)
	sparkle.SpreadAngle = Vector2.new(360, 360)
	sparkle.VelocityInheritance = 0.1
	sparkle.Speed = NumberRange.new(2, 4)
	sparkle.LightEmission = 1
	sparkle.LightInfluence = 0
	sparkle.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.5),
		NumberSequenceKeypoint.new(1, 0)
	})
	sparkle.Color = ColorSequence.new(orb.Color)
	sparkle.Parent = orb
	
	-- Trail effect
	local attachment0 = Instance.new("Attachment")
	attachment0.Position = Vector3.new(0, -ORB_SIZE.Y/2, 0)
	attachment0.Parent = orb
	
	local attachment1 = Instance.new("Attachment")
	attachment1.Position = Vector3.new(0, ORB_SIZE.Y/2, 0)
	attachment1.Parent = orb
	
	local trail = Instance.new("Trail")
	trail.Attachment0 = attachment0
	trail.Attachment1 = attachment1
	trail.Lifetime = 0.3
	trail.FaceCamera = true
	trail.Color = ColorSequence.new(orb.Color)
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	})
	trail.Parent = orb
	
	-- Position with offset
	local dropPart = script.Parent:WaitForChild("Drop")
	orb.CFrame = dropPart.CFrame - Vector3.new(0, 1.5, 0) + getRandomOffset()
	
	-- Random velocity
	orb.AssemblyLinearVelocity = Vector3.new(
		math.random(-4, 4),
		-3,
		math.random(-4, 4)
	)
	
	-- Spin effect
	local spin = Instance.new("BodyAngularVelocity")
	spin.AngularVelocity = Vector3.new(
		math.random(-3, 3),
		math.random(3, 8),
		math.random(-3, 3)
	)
	spin.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	spin.Parent = orb
	
	-- Spawn
	orb.Parent = PartStorage
	
	-- Bounce animation
	local bounceAnim = TweenService:Create(orb,
		TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{Size = ORB_SIZE}
	)
	orb.Size = ORB_SIZE * 0.5
	bounceAnim:Play()
	
	-- Pulse glow animation
	task.spawn(function()
		while orb.Parent do
			TweenService:Create(glowPart,
				TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Size = ORB_SIZE * 1.4, Transparency = 0.8}
			):Play()
			task.wait(1)
			TweenService:Create(glowPart,
				TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Size = ORB_SIZE * 1.3, Transparency = 0.7}
			):Play()
			task.wait(1)
		end
	end)
	
	-- Set spawn time
	orb:SetAttribute("SpawnTime", tick())
	
	-- Cleanup
	Debris:AddItem(orb, DROP_LIFETIME)
	
	-- Fade out effect
	task.delay(DROP_LIFETIME - 3, function()
		if orb.Parent then
			sparkle.Enabled = false
			TweenService:Create(orb,
				TweenInfo.new(3, Enum.EasingStyle.Quad),
				{Transparency = 1, Size = ORB_SIZE * 0.5}
			):Play()
			TweenService:Create(pointLight,
				TweenInfo.new(3, Enum.EasingStyle.Linear),
				{Brightness = 0, Range = 0}
			):Play()
		end
	end)
end

-- Main dropper loop
while true do
	createEnhancedOrb()
	task.wait(DROP_RATE)
end