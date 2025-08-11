--[[
	Modern Cinnamoroll Dropper v1 - Basic Tier
	Creates cute blue orbs with glow effects and anti-stacking physics
--]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

-- Wait for PartStorage
local PartStorage = workspace:WaitForChild("PartStorage")

-- Configuration
local DROP_RATE = 1.2 -- Seconds between drops
local DROP_VALUE = 10 -- Cash value
local DROP_LIFETIME = 25 -- Seconds before despawn
local ORB_SIZE = Vector3.new(1.4, 1.4, 1.4) -- Spherical orb

-- Cinnamoroll theme colors
local COLORS = {
	Color3.fromRGB(173, 216, 230), -- Light blue (main)
	Color3.fromRGB(135, 206, 235), -- Sky blue
	Color3.fromRGB(176, 224, 230), -- Powder blue
	Color3.fromRGB(175, 238, 238), -- Pale turquoise
}

-- Anti-stacking offset patterns
local OFFSET_PATTERNS = {
	Vector3.new(0.3, 0, 0.3),
	Vector3.new(-0.3, 0, 0.3),
	Vector3.new(0.3, 0, -0.3),
	Vector3.new(-0.3, 0, -0.3),
	Vector3.new(0, 0, 0),
}
local offsetIndex = 1

-- Create orb with effects
local function createOrb()
	-- Main orb part
	local orb = Instance.new("Part")
	orb.Name = "CinnamorollOrb"
	orb.Shape = Enum.PartType.Ball
	orb.Material = Enum.Material.ForceField
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	orb.Size = ORB_SIZE
	orb.Color = COLORS[math.random(1, #COLORS)]
	orb.Transparency = 0.2
	
	-- Physics properties (anti-stacking)
	orb.CustomPhysicalProperties = PhysicalProperties.new(
		0.7, -- Density (lighter)
		0.5, -- Friction
		0.2, -- Elasticity (bouncy)
		1,   -- ElasticityWeight
		1    -- FrictionWeight
	)
	
	-- Add glow effect
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 2
	pointLight.Range = 6
	pointLight.Color = orb.Color
	pointLight.Parent = orb
	
	-- Add selection box for outline
	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Color3 = Color3.new(1, 1, 1)
	selectionBox.Transparency = 0.7
	selectionBox.LineThickness = 0.05
	selectionBox.Adornee = orb
	selectionBox.Parent = orb
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = DROP_VALUE
	cash.Parent = orb
	
	-- Sparkle effect
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkle.Rate = 10
	sparkle.Lifetime = NumberRange.new(0.5, 1)
	sparkle.SpreadAngle = Vector2.new(180, 180)
	sparkle.VelocityInheritance = 0
	sparkle.Speed = NumberRange.new(1, 2)
	sparkle.LightEmission = 1
	sparkle.LightInfluence = 0
	sparkle.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.5, 0.4),
		NumberSequenceKeypoint.new(1, 0)
	})
	sparkle.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(1, 1)
	})
	sparkle.Color = ColorSequence.new(orb.Color)
	sparkle.Parent = orb
	
	-- Position with anti-stacking offset
	local dropPart = script.Parent:WaitForChild("Drop")
	local offset = OFFSET_PATTERNS[offsetIndex]
	offsetIndex = (offsetIndex % #OFFSET_PATTERNS) + 1
	
	orb.CFrame = dropPart.CFrame - Vector3.new(0, 1.5, 0) + offset
	
	-- Add slight random velocity to prevent perfect stacking
	orb.AssemblyLinearVelocity = Vector3.new(
		math.random(-3, 3),
		-5,
		math.random(-3, 3)
	)
	
	-- Add rotation for visual appeal
	local spin = Instance.new("BodyAngularVelocity")
	spin.AngularVelocity = Vector3.new(0, 5, 0)
	spin.MaxTorque = Vector3.new(0, math.huge, 0)
	spin.Parent = orb
	
	-- Spawn effect
	orb.Parent = PartStorage
	
	-- Entrance animation
	local entranceTween = TweenService:Create(orb,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = ORB_SIZE * 1.2}
	)
	entranceTween:Play()
	entranceTween.Completed:Connect(function()
		TweenService:Create(orb,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad),
			{Size = ORB_SIZE}
		):Play()
	end)
	
	-- Set spawn time for cleanup
	orb:SetAttribute("SpawnTime", tick())
	
	-- Cleanup
	Debris:AddItem(orb, DROP_LIFETIME)
	
	-- Fade out before despawn
	task.delay(DROP_LIFETIME - 2, function()
		if orb.Parent then
			TweenService:Create(orb,
				TweenInfo.new(2, Enum.EasingStyle.Linear),
				{Transparency = 1}
			):Play()
			TweenService:Create(pointLight,
				TweenInfo.new(2, Enum.EasingStyle.Linear),
				{Brightness = 0}
			):Play()
		end
	end)
end

-- Main dropper loop
while true do
	createOrb()
	task.wait(DROP_RATE)
end