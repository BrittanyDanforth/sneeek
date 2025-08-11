--[[
	Cinnamoroll Dropper 12 - Enhanced Paintball Gun Dropper
	Drops paintball guns with rainbow paint trails
	NO CLEANUP - Guns stay until collected
--]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local PhysicsService = game:GetService("PhysicsService")

-- Wait for PartStorage
task.wait(2)
local PartStorage = workspace:WaitForChild("PartStorage")

-- Find the Drop part
local dropPart = script.Parent:WaitForChild("Drop")

-- Mesh settings
local meshID = "rbxasset://fonts/PaintballGun.mesh"
local textureID = "rbxasset://textures/PaintballGunTex128.png"

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

-- Rainbow effect
local hue = 0

while true do
	task.wait(1.5) -- Drop rate
	
	-- Create enhanced paintball gun
	local gun = Instance.new("Part")
	gun.Name = "EnhancedPaintballGun"
	gun.Size = Vector3.new(0.2, 0.2, 0.2)
	gun.TopSurface = Enum.SurfaceType.Smooth
	gun.BottomSurface = Enum.SurfaceType.Smooth
	gun.Material = Enum.Material.Metal
	gun.BrickColor = BrickColor.new("Dark stone grey")
	
	-- Collision settings
	gun.CanCollide = true
	gun.CanTouch = true
	gun.CanQuery = true
	
	-- Set collision group
	pcall(function()
		gun.CollisionGroup = ORB_GROUP
	end)
	
	-- Enhanced gun mesh
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshId = meshID
	mesh.TextureId = textureID
	mesh.Scale = Vector3.new(1, 1, 1) -- Bigger!
	mesh.Parent = gun
	
	-- Physics
	gun.CustomPhysicalProperties = PhysicalProperties.new(
		0.4,  -- Slightly lighter
		0.7,  -- Better friction
		0.3,  -- More bounce
		1, 1
	)
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 100
	cash.Parent = gun
	
	-- Rainbow glow
	hue = (hue + 30) % 360
	local color = Color3.fromHSV(hue/360, 0.8, 1)
	
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 0.8
	pointLight.Range = 10
	pointLight.Color = color
	pointLight.Parent = gun
	
	-- Metallic outline
	local selection = Instance.new("SelectionBox")
	selection.Adornee = gun
	selection.Color3 = color
	selection.LineThickness = 0.1
	selection.Transparency = 0.3
	selection.Parent = gun
	
	-- Paint trail attachments
	local attach1 = Instance.new("Attachment")
	attach1.Position = Vector3.new(0, 0, -0.1)
	attach1.Parent = gun
	
	local attach2 = Instance.new("Attachment")
	attach2.Position = Vector3.new(0, 0, 0.1)
	attach2.Parent = gun
	
	-- Rainbow paint trail
	local trail = Instance.new("Trail")
	trail.Attachment0 = attach1
	trail.Attachment1 = attach2
	trail.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromHSV((hue/360 + 0) % 1, 0.8, 1)),
		ColorSequenceKeypoint.new(0.5, Color3.fromHSV((hue/360 + 0.5) % 1, 0.8, 1)),
		ColorSequenceKeypoint.new(1, Color3.fromHSV((hue/360 + 1) % 1, 0.8, 1))
	}
	trail.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 1)
	}
	trail.Lifetime = 1
	trail.MinLength = 0
	trail.Parent = gun
	
	-- Multicolor paint particles
	local paint = Instance.new("ParticleEmitter")
	paint.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	paint.Rate = 25
	paint.Lifetime = NumberRange.new(0.5, 1)
	paint.Speed = NumberRange.new(3, 5)
	paint.SpreadAngle = Vector2.new(90, 90)
	paint.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.5, 0.3),
		NumberSequenceKeypoint.new(1, 0)
	}
	paint.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 100)),
		ColorSequenceKeypoint.new(0.33, Color3.fromRGB(100, 255, 100)),
		ColorSequenceKeypoint.new(0.66, Color3.fromRGB(100, 100, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 100))
	}
	paint.LightEmission = 0.7
	paint.VelocityInheritance = 0.3
	paint.EmissionDirection = Enum.NormalId.Front
	paint.Parent = gun
	
	-- Position with spin
	gun.CFrame = dropPart.CFrame * CFrame.Angles(math.rad(-90), math.rad(hue), 0) - Vector3.new(0, 5, 0)
	
	-- Complex drop movement
	local angle = math.rad(hue * 2)
	gun.AssemblyLinearVelocity = Vector3.new(
		math.sin(angle) * 3,
		-12,
		math.cos(angle) * 3
	)
	gun.AssemblyAngularVelocity = Vector3.new(5, 10, 5)
	
	-- Parent to storage
	gun.Parent = PartStorage
	
	-- Enhanced spawn animation
	mesh.Scale = Vector3.new(0, 0, 0)
	gun.Transparency = 1
	
	-- Materialize effect
	TweenService:Create(gun,
		TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		{Transparency = 0}
	):Play()
	
	TweenService:Create(mesh,
		TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{Scale = Vector3.new(1, 1, 1)}
	):Play()
	
	-- Energy burst
	pointLight.Brightness = 3
	pointLight.Range = 20
	TweenService:Create(pointLight,
		TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Brightness = 0.8, Range = 10}
	):Play()
	
	-- Paint explosion
	paint:Emit(50)
	
	-- Continuous rainbow animation
	task.spawn(function()
		local localHue = hue
		while gun.Parent do
			localHue = (localHue + 2) % 360
			local newColor = Color3.fromHSV(localHue/360, 0.8, 1)
			pointLight.Color = newColor
			selection.Color3 = newColor
			task.wait(0.1)
		end
	end)
	
	-- NO CLEANUP - Enhanced guns stay until collected!
end