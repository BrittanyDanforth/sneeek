--[[
	Cinnamoroll Dropper 3 - Premium Star Dropper
	Drops magical star items with rainbow effects
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
	
	-- Create star base
	local star = Instance.new("Part")
	star.Name = "PastelStar"
	star.Size = Vector3.new(2, 2, 0.5) -- Flat star shape
	star.Material = Enum.Material.ForceField -- Softer than Neon
	star.Color = getRainbowColor(tick())
	star.Transparency = 0.1
	star.TopSurface = Enum.SurfaceType.Smooth
	star.BottomSurface = Enum.SurfaceType.Smooth
	star.CanCollide = true
	star.CanTouch = true
	star.CanQuery = true
	
	-- Star mesh
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.FileMesh
	mesh.MeshId = "rbxassetid://3270017" -- Classic star mesh
	mesh.Scale = Vector3.new(1.2, 1.2, 0.4) -- Slightly smaller
	mesh.Parent = star
	
	-- Soft glow
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
	
	-- Softer sparkles
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
	
	-- Simpler trail effect
	local attachment1 = Instance.new("Attachment")
	attachment1.Position = Vector3.new(1, 0, 0)
	attachment1.Parent = star
	
	local attachment2 = Instance.new("Attachment")
	attachment2.Position = Vector3.new(-1, 0, 0)
	attachment2.Parent = star
	
	local trail = Instance.new("Trail")
	trail.Attachment0 = attachment1
	trail.Attachment1 = attachment2
	trail.Color = ColorSequence.new(star.Color)
	trail.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	}
	trail.Lifetime = 0.5
	trail.MinLength = 0
	trail.FaceCamera = true
	trail.Parent = star
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 5 -- Premium value
	cash.Parent = star
	
	-- Set collision group
	star.CollisionGroup = "CinnamorollOrbs"
	
	-- Position at dropper
	star.CFrame = dropPart.CFrame * CFrame.new(0, -2, 0)
	
	-- Star physics
	star.CustomPhysicalProperties = PhysicalProperties.new(
		0.2, -- Light
		0.4, -- Medium friction
		0.3, -- Some bounce
		1, 1
	)
	
	-- Drop with slight spin
	star.AssemblyLinearVelocity = Vector3.new(0, -10, 0)
	star.AssemblyAngularVelocity = Vector3.new(0, 5, 0)
	
	-- Spawn animation (simpler)
	star.Transparency = 0.8
	mesh.Scale = Vector3.new(0.1, 0.1, 0.1)
	
	-- Simple spawn ring effect
	local spawnRing = Instance.new("Part")
	spawnRing.Name = "SpawnEffect"
	spawnRing.Size = Vector3.new(1, 0.1, 1)
	spawnRing.Material = Enum.Material.ForceField
	spawnRing.Color = star.Color
	spawnRing.Transparency = 0.3
	spawnRing.Anchored = true
	spawnRing.CanCollide = false
	spawnRing.CFrame = star.CFrame
	spawnRing.Parent = PartStorage
	
	local ringMesh = Instance.new("SpecialMesh")
	ringMesh.MeshType = Enum.MeshType.Sphere
	ringMesh.Scale = Vector3.new(3, 0.1, 3)
	ringMesh.Parent = spawnRing
	
	-- Animate spawn
	TweenService:Create(star,
		TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Transparency = 0.1}
	):Play()
	
	TweenService:Create(mesh,
		TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Scale = Vector3.new(1.2, 1.2, 0.4)}
	):Play()
	
	TweenService:Create(spawnRing,
		TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = Vector3.new(5, 0.1, 5), Transparency = 1}
	):Play()
	
	TweenService:Create(ringMesh,
		TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Scale = Vector3.new(5, 0.1, 5)}
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
			trail.Color = ColorSequence.new(star.Color)
			glow.Color = star.Color
			task.wait(0.1)
		end
	end)
	
	-- Parent to workspace
	star.Parent = PartStorage
end