--[[
	Cinnamoroll Dropper 2 - Enhanced Kawaii Style
	Fixed: Collides with conveyor/ground but not players
	Removed debug prints
--]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local PhysicsService = game:GetService("PhysicsService")

-- Wait for PartStorage
task.wait(2)
local PartStorage = workspace:WaitForChild("PartStorage")

-- Find the Drop part
local dropPart = script.Parent:WaitForChild("Drop")

-- Pattern for anti-stacking
local dropPattern = 1

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

local orbCount = 0

while true do
	task.wait(1) -- Faster drops

	orbCount = orbCount + 1

	-- Create regular Part with SpecialMesh
	local orb = Instance.new("Part")
	orb.Name = "CinnamorollMesh_" .. orbCount
	orb.Size = Vector3.new(2, 2, 2) -- Base size
	orb.Material = Enum.Material.SmoothPlastic  -- Clean material
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	orb.Color = Color3.new(1, 1, 1) -- White to show texture properly
	orb.Transparency = 0 -- Fully visible

	-- Add mesh
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.FileMesh
	mesh.MeshId = "rbxassetid://114684643919279"  -- Cinnamoroll Plushie mesh
	mesh.TextureId = "rbxassetid://136339015269351"  -- Cinnamoroll Plushie texture
	mesh.Scale = Vector3.new(2, 2, 2) -- Adjust scale as needed
	mesh.Parent = orb

	-- COLLISION FIXED!
	orb.CanCollide = true -- Now collides with conveyor
	orb.CanTouch = true
	orb.CanQuery = true

	-- Set collision group
	pcall(function()
		orb.CollisionGroup = ORB_GROUP
	end)

	-- Fluffy physics
	orb.CustomPhysicalProperties = PhysicalProperties.new(
		0.2,  -- Super light like a cloud
		0.3,  -- Low friction
		0,    -- No bounce
		1, 1
	)

	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 15
	cash.Parent = orb

	-- REDUCED GLOW
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 0.6  -- Reduced from 1.5
	pointLight.Range = 4         -- Reduced from 7
	pointLight.Color = Color3.new(1, 1, 1)  -- White light
	pointLight.Parent = orb

	-- ENHANCED sparkles with color
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkle.Rate = 5          -- More sparkles for mid-tier
	sparkle.Lifetime = NumberRange.new(0.5, 1.5)
	sparkle.Speed = NumberRange.new(0.5, 2)
	sparkle.SpreadAngle = Vector2.new(180, 180)
	sparkle.LightEmission = 1  -- Full glow
	sparkle.LightInfluence = 0
	sparkle.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 0)
	}
	-- White sparkles to match Cinnamoroll
	sparkle.Color = ColorSequence.new(Color3.new(1, 1, 1))
	sparkle.Parent = orb

	-- Add secondary star particles
	local stars = Instance.new("ParticleEmitter")
	stars.Texture = "rbxasset://textures/particles/star.dds"
	stars.Rate = 2
	stars.Lifetime = NumberRange.new(1, 2)
	stars.Speed = NumberRange.new(0.5)
	stars.SpreadAngle = Vector2.new(360, 360)
	stars.LightEmission = 0.8
	stars.Size = NumberSequence.new(0.4)
	stars.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	stars.Parent = orb

	-- Pattern positioning
	local patterns = {
		Vector3.new(0.2, 0, 0.2),
		Vector3.new(-0.2, 0, 0.2),
		Vector3.new(0.2, 0, -0.2),
		Vector3.new(-0.2, 0, -0.2),
		Vector3.new(0, 0, 0),
	}
	local offset = patterns[dropPattern]
	dropPattern = (dropPattern % #patterns) + 1

	-- Normal spawn (no 180 degree rotation)
	orb.CFrame = dropPart.CFrame - Vector3.new(0, 1.75, 0) + offset

	-- Float down gently
	orb.AssemblyLinearVelocity = Vector3.new(
		offset.X * 2,
		-10,  -- Gentle float
		offset.Z * 2
	)

	-- Semi-transparent cloud
	orb.Transparency = 0  -- FULLY SOLID

	-- Set spawn time
	orb:SetAttribute("SpawnTime", tick())

	-- Parent to storage
	orb.Parent = PartStorage

	-- Bounce spawn animation
	mesh.Scale = Vector3.new(0.5, 0.5, 0.5)
	local spawnTween = TweenService:Create(mesh,
		TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{Scale = Vector3.new(2, 2, 2)}
	)
	spawnTween:Play()

	-- POLISH: Magical spawn flash
	pointLight.Brightness = 2 -- Bright flash
	TweenService:Create(pointLight,
		TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Brightness = 0.6} -- Back to normal
	):Play()

	-- POLISH: Cloud puff spawn effect
	local spawnPuff = Instance.new("ParticleEmitter")
	spawnPuff.Texture = "rbxassetid://262979222" -- Ring texture
	spawnPuff.Rate = 0
	spawnPuff.Speed = NumberRange.new(0)
	spawnPuff.Lifetime = NumberRange.new(0.4)
	spawnPuff.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 2.5) -- Larger for cloud effect
	})
	spawnPuff.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.5, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	})
	spawnPuff.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)) -- White cloud
	spawnPuff.Parent = orb
	spawnPuff:Emit(2) -- Two puffs
	Debris:AddItem(spawnPuff, 1)

	-- NO CLEANUP - Orbs stay until collected!
end