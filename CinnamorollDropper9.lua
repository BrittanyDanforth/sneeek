--[[
	Cinnamoroll Dropper 9 - Star Drop Style
	Drops twinkling star-shaped Cinnamoroll orbs
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

-- Cinnamoroll star colors
local COLORS = {
	Color3.fromRGB(255, 240, 250),    -- Pink star
	Color3.fromRGB(240, 250, 255),    -- Blue star
	Color3.fromRGB(255, 250, 240),    -- Yellow star
	Color3.fromRGB(250, 240, 255),    -- Purple star
	Color3.fromRGB(240, 255, 250),    -- Mint star
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

-- Star pattern
local starAngle = 0

while true do
	task.wait(0.5) -- Fast drops!
	
	-- Create star orb
	local orb = Instance.new("Part")
	orb.Name = "StarOrb"
	orb.Shape = Enum.PartType.Ball
	orb.Size = Vector3.new(1.4, 1.4, 1.4)
	orb.Material = Enum.Material.ForceField
	orb.Color = COLORS[math.random(1, #COLORS)]
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
	
	-- Star physics
	orb.CustomPhysicalProperties = PhysicalProperties.new(
		0.2,  -- Light
		0.5,  -- Medium friction
		0.3,  -- Some bounce
		1, 1
	)
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 100
	cash.Parent = orb
	
	-- Star glow
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 0.6
	pointLight.Range = 8
	pointLight.Color = orb.Color
	pointLight.Parent = orb
	
	-- Star outline
	local selection = Instance.new("SelectionBox")
	selection.Adornee = orb
	selection.Color3 = Color3.fromRGB(255, 255, 255)
	selection.LineThickness = 0.05
	selection.Transparency = 0.3
	selection.Parent = orb
	
	-- Twinkling stars
	local stars = Instance.new("ParticleEmitter")
	stars.Texture = "rbxasset://textures/particles/star.dds"
	stars.Rate = 15
	stars.Lifetime = NumberRange.new(0.5, 1.5)
	stars.Speed = NumberRange.new(1, 3)
	stars.SpreadAngle = Vector2.new(360, 360)
	stars.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.4),
		NumberSequenceKeypoint.new(1, 0)
	}
	stars.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	stars.LightEmission = 0.8
	stars.Parent = orb
	
	-- Sparkle trail
	local sparkles = Instance.new("ParticleEmitter")
	sparkles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkles.Rate = 10
	sparkles.Lifetime = NumberRange.new(0.3, 0.8)
	sparkles.Speed = NumberRange.new(0.5)
	sparkles.SpreadAngle = Vector2.new(180, 180)
	sparkles.Size = NumberSequence.new(0.2)
	sparkles.Color = ColorSequence.new(orb.Color)
	sparkles.LightEmission = 0.6
	sparkles.VelocityInheritance = 0.5
	sparkles.Parent = orb
	
	-- Star spin position
	starAngle = starAngle + 45
	local starX = math.cos(math.rad(starAngle)) * 0.4
	local starZ = math.sin(math.rad(starAngle)) * 0.4
	orb.CFrame = dropPart.CFrame - Vector3.new(starX, 1.4, starZ)
	
	-- Drop with twinkle
	orb.AssemblyLinearVelocity = Vector3.new(starX * 2, -10, starZ * 2)
	orb.AssemblyAngularVelocity = Vector3.new(
		math.random(-3, 3),
		5,
		math.random(-3, 3)
	)
	
	-- Slight transparency
	orb.Transparency = 0.1
	
	-- Parent to storage
	orb.Parent = PartStorage
	
	-- Spawn animation (star burst)
	orb.Size = Vector3.new(0.1, 0.1, 0.1)
	
	TweenService:Create(orb,
		TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = Vector3.new(1.4, 1.4, 1.4)}
	):Play()
	
	-- Star flash
	pointLight.Brightness = 2
	TweenService:Create(pointLight,
		TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Brightness = 0.6}
	):Play()
	
	-- Twinkle animation
	task.spawn(function()
		while orb.Parent do
			TweenService:Create(pointLight,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Brightness = 0.8}
			):Play()
			task.wait(0.5)
			TweenService:Create(pointLight,
				TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Brightness = 0.4}
			):Play()
			task.wait(0.5)
		end
	end)
	
	-- NO CLEANUP - Star orbs stay until collected!
end