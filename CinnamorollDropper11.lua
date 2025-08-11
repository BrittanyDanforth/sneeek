--[[
	Cinnamoroll Dropper 11 - Paintball Gun Dropper
	Drops colorful paintball guns
	NO CLEANUP - Guns stay until collected
--]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local PhysicsService = game:GetService("PhysicsService")

-- Wait for PartStorage
task.wait(2)
local PartStorage = workspace:WaitForChild("PartStorage")

-- Find the Drop part
local dropPart = script.Parent:WaitForChild("Drop")

-- Mesh settings
local meshID = "rbxasset://fonts/PaintballGun.mesh"
local textureID = "rbxasset://textures/PaintballGunTex128.png"

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

-- Colors for variety
local COLORS = {
	Color3.fromRGB(255, 100, 100), -- Red
	Color3.fromRGB(100, 100, 255), -- Blue
	Color3.fromRGB(100, 255, 100), -- Green
	Color3.fromRGB(255, 255, 100), -- Yellow
	Color3.fromRGB(255, 100, 255), -- Magenta
}

local colorIndex = 1

while true do
	task.wait(1.5) -- Drop rate
	
	-- Create paintball gun
	local gun = Instance.new("Part")
	gun.Name = "PaintballGun"
	gun.Size = Vector3.new(0.2, 0.2, 0.2) -- Small base size
	gun.TopSurface = Enum.SurfaceType.Smooth
	gun.BottomSurface = Enum.SurfaceType.Smooth
	gun.Material = Enum.Material.Plastic
	gun.BrickColor = BrickColor.new("Medium stone grey")
	
	-- Collision settings
	gun.CanCollide = true
	gun.CanTouch = true
	gun.CanQuery = true
	
	-- Set collision group
	pcall(function()
		gun.CollisionGroup = ORB_GROUP
	end)
	
	-- Gun mesh
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshId = meshID
	mesh.TextureId = textureID
	mesh.Scale = Vector3.new(0.8, 0.8, 0.8)
	mesh.Parent = gun
	
	-- Physics
	gun.CustomPhysicalProperties = PhysicalProperties.new(
		0.5,  -- Medium weight
		0.6,  -- Good friction
		0.2,  -- Small bounce
		1, 1
	)
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 100
	cash.Parent = gun
	
	-- Colorful glow
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 0.6
	pointLight.Range = 8
	pointLight.Color = COLORS[colorIndex]
	pointLight.Parent = gun
	
	colorIndex = (colorIndex % #COLORS) + 1
	
	-- Paint splatter particles
	local paint = Instance.new("ParticleEmitter")
	paint.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	paint.Rate = 15
	paint.Lifetime = NumberRange.new(0.3, 0.8)
	paint.Speed = NumberRange.new(2, 4)
	paint.SpreadAngle = Vector2.new(60, 60)
	paint.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 0.1)
	}
	paint.Color = ColorSequence.new(pointLight.Color)
	paint.LightEmission = 0.5
	paint.VelocityInheritance = 0.2
	paint.EmissionDirection = Enum.NormalId.Front
	paint.Parent = gun
	
	-- Position
	gun.CFrame = dropPart.CFrame * CFrame.Angles(math.rad(-90), 0, 0) - Vector3.new(0, 5, 0)
	
	-- Drop with tumble
	gun.AssemblyLinearVelocity = Vector3.new(
		math.random(-2, 2),
		-15,
		math.random(-2, 2)
	)
	gun.AssemblyAngularVelocity = Vector3.new(
		math.random(-3, 3),
		math.random(-3, 3),
		math.random(-3, 3)
	)
	
	-- Parent to storage
	gun.Parent = PartStorage
	
	-- Spawn animation
	mesh.Scale = Vector3.new(0.1, 0.1, 0.1)
	gun.Transparency = 0.5
	
	TweenService:Create(mesh,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Scale = Vector3.new(0.8, 0.8, 0.8)}
	):Play()
	
	TweenService:Create(gun,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Transparency = 0}
	):Play()
	
	-- Flash effect
	pointLight.Brightness = 2
	TweenService:Create(pointLight,
		TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Brightness = 0.6}
	):Play()
	
	-- Paint burst on spawn
	paint:Emit(20)
	
	-- NO CLEANUP - Paintball guns stay until collected!
end