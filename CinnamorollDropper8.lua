--[[
	Cinnamoroll Dropper 8 - Lime Fabric Cube Dropper
	Drops soft fabric cubes with kawaii effects
	NO CLEANUP - Cubes stay until collected
--]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local PhysicsService = game:GetService("PhysicsService")

-- Wait for PartStorage
task.wait(2)
local PartStorage = workspace:WaitForChild("PartStorage")

-- Find the Drop part
local dropPart = script.Parent:WaitForChild("Drop")

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

game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(setupPlayer)
end)

for _, player in ipairs(game.Players:GetPlayers()) do
	if player.Character then
		setupPlayer(player.Character)
	end
end

-- Rotation pattern
local rotation = 0

while true do
	task.wait(0.5) -- Fast drops!
	
	-- Create fabric cube
	local cube = Instance.new("Part")
	cube.Name = "FabricCube"
	cube.Shape = Enum.PartType.Block
	cube.Size = Vector3.new(1, 1, 1)
	cube.BrickColor = BrickColor.new("Lime green")
	cube.Material = Enum.Material.Fabric
	cube.TopSurface = Enum.SurfaceType.Smooth
	cube.BottomSurface = Enum.SurfaceType.Smooth
	
	-- Collision settings
	cube.CanCollide = true
	cube.CanTouch = true
	cube.CanQuery = true
	
	-- Set collision group
	pcall(function()
		cube.CollisionGroup = ORB_GROUP
	end)
	
	-- Soft physics (it's fabric!)
	cube.CustomPhysicalProperties = PhysicalProperties.new(
		0.2,  -- Light
		0.9,  -- High friction (fabric grips)
		0.3,  -- Some bounce (soft)
		1, 1
	)
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 100
	cash.Parent = cube
	
	-- Fabric glow
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 0.5
	pointLight.Range = 6
	pointLight.Color = Color3.fromRGB(50, 255, 50) -- Bright lime
	pointLight.Parent = cube
	
	-- Soft outline
	local selection = Instance.new("SelectionBox")
	selection.Adornee = cube
	selection.Color3 = Color3.fromRGB(100, 255, 100)
	selection.LineThickness = 0.05
	selection.Transparency = 0.3
	selection.Parent = cube
	
	-- Fabric particles
	local fabric = Instance.new("ParticleEmitter")
	fabric.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	fabric.Rate = 10
	fabric.Lifetime = NumberRange.new(0.5, 1)
	fabric.Speed = NumberRange.new(0.5, 1)
	fabric.SpreadAngle = Vector2.new(180, 180)
	fabric.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 0)
	}
	fabric.Color = ColorSequence.new(Color3.fromRGB(200, 255, 200))
	fabric.LightEmission = 0.3
	fabric.VelocityInheritance = 0.5
	fabric.Parent = cube
	
	-- Position with spin
	rotation = rotation + 15
	cube.CFrame = dropPart.CFrame * CFrame.Angles(math.rad(rotation), 0, math.rad(rotation)) - Vector3.new(0, 1.4, 0)
	
	-- Drop with spin
	cube.AssemblyLinearVelocity = Vector3.new(0, -10, 0)
	cube.AssemblyAngularVelocity = Vector3.new(2, 4, 2)
	
	-- Parent to storage
	cube.Parent = PartStorage
	
	-- Spawn animation (compress and release)
	cube.Size = Vector3.new(0.5, 2, 0.5)
	
	TweenService:Create(cube,
		TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{Size = Vector3.new(1, 1, 1)}
	):Play()
	
	-- Flash
	pointLight.Brightness = 1.5
	TweenService:Create(pointLight,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Brightness = 0.5}
	):Play()
	
	-- NO CLEANUP - Fabric cubes stay until collected!
end