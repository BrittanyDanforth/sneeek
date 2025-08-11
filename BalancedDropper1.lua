--[[
	Balanced Dropper v1 - Basic ($10)
	Good physics, proper collision, nice visuals
--]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local PartStorage = workspace:WaitForChild("PartStorage")

-- Configuration
local DROP_RATE = 1.2
local DROP_VALUE = 10
local DROP_LIFETIME = 20

-- Colors
local COLORS = {
	Color3.fromRGB(173, 216, 230), -- Light blue
	Color3.fromRGB(135, 206, 235), -- Sky blue
}

local function createOrb()
	local orb = Instance.new("Part")
	orb.Name = "CashOrb"
	orb.Shape = Enum.PartType.Ball
	orb.Material = Enum.Material.Neon
	orb.Size = Vector3.new(1.4, 1.4, 1.4)
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	orb.Color = COLORS[math.random(1, #COLORS)]
	orb.Transparency = 0.15
	
	-- PROPER COLLISION - Can't walk through
	orb.CanCollide = true
	orb.CanTouch = true
	orb.CanQuery = true
	
	-- Balanced physics - not too bouncy, not too heavy
	orb.CustomPhysicalProperties = PhysicalProperties.new(
		0.7,  -- Density (light but not too light)
		0.5,  -- Friction
		0.2,  -- Elasticity (some bounce)
		1,    -- ElasticityWeight
		1     -- FrictionWeight
	)
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = DROP_VALUE
	cash.Parent = orb
	
	-- Nice glow
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 1.5
	pointLight.Range = 6
	pointLight.Color = orb.Color
	pointLight.Parent = orb
	
	-- Light particles
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkle.Rate = 5
	sparkle.Lifetime = NumberRange.new(0.5, 1)
	sparkle.Speed = NumberRange.new(1)
	sparkle.LightEmission = 1
	sparkle.Size = NumberSequence.new(0.2)
	sparkle.Color = ColorSequence.new(orb.Color)
	sparkle.Parent = orb
	
	-- Position with offset to prevent stacking
	local dropPart = script.Parent:WaitForChild("Drop")
	local offsetX = math.random(-3, 3) * 0.15
	local offsetZ = math.random(-3, 3) * 0.15
	
	orb.CFrame = dropPart.CFrame - Vector3.new(offsetX, 1.7, offsetZ)
	
	-- Good velocity - not too slow, not crazy
	orb.AssemblyLinearVelocity = Vector3.new(
		offsetX * 2,  -- Slight horizontal based on offset
		-15,          -- Good drop speed
		offsetZ * 2
	)
	
	-- Slight spin
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
	bodyVelocity.Velocity = Vector3.new(0, -15, 0)
	bodyVelocity.Parent = orb
	
	-- Destroy velocity after landing
	task.delay(0.5, function()
		if bodyVelocity.Parent then
			bodyVelocity:Destroy()
		end
	end)
	
	-- Set spawn time
	orb:SetAttribute("SpawnTime", tick())
	
	-- Parent to storage
	orb.Parent = PartStorage
	
	-- Spawn effect
	orb.Size = Vector3.new(0.7, 0.7, 0.7)
	local spawnTween = TweenService:Create(orb,
		TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = Vector3.new(1.4, 1.4, 1.4)}
	)
	spawnTween:Play()
	
	-- Cleanup
	Debris:AddItem(orb, DROP_LIFETIME)
	
	-- Fade out before despawn
	task.delay(DROP_LIFETIME - 2, function()
		if orb.Parent then
			sparkle.Enabled = false
			TweenService:Create(orb,
				TweenInfo.new(2, Enum.EasingStyle.Linear),
				{Transparency = 0.8}
			):Play()
		end
	end)
end

-- Main loop
while true do
	createOrb()
	task.wait(DROP_RATE)
end