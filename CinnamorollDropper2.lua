--[[
	Cinnamoroll Dropper 2 - Cloud Kawaii Dropper
	Drops cute cloud-shaped items with Cinnamoroll colors
	NO CLEANUP - Items stay until collected
--]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local PhysicsService = game:GetService("PhysicsService")

-- Wait for PartStorage
task.wait(2)
local PartStorage = workspace:WaitForChild("PartStorage")

-- Find the Drop part
local dropPart = script.Parent:WaitForChild("Drop")

-- Cinnamoroll cloud colors
local COLORS = {
	Color3.fromRGB(240, 248, 255),    -- Alice blue
	Color3.fromRGB(255, 240, 248),    -- Lavender blush
	Color3.fromRGB(230, 240, 255),    -- Light sky blue
	Color3.fromRGB(255, 245, 238),    -- Seashell
	Color3.fromRGB(240, 255, 255),    -- Azure
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

game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(setupPlayer)
end)

for _, player in ipairs(game.Players:GetPlayers()) do
	if player.Character then
		setupPlayer(player.Character)
	end
end

local cloudCount = 0

while true do
	task.wait(0.8) -- Slightly faster than Dropper 1
	cloudCount = cloudCount + 1
	
	-- Create cloud base
	local cloud = Instance.new("Part")
	cloud.Name = "KawaiiCloud"
	cloud.Size = Vector3.new(2, 1, 1.5) -- Cloud proportions
	cloud.Material = Enum.Material.ForceField
	cloud.Color = COLORS[math.random(1, #COLORS)]
	cloud.TopSurface = Enum.SurfaceType.Smooth
	cloud.BottomSurface = Enum.SurfaceType.Smooth
	cloud.Transparency = 0.2
	
	-- Make it more cloud-like with a mesh
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Scale = Vector3.new(1.2, 0.8, 1) -- Flatten for cloud shape
	mesh.Parent = cloud
	
	-- Cloud glow
	local glow = Instance.new("PointLight")
	glow.Brightness = 0.5
	glow.Range = 6
	glow.Color = cloud.Color
	glow.Parent = cloud
	
	-- Cloud outline
	local selection = Instance.new("SelectionSphere")
	selection.Adornee = cloud
	selection.Color3 = Color3.fromRGB(173, 216, 230) -- Light blue
	selection.SurfaceTransparency = 1
	selection.Transparency = 0.4
	selection.Parent = cloud
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 10 -- Higher than Dropper 1
	cash.Parent = cloud
	
	-- Position
	cloud.CFrame = dropPart.CFrame - Vector3.new(0, 2, 0)
	
	-- Set collision group
	pcall(function()
		cloud.CollisionGroup = ORB_GROUP
	end)
	
	-- Cloud physics
	cloud.CustomPhysicalProperties = PhysicalProperties.new(
		0.1,  -- Very light
		0.3,  -- Low friction
		0,    -- No bounce
		1, 1
	)
	
	-- Float down
	cloud.AssemblyLinearVelocity = Vector3.new(
		math.random(-2, 2),
		-8,  -- Slower fall
		math.random(-2, 2)
	)
	
	-- Parent to storage
	cloud.Parent = PartStorage
	
	-- Spawn animation
	mesh.Scale = Vector3.new(0.1, 0.1, 0.1)
	TweenService:Create(mesh,
		TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{Scale = Vector3.new(1.2, 0.8, 1)}
	):Play()
	
	-- Cloud particles
	local mist = Instance.new("ParticleEmitter")
	mist.Texture = "rbxasset://textures/particles/smoke_main.dds"
	mist.Rate = 3
	mist.Lifetime = NumberRange.new(1, 2)
	mist.Speed = NumberRange.new(0.5)
	mist.SpreadAngle = Vector2.new(180, 180)
	mist.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	}
	mist.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(1, 1)
	}
	mist.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	mist.VelocityInheritance = 0.5
	mist.Parent = cloud
	
	-- Sparkles
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkle.Rate = 5
	sparkle.Lifetime = NumberRange.new(0.5, 1)
	sparkle.Speed = NumberRange.new(0.5)
	sparkle.SpreadAngle = Vector2.new(180, 180)
	sparkle.Size = NumberSequence.new(0.3)
	sparkle.Color = ColorSequence.new(cloud.Color)
	sparkle.LightEmission = 0.8
	sparkle.Parent = cloud
	
	-- NO CLEANUP - Clouds stay until collected!
end