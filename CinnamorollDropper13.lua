--[[
	Cinnamoroll Dropper 13 - ULTIMATE Paintball Gun Dropper
	Drops legendary paintball guns with insane effects
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

-- Ultimate effects
local masterHue = 0
local dropCount = 0

while true do
	task.wait(1.5) -- Drop rate
	dropCount = dropCount + 1
	
	-- Create LEGENDARY paintball gun
	local gun = Instance.new("Part")
	gun.Name = "LegendaryPaintballGun"
	gun.Size = Vector3.new(0.2, 0.2, 0.2)
	gun.TopSurface = Enum.SurfaceType.Smooth
	gun.BottomSurface = Enum.SurfaceType.Smooth
	gun.Material = Enum.Material.Neon -- GLOWING!
	gun.BrickColor = BrickColor.new("Institutional white")
	
	-- Collision settings
	gun.CanCollide = true
	gun.CanTouch = true
	gun.CanQuery = true
	
	-- Set collision group
	pcall(function()
		gun.CollisionGroup = ORB_GROUP
	end)
	
	-- LEGENDARY gun mesh
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshId = meshID
	mesh.TextureId = textureID
	mesh.Scale = Vector3.new(1.2, 1.2, 1.2) -- BIGGEST!
	mesh.Parent = gun
	
	-- Physics
	gun.CustomPhysicalProperties = PhysicalProperties.new(
		0.3,  -- Light for effects
		0.8,  -- High friction
		0.5,  -- Bouncy!
		1, 1
	)
	
	-- Cash value (PREMIUM!)
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 100 -- Still 100 as requested
	cash.Parent = gun
	
	-- ULTIMATE rainbow core glow
	masterHue = (masterHue + 20) % 360
	local coreColor = Color3.fromHSV(masterHue/360, 1, 1)
	
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 1.2
	pointLight.Range = 15
	pointLight.Color = coreColor
	pointLight.Parent = gun
	
	-- Triple outline effect!
	for i = 1, 3 do
		local outline = Instance.new("SelectionBox")
		outline.Adornee = gun
		outline.Color3 = Color3.fromHSV((masterHue/360 + i*0.33) % 1, 1, 1)
		outline.LineThickness = 0.05 + (i * 0.05)
		outline.Transparency = 0.2 + (i * 0.2)
		outline.Parent = gun
	end
	
	-- ULTIMATE paint system
	local paintColors = {}
	for i = 0, 5 do
		table.insert(paintColors, ColorSequenceKeypoint.new(
			i/5,
			Color3.fromHSV((i/5), 1, 1)
		))
	end
	
	-- Main paint emitter
	local paint = Instance.new("ParticleEmitter")
	paint.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	paint.Rate = 50 -- MAXIMUM PAINT!
	paint.Lifetime = NumberRange.new(1, 2)
	paint.Speed = NumberRange.new(5, 8)
	paint.SpreadAngle = Vector2.new(120, 120)
	paint.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(0.5, 0.5),
		NumberSequenceKeypoint.new(1, 0)
	}
	paint.Color = ColorSequence.new(paintColors)
	paint.LightEmission = 1
	paint.VelocityInheritance = 0.5
	paint.EmissionDirection = Enum.NormalId.Front
	paint.Parent = gun
	
	-- Secondary sparkle emitter
	local sparkles = Instance.new("ParticleEmitter")
	sparkles.Texture = "rbxasset://textures/particles/star.dds"
	sparkles.Rate = 30
	sparkles.Lifetime = NumberRange.new(0.5, 1.5)
	sparkles.Speed = NumberRange.new(2, 4)
	sparkles.SpreadAngle = Vector2.new(360, 360)
	sparkles.Size = NumberSequence.new(0.5)
	sparkles.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	sparkles.LightEmission = 1
	sparkles.Parent = gun
	
	-- ULTIMATE trail system
	local attachments = {}
	for i = 1, 4 do
		local attach = Instance.new("Attachment")
		local angle = (i-1) * 90
		attach.Position = Vector3.new(
			math.cos(math.rad(angle)) * 0.1,
			0,
			math.sin(math.rad(angle)) * 0.1
		)
		attach.Parent = gun
		table.insert(attachments, attach)
	end
	
	-- Create trails between all attachments
	for i = 1, #attachments do
		for j = i+1, #attachments do
			local trail = Instance.new("Trail")
			trail.Attachment0 = attachments[i]
			trail.Attachment1 = attachments[j]
			trail.Color = ColorSequence.new(coreColor)
			trail.Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0.5),
				NumberSequenceKeypoint.new(1, 1)
			}
			trail.Lifetime = 0.5
			trail.MinLength = 0
			trail.Parent = gun
		end
	end
	
	-- Beam crown effect
	local crownAttach = Instance.new("Attachment")
	crownAttach.Position = Vector3.new(0, 0.2, 0)
	crownAttach.Parent = gun
	
	for i = 1, 4 do
		local beam = Instance.new("Beam")
		beam.Attachment0 = crownAttach
		beam.Attachment1 = attachments[i]
		beam.Color = ColorSequence.new(Color3.fromHSV((masterHue/360 + i*0.25) % 1, 1, 1))
		beam.Transparency = NumberSequence.new(0.7)
		beam.Width0 = 0.5
		beam.Width1 = 0.1
		beam.Parent = gun
	end
	
	-- LEGENDARY spawn position
	local spawnAngle = dropCount * 0.3
	local spawnRadius = 0.8
	gun.CFrame = dropPart.CFrame * 
		CFrame.Angles(math.rad(-90), math.rad(masterHue), math.rad(45)) * 
		CFrame.new(
			math.cos(spawnAngle) * spawnRadius,
			-5,
			math.sin(spawnAngle) * spawnRadius
		)
	
	-- ULTIMATE movement
	gun.AssemblyLinearVelocity = Vector3.new(
		math.random(-5, 5),
		-10,
		math.random(-5, 5)
	)
	gun.AssemblyAngularVelocity = Vector3.new(10, 20, 10) -- MAXIMUM SPIN!
	
	-- Parent to storage
	gun.Parent = PartStorage
	
	-- LEGENDARY spawn animation
	gun.Transparency = 1
	mesh.Scale = Vector3.new(0, 0, 0)
	
	-- Lightning spawn effect
	local lightning = Instance.new("ParticleEmitter")
	lightning.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	lightning.Rate = 0
	lightning.Speed = NumberRange.new(10, 20)
	lightning.SpreadAngle = Vector2.new(360, 360)
	lightning.Lifetime = NumberRange.new(0.1, 0.3)
	lightning.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 2),
		NumberSequenceKeypoint.new(1, 0)
	}
	lightning.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	lightning.LightEmission = 1
	lightning.Parent = gun
	lightning:Emit(100)
	Debris:AddItem(lightning, 1)
	
	-- Epic materialization
	TweenService:Create(gun,
		TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Transparency = 0}
	):Play()
	
	TweenService:Create(mesh,
		TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{Scale = Vector3.new(1.2, 1.2, 1.2)}
	):Play()
	
	-- MEGA flash
	pointLight.Brightness = 5
	pointLight.Range = 30
	TweenService:Create(pointLight,
		TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Brightness = 1.2, Range = 15}
	):Play()
	
	-- Paint EXPLOSION!
	paint:Emit(200)
	sparkles:Emit(100)
	
	-- Continuous ULTIMATE animations
	task.spawn(function()
		local localHue = masterHue
		local pulseTime = 0
		while gun.Parent do
			-- Rainbow cycling
			localHue = (localHue + 3) % 360
			local newColor = Color3.fromHSV(localHue/360, 1, 1)
			pointLight.Color = newColor
			
			-- Pulsing
			pulseTime = pulseTime + 0.1
			local pulse = math.sin(pulseTime * 2) * 0.1 + 1
			mesh.Scale = Vector3.new(1.2 * pulse, 1.2 * pulse, 1.2 * pulse)
			pointLight.Brightness = 1.2 * pulse
			
			task.wait(0.05)
		end
	end)
	
	-- NO CLEANUP - LEGENDARY guns stay until collected!
end