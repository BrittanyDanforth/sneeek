--[[
	Cinnamoroll Dropper 11 - Marshmallow Drop Style
	Drops soft Cinnamoroll marshmallows
	NO CLEANUP - Marshmallows stay until collected
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

-- Marshmallow colors
local COLORS = {
	Color3.fromRGB(255, 250, 250), -- White
	Color3.fromRGB(255, 245, 250), -- Pink tint
	Color3.fromRGB(250, 250, 255), -- Blue tint
	Color3.fromRGB(255, 255, 250), -- Cream
}

local colorIndex = 1

while true do
	task.wait(1.5) -- Drop rate
	
	-- Create marshmallow
	local marshmallow = Instance.new("Part")
	marshmallow.Name = "Marshmallow"
	marshmallow.Shape = Enum.PartType.Block
	marshmallow.Size = Vector3.new(1.2, 1, 1.2)
	marshmallow.Material = Enum.Material.SmoothPlastic
	marshmallow.Color = COLORS[colorIndex]
	marshmallow.TopSurface = Enum.SurfaceType.Smooth
	marshmallow.BottomSurface = Enum.SurfaceType.Smooth
	
	colorIndex = (colorIndex % #COLORS) + 1
	
	-- Round the edges
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Brick
	mesh.Scale = Vector3.new(1, 0.8, 1)
	mesh.Parent = marshmallow
	
	-- Collision settings
	marshmallow.CanCollide = true
	marshmallow.CanTouch = true
	marshmallow.CanQuery = true
	
	-- Set collision group
	pcall(function()
		marshmallow.CollisionGroup = ORB_GROUP
	end)
	
	-- Soft physics
	marshmallow.CustomPhysicalProperties = PhysicalProperties.new(
		0.1,  -- Very light
		0.8,  -- High friction (sticky)
		0.4,  -- Bouncy
		1, 1
	)
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 100
	cash.Parent = marshmallow
	
	-- Soft glow
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 0.3
	pointLight.Range = 5
	pointLight.Color = Color3.fromRGB(255, 250, 240)
	pointLight.Parent = marshmallow
	
	-- Marshmallow transparency
	marshmallow.Transparency = 0.1
	
	-- Powdered sugar particles
	local powder = Instance.new("ParticleEmitter")
	powder.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	powder.Rate = 8
	powder.Lifetime = NumberRange.new(0.5, 1)
	powder.Speed = NumberRange.new(0.5, 1)
	powder.SpreadAngle = Vector2.new(180, 180)
	powder.Size = NumberSequence.new(0.1)
	powder.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	powder.LightEmission = 0.3
	powder.VelocityInheritance = 0.8
	powder.Parent = marshmallow
	
	-- Position with tumble
	marshmallow.CFrame = dropPart.CFrame * CFrame.Angles(
		math.rad(math.random(-20, 20)),
		math.rad(math.random(0, 360)),
		math.rad(math.random(-20, 20))
	) - Vector3.new(0, 5, 0)
	
	-- Drop with tumble
	marshmallow.AssemblyLinearVelocity = Vector3.new(
		math.random(-1, 1),
		-12,
		math.random(-1, 1)
	)
	marshmallow.AssemblyAngularVelocity = Vector3.new(
		math.random(-2, 2),
		math.random(-2, 2),
		math.random(-2, 2)
	)
	
	-- Parent to storage
	marshmallow.Parent = PartStorage
	
	-- Spawn animation (squish and bounce)
	mesh.Scale = Vector3.new(1.3, 0.5, 1.3)
	
	TweenService:Create(mesh,
		TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{Scale = Vector3.new(1, 0.8, 1)}
	):Play()
	
	-- Puff of sugar
	powder:Emit(20)
	
	-- NO CLEANUP - Marshmallows stay until collected!
end