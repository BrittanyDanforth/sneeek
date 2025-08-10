--[[
	Balanced Dropper v3 - Premium ($30)
	Best visuals without lag, proper physics
--]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local PartStorage = workspace:WaitForChild("PartStorage")

-- Configuration
local DROP_RATE = 0.8
local DROP_VALUE = 30
local DROP_LIFETIME = 25

-- Premium colors
local COLORS = {
	Color3.fromRGB(135, 206, 250), -- Sky blue
	Color3.fromRGB(147, 197, 253), -- Light blue
	Color3.fromRGB(173, 216, 230), -- Powder blue
}

-- Smart offset system
local lastPositions = {}
local MAX_MEMORY = 3

local function getSmartOffset()
	local offset = Vector3.new(
		math.random(-5, 5) * 0.15,
		0,
		math.random(-5, 5) * 0.15
	)
	
	-- Check recent positions
	for _, pos in ipairs(lastPositions) do
		if (offset - pos).Magnitude < 0.3 then
			offset = offset + Vector3.new(
				math.random(-2, 2) * 0.2,
				0,
				math.random(-2, 2) * 0.2
			)
		end
	end
	
	table.insert(lastPositions, offset)
	if #lastPositions > MAX_MEMORY then
		table.remove(lastPositions, 1)
	end
	
	return offset
end

local function createOrb()
	local orb = Instance.new("Part")
	orb.Name = "CashOrb"
	orb.Shape = Enum.PartType.Ball
	orb.Material = Enum.Material.Neon
	orb.Size = Vector3.new(1.8, 1.8, 1.8)
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	orb.Color = COLORS[math.random(1, #COLORS)]
	orb.Transparency = 0.05
	
	-- Solid collision - can't phase through
	orb.CanCollide = true
	orb.CanTouch = true
	orb.CanQuery = true
	
	-- Premium physics
	orb.CustomPhysicalProperties = PhysicalProperties.new(
		0.5,  -- Light but not too light
		0.35, -- Good friction
		0.3,  -- Nice bounce
		1,
		1
	)
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = DROP_VALUE
	cash.Parent = orb
	
	-- Premium lighting
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 2.5
	pointLight.Range = 10
	pointLight.Color = orb.Color
	pointLight.Parent = orb
	
	-- Inner core glow
	local core = Instance.new("Part")
	core.Name = "Core"
	core.Shape = Enum.PartType.Ball
	core.Material = Enum.Material.Neon
	core.Size = Vector3.new(1.2, 1.2, 1.2)
	core.Color = Color3.fromRGB(255, 255, 255)
	core.Transparency = 0.5
	core.CanCollide = false
	core.Massless = true
	core.Parent = orb
	
	local coreWeld = Instance.new("WeldConstraint")
	coreWeld.Part0 = orb
	coreWeld.Part1 = core
	coreWeld.Parent = orb
	
	-- Premium particles
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkle.Rate = 15
	sparkle.Lifetime = NumberRange.new(0.8, 1.5)
	sparkle.Speed = NumberRange.new(1, 3)
	sparkle.LightEmission = 1
	sparkle.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.4),
		NumberSequenceKeypoint.new(1, 0)
	}
	sparkle.Color = ColorSequence.new(orb.Color)
	sparkle.SpreadAngle = Vector2.new(360, 360)
	sparkle.VelocityInheritance = 0.1
	sparkle.Parent = orb
	
	-- Simple trail
	local attachment1 = Instance.new("Attachment")
	attachment1.Position = Vector3.new(0, -0.9, 0)
	attachment1.Parent = orb
	
	local attachment2 = Instance.new("Attachment")
	attachment2.Position = Vector3.new(0, 0.9, 0)
	attachment2.Parent = orb
	
	local trail = Instance.new("Trail")
	trail.Attachment0 = attachment1
	trail.Attachment1 = attachment2
	trail.Lifetime = 0.3
	trail.FaceCamera = true
	trail.Color = ColorSequence.new(orb.Color)
	trail.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	}
	trail.Parent = orb
	
	-- Smart positioning
	local dropPart = script.Parent:WaitForChild("Drop")
	local offset = getSmartOffset()
	orb.CFrame = dropPart.CFrame - Vector3.new(0, 1.7, 0) + offset
	
	-- Premium velocity
	local angle = math.random() * math.pi * 2
	orb.AssemblyLinearVelocity = Vector3.new(
		math.cos(angle) * 4,
		-20,
		math.sin(angle) * 4
	)
	
	-- Controlled spin
	local spin = Instance.new("BodyAngularVelocity")
	spin.AngularVelocity = Vector3.new(
		math.random(-2, 2),
		math.random(3, 6),
		math.random(-2, 2)
	)
	spin.MaxTorque = Vector3.new(4000, 4000, 4000)
	spin.Parent = orb
	
	-- Remove spin after landing
	task.delay(1, function()
		if spin.Parent then
			spin:Destroy()
		end
	end)
	
	-- Set spawn time
	orb:SetAttribute("SpawnTime", tick())
	
	-- Parent to storage
	orb.Parent = PartStorage
	
	-- Premium entrance
	orb.Size = Vector3.new(0.3, 0.3, 0.3)
	core.Size = Vector3.new(0.2, 0.2, 0.2)
	
	TweenService:Create(orb,
		TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = Vector3.new(1.8, 1.8, 1.8)}
	):Play()
	
	TweenService:Create(core,
		TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = Vector3.new(1.2, 1.2, 1.2)}
	):Play()
	
	-- Core pulse
	task.spawn(function()
		while orb.Parent and core.Parent do
			TweenService:Create(core,
				TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Size = Vector3.new(1.3, 1.3, 1.3), Transparency = 0.6}
			):Play()
			task.wait(1.5)
			if not core.Parent then break end
			TweenService:Create(core,
				TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Size = Vector3.new(1.2, 1.2, 1.2), Transparency = 0.5}
			):Play()
			task.wait(1.5)
		end
	end)
	
	-- Cleanup
	Debris:AddItem(orb, DROP_LIFETIME)
	
	-- Premium fade out
	task.delay(DROP_LIFETIME - 4, function()
		if orb.Parent then
			sparkle.Enabled = false
			trail.Enabled = false
			
			TweenService:Create(orb,
				TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{Transparency = 0.8, Size = Vector3.new(1.5, 1.5, 1.5)}
			):Play()
			
			TweenService:Create(core,
				TweenInfo.new(4, Enum.EasingStyle.Quad),
				{Transparency = 1, Size = Vector3.new(0.5, 0.5, 0.5)}
			):Play()
			
			TweenService:Create(pointLight,
				TweenInfo.new(4, Enum.EasingStyle.Linear),
				{Brightness = 0, Range = 0}
			):Play()
		end
	end)
end

-- Main loop
while true do
	createOrb()
	task.wait(DROP_RATE)
end