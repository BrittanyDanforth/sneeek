--[[
	Pooled Dropper v1 - Basic ($10)
	High performance part pooling system with collision groups
	No flinging, no lag, professional grade
--]]

local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")

-- Configuration
local Config = {
	DROP_RATE = 1.2, -- Seconds between drops
	DROP_VALUE = 10, -- Cash value per orb
	DROP_LIFETIME = 20, -- How long orbs last
	POOL_SIZE = 50, -- Max orbs in pool (adjust based on your needs)
	
	ORB_SIZE = Vector3.new(1.4, 1.4, 1.4),
	ORB_COLORS = {
		Color3.fromRGB(173, 216, 230), -- Light blue
		Color3.fromRGB(135, 206, 235), -- Sky blue
		Color3.fromRGB(176, 224, 230), -- Powder blue
	},
	ORB_COLLISION_GROUP = "Orbs", -- Must match CollisionGroupSetup
	
	-- Physics
	DROP_VELOCITY = -15,
	OFFSET_RANGE = 0.4,
}

-- References
local dropPart = script.Parent:WaitForChild("Drop")
local partStorage = workspace:WaitForChild("PartStorage")

-- Pool management
local orbPool = {}
local activeOrbs = {}

-- Create orb template
local function createOrb()
	local orb = Instance.new("Part")
	orb.Name = "PooledOrb_Basic"
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
	
	-- Optimized physics
	orb.CustomPhysicalProperties = PhysicalProperties.new(
		0.7, -- Density
		0.5, -- Friction
		0.2, -- Elasticity
		1,   -- ElasticityWeight
		1    -- FrictionWeight
	)
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = Config.DROP_VALUE
	cash.Parent = orb
	
	-- Simple glow
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 1.5
	pointLight.Range = 6
	pointLight.Parent = orb
	
	-- Light particles
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkle.Rate = 5
	sparkle.Lifetime = NumberRange.new(0.5, 1)
	sparkle.Speed = NumberRange.new(1)
	sparkle.LightEmission = 1
	sparkle.Size = NumberSequence.new(0.2)
	sparkle.Enabled = false -- Start disabled
	sparkle.Parent = orb
	
	-- Start in storage, disabled
	orb.Transparency = 1
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
	print("[Dropper1] Initialized pool with", Config.POOL_SIZE, "orbs")
end

-- Get orb from pool
local function getFromPool()
	for _, orb in ipairs(orbPool) do
		if not orb:GetAttribute("InUse") then
			return orb
		end
	end
	
	-- If pool is exhausted, create one more (but warn)
	warn("[Dropper1] Pool exhausted! Consider increasing POOL_SIZE")
	local newOrb = createOrb()
	table.insert(orbPool, newOrb)
	return newOrb
end

-- Return orb to pool
local function returnToPool(orb)
	if not orb or not orb.Parent then return end
	
	-- Reset state
	orb:SetAttribute("InUse", false)
	orb.Transparency = 1
	orb.AssemblyLinearVelocity = Vector3.zero
	orb.AssemblyAngularVelocity = Vector3.zero
	orb.Parent = partStorage
	
	-- Disable effects
	local sparkle = orb:FindFirstChild("ParticleEmitter")
	if sparkle then sparkle.Enabled = false end
	
	local light = orb:FindFirstChild("PointLight")
	if light then light.Enabled = false end
	
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
	
	-- Position with offset
	local offsetX = (math.random() - 0.5) * Config.OFFSET_RANGE
	local offsetZ = (math.random() - 0.5) * Config.OFFSET_RANGE
	orb.CFrame = dropPart.CFrame + Vector3.new(offsetX, -1.7, offsetZ)
	
	-- Apply velocity
	orb.AssemblyLinearVelocity = Vector3.new(
		offsetX * 3,
		Config.DROP_VELOCITY,
		offsetZ * 3
	)
	
	-- Enable visuals
	orb.Transparency = 0.15
	orb.PointLight.Enabled = true
	orb.ParticleEmitter.Enabled = true
	orb.Parent = workspace
	
	-- Spawn animation
	orb.Size = Config.ORB_SIZE * 0.5
	local spawnTween = TweenService:Create(orb,
		TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = Config.ORB_SIZE}
	)
	spawnTween:Play()
	
	-- Schedule cleanup
	task.delay(Config.DROP_LIFETIME, function()
		if orb:GetAttribute("InUse") then
			-- Fade out
			orb.ParticleEmitter.Enabled = false
			local fadeTween = TweenService:Create(orb,
				TweenInfo.new(1, Enum.EasingStyle.Linear),
				{Transparency = 0.8}
			)
			fadeTween:Play()
			fadeTween.Completed:Wait()
			returnToPool(orb)
		end
	end)
end

-- Cleanup on collection
workspace.DescendantRemoving:Connect(function(descendant)
	if descendant.Name == "PooledOrb_Basic" and descendant:GetAttribute("InUse") then
		-- Orb was collected/destroyed, return to pool
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