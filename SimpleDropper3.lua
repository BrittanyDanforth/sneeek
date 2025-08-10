--[[
	Simple Clean Dropper v3 - Premium ($30)
	Clean, no lag, no crazy effects
--]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local PartStorage = workspace:WaitForChild("PartStorage")

-- Configuration
local DROP_RATE = 0.8
local DROP_VALUE = 30
local DROP_LIFETIME = 25

-- Nice colors without rainbow spam
local COLORS = {
	Color3.fromRGB(135, 206, 250), -- Sky blue
	Color3.fromRGB(176, 224, 230), -- Powder blue
}

-- Create premium orb
local function createOrb()
	local orb = Instance.new("Part")
	orb.Name = "CashOrb"
	orb.Shape = Enum.PartType.Ball
	orb.Material = Enum.Material.Neon
	orb.Size = Vector3.new(1.8, 1.8, 1.8)
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	orb.Color = COLORS[math.random(1, #COLORS)]
	orb.Transparency = 0.1
	
	-- Good physics
	orb.CustomPhysicalProperties = PhysicalProperties.new(
		0.7,  -- Light
		0.3,  -- Low friction
		0.2,  -- Some bounce
		1,
		1
	)
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = DROP_VALUE
	cash.Parent = orb
	
	-- Premium glow
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 3
	pointLight.Range = 8
	pointLight.Color = orb.Color
	pointLight.Parent = orb
	
	-- Simple particles (not too many)
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkle.Rate = 10 -- Low rate
	sparkle.Lifetime = NumberRange.new(0.5, 1)
	sparkle.Speed = NumberRange.new(1, 2)
	sparkle.LightEmission = 1
	sparkle.LightInfluence = 0
	sparkle.Size = NumberSequence.new(0.3)
	sparkle.Color = ColorSequence.new(orb.Color)
	sparkle.Parent = orb
	
	-- Position with smart offset
	local dropPart = script.Parent:WaitForChild("Drop")
	orb.CFrame = dropPart.CFrame - Vector3.new(
		math.random(-5, 5) * 0.2,
		1.5,
		math.random(-5, 5) * 0.2
	)
	
	-- Controlled velocity - not too wild
	orb.AssemblyLinearVelocity = Vector3.new(
		math.random(-3, 3),
		-10,
		math.random(-3, 3)
	)
	
	-- Simple rotation
	local spin = Instance.new("BodyAngularVelocity")
	spin.AngularVelocity = Vector3.new(0, 3, 0)
	spin.MaxTorque = Vector3.new(0, math.huge, 0)
	spin.Parent = orb
	
	-- Set spawn time
	orb:SetAttribute("SpawnTime", tick())
	
	-- Parent to storage
	orb.Parent = PartStorage
	
	-- Simple entrance
	orb.Size = Vector3.new(0.5, 0.5, 0.5)
	TweenService:Create(orb,
		TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = Vector3.new(1.8, 1.8, 1.8)}
	):Play()
	
	-- Cleanup
	Debris:AddItem(orb, DROP_LIFETIME)
	
	-- Simple fade before despawn
	task.delay(DROP_LIFETIME - 2, function()
		if orb.Parent then
			sparkle.Enabled = false
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

-- Main loop
while true do
	createOrb()
	task.wait(DROP_RATE)
end