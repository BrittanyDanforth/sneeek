--[[
	Cinnamoroll Dropper 4 - Pastel Kawaii Style
	Drops soft pastel Cinnamoroll orbs
	NO CLEANUP - Orbs stay until collected
--]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local PhysicsService = game:GetService("PhysicsService")

-- Wait for PartStorage
task.wait(2)
local PartStorage = workspace:WaitForChild("PartStorage")

-- Find the Drop part
local dropPart = script.Parent:WaitForChild("Drop")

-- Cinnamoroll pastel colors
local COLORS = {
	Color3.fromRGB(255, 230, 240),    -- Soft pink
	Color3.fromRGB(230, 240, 255),    -- Soft blue
	Color3.fromRGB(255, 240, 230),    -- Soft peach
	Color3.fromRGB(240, 230, 255),    -- Soft lavender
	Color3.fromRGB(230, 255, 240),    -- Soft mint
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

local colorIndex = 1

while true do
	task.wait(1) -- Drop rate
	
	-- Create pastel orb
	local orb = Instance.new("Part")
	orb.Name = "PastelCinnamorollOrb"
	orb.Shape = Enum.PartType.Ball
	orb.Material = Enum.Material.ForceField -- Soft dreamy material
	orb.Size = Vector3.new(1.5, 1.5, 1.5)
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	orb.Color = COLORS[colorIndex]
	
	colorIndex = (colorIndex % #COLORS) + 1
	
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
		0.3,  -- Light
		0.5,  -- Medium friction
		0.2,  -- Small bounce
		1, 1
	)
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 30
	cash.Parent = orb
	
	-- Soft pastel glow
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 0.5
	pointLight.Range = 5
	pointLight.Color = orb.Color
	pointLight.Parent = orb
	
	-- Subtle outline
	local selection = Instance.new("SelectionBox")
	selection.Adornee = orb
	selection.Color3 = Color3.fromRGB(255, 255, 255) -- White outline
	selection.LineThickness = 0.03
	selection.Transparency = 0.5
	selection.Parent = orb
	
	-- Soft sparkles
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkle.Rate = 4
	sparkle.Lifetime = NumberRange.new(0.5, 1)
	sparkle.Speed = NumberRange.new(0.5, 1)
	sparkle.SpreadAngle = Vector2.new(180, 180)
	sparkle.Size = NumberSequence.new(0.2)
	sparkle.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	sparkle.LightEmission = 0.5
	sparkle.VelocityInheritance = 0.3
	sparkle.Parent = orb
	
	-- Position
	orb.CFrame = dropPart.CFrame - Vector3.new(0, 1.75, 0)
	
	-- Drop velocity
	orb.AssemblyLinearVelocity = Vector3.new(0, -14, 0)
	
	-- Slightly transparent
	orb.Transparency = 0.2
	
	-- Parent to storage
	orb.Parent = PartStorage
	
	-- Spawn animation
	orb.Size = Vector3.new(0.5, 0.5, 0.5)
	TweenService:Create(orb,
		TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{Size = Vector3.new(1.5, 1.5, 1.5)}
	):Play()
	
	-- Soft flash
	pointLight.Brightness = 1
	TweenService:Create(pointLight,
		TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Brightness = 0.5}
	):Play()
	
	-- NO CLEANUP - Orbs stay until collected!
end