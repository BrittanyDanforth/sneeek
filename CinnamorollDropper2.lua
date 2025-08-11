--[[
	Cinnamoroll Dropper 2 - Enhanced Kawaii Style
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

-- Create collision groups
local ORB_GROUP = "CinnamorollOrbs"
local PLAYER_GROUP = "Players"

pcall(function()
	PhysicsService:RegisterCollisionGroup(ORB_GROUP)
	PhysicsService:RegisterCollisionGroup(PLAYER_GROUP)
	PhysicsService:CollisionGroupSetCollidable(ORB_GROUP, PLAYER_GROUP, false)
	PhysicsService:CollisionGroupSetCollidable(ORB_GROUP, ORB_GROUP, false)
end)

-- Setup player collision groups
local function setupPlayer(character)
	task.wait(0.1)
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			pcall(function()
				part.CollisionGroup = PLAYER_GROUP
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
	task.wait(1) -- Faster drops

	-- Create fluffy orb
	local orb = Instance.new("Part")
	orb.Name = "CinnamorollCloud"
	orb.Shape = Enum.PartType.Ball
	orb.Material = Enum.Material.Neon
	orb.Size = Vector3.new(1.6, 1.6, 1.6)
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	orb.Color = COLORS[rng:NextInteger(1, #COLORS)]

	-- Collision settings
	orb.CanCollide = true
	orb.CanTouch = true
	orb.CanQuery = true

	-- Set collision group
	pcall(function()
		orb.CollisionGroup = ORB_GROUP
	end)

	-- Fluffy physics
	orb.CustomPhysicalProperties = PhysicalProperties.new(
		0.2,  -- Super light like a cloud
		0.3,  -- Low friction
		0,    -- No bounce
		1, 1
	)

	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 15
	cash.Parent = orb

	-- Reduced glow
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 0.6
	pointLight.Range = 4
	pointLight.Color = Color3.fromRGB(190, 210, 235)
	pointLight.Parent = orb

	-- Selection sphere outline
	local selection = Instance.new("SelectionSphere")
	selection.Adornee = orb
	selection.Color3 = Color3.fromRGB(135, 206, 250)
	selection.SurfaceTransparency = 1  -- No texture
	selection.Transparency = 0.3
	selection.Parent = orb

	-- Enhanced sparkles
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkle.Rate = 5
	sparkle.Lifetime = NumberRange.new(0.5, 1.5)
	sparkle.Speed = NumberRange.new(0.5, 2)
	sparkle.SpreadAngle = Vector2.new(180, 180)
	sparkle.LightEmission = 1
	sparkle.LightInfluence = 0
	sparkle.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 0)
	}
	sparkle.Color = ColorSequence.new(orb.Color)
	sparkle.Parent = orb
	
	-- Star particles
	local stars = Instance.new("ParticleEmitter")
	stars.Texture = "rbxasset://textures/particles/star.dds"
	stars.Rate = 2
	stars.Lifetime = NumberRange.new(1, 2)
	stars.Speed = NumberRange.new(0.5)
	stars.SpreadAngle = Vector2.new(360, 360)
	stars.LightEmission = 0.8
	stars.Size = NumberSequence.new(0.4)
	stars.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	stars.Parent = orb

	-- Pattern positioning
	local offset = patterns[dropPattern]
	dropPattern = (dropPattern % #patterns) + 1

	orb.CFrame = dropPart.CFrame - Vector3.new(0, 1.75, 0) + offset

	-- Float down gently
	orb.AssemblyLinearVelocity = Vector3.new(
		offset.X * 2,
		-10,
		offset.Z * 2
	)

	-- Fully solid
	orb.Transparency = 0

	-- Set spawn time
	orb:SetAttribute("SpawnTime", time())

	-- Parent to storage
	orb.Parent = PartStorage

	-- Bounce spawn animation
	orb.Size = Vector3.new(0.4, 0.4, 0.4)
	TweenService:Create(orb,
		TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{Size = Vector3.new(1.6, 1.6, 1.6)}
	):Play()

	-- Magical spawn flash
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
	Debris:AddItem(spawnPuff, 1) -- Only cleanup the effect!

	-- NO CLEANUP FOR ORBS - They stay until collected by the tycoon!
end