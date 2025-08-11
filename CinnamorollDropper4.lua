--[[
	Cinnamoroll Dropper 4 - Customizable Color Dropper
	Uses parent's DropColor and MaterialValue
	NO CLEANUP - Orbs stay until collected
--]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")

-- Wait for PartStorage
task.wait(2)
local PartStorage = workspace:WaitForChild("PartStorage")

-- Find the Drop part
local dropPart = script.Parent:WaitForChild("Drop")

-- Get parent values
local parentModel = script.Parent.Parent.Parent
local dropColorValue = parentModel:WaitForChild("DropColor")
local materialValue = parentModel:WaitForChild("MaterialValue")

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

while true do
	task.wait(1) -- Drop rate
	
	-- Create customizable orb
	local orb = Instance.new("Part")
	orb.Name = "CustomOrb"
	orb.BrickColor = dropColorValue.Value
	orb.Material = materialValue.Value
	orb.Shape = Enum.PartType.Ball
	orb.Size = Vector3.new(1.7, 1.7, 1.7)
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	
	-- Collision settings
	orb.CanCollide = true
	orb.CanTouch = true
	orb.CanQuery = true
	
	-- Set collision group
	pcall(function()
		orb.CollisionGroup = ORB_GROUP
	end)
	
	-- Physics
	orb.CustomPhysicalProperties = PhysicalProperties.new(
		0.4,  -- Medium density
		0.5,  -- Medium friction
		0.1,  -- Low bounce
		1, 1
	)
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 30
	cash.Parent = orb
	
	-- Adaptive glow based on material
	if materialValue.Value == Enum.Material.Neon or materialValue.Value == Enum.Material.ForceField then
		local pointLight = Instance.new("PointLight")
		pointLight.Brightness = 0.8
		pointLight.Range = 6
		pointLight.Color = orb.Color
		pointLight.Parent = orb
	end
	
	-- Position
	orb.CFrame = dropPart.CFrame - Vector3.new(0, 1.75, 0)
	
	-- Drop velocity
	orb.AssemblyLinearVelocity = Vector3.new(0, -14, 0)
	
	-- Parent to storage
	orb.Parent = PartStorage
	
	-- Spawn animation
	orb.Size = Vector3.new(0.5, 0.5, 0.5)
	local spawnTween = TweenService:Create(orb,
		TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{Size = Vector3.new(1.7, 1.7, 1.7)}
	)
	spawnTween:Play()
	
	-- Spawn particles
	local spawnBurst = Instance.new("ParticleEmitter")
	spawnBurst.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	spawnBurst.Rate = 0
	spawnBurst.Speed = NumberRange.new(2, 4)
	spawnBurst.SpreadAngle = Vector2.new(360, 360)
	spawnBurst.Lifetime = NumberRange.new(0.5)
	spawnBurst.Size = NumberSequence.new(0.5)
	spawnBurst.Color = ColorSequence.new(orb.Color)
	spawnBurst.Parent = orb
	spawnBurst:Emit(10)
	Debris:AddItem(spawnBurst, 1)
	
	-- NO CLEANUP - Orbs stay until collected!
end