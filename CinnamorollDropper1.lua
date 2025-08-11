--[[
	Cinnamoroll Dropper 1 - Basic Kawaii Dropper
	Drops cute Bloxy Cola bottles with Cinnamoroll colors
	NO CLEANUP - Items stay until collected
--]]

local Debris = game:GetService("Debris")
local PhysicsService = game:GetService("PhysicsService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- Wait for PartStorage
wait(2)
workspace:WaitForChild("PartStorage")

-- Find the Drop part
local dropperPart = script.Parent:WaitForChild("Drop")

-- Variables for orb creation
local orbCount = 0

-- FIXED: Using new collision group API
local ORB_GROUP = "CinnamorollOrbs"
local PLAYER_GROUP = "Players"

-- Create collision groups
pcall(function()
	PhysicsService:RegisterCollisionGroup(ORB_GROUP)
	PhysicsService:RegisterCollisionGroup(PLAYER_GROUP)
	-- Orbs don't collide with players
	PhysicsService:CollisionGroupSetCollidable(ORB_GROUP, PLAYER_GROUP, false)
	-- Orbs don't collide with each other
	PhysicsService:CollisionGroupSetCollidable(ORB_GROUP, ORB_GROUP, false)
	print("Collision groups created successfully!")
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

-- Apply to existing and new players
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		setupPlayer(character)
	end)
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player.Character then
		task.spawn(function()
			setupPlayer(player.Character)
		end)
	end
end

-- Kawaii color palette
local COLORS = {
	Color3.fromRGB(255, 182, 193), -- Light Pink
	Color3.fromRGB(173, 216, 230), -- Light Blue  
	Color3.fromRGB(221, 160, 221), -- Plum
	Color3.fromRGB(152, 226, 255), -- Baby Blue
	Color3.fromRGB(255, 218, 185), -- Peach
}

while true do
	task.wait(1.2) -- Slow drop rate (basic dropper)
	local orb = Instance.new("Part", workspace.PartStorage)
	orb.Name = "KawaiiCupcake" 
	orb.Size = Vector3.new(1.5, 1.5, 1.5) -- Cupcake size
	orb.Material = Enum.Material.SmoothPlastic
	orb.Color = COLORS[math.random(1, #COLORS)]
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	orb.CanCollide = true
	orb.CanTouch = true
	orb.CanQuery = true
	
	-- Add kawaii cupcake mesh
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.FileMesh
	mesh.MeshId = "rbxassetid://20170940" -- Kawaii Cupcake from catalog
	mesh.TextureId = "" -- Use part color
	mesh.Scale = Vector3.new(0.02, 0.02, 0.02) -- Scale down the mesh appropriately
	mesh.Parent = orb
	
	-- Simple particles for basic dropper
	local particles = Instance.new("ParticleEmitter")
	particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particles.Rate = 5 -- Low rate for basic
	particles.Lifetime = NumberRange.new(1, 2)
	particles.Speed = NumberRange.new(0.5)
	particles.SpreadAngle = Vector2.new(45, 45)
	particles.Color = ColorSequence.new(orb.Color)
	particles.LightEmission = 0.3
	particles.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 0)
	}
	particles.Parent = orb
	
	-- Add cash value
	local cash = Instance.new("IntValue", orb)
	cash.Name = "Cash"
	cash.Value = 1 -- Basic value
	
	-- Set collision group
	orb.CollisionGroup = "CinnamorollOrbs"
	
	-- Position and drop
	orb.CFrame = dropperPart.CFrame * CFrame.new(0, -2, 0)
	
	-- Simple spawn animation
	orb.Transparency = 1
	TweenService:Create(orb,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Transparency = 0}
	):Play()
	
	TweenService:Create(mesh,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Scale = Vector3.new(0.02, 0.02, 0.02)}
	):Play()
	
	-- Parent to workspace after setup
	orb.Parent = workspace.PartStorage
end