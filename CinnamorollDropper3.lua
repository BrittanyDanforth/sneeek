--[[
	Cinnamoroll Dropper 3 - Premium Star Style
	Uses Kawaii Star mesh with rainbow effects
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

-- Soft pastel rainbow for a more subtle premium look
local function getRainbowColor(time)
	local hue = (time * 0.05) % 1 -- Slower color change
	local sat = 0.3 -- Low saturation for pastel
	local val = 0.95 -- High value for brightness
	return Color3.fromHSV(hue, sat, val)
end

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

local starCount = 0

while true do
	task.wait(0.6) -- Fast drop rate for premium
	starCount = starCount + 1
	
	-- Create star part
	local star = Instance.new("Part")
	star.Name = "PremiumStar_" .. starCount
	star.Size = Vector3.new(2, 2, 2) -- Base size for mesh
	star.Material = Enum.Material.Neon -- Premium glow
	star.Color = getRainbowColor(tick())
	star.TopSurface = Enum.SurfaceType.Smooth
	star.BottomSurface = Enum.SurfaceType.Smooth
	star.Transparency = 0
	
	-- Add kawaii star mesh
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.FileMesh
	mesh.MeshId = "rbxassetid://4580655175" -- Kawaii Star
	mesh.TextureId = "" -- Use part color
	mesh.Scale = Vector3.new(2, 2, 2) -- Scale for star
	mesh.Parent = star
	
	-- COLLISION
	star.CanCollide = true
	star.CanTouch = true
	star.CanQuery = true
	
	-- Set collision group
	pcall(function()
		star.CollisionGroup = ORB_GROUP
	end)
	
	-- Star physics
	star.CustomPhysicalProperties = PhysicalProperties.new(
		0.2, -- Light
		0.4, -- Medium friction
		0.3, -- Some bounce
		1, 1
	)
	
	-- Premium glow
	local glow = Instance.new("PointLight")
	glow.Brightness = 1
	glow.Range = 10
	glow.Color = star.Color
	glow.Parent = star
	
	-- Selection sphere for soft outline
	local selection = Instance.new("SelectionSphere")
	selection.Adornee = star
	selection.Color3 = getRainbowColor(tick() + 0.5)
	selection.SurfaceTransparency = 1
	selection.Transparency = 0.5
	selection.Parent = star
	
	-- Rainbow sparkles
	local sparkles = Instance.new("ParticleEmitter")
	sparkles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkles.Rate = 25
	sparkles.Lifetime = NumberRange.new(1.5, 2.5)
	sparkles.Speed = NumberRange.new(1, 2)
	sparkles.SpreadAngle = Vector2.new(45, 45)
	sparkles.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, getRainbowColor(tick())),
		ColorSequenceKeypoint.new(0.5, getRainbowColor(tick() + 0.5)),
		ColorSequenceKeypoint.new(1, getRainbowColor(tick() + 1))
	}
	sparkles.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.4),
		NumberSequenceKeypoint.new(0.5, 0.6),
		NumberSequenceKeypoint.new(1, 0)
	}
	sparkles.LightEmission = 0.8
	sparkles.VelocityInheritance = 0.3
	sparkles.Parent = star
	
	-- Star pattern particles
	local starParticles = Instance.new("ParticleEmitter")
	starParticles.Texture = "rbxasset://textures/particles/star.dds"
	starParticles.Rate = 10
	starParticles.Lifetime = NumberRange.new(2, 3)
	starParticles.Speed = NumberRange.new(1)
	starParticles.SpreadAngle = Vector2.new(180, 180)
	starParticles.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 0.1)
	}
	starParticles.Color = ColorSequence.new(Color3.fromRGB(255, 255, 200))
	starParticles.LightEmission = 1
	starParticles.Parent = star
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 50 -- Premium value
	cash.Parent = star
	
	-- Position at dropper
	star.CFrame = dropPart.CFrame - Vector3.new(0, 1.75, 0)
	
	-- Drop with slight spin
	star.AssemblyLinearVelocity = Vector3.new(0, -10, 0)
	star.AssemblyAngularVelocity = Vector3.new(0, 5, 0)
	
	-- Parent to workspace
	star.Parent = PartStorage
	
	-- Spawn animation
	mesh.Scale = Vector3.new(0.5, 0.5, 0.5)
	
	TweenService:Create(mesh,
		TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Scale = Vector3.new(2, 2, 2)}
	):Play()
	
	-- Flash effect
	glow.Brightness = 2
	TweenService:Create(glow,
		TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Brightness = 1}
	):Play()
	
	-- Premium spawn ring effect
	local spawnRing = Instance.new("Part")
	spawnRing.Name = "SpawnEffect"
	spawnRing.Shape = Enum.PartType.Cylinder
	spawnRing.Size = Vector3.new(0.1, 3, 3)
	spawnRing.Material = Enum.Material.ForceField
	spawnRing.Color = star.Color
	spawnRing.Transparency = 0.3
	spawnRing.Anchored = true
	spawnRing.CanCollide = false
	spawnRing.CFrame = star.CFrame * CFrame.Angles(0, 0, math.rad(90))
	spawnRing.Parent = PartStorage
	
	-- Animate spawn ring
	TweenService:Create(spawnRing,
		TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = Vector3.new(0.1, 5, 5), Transparency = 1}
	):Play()
	
	-- Clean up spawn effect
	task.delay(0.4, function()
		spawnRing:Destroy()
	end)
	
	-- Update color continuously
	task.spawn(function()
		while star.Parent do
			star.Color = getRainbowColor(tick())
			selection.Color3 = getRainbowColor(tick() + 0.5)
			glow.Color = star.Color
			task.wait(0.1)
		end
	end)
	
	-- NO CLEANUP - Stars stay until collected!
end