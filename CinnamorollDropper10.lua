--[[
	Cinnamoroll Dropper 10 - Premium Fabric Cube Dropper
	Drops morphing fabric cubes with rainbow effects
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

-- Rainbow colors
local rainbowPhase = 0
local dropCount = 0

while true do
	task.wait(0.5) -- Fast drops!
	dropCount = dropCount + 1
	
	-- Create premium fabric cube
	local cube = Instance.new("Part")
	cube.Name = "PremiumFabricCube"
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
	
	-- Premium physics
	cube.CustomPhysicalProperties = PhysicalProperties.new(
		0.1,  -- Ultra light
		0.7,  -- Good friction
		0.4,  -- Nice bounce
		1, 1
	)
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 100
	cash.Parent = cube
	
	-- Premium rainbow glow
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 0.8
	pointLight.Range = 10
	pointLight.Color = Color3.fromRGB(50, 255, 50)
	pointLight.Parent = cube
	
	-- Double outline effect
	local outline1 = Instance.new("SelectionBox")
	outline1.Adornee = cube
	outline1.Color3 = Color3.fromRGB(200, 255, 200)
	outline1.LineThickness = 0.1
	outline1.Transparency = 0.2
	outline1.Parent = cube
	
	local outline2 = Instance.new("SelectionBox")
	outline2.Adornee = cube
	outline2.Color3 = Color3.fromRGB(100, 255, 100)
	outline2.LineThickness = 0.15
	outline2.Transparency = 0.5
	outline2.Parent = cube
	
	-- Premium particles
	local magic = Instance.new("ParticleEmitter")
	magic.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	magic.Rate = 30
	magic.Lifetime = NumberRange.new(0.5, 1.5)
	magic.Speed = NumberRange.new(1, 3)
	magic.SpreadAngle = Vector2.new(360, 360)
	magic.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.5, 0.3),
		NumberSequenceKeypoint.new(1, 0)
	}
	magic.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 200)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 255, 200)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 255, 255))
	}
	magic.LightEmission = 0.8
	magic.VelocityInheritance = 0.3
	magic.Parent = cube
	
	-- Beam effect
	local attach1 = Instance.new("Attachment")
	attach1.Position = Vector3.new(0, 0.5, 0)
	attach1.Parent = cube
	
	local attach2 = Instance.new("Attachment")
	attach2.Position = Vector3.new(0, -0.5, 0)
	attach2.Parent = cube
	
	local beam = Instance.new("Beam")
	beam.Attachment0 = attach1
	beam.Attachment1 = attach2
	beam.Color = ColorSequence.new(Color3.fromRGB(150, 255, 150))
	beam.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(0.5, 0.5),
		NumberSequenceKeypoint.new(1, 0.8)
	}
	beam.Width0 = 2
	beam.Width1 = 2
	beam.Parent = cube
	
	-- Spiral position
	local spiralRadius = 0.5
	local spiralAngle = dropCount * 0.5
	local offsetX = math.cos(spiralAngle) * spiralRadius
	local offsetZ = math.sin(spiralAngle) * spiralRadius
	local offsetY = math.sin(dropCount * 0.3) * 0.2
	
	cube.CFrame = dropPart.CFrame - Vector3.new(offsetX, 1.4 - offsetY, offsetZ)
	
	-- Complex movement
	cube.AssemblyLinearVelocity = Vector3.new(
		offsetX * 4,
		-8 + offsetY * 2,
		offsetZ * 4
	)
	cube.AssemblyAngularVelocity = Vector3.new(3, 6, 3)
	
	-- Parent to storage
	cube.Parent = PartStorage
	
	-- Morph animation
	cube.Size = Vector3.new(2, 0.1, 2)
	
	TweenService:Create(cube,
		TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{Size = Vector3.new(1, 1, 1)}
	):Play()
	
	-- Rainbow color animation
	task.spawn(function()
		local hue = 0
		while cube.Parent do
			hue = (hue + 2) % 360
			local color = Color3.fromHSV(hue/360, 0.3, 1) -- Soft pastel rainbow
			pointLight.Color = color
			outline1.Color3 = color
			task.wait(0.1)
		end
	end)
	
	-- Pulse animation
	task.spawn(function()
		task.wait(0.3)
		while cube.Parent do
			TweenService:Create(cube,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Size = Vector3.new(1.1, 1.1, 1.1)}
			):Play()
			task.wait(0.5)
			TweenService:Create(cube,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Size = Vector3.new(1, 1, 1)}
			):Play()
			task.wait(0.5)
		end
	end)
	
	-- NO CLEANUP - Premium cubes stay until collected!
end