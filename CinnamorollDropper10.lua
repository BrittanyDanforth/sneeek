--[[
	Cinnamoroll Dropper 10 - Heart Drop Style
	Drops rainbow heart-themed Cinnamoroll orbs
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

-- Rainbow phase
local rainbowPhase = 0
local dropCount = 0

while true do
	task.wait(0.5) -- Fast drops!
	dropCount = dropCount + 1
	
	-- Create heart orb
	local orb = Instance.new("Part")
	orb.Name = "HeartOrb"
	orb.Shape = Enum.PartType.Ball
	orb.Size = Vector3.new(1.5, 1.5, 1.5)
	orb.Material = Enum.Material.Neon
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	
	-- Rainbow color
	rainbowPhase = (rainbowPhase + 30) % 360
	orb.Color = Color3.fromHSV(rainbowPhase/360, 0.4, 1) -- Soft pastel rainbow
	
	-- Collision settings
	orb.CanCollide = true
	orb.CanTouch = true
	orb.CanQuery = true
	
	-- Set collision group
	pcall(function()
		orb.CollisionGroup = ORB_GROUP
	end)
	
	-- Heart physics
	orb.CustomPhysicalProperties = PhysicalProperties.new(
		0.15, -- Very light
		0.6,  -- Good friction
		0.4,  -- Bouncy
		1, 1
	)
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 100
	cash.Parent = orb
	
	-- Rainbow glow
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 0.7
	pointLight.Range = 10
	pointLight.Color = orb.Color
	pointLight.Parent = orb
	
	-- Heart outline
	local selection = Instance.new("SelectionSphere")
	selection.Adornee = orb
	selection.Color3 = orb.Color
	selection.SurfaceTransparency = 1
	selection.Transparency = 0.3
	selection.Parent = orb
	
	-- Heart particles
	local hearts = Instance.new("ParticleEmitter")
	hearts.Texture = "rbxasset://textures/particles/heart.dds"
	hearts.Rate = 8
	hearts.Lifetime = NumberRange.new(1, 2)
	hearts.Speed = NumberRange.new(1, 3)
	hearts.SpreadAngle = Vector2.new(180, 180)
	hearts.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.4),
		NumberSequenceKeypoint.new(1, 0.2)
	}
	hearts.Color = ColorSequence.new(orb.Color)
	hearts.LightEmission = 0.7
	hearts.Parent = orb
	
	-- Rainbow sparkles
	local sparkles = Instance.new("ParticleEmitter")
	sparkles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkles.Rate = 20
	sparkles.Lifetime = NumberRange.new(0.5, 1)
	sparkles.Speed = NumberRange.new(1, 2)
	sparkles.SpreadAngle = Vector2.new(360, 360)
	sparkles.Size = NumberSequence.new(0.3)
	sparkles.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0.4, 1)),
		ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 0.4, 1)),
		ColorSequenceKeypoint.new(0.66, Color3.fromHSV(0.66, 0.4, 1)),
		ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 0.4, 1))
	}
	sparkles.LightEmission = 0.8
	sparkles.VelocityInheritance = 0.3
	sparkles.Parent = orb
	
	-- Heart motion pattern
	local heartAngle = dropCount * 0.5
	local heartRadius = 0.3
	local offsetX = math.cos(heartAngle) * heartRadius
	local offsetZ = math.sin(heartAngle) * heartRadius
	
	orb.CFrame = dropPart.CFrame - Vector3.new(offsetX, 1.4, offsetZ)
	
	-- Float with love
	orb.AssemblyLinearVelocity = Vector3.new(
		offsetX * 3,
		-9,
		offsetZ * 3
	)
	orb.AssemblyAngularVelocity = Vector3.new(2, 4, 2)
	
	-- Parent to storage
	orb.Parent = PartStorage
	
	-- Spawn animation (heart beat)
	orb.Size = Vector3.new(0.8, 0.8, 0.8)
	
	TweenService:Create(orb,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = Vector3.new(1.6, 1.6, 1.6)}
	):Play()
	
	task.wait(0.1)
	
	TweenService:Create(orb,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = Vector3.new(1.5, 1.5, 1.5)}
	):Play()
	
	-- Rainbow flash
	pointLight.Brightness = 2
	TweenService:Create(pointLight,
		TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Brightness = 0.7}
	):Play()
	
	-- Continuous color shift
	task.spawn(function()
		local localPhase = rainbowPhase
		while orb.Parent do
			localPhase = (localPhase + 2) % 360
			local newColor = Color3.fromHSV(localPhase/360, 0.4, 1)
			orb.Color = newColor
			pointLight.Color = newColor
			selection.Color3 = newColor
			hearts.Color = ColorSequence.new(newColor)
			task.wait(0.1)
		end
	end)
	
	-- Heart beat pulse
	task.spawn(function()
		while orb.Parent do
			TweenService:Create(orb,
				TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Size = Vector3.new(1.6, 1.6, 1.6)}
			):Play()
			task.wait(0.4)
			TweenService:Create(orb,
				TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Size = Vector3.new(1.5, 1.5, 1.5)}
			):Play()
			task.wait(0.4)
		end
	end)
	
	-- NO CLEANUP - Heart orbs stay until collected!
end