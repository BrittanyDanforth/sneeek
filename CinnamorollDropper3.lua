--[[
	Cinnamoroll Dropper 3 - Premium Kawaii Style
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

-- Premium Cinnamoroll palette (TONED DOWN Blue-themed)
local COLORS = {
	Color3.fromRGB(125, 186, 230),    -- Softer light sky blue
	Color3.fromRGB(153, 196, 210),    -- Muted light blue
	Color3.fromRGB(100, 139, 207),    -- Softer cornflower blue
	Color3.fromRGB(80, 120, 160),     -- Muted steel blue
	Color3.fromRGB(156, 204, 210),    -- Gentle powder blue
}

-- Random number generator
local rng = Random.new()

-- Smart positioning
local recentPositions = {}
local MAX_MEMORY = 3

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

local function getSmartOffset()
	local offset = Vector3.new(
		rng:NextNumber(-0.3, 0.3),
		0,
		rng:NextNumber(-0.3, 0.3)
	)

	-- Avoid recent positions
	for _, pos in ipairs(recentPositions) do
		if (offset - pos).Magnitude < 0.2 then
			offset = offset + Vector3.new(
				rng:NextNumber(-0.15, 0.15),
				0,
				rng:NextNumber(-0.15, 0.15)
			)
		end
	end

	table.insert(recentPositions, offset)
	if #recentPositions > MAX_MEMORY then
		table.remove(recentPositions, 1)
	end

	return offset
end

while true do
	task.wait(0.8) -- Premium faster drops

	-- Create dreamy orb
	local orb = Instance.new("Part")
	orb.Name = "CinnamorollDream"
	orb.Shape = Enum.PartType.Ball
	orb.Material = Enum.Material.Neon
	orb.Size = Vector3.new(1.8, 1.8, 1.8)
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

	-- Dream-like physics
	orb.CustomPhysicalProperties = PhysicalProperties.new(
		0.1,  -- Ultra light
		0.2,  -- Smooth friction
		0,    -- No bounce
		1, 1
	)

	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 30
	cash.Parent = orb

	-- Premium lighting
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 0.8
	pointLight.Range = 5
	pointLight.Color = Color3.fromRGB(125, 186, 230)
	pointLight.Parent = orb

	-- Premium selection sphere outline
	local selection = Instance.new("SelectionSphere")
	selection.Adornee = orb
	selection.Color3 = Color3.fromRGB(70, 130, 180)
	selection.SurfaceTransparency = 1  -- No texture
	selection.Transparency = 0.2
	selection.Parent = orb

	-- Blue sparkles
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkle.Rate = 5
	sparkle.Lifetime = NumberRange.new(1, 2)
	sparkle.Speed = NumberRange.new(1, 3)
	sparkle.SpreadAngle = Vector2.new(360, 360)
	sparkle.LightEmission = 0.7
	sparkle.LightInfluence = 0
	sparkle.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.5, 0.3),
		NumberSequenceKeypoint.new(1, 0)
	}
	sparkle.Color = ColorSequence.new(Color3.fromRGB(125, 186, 230))
	sparkle.VelocityInheritance = 0.2
	sparkle.Parent = orb

	-- Heart particles
	local hearts = Instance.new("ParticleEmitter")
	hearts.Texture = "rbxasset://textures/particles/heart.dds"
	hearts.Rate = 1
	hearts.Lifetime = NumberRange.new(2, 3)
	hearts.Speed = NumberRange.new(0.5)
	hearts.SpreadAngle = Vector2.new(180, 180)
	hearts.LightEmission = 0.3
	hearts.Size = NumberSequence.new(0.2)
	hearts.Color = ColorSequence.new(Color3.fromRGB(156, 204, 210))
	hearts.Parent = orb

	-- Smart positioning
	local offset = getSmartOffset()
	orb.CFrame = dropPart.CFrame - Vector3.new(0, 1.75, 0) + offset

	-- Dreamy float
	local angle = rng:NextNumber(0, math.pi * 2)
	orb.AssemblyLinearVelocity = Vector3.new(
		math.cos(angle) * 2,
		-12,
		math.sin(angle) * 2
	)

	-- Completely opaque
	orb.Transparency = 0

	-- Set spawn time
	orb:SetAttribute("SpawnTime", time())

	-- Parent to storage
	orb.Parent = PartStorage

	-- Premium entrance animation
	orb.Size = Vector3.new(0.5, 0.5, 0.5)

	TweenService:Create(orb,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = Vector3.new(1.8, 1.8, 1.8)}
	):Play()

	-- Premium spawn flash
	pointLight.Brightness = 3
	TweenService:Create(pointLight,
		TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Brightness = 0.8}
	):Play()

	-- Dream ring spawn effect
	local spawnRing = Instance.new("ParticleEmitter")
	spawnRing.Texture = "rbxassetid://262979222"
	spawnRing.Rate = 0
	spawnRing.Speed = NumberRange.new(0)
	spawnRing.Lifetime = NumberRange.new(0.5)
	spawnRing.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),  -- Start as ring
		NumberSequenceKeypoint.new(1, 3.5)
	})
	spawnRing.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.6),
		NumberSequenceKeypoint.new(1, 1)
	})
	spawnRing.Color = ColorSequence.new(Color3.fromRGB(135, 206, 250))
	spawnRing.LightEmission = 0.5
	spawnRing.Parent = orb
	spawnRing:Emit(2)
	Debris:AddItem(spawnRing, 1) -- Only cleanup the effect!

	-- NO CLEANUP FOR ORBS - They stay until collected by the tycoon!
end