--[[
	Cinnamoroll Dropper 4 - Donut Dropper
	Drops cute pastel donuts
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

-- Strawberry cake colors
local COLORS = {
	Color3.fromRGB(255, 182, 193), -- Strawberry Pink
	Color3.fromRGB(255, 239, 213), -- Cream
	Color3.fromRGB(255, 204, 204), -- Light Pink
	Color3.fromRGB(255, 228, 225), -- Misty Rose
	Color3.fromRGB(250, 235, 215), -- Antique White
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

local cakeCount = 0

while true do
	task.wait(0.9) -- Medium-fast drop rate
	cakeCount = cakeCount + 1
	
	-- Create cake slice
	local cake = Instance.new("Part")
	cake.Name = "StrawberryCakeSlice"
	cake.Size = Vector3.new(2, 2, 2) -- Cake slice size
	cake.Material = Enum.Material.SmoothPlastic
	cake.Color = COLORS[math.random(1, #COLORS)]
	cake.TopSurface = Enum.SurfaceType.Smooth
	cake.BottomSurface = Enum.SurfaceType.Smooth
	cake.CanCollide = true
	cake.CanTouch = true
	cake.CanQuery = true
	
	-- Add cake slice mesh
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.FileMesh
	mesh.MeshId = "rbxassetid://16511869836" -- Strawberry Cake Slice
	mesh.TextureId = "" -- Use part color
	mesh.Scale = Vector3.new(0.5, 0.5, 0.5) -- Scale appropriately
	mesh.Parent = cake
	
	-- Frosting shine
	cake.Reflectance = 0.2
	
	-- Sweet glow
	local glow = Instance.new("PointLight")
	glow.Brightness = 0.6
	glow.Range = 7
	glow.Color = Color3.fromRGB(255, 204, 204) -- Pink glow
	glow.Parent = cake
	
	-- Strawberry particles
	local berries = Instance.new("ParticleEmitter")
	berries.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	berries.Rate = 8
	berries.Lifetime = NumberRange.new(1, 2)
	berries.Speed = NumberRange.new(0.5, 1)
	berries.SpreadAngle = Vector2.new(30, 30)
	berries.Color = ColorSequence.new(Color3.fromRGB(255, 99, 71)) -- Tomato red (strawberry)
	berries.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 0.1)
	}
	berries.LightEmission = 0.5
	berries.Parent = cake
	
	-- Cream particles
	local cream = Instance.new("ParticleEmitter")
	cream.Texture = "rbxasset://textures/particles/smoke_main.dds"
	cream.Rate = 5
	cream.Lifetime = NumberRange.new(1.5, 2.5)
	cream.Speed = NumberRange.new(0.3)
	cream.SpreadAngle = Vector2.new(45, 45)
	cream.Color = ColorSequence.new(Color3.fromRGB(255, 250, 240)) -- Cream white
	cream.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.7),
		NumberSequenceKeypoint.new(1, 1)
	}
	cream.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.4),
		NumberSequenceKeypoint.new(1, 0.8)
	}
	cream.LightEmission = 0.3
	cream.Parent = cake
	
	-- Soft outline
	local selection = Instance.new("SelectionBox")
	selection.Adornee = cake
	selection.Color3 = Color3.fromRGB(255, 182, 193)
	selection.Transparency = 0.6
	selection.LineThickness = 0.05
	selection.Parent = cake
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 4 -- Good value
	cash.Parent = cake
	
	-- Set collision group
	cake.CollisionGroup = "CinnamorollOrbs"
	
	-- Position at dropper
	cake.CFrame = dropPart.CFrame * CFrame.new(0, -2, 0)
	
	-- Cake physics
	cake.CustomPhysicalProperties = PhysicalProperties.new(
		0.4, -- Medium density
		0.6, -- Good friction
		0.1, -- Low bounce
		1, 1
	)
	
	-- Drop
	cake.AssemblyLinearVelocity = Vector3.new(0, -8, 0)
	
	-- Spawn animation
	cake.Transparency = 1
	mesh.Scale = Vector3.new(0.1, 0.1, 0.1)
	
	TweenService:Create(cake,
		TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Transparency = 0}
	):Play()
	
	TweenService:Create(mesh,
		TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Scale = Vector3.new(0.5, 0.5, 0.5)}
	):Play()
	
	-- Parent to workspace
	cake.Parent = PartStorage
end