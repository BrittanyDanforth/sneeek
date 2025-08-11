--[[
	Cinnamoroll Dropper 1 - Basic Kawaii Style
	Fixed: Collides with conveyor/ground but not players
	POLISHED: Modernized with Random.new() and time()
	NO CLEANUP: Orbs stay until collected
--]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

-- Wait for PartStorage
task.wait(2)
local PartStorage = workspace:WaitForChild("PartStorage")

-- Find the Drop part
local dropPart = script.Parent:WaitForChild("Drop")

-- Cinnamoroll colors (TONED DOWN - less saturated)
local COLORS = {
	Color3.fromRGB(153, 196, 210),    -- Muted light blue
	Color3.fromRGB(125, 186, 215),    -- Softer sky blue
	Color3.fromRGB(156, 204, 210),    -- Gentle powder blue
	Color3.fromRGB(100, 139, 207),    -- Softer cornflower blue
}

-- Random number generator
local rng = Random.new()

-- Create collision groups
local ORB_GROUP = "CinnamorollOrbs"
local PLAYER_GROUP = "Players"

pcall(function()
	PhysicsService:CreateCollisionGroup(ORB_GROUP)
	PhysicsService:CreateCollisionGroup(PLAYER_GROUP)
	PhysicsService:CollisionGroupSetCollidable(ORB_GROUP, PLAYER_GROUP, false)
	PhysicsService:CollisionGroupSetCollidable(ORB_GROUP, ORB_GROUP, false)
end)

-- Setup player collision groups
local function setupPlayer(character)
	task.wait(0.1)
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			pcall(function()
				PhysicsService:SetPartCollisionGroup(part, PLAYER_GROUP)
			end)
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(setupPlayer)
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player.Character then
		setupPlayer(player.Character)
	end
end

while true do
	task.wait(1.2) -- Drop rate

	-- Create cute orb (BASIC - it's free!)
	local orb = Instance.new("Part")
	orb.Name = "CinnamorollOrb"
	orb.Shape = Enum.PartType.Ball
	orb.Material = Enum.Material.SmoothPlastic  -- Basic material
	orb.Size = Vector3.new(1.4, 1.4, 1.4)
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	orb.Color = COLORS[rng:NextInteger(1, #COLORS)]

	-- Collision settings
	orb.CanCollide = true
	orb.CanTouch = true
	orb.CanQuery = true

	-- Set collision group
	pcall(function()
		PhysicsService:SetPartCollisionGroup(orb, ORB_GROUP)
	end)

	-- Light weight for smooth movement
	orb.CustomPhysicalProperties = PhysicalProperties.new(
		0.3,  -- Very light density
		0.5,  -- Medium friction
		0.1,  -- Low bounce
		1, 1
	)

	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 10
	cash.Parent = orb

	-- Basic glow
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 0.4
	pointLight.Range = 3
	pointLight.Color = Color3.fromRGB(180, 210, 235)
	pointLight.Parent = orb

	-- Position with small offset
	local offsetX = rng:NextNumber(-0.2, 0.2)
	local offsetZ = rng:NextNumber(-0.2, 0.2)
	orb.CFrame = dropPart.CFrame - Vector3.new(offsetX, 1.75, offsetZ)

	-- Gentle drop
	orb.AssemblyLinearVelocity = Vector3.new(0, -12, 0)

	-- Cloud-like transparency
	orb.Transparency = 0.1

	-- Set spawn time
	orb:SetAttribute("SpawnTime", time())

	-- Parent to storage
	orb.Parent = PartStorage

	-- Simple spawn effect
	orb.Size = Vector3.new(0.7, 0.7, 0.7)
	TweenService:Create(orb,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = Vector3.new(1.4, 1.4, 1.4)}
	):Play()

	-- Spawn flash
	pointLight.Brightness = 1.5
	TweenService:Create(pointLight,
		TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Brightness = 0.4}
	):Play()

	-- Spawn ring effect
	local spawnRing = Instance.new("ParticleEmitter")
	spawnRing.Texture = "rbxassetid://262979222"
	spawnRing.Rate = 0
	spawnRing.Speed = NumberRange.new(0)
	spawnRing.Lifetime = NumberRange.new(0.3)
	spawnRing.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(1, 2)
	})
	spawnRing.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.6),
		NumberSequenceKeypoint.new(1, 1)
	})
	spawnRing.Color = ColorSequence.new(orb.Color)
	spawnRing.Parent = orb
	spawnRing:Emit(1)
	Debris:AddItem(spawnRing, 1) -- Only cleanup the effect, not the orb!

	-- NO CLEANUP FOR ORBS - They stay until collected by the tycoon!
end