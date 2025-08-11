--[[
	Cinnamoroll Dropper 1 - Basic Kawaii Style (Performance Optimized)
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
local DROP_INTERVAL = 1.2 -- Basic drop rate
local ORB_LIFETIME = 300 -- 5 minutes - plenty of time for conveyor
local DROP_PART_NAME = "Drop"
local CASH_VALUE = 10
local MAX_CACHE_SIZE = 20 -- Keep cache reasonable

-- Wait for dependencies
task.wait(2)
local dropperModel = script.Parent
local PartStorage = workspace:WaitForChild("PartStorage")

print("=== CINNAMOROLL DROPPER 1 (BASIC-CACHED) ===")

-- Find the Drop part
local dropPart = dropperModel:FindFirstChild(DROP_PART_NAME)
if not dropPart then
	warn("Cinnamoroll Dropper 1: 'Drop' part not found in", dropperModel:GetFullName())
	return
end

-- Cinnamoroll colors (TONED DOWN - less saturated)
local COLORS = {
	Color3.fromRGB(153, 196, 210),    -- Muted light blue
	Color3.fromRGB(125, 186, 215),    -- Softer sky blue
	Color3.fromRGB(156, 204, 210),    -- Gentle powder blue
	Color3.fromRGB(100, 139, 207),    -- Softer cornflower blue
}

-- Random number generator
local rng = Random.new()

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
	-- Create basic orb
	local orb = Instance.new("Part")
	orb.Shape = Enum.PartType.Ball
	orb.Material = Enum.Material.SmoothPlastic  -- Basic material
	orb.Size = Vector3.new(1.4, 1.4, 1.4)
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	orb.CanCollide = true
	orb.CanTouch = true
	orb.CanQuery = true
	orb.Anchored = true
	pcall(function() PhysicsService:SetPartCollisionGroup(orb, ORB_GROUP) end)
	
	-- Light physics
	orb.CustomPhysicalProperties = PhysicalProperties.new(0.3, 0.5, 0.1, 1, 1)
	
	-- Cash value
	local cash = Instance.new("IntValue", orb)
	cash.Name = "Cash"
	
	-- Basic glow
	local pointLight = Instance.new("PointLight", orb)
	pointLight.Name = "PointLight"
	pointLight.Brightness = 0.4
	pointLight.Range = 3
	pointLight.Color = Color3.fromRGB(180, 210, 235)
	
	return orb
end

local function getOrb()
	if #orbCache > 0 then
		return table.remove(orbCache)
	end
	return createOrbTemplate()
end

local function returnOrbToCache(orb)
	-- Only cache if there's room, otherwise just leave it alone
	if #orbCache < MAX_CACHE_SIZE then
		orb.Transparency = 1
		orb.Anchored = true
		orb.Parent = PartStorage
		table.insert(orbCache, orb)
	end
	-- If cache is full, do nothing - let the orb exist!
end

-- Main Loop
while true do
	task.wait(DROP_INTERVAL)
	
	-- Get orb from cache
	local orb = getOrb()
	orb.Name = "CinnamorollOrb"
	orb.Color = COLORS[rng:NextInteger(1, #COLORS)]
	orb.Cash.Value = CASH_VALUE
	orb:SetAttribute("SpawnTime", time())
	
	-- Position
	local offsetX = rng:NextNumber(-0.2, 0.2)
	local offsetZ = rng:NextNumber(-0.2, 0.2)
	orb.CFrame = dropPart.CFrame - Vector3.new(offsetX, 1.75, offsetZ)
	
	-- Re-enable
	orb.PointLight.Enabled = true
	orb.Transparency = 0.1  -- Slightly transparent
	orb.Parent = PartStorage
	
	-- Simple spawn animation
	orb.Size = Vector3.new(0.7, 0.7, 0.7)
	TweenService:Create(orb,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = Vector3.new(1.4, 1.4, 1.4)}
	):Play()
	
	-- Launch
	orb.Anchored = false
	orb.AssemblyLinearVelocity = Vector3.new(0, -12, 0)
	
	-- NO AUTOMATIC CLEANUP - Orbs stay until collected!
	-- The game/tycoon system should handle cleanup when collected
end