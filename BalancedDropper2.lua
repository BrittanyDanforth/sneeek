--[[
	Balanced Dropper v2 - Mid Tier ($15)
	Enhanced visuals, solid collision, good speed
--]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local PartStorage = workspace:WaitForChild("PartStorage")

-- Configuration
local DROP_RATE = 1
local DROP_VALUE = 15
local DROP_LIFETIME = 22

-- Colors
local COLORS = {
	Color3.fromRGB(135, 206, 250), -- Light sky blue
	Color3.fromRGB(100, 149, 237), -- Cornflower blue
}

local offsetIndex = 1
local offsets = {
	Vector3.new(0.3, 0, 0.3),
	Vector3.new(-0.3, 0, 0.3),
	Vector3.new(0.3, 0, -0.3),
	Vector3.new(-0.3, 0, -0.3),
	Vector3.new(0, 0, 0),
}

local function createOrb()
	local orb = Instance.new("Part")
	orb.Name = "CashOrb"
	orb.Shape = Enum.PartType.Ball
	orb.Material = Enum.Material.Neon
	orb.Size = Vector3.new(1.6, 1.6, 1.6)
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	orb.Color = COLORS[math.random(1, #COLORS)]
	orb.Transparency = 0.1
	
	-- Solid collision
	orb.CanCollide = true
	orb.CanTouch = true
	orb.CanQuery = true
	
	-- Better physics
	orb.CustomPhysicalProperties = PhysicalProperties.new(
		0.6,  -- Lighter than default
		0.4,  -- Medium friction
		0.25, -- Some bounce
		1,
		1
	)
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = DROP_VALUE
	cash.Parent = orb
	
	-- Enhanced glow
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 2
	pointLight.Range = 8
	pointLight.Color = orb.Color
	pointLight.Parent = orb
	
	-- Outer glow effect
	local glowPart = Instance.new("Part")
	glowPart.Name = "Glow"
	glowPart.Shape = Enum.PartType.Ball
	glowPart.Material = Enum.Material.ForceField
	glowPart.Size = Vector3.new(2, 2, 2)
	glowPart.Color = orb.Color
	glowPart.Transparency = 0.75
	glowPart.CanCollide = false
	glowPart.Massless = true
	glowPart.Parent = orb
	
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = orb
	weld.Part1 = glowPart
	weld.Parent = orb
	
	-- Better particles
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkle.Rate = 10
	sparkle.Lifetime = NumberRange.new(0.5, 1)
	sparkle.Speed = NumberRange.new(1, 2)
	sparkle.LightEmission = 1
	sparkle.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 0)
	}
	sparkle.Color = ColorSequence.new(orb.Color)
	sparkle.Parent = orb
	
	-- Smart positioning
	local dropPart = script.Parent:WaitForChild("Drop")
	local offset = offsets[offsetIndex]
	offsetIndex = (offsetIndex % #offsets) + 1
	
	orb.CFrame = dropPart.CFrame - Vector3.new(0, 1.7, 0) + offset
	
	-- Good drop velocity
	orb.AssemblyLinearVelocity = Vector3.new(
		offset.X * 3,
		-18,
		offset.Z * 3
	)
	
	-- Add spin
	local spin = Instance.new("BodyAngularVelocity")
	spin.AngularVelocity = Vector3.new(0, 5, 0)
	spin.MaxTorque = Vector3.new(0, math.huge, 0)
	spin.Parent = orb
	
	-- Remove spin after landing
	task.delay(0.8, function()
		if spin.Parent then
			spin:Destroy()
		end
	end)
	
	-- Set spawn time
	orb:SetAttribute("SpawnTime", tick())
	
	-- Parent to storage
	orb.Parent = PartStorage
	
	-- Bounce spawn
	orb.Size = Vector3.new(0.4, 0.4, 0.4)
	glowPart.Size = Vector3.new(0.5, 0.5, 0.5)
	
	TweenService:Create(orb,
		TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{Size = Vector3.new(1.6, 1.6, 1.6)}
	):Play()
	
	TweenService:Create(glowPart,
		TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{Size = Vector3.new(2, 2, 2)}
	):Play()
	
	-- Pulse glow
	task.spawn(function()
		while orb.Parent and glowPart.Parent do
			TweenService:Create(glowPart,
				TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Size = Vector3.new(2.2, 2.2, 2.2), Transparency = 0.8}
			):Play()
			task.wait(1)
			if not glowPart.Parent then break end
			TweenService:Create(glowPart,
				TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Size = Vector3.new(2, 2, 2), Transparency = 0.75}
			):Play()
			task.wait(1)
		end
	end)
	
	-- Cleanup
	Debris:AddItem(orb, DROP_LIFETIME)
	
	-- Fade out
	task.delay(DROP_LIFETIME - 3, function()
		if orb.Parent then
			sparkle.Enabled = false
			TweenService:Create(orb,
				TweenInfo.new(3, Enum.EasingStyle.Quad),
				{Transparency = 0.7}
			):Play()
			TweenService:Create(pointLight,
				TweenInfo.new(3, Enum.EasingStyle.Linear),
				{Brightness = 0}
			):Play()
		end
	end)
end

-- Main loop
while true do
	createOrb()
	task.wait(DROP_RATE)
end