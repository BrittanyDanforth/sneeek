--[[
	Pooled Dropper v3 - Premium ($30)
	Premium effects with part pooling, optimized performance
	Professional grade with no flinging
--]]

local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")

-- Configuration
local Config = {
	DROP_RATE = 0.8, -- Faster drops
	DROP_VALUE = 30, -- Premium value
	DROP_LIFETIME = 25, -- Longer lifetime
	POOL_SIZE = 80, -- Largest pool
	
	ORB_SIZE = Vector3.new(1.8, 1.8, 1.8),
	CORE_SIZE = Vector3.new(1.2, 1.2, 1.2),
	ORB_COLORS = {
		Color3.fromRGB(135, 206, 250), -- Sky blue
		Color3.fromRGB(147, 197, 253), -- Light blue
		Color3.fromRGB(173, 216, 230), -- Powder blue
		Color3.fromRGB(119, 181, 254), -- French sky blue
	},
	ORB_COLLISION_GROUP = "Orbs",
	
	-- Physics
	DROP_VELOCITY = -20,
	MAX_OFFSET_MEMORY = 5,
}

-- References
local dropPart = script.Parent:WaitForChild("Drop")
local partStorage = workspace:WaitForChild("PartStorage")

-- Pool management
local orbPool = {}
local activeOrbs = {}
local recentOffsets = {}

-- Smart offset system
local function getSmartOffset()
	local offset = Vector3.new(
		(math.random() - 0.5) * 0.8,
		0,
		(math.random() - 0.5) * 0.8
	)
	
	-- Check against recent positions
	for _, recent in ipairs(recentOffsets) do
		if (offset - recent).Magnitude < 0.3 then
			offset = offset + Vector3.new(
				(math.random() - 0.5) * 0.4,
				0,
				(math.random() - 0.5) * 0.4
			)
		end
	end
	
	table.insert(recentOffsets, offset)
	if #recentOffsets > Config.MAX_OFFSET_MEMORY then
		table.remove(recentOffsets, 1)
	end
	
	return offset
end

-- Create premium orb
local function createOrb()
	local orb = Instance.new("Part")
	orb.Name = "PooledOrb_Premium"
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
	
	-- Premium physics
	orb.CustomPhysicalProperties = PhysicalProperties.new(
		0.5, -- Light
		0.35, -- Good friction
		0.3, -- Nice bounce
		1, 1
	)
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = Config.DROP_VALUE
	cash.Parent = orb
	
	-- Premium lighting
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 2.5
	pointLight.Range = 10
	pointLight.Parent = orb
	
	-- Inner core
	local core = Instance.new("Part")
	core.Name = "Core"
	core.Shape = Enum.PartType.Ball
	core.Material = Enum.Material.Neon
	core.Size = Config.CORE_SIZE
	core.Color = Color3.fromRGB(255, 255, 255)
	core.Transparency = 0.5
	core.CanCollide = false
	core.CanTouch = false
	core.CanQuery = false
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
	sparkle.SpreadAngle = Vector2.new(360, 360)
	sparkle.VelocityInheritance = 0.1
	sparkle.Enabled = false
	sparkle.Parent = orb
	
	-- Trail attachments
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
	trail.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	}
	trail.Enabled = false
	trail.Parent = orb
	
	-- Start in storage
	orb.Transparency = 1
	core.Transparency = 1
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
	print("[Dropper3] Initialized premium pool with", Config.POOL_SIZE, "orbs")
end

-- Get orb from pool
local function getFromPool()
	for _, orb in ipairs(orbPool) do
		if not orb:GetAttribute("InUse") then
			return orb
		end
	end
	
	warn("[Dropper3] Premium pool exhausted!")
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
	
	-- Reset core
	local core = orb:FindFirstChild("Core")
	if core then
		core.Transparency = 1
		core.Size = Config.CORE_SIZE
	end
	
	-- Disable effects
	local sparkle = orb:FindFirstChild("ParticleEmitter")
	if sparkle then sparkle.Enabled = false end
	
	local light = orb:FindFirstChild("PointLight")
	if light then 
		light.Enabled = false
		light.Brightness = 2.5
		light.Range = 10
	end
	
	local trail = orb:FindFirstChild("Trail")
	if trail then trail.Enabled = false end
	
	-- Remove spin
	local spin = orb:FindFirstChild("BodyAngularVelocity")
	if spin then spin:Destroy() end
	
	-- Remove from active list
	local index = table.find(activeOrbs, orb)
	if index then
		table.remove(activeOrbs, index)
	end
end

-- Spawn premium orb
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
	orb.Trail.Color = ColorSequence.new(color)
	
	-- Smart positioning
	local offset = getSmartOffset()
	orb.CFrame = dropPart.CFrame - Vector3.new(0, 1.7, 0) + offset
	
	-- Premium velocity
	local angle = math.random() * math.pi * 2
	orb.AssemblyLinearVelocity = Vector3.new(
		math.cos(angle) * 4,
		Config.DROP_VELOCITY,
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
	
	task.delay(1, function()
		if spin.Parent then spin:Destroy() end
	end)
	
	-- Enable visuals
	orb.Transparency = 0.05
	orb.Core.Transparency = 0.5
	orb.PointLight.Enabled = true
	orb.ParticleEmitter.Enabled = true
	orb.Trail.Enabled = true
	orb.Parent = workspace
	
	-- Premium entrance
	orb.Size = Vector3.new(0.3, 0.3, 0.3)
	orb.Core.Size = Vector3.new(0.2, 0.2, 0.2)
	
	TweenService:Create(orb,
		TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = Config.ORB_SIZE}
	):Play()
	
	TweenService:Create(orb.Core,
		TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = Config.CORE_SIZE}
	):Play()
	
	-- Core pulse
	task.spawn(function()
		while orb:GetAttribute("InUse") and orb.Parent do
			TweenService:Create(orb.Core,
				TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Size = Config.CORE_SIZE * 1.1, Transparency = 0.6}
			):Play()
			task.wait(1.5)
			if not orb:GetAttribute("InUse") then break end
			TweenService:Create(orb.Core,
				TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Size = Config.CORE_SIZE, Transparency = 0.5}
			):Play()
			task.wait(1.5)
		end
	end)
	
	-- Schedule cleanup
	task.delay(Config.DROP_LIFETIME, function()
		if orb:GetAttribute("InUse") then
			-- Premium fade out
			orb.ParticleEmitter.Enabled = false
			orb.Trail.Enabled = false
			
			TweenService:Create(orb,
				TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{Transparency = 0.8, Size = Config.ORB_SIZE * 0.8}
			):Play()
			
			TweenService:Create(orb.Core,
				TweenInfo.new(3, Enum.EasingStyle.Quad),
				{Transparency = 1, Size = Config.CORE_SIZE * 0.5}
			):Play()
			
			TweenService:Create(orb.PointLight,
				TweenInfo.new(3, Enum.EasingStyle.Linear),
				{Brightness = 0, Range = 0}
			):Play()
			
			task.wait(3)
			returnToPool(orb)
		end
	end)
end

-- Cleanup on collection
workspace.DescendantRemoving:Connect(function(descendant)
	if descendant.Name == "PooledOrb_Premium" and descendant:GetAttribute("InUse") then
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