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

-- Premium rainbow colors
local function getRainbowColor(time)
	local hue = (time * 0.1) % 1
	return Color3.fromHSV(hue, 0.3, 1) -- Soft pastel rainbow
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
	task.wait(0.6) -- Fastest drop rate
	starCount = starCount + 1
	
	-- Create star base
	local star = Instance.new("Part")
	star.Name = "PremiumStar"
	star.Size = Vector3.new(2, 2, 0.5) -- Flat star shape
	star.Material = Enum.Material.Neon
	star.Color = getRainbowColor(tick())
	star.TopSurface = Enum.SurfaceType.Smooth
	star.BottomSurface = Enum.SurfaceType.Smooth
	star.Transparency = 0
	
	-- Star mesh
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.FileMesh
	mesh.MeshId = "rbxassetid://3270017" -- Classic star mesh
	mesh.Scale = Vector3.new(1.5, 1.5, 0.5)
	mesh.Parent = star
	
	-- Premium glow
	local glow = Instance.new("PointLight")
	glow.Brightness = 0.8
	glow.Range = 10
	glow.Color = star.Color
	glow.Parent = star
	
	-- Premium outline effect
	local selection = Instance.new("SelectionSphere")
	selection.Adornee = star
	selection.Color3 = star.Color
	selection.SurfaceTransparency = 1
	selection.Transparency = 0.2
	selection.Parent = star
	
	-- Cash value (premium!)
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 20 -- Highest value
	cash.Parent = star
	
	-- Position
	star.CFrame = dropPart.CFrame * CFrame.Angles(0, math.rad(starCount * 30), 0) - Vector3.new(0, 2, 0)
	
	-- Set collision group
	pcall(function()
		star.CollisionGroup = ORB_GROUP
	end)
	
	-- Star physics
	star.CustomPhysicalProperties = PhysicalProperties.new(
		0.2,  -- Light
		0.5,  -- Medium friction
		0.3,  -- Some bounce
		1, 1
	)
	
	-- Spinning drop
	star.AssemblyLinearVelocity = Vector3.new(0, -12, 0)
	star.AssemblyAngularVelocity = Vector3.new(0, 10, 0) -- Spin!
	
	-- Parent to storage
	star.Parent = PartStorage
	
	-- Premium spawn animation
	mesh.Scale = Vector3.new(0, 0, 0)
	star.Transparency = 1
	
	-- Materialize
	TweenService:Create(star,
		TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Transparency = 0}
	):Play()
	
	TweenService:Create(mesh,
		TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Scale = Vector3.new(1.5, 1.5, 0.5)}
	):Play()
	
	-- Flash effect
	glow.Brightness = 2
	TweenService:Create(glow,
		TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Brightness = 0.8}
	):Play()
	
	-- Rainbow sparkles
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkle.Rate = 15
	sparkle.Lifetime = NumberRange.new(0.5, 1.5)
	sparkle.Speed = NumberRange.new(1, 3)
	sparkle.SpreadAngle = Vector2.new(360, 360)
	sparkle.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.5),
		NumberSequenceKeypoint.new(1, 0)
	}
	sparkle.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 200)),
		ColorSequenceKeypoint.new(0.33, Color3.fromRGB(200, 255, 200)),
		ColorSequenceKeypoint.new(0.66, Color3.fromRGB(200, 200, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 200))
	}
	sparkle.LightEmission = 1
	sparkle.VelocityInheritance = 0.2
	sparkle.Parent = star
	
	-- Star trail
	local attachment1 = Instance.new("Attachment")
	attachment1.Position = Vector3.new(0, 1, 0)
	attachment1.Parent = star
	
	local attachment2 = Instance.new("Attachment")
	attachment2.Position = Vector3.new(0, -1, 0)
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
	trail.Parent = star
	
	-- Continuous color animation
	task.spawn(function()
		while star.Parent do
			local newColor = getRainbowColor(tick())
			star.Color = newColor
			glow.Color = newColor
			selection.Color3 = newColor
			trail.Color = ColorSequence.new(newColor)
			task.wait(0.1)
		end
	end)
	
	-- NO CLEANUP - Stars stay until collected!
end