--[[
	Cinnamoroll Dropper 2 - Enhanced Kawaii Style (Performance Optimized)
	Fixed: Collides with conveyor/ground but not players
	OPTIMIZED: Part caching system for better performance
	Modernized: Uses time() and Random.new()
--]]

-- Services
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

-- Configuration
local DROP_INTERVAL = 1.0 -- Faster drops
local ORB_LIFETIME = 22
local DROP_PART_NAME = "Drop"
local CASH_VALUE = 15
local MAX_CACHE_SIZE = 30 -- Medium cache size

-- Wait for dependencies
task.wait(2)
local dropperModel = script.Parent
local PartStorage = workspace:WaitForChild("PartStorage")

print("=== CINNAMOROLL DROPPER 2 (ENHANCED-CACHED) ===")

-- Find the Drop part
local dropPart = dropperModel:FindFirstChild(DROP_PART_NAME)
if not dropPart then
	warn("Cinnamoroll Dropper 2: 'Drop' part not found in", dropperModel:GetFullName())
	return
end

-- Cinnamoroll palette (TONED DOWN whites for Neon)
local COLORS = {
	Color3.fromRGB(240, 240, 255),    -- Soft blue-white
	Color3.fromRGB(255, 230, 240),    -- Pink-tinted white
	Color3.fromRGB(230, 240, 255),    -- Blue-tinted white
	Color3.fromRGB(255, 220, 230),    -- Light pink
	Color3.fromRGB(240, 230, 255),    -- Lavender white
}

-- Random number generator
local rng = Random.new()

-- Pattern for anti-stacking
local dropPattern = 1
local patterns = {
	Vector3.new(0.2, 0, 0.2),
	Vector3.new(-0.2, 0, 0.2),
	Vector3.new(0.2, 0, -0.2),
	Vector3.new(-0.2, 0, -0.2),
	Vector3.new(0, 0, 0),
}

-- Collision Groups Setup
local ORB_GROUP = "CinnamorollOrbs"
local PLAYER_GROUP = "Players"

pcall(function()
	PhysicsService:CreateCollisionGroup(ORB_GROUP)
	PhysicsService:CreateCollisionGroup(PLAYER_GROUP)
	PhysicsService:CollisionGroupSetCollidable(ORB_GROUP, PLAYER_GROUP, false)
	PhysicsService:CollisionGroupSetCollidable(ORB_GROUP, ORB_GROUP, false)
end)

local function setupPlayerCharacter(character)
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			pcall(function() PhysicsService:SetPartCollisionGroup(part, PLAYER_GROUP) end)
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(setupPlayerCharacter)
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player.Character then
		setupPlayerCharacter(player.Character)
	end
end

-- ================================================
-- === PART CACHING SYSTEM =======================
-- ================================================
local orbCache = {}

local function createOrbTemplate()
	-- Create fluffy orb
	local orb = Instance.new("Part")
	orb.Shape = Enum.PartType.Ball
	orb.Material = Enum.Material.Neon
	orb.Size = Vector3.new(1.6, 1.6, 1.6)
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	orb.CanCollide = true
	orb.CanTouch = true
	orb.CanQuery = true
	orb.Anchored = true
	pcall(function() PhysicsService:SetPartCollisionGroup(orb, ORB_GROUP) end)
	
	-- Fluffy physics
	orb.CustomPhysicalProperties = PhysicalProperties.new(0.2, 0.3, 0, 1, 1)
	
	-- Cash value
	local cash = Instance.new("IntValue", orb)
	cash.Name = "Cash"
	
	-- Reduced glow
	local pointLight = Instance.new("PointLight", orb)
	pointLight.Name = "PointLight"
	pointLight.Brightness = 0.6
	pointLight.Range = 4
	pointLight.Color = Color3.fromRGB(190, 210, 235)
	
	-- Selection sphere outline
	local selection = Instance.new("SelectionSphere", orb)
	selection.Name = "SelectionSphere"
	selection.Adornee = orb
	selection.Color3 = Color3.fromRGB(135, 206, 250)
	selection.SurfaceTransparency = 1  -- No texture
	selection.Transparency = 0.3
	
	-- Enhanced sparkles
	local sparkle = Instance.new("ParticleEmitter", orb)
	sparkle.Name = "Sparkle"
	sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkle.Rate = 5
	sparkle.Lifetime = NumberRange.new(0.5, 1.5)
	sparkle.Speed = NumberRange.new(0.5, 2)
	sparkle.SpreadAngle = Vector2.new(180, 180)
	sparkle.LightEmission = 1
	sparkle.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 0)
	}
	sparkle.VelocityInheritance = 0
	
	-- Star particles
	local stars = Instance.new("ParticleEmitter", orb)
	stars.Name = "Stars"
	stars.Texture = "rbxasset://textures/particles/star.dds"
	stars.Rate = 2
	stars.Lifetime = NumberRange.new(1, 2)
	stars.Speed = NumberRange.new(0.5)
	stars.SpreadAngle = Vector2.new(360, 360)
	stars.LightEmission = 0.8
	stars.Size = NumberSequence.new(0.4)
	stars.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	
	return orb
end

local function getOrb()
	if #orbCache > 0 then
		return table.remove(orbCache)
	end
	return createOrbTemplate()
end

local function returnOrbToCache(orb)
	if #orbCache >= MAX_CACHE_SIZE then
		orb:Destroy()
		return
	end
	
	orb.Transparency = 1
	orb.Anchored = true
	orb.Parent = PartStorage
	table.insert(orbCache, orb)
end

-- Main Loop
while true do
	task.wait(DROP_INTERVAL)
	
	-- Get orb from cache
	local orb = getOrb()
	orb.Name = "CinnamorollCloud"
	orb.Color = COLORS[rng:NextInteger(1, #COLORS)]
	orb.Cash.Value = CASH_VALUE
	orb:SetAttribute("SpawnTime", time())
	
	-- Pattern positioning
	local offset = patterns[dropPattern]
	dropPattern = (dropPattern % #patterns) + 1
	orb.CFrame = dropPart.CFrame - Vector3.new(0, 1.75, 0) + offset
	
	-- Re-enable all effects
	orb.PointLight.Enabled = true
	orb.SelectionSphere.Visible = true
	orb.Sparkle.Enabled = true
	orb.Sparkle.Color = ColorSequence.new(orb.Color)  -- Match orb color
	orb.Stars.Enabled = true
	orb.Transparency = 0
	orb.Parent = PartStorage
	
	-- Bounce spawn animation
	orb.Size = Vector3.new(0.4, 0.4, 0.4)
	TweenService:Create(orb,
		TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{Size = Vector3.new(1.6, 1.6, 1.6)}
	):Play()
	
	-- Magical spawn flash
	local pointLight = orb.PointLight
	pointLight.Brightness = 2
	TweenService:Create(pointLight,
		TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Brightness = 0.6}
	):Play()
	
	-- Cloud puff spawn effect
	local spawnPuff = Instance.new("ParticleEmitter")
	spawnPuff.Texture = "rbxassetid://262979222"
	spawnPuff.Rate = 0
	spawnPuff.Speed = NumberRange.new(0)
	spawnPuff.Lifetime = NumberRange.new(0.4)
	spawnPuff.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 2.5)
	})
	spawnPuff.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.5, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	})
	spawnPuff.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	spawnPuff.Parent = orb
	spawnPuff:Emit(2)
	Debris:AddItem(spawnPuff, 1)
	
	-- Launch
	orb.Anchored = false
	orb.AssemblyLinearVelocity = Vector3.new(
		offset.X * 2,
		-10,
		offset.Z * 2
	)
	
	-- Cleanup
	task.delay(ORB_LIFETIME - 2, function()
		if orb and orb.Parent then
			orb.Sparkle.Enabled = false
			orb.Stars.Enabled = false
			
			-- Cloud pop animation
			orb.Sparkle:Emit(10)
			
			-- Cloud dissipate effect
			local cloudPop = Instance.new("ParticleEmitter")
			cloudPop.Texture = "rbxasset://textures/particles/smoke_main.dds"
			cloudPop.Rate = 0
			cloudPop.Speed = NumberRange.new(2, 4)
			cloudPop.SpreadAngle = Vector2.new(360, 360)
			cloudPop.Lifetime = NumberRange.new(0.6)
			cloudPop.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.5),
				NumberSequenceKeypoint.new(1, 1.5)
			})
			cloudPop.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.5),
				NumberSequenceKeypoint.new(1, 1)
			})
			cloudPop.Color = ColorSequence.new(orb.Color)
			cloudPop.Parent = orb
			cloudPop:Emit(6)
			
			-- Shrink and fade
			TweenService:Create(orb,
				TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.In),
				{Size = Vector3.new(0.1, 0.1, 0.1), Transparency = 0.7}
			):Play()
			
			TweenService:Create(pointLight,
				TweenInfo.new(0.4, Enum.EasingStyle.Linear),
				{Brightness = 0, Range = 0}
			):Play()
		end
	end)
	
	task.delay(ORB_LIFETIME, function()
		if orb and orb.Parent then
			returnOrbToCache(orb)
		end
	end)
end