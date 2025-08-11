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
	wait(0.7) -- Drop rate
	orbCount = orbCount + 1
	
	-- Create kawaii cola bottle
	local orb = Instance.new("Part", workspace.PartStorage)
	orb.Name = "KawaiiCola"
	orb.Size = Vector3.new(1, 1, 1) -- Base size for mesh
	orb.Material = Enum.Material.Plastic
	orb.Color = COLORS[math.random(1, #COLORS)]
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	
	-- Add Bloxy Cola mesh
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshId = "rbxassetid://10470609"
	mesh.TextureId = "" -- No texture, use part color
	mesh.Scale = Vector3.new(0.8, 0.8, 0.8) -- Slightly smaller for cuteness
	mesh.Parent = orb
	
	-- Basic glow
	local glow = Instance.new("PointLight")
	glow.Brightness = 0.3
	glow.Range = 4
	glow.Color = orb.Color
	glow.Parent = orb
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 5 -- Low value for basic dropper
	cash.Parent = orb
	
	-- Position at dropper
	orb.CFrame = script.Parent.Drop.CFrame - Vector3.new(0, 2, 0)
	
	-- Set collision group
	pcall(function()
		orb.CollisionGroup = ORB_GROUP
	end)
	
	-- Basic physics
	orb.CustomPhysicalProperties = PhysicalProperties.new(
		0.3, -- Low density
		0.5, -- Medium friction
		0.2, -- Low bounce
		1, 1
	)
	
	-- Drop velocity
	orb.AssemblyLinearVelocity = Vector3.new(0, -15, 0)
	
	-- Simple spawn animation
	mesh.Scale = Vector3.new(0.1, 0.1, 0.1)
	TweenService:Create(mesh,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Scale = Vector3.new(0.8, 0.8, 0.8)}
	):Play()
	
	-- Simple sparkle
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkle.Rate = 2
	sparkle.Lifetime = NumberRange.new(0.5)
	sparkle.Speed = NumberRange.new(0.5)
	sparkle.SpreadAngle = Vector2.new(180, 180)
	sparkle.Size = NumberSequence.new(0.2)
	sparkle.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	sparkle.LightEmission = 0.5
	sparkle.Parent = orb
	
	-- NO CLEANUP - Items stay until collected!
end