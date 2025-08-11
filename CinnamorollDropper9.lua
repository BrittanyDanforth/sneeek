--[[
	Cinnamoroll Dropper 9 - Enhanced Fabric Cube Dropper
	Drops bouncy fabric cubes with trail effects
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

-- Pattern offset
local offsetAngle = 0

while true do
	task.wait(0.5) -- Fast drops!
	
	-- Create enhanced fabric cube
	local cube = Instance.new("Part")
	cube.Name = "EnhancedFabricCube"
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
	
	-- Bouncy physics
	cube.CustomPhysicalProperties = PhysicalProperties.new(
		0.15, -- Super light
		0.8,  -- Good friction
		0.5,  -- Extra bouncy!
		1, 1
	)
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 100
	cash.Parent = cube
	
	-- Enhanced glow
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 0.7
	pointLight.Range = 8
	pointLight.Color = Color3.fromRGB(100, 255, 100)
	pointLight.Parent = cube
	
	-- Gradient effect
	local gradient = Instance.new("SelectionBox")
	gradient.Adornee = cube
	gradient.Color3 = Color3.fromRGB(150, 255, 150)
	gradient.LineThickness = 0.08
	gradient.Transparency = 0.2
	gradient.Parent = cube
	
	-- Trail effect
	local attachment0 = Instance.new("Attachment")
	attachment0.Position = Vector3.new(0.5, 0.5, 0.5)
	attachment0.Parent = cube
	
	local attachment1 = Instance.new("Attachment")
	attachment1.Position = Vector3.new(-0.5, -0.5, -0.5)
	attachment1.Parent = cube
	
	local trail = Instance.new("Trail")
	trail.Attachment0 = attachment0
	trail.Attachment1 = attachment1
	trail.Color = ColorSequence.new(Color3.fromRGB(200, 255, 200))
	trail.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	}
	trail.Lifetime = 0.5
	trail.MinLength = 0
	trail.Parent = cube
	
	-- Sparkle trail
	local sparkles = Instance.new("ParticleEmitter")
	sparkles.Texture = "rbxasset://textures/particles/star.dds"
	sparkles.Rate = 20
	sparkles.Lifetime = NumberRange.new(0.3, 0.6)
	sparkles.Speed = NumberRange.new(1, 2)
	sparkles.SpreadAngle = Vector2.new(360, 360)
	sparkles.Size = NumberSequence.new(0.3)
	sparkles.Color = ColorSequence.new(Color3.fromRGB(150, 255, 150))
	sparkles.LightEmission = 0.5
	sparkles.Parent = cube
	
	-- Position with circular pattern
	offsetAngle = offsetAngle + 30
	local offsetX = math.cos(math.rad(offsetAngle)) * 0.5
	local offsetZ = math.sin(math.rad(offsetAngle)) * 0.5
	cube.CFrame = dropPart.CFrame - Vector3.new(offsetX, 1.4, offsetZ)
	
	-- Drop with lateral movement
	cube.AssemblyLinearVelocity = Vector3.new(offsetX * 3, -12, offsetZ * 3)
	cube.AssemblyAngularVelocity = Vector3.new(
		math.random(-5, 5),
		math.random(-5, 5),
		math.random(-5, 5)
	)
	
	-- Parent to storage
	cube.Parent = PartStorage
	
	-- Spawn animation (pop effect)
	cube.Size = Vector3.new(0.1, 0.1, 0.1)
	cube.Transparency = 0.5
	
	TweenService:Create(cube,
		TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = Vector3.new(1, 1, 1), Transparency = 0}
	):Play()
	
	-- Pulse effect
	task.spawn(function()
		task.wait(0.2)
		TweenService:Create(pointLight,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{Brightness = 1.2, Range = 10}
		):Play()
		task.wait(0.3)
		TweenService:Create(pointLight,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{Brightness = 0.7, Range = 8}
		):Play()
	end)
	
	-- NO CLEANUP - Enhanced cubes stay until collected!
end