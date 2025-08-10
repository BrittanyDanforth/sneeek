--[[
	Pooled Dropper v2 - Mid Tier ($15)
	Enhanced visuals with outer glow, part pooling, no flinging
	Based on user's preferred "Dropper 2" style
--]]

local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")

-- Configuration
local Config = {
	DROP_RATE = 1, -- Seconds between drops
	DROP_VALUE = 15, -- Cash value per orb
	DROP_LIFETIME = 22, -- How long orbs last
	POOL_SIZE = 60, -- Larger pool for mid-tier
	
	ORB_SIZE = Vector3.new(1.6, 1.6, 1.6),
	GLOW_SIZE = Vector3.new(2, 2, 2),
	ORB_COLORS = {
		Color3.fromRGB(135, 206, 250), -- Light sky blue
		Color3.fromRGB(100, 149, 237), -- Cornflower blue
		Color3.fromRGB(147, 197, 253), -- Light blue
	},
	ORB_COLLISION_GROUP = "Orbs",
	
	-- Physics
	DROP_VELOCITY = -18,
	OFFSET_PATTERNS = {
		Vector3.new(0.3, 0, 0.3),
		Vector3.new(-0.3, 0, 0.3),
		Vector3.new(0.3, 0, -0.3),
		Vector3.new(-0.3, 0, -0.3),
		Vector3.new(0, 0, 0),
	},
}

-- References
local dropPart = script.Parent:WaitForChild("Drop")
local partStorage = workspace:WaitForChild("PartStorage")

-- Pool management
local orbPool = {}
local activeOrbs = {}
local patternIndex = 1

-- Create orb with glow
local function createOrb()
	local orb = Instance.new("Part")
	orb.Name = "PooledOrb_Mid"
	orb.Shape = Enum.PartType.Ball
	orb.Material = Enum.Material.Neon
	orb.Size = Config.ORB_SIZE
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	orb.Anchored = false
	orb.CanCollide = true
	orb.CanTouch = true
	orb.CanQuery = true
	
	-- Set collision group
	pcall(function()
		PhysicsService:SetPartCollisionGroup(orb, Config.ORB_COLLISION_GROUP)
	end)
	
	-- Better physics
	orb.CustomPhysicalProperties = PhysicalProperties.new(
		0.6, -- Lighter
		0.4, -- Medium friction
		0.25, -- Some bounce
		1, 1
	)
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = Config.DROP_VALUE
	cash.Parent = orb
	
	-- Enhanced glow
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 2
	pointLight.Range = 8
	pointLight.Parent = orb
	
	-- Outer glow effect (user's favorite)
	local glowPart = Instance.new("Part")
	glowPart.Name = "Glow"
	glowPart.Shape = Enum.PartType.Ball
	glowPart.Material = Enum.Material.ForceField
	glowPart.Size = Config.GLOW_SIZE
	glowPart.Transparency = 0.75
	glowPart.CanCollide = false
	glowPart.CanTouch = false
	glowPart.CanQuery = false
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
	sparkle.Enabled = false
	sparkle.Parent = orb
	
	-- Start in storage
	orb.Transparency = 1
	glowPart.Transparency = 1
	orb.Parent = partStorage
	orb:SetAttribute("InUse", false)
	orb:SetAttribute("SpawnTime", 0)
	
	return orb
end

-- Initialize pool
local function initializePool()
	for i = 1, Config.POOL_SIZE do
		local orb = createOrb()
		table.insert(orbPool, orb)
	end
	print("[Dropper2] Initialized pool with", Config.POOL_SIZE, "orbs")
end

-- Get orb from pool
local function getFromPool()
	for _, orb in ipairs(orbPool) do
		if not orb:GetAttribute("InUse") then
			return orb
		end
	end
	
	warn("[Dropper2] Pool exhausted! Consider increasing POOL_SIZE")
	local newOrb = createOrb()
	table.insert(orbPool, newOrb)
	return newOrb
end

-- Return orb to pool
local function returnToPool(orb)
	if not orb or not orb.Parent then return end
	
	-- Stop any running tweens
	orb:SetAttribute("InUse", false)
	orb.Transparency = 1
	orb.AssemblyLinearVelocity = Vector3.zero
	orb.AssemblyAngularVelocity = Vector3.zero
	orb.Parent = partStorage
	
	-- Reset glow
	local glow = orb:FindFirstChild("Glow")
	if glow then
		glow.Transparency = 1
		glow.Size = Config.GLOW_SIZE
	end
	
	-- Disable effects
	local sparkle = orb:FindFirstChild("ParticleEmitter")
	if sparkle then sparkle.Enabled = false end
	
	local light = orb:FindFirstChild("PointLight")
	if light then light.Enabled = false end
	
	-- Remove spin
	local spin = orb:FindFirstChild("BodyAngularVelocity")
	if spin then spin:Destroy() end
	
	-- Remove from active list
	local index = table.find(activeOrbs, orb)
	if index then
		table.remove(activeOrbs, index)
	end
end

-- Spawn an orb
local function spawnOrb()
	local orb = getFromPool()
	if not orb then return end
	
	-- Mark as active
	orb:SetAttribute("InUse", true)
	orb:SetAttribute("SpawnTime", tick())
	table.insert(activeOrbs, orb)
	
	-- Random color
	local color = Config.ORB_COLORS[math.random(1, #Config.ORB_COLORS)]
	orb.Color = color
	orb.PointLight.Color = color
	orb.ParticleEmitter.Color = ColorSequence.new(color)
	orb.Glow.Color = color
	
	-- Pattern positioning
	local offset = Config.OFFSET_PATTERNS[patternIndex]
	patternIndex = (patternIndex % #Config.OFFSET_PATTERNS) + 1
	orb.CFrame = dropPart.CFrame - Vector3.new(0, 1.7, 0) + offset
	
	-- Apply velocity
	orb.AssemblyLinearVelocity = Vector3.new(
		offset.X * 3,
		Config.DROP_VELOCITY,
		offset.Z * 3
	)
	
	-- Add spin
	local spin = Instance.new("BodyAngularVelocity")
	spin.AngularVelocity = Vector3.new(0, 5, 0)
	spin.MaxTorque = Vector3.new(0, math.huge, 0)
	spin.Parent = orb
	
	-- Remove spin after landing
	task.delay(0.8, function()
		if spin.Parent then spin:Destroy() end
	end)
	
	-- Enable visuals
	orb.Transparency = 0.1
	orb.Glow.Transparency = 0.75
	orb.PointLight.Enabled = true
	orb.ParticleEmitter.Enabled = true
	orb.Parent = workspace
	
	-- Bounce spawn animation
	orb.Size = Vector3.new(0.4, 0.4, 0.4)
	orb.Glow.Size = Vector3.new(0.5, 0.5, 0.5)
	
	TweenService:Create(orb,
		TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{Size = Config.ORB_SIZE}
	):Play()
	
	TweenService:Create(orb.Glow,
		TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{Size = Config.GLOW_SIZE}
	):Play()
	
	-- Pulse glow
	task.spawn(function()
		while orb:GetAttribute("InUse") and orb.Parent do
			TweenService:Create(orb.Glow,
				TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Size = Config.GLOW_SIZE * 1.1, Transparency = 0.8}
			):Play()
			task.wait(1)
			if not orb:GetAttribute("InUse") then break end
			TweenService:Create(orb.Glow,
				TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Size = Config.GLOW_SIZE, Transparency = 0.75}
			):Play()
			task.wait(1)
		end
	end)
	
	-- Schedule cleanup
	task.delay(Config.DROP_LIFETIME, function()
		if orb:GetAttribute("InUse") then
			-- Fade out
			orb.ParticleEmitter.Enabled = false
			TweenService:Create(orb,
				TweenInfo.new(2, Enum.EasingStyle.Quad),
				{Transparency = 0.7}
			):Play()
			TweenService:Create(orb.Glow,
				TweenInfo.new(2, Enum.EasingStyle.Quad),
				{Transparency = 1}
			):Play()
			TweenService:Create(orb.PointLight,
				TweenInfo.new(2, Enum.EasingStyle.Linear),
				{Brightness = 0}
			):Play()
			task.wait(2)
			returnToPool(orb)
		end
	end)
end

-- Cleanup on collection
workspace.DescendantRemoving:Connect(function(descendant)
	if descendant.Name == "PooledOrb_Mid" and descendant:GetAttribute("InUse") then
		task.defer(function()
			returnToPool(descendant)
		end)
	end
end)

-- Initialize
initializePool()

-- Main loop
while true do
	spawnOrb()
	task.wait(Config.DROP_RATE)
end