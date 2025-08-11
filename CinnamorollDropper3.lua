--[[
	Cinnamoroll Dropper 3 - Premium Kawaii Style
	Fixed: Collides with conveyor/ground but not players
	WITH DEBUG PRINTS
--]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local PhysicsService = game:GetService("PhysicsService")

-- Wait for PartStorage
task.wait(2)
local PartStorage = workspace:WaitForChild("PartStorage")

-- DEBUG: Print script location
print("=== CINNAMOROLL DROPPER 3 (PREMIUM) DEBUG ===")
print("Script location:", script:GetFullName())
print("Script parent:", script.Parent.Name, "Class:", script.Parent.ClassName)
print("Script grandparent:", script.Parent.Parent and script.Parent.Parent.Name or "nil")
print("Script great-grandparent:", script.Parent.Parent and script.Parent.Parent.Parent and script.Parent.Parent.Parent.Name or "nil")

-- Find the Drop part
local dropPart = script.Parent:WaitForChild("Drop")
print("Drop part found at:", dropPart:GetFullName())
print("Drop part position:", dropPart.Position)

-- Premium Cinnamoroll palette (Blue-themed)
local COLORS = {
	Color3.fromRGB(135, 206, 250),    -- Light sky blue
	Color3.fromRGB(173, 216, 230),    -- Light blue
	Color3.fromRGB(100, 149, 237),    -- Cornflower blue
	Color3.fromRGB(70, 130, 180),     -- Steel blue
	Color3.fromRGB(176, 224, 230),    -- Powder blue
}

-- Smart positioning
local recentPositions = {}
local MAX_MEMORY = 3

-- Create collision groups
local ORB_GROUP = "CinnamorollOrbs"
local PLAYER_GROUP = "Players"

pcall(function()
	PhysicsService:CreateCollisionGroup(ORB_GROUP)
	PhysicsService:CreateCollisionGroup(PLAYER_GROUP)
	PhysicsService:CollisionGroupSetCollidable(ORB_GROUP, PLAYER_GROUP, false)
	PhysicsService:CollisionGroupSetCollidable(ORB_GROUP, ORB_GROUP, false)
	print("Premium collision groups configured")
end)

-- Setup player collision groups
local function setupPlayer(character)
	task.wait(0.1)
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			pcall(function()
				PhysicsService:SetPartCollisionGroup(part, PLAYER_GROUP)
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

local function getSmartOffset()
	local offset = Vector3.new(
		(math.random() - 0.5) * 0.6,
		0,
		(math.random() - 0.5) * 0.6
	)
	
	-- Avoid recent positions
	for _, pos in ipairs(recentPositions) do
		if (offset - pos).Magnitude < 0.2 then
			offset = offset + Vector3.new(
				(math.random() - 0.5) * 0.3,
				0,
				(math.random() - 0.5) * 0.3
			)
		end
	end
	
	table.insert(recentPositions, offset)
	if #recentPositions > MAX_MEMORY then
		table.remove(recentPositions, 1)
	end
	
	return offset
end

local orbCount = 0

while true do
	task.wait(0.8) -- Premium faster drops
	
	orbCount = orbCount + 1
	print("\n--- Premium Dropper 3: Creating Dream Orb #" .. orbCount .. " ---")
	
	-- Create dreamy orb
	local orb = Instance.new("Part")
	orb.Name = "CinnamorollDream_" .. orbCount
	orb.Shape = Enum.PartType.Ball
	orb.Material = Enum.Material.Neon
	orb.Size = Vector3.new(1.8, 1.8, 1.8)
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	orb.Color = COLORS[math.random(1, #COLORS)]
	
	-- COLLISION FIXED - Collides with world but not players!
	orb.CanCollide = true -- CHANGED!
	orb.CanTouch = true
	orb.CanQuery = true
	
	-- Set collision group
	pcall(function()
		PhysicsService:SetPartCollisionGroup(orb, ORB_GROUP)
		print("Premium orb", orbCount, "collision group set")
	end)
	
	-- Dream-like physics
	orb.CustomPhysicalProperties = PhysicalProperties.new(
		0.1,  -- Ultra light
		0.2,  -- Smooth friction
		0,    -- No bounce - soft landing
		1, 1
	)
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 30
	cash.Parent = orb
	
	-- Premium lighting
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 2
	pointLight.Range = 10
	pointLight.Color = Color3.fromRGB(135, 206, 250)  -- Light sky blue glow
	pointLight.Parent = orb
	
	-- Inner star core
	local core = Instance.new("Part")
	core.Name = "Core"
	core.Shape = Enum.PartType.Ball
	core.Material = Enum.Material.Neon
	core.Size = Vector3.new(1, 1, 1)
	core.Color = Color3.fromRGB(100, 149, 237) -- Cornflower blue core
	core.Transparency = 0.3
	core.CanCollide = false
	core.Massless = true
	core.Parent = orb
	
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = orb
	weld.Part1 = core
	weld.Parent = orb
	
	-- Blue sparkles (as requested)
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkle.Rate = 20  -- Good amount of sparkles
	sparkle.Lifetime = NumberRange.new(1, 2)
	sparkle.Speed = NumberRange.new(1, 3)
	sparkle.SpreadAngle = Vector2.new(360, 360)
	sparkle.LightEmission = 1
	sparkle.LightInfluence = 0
	sparkle.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.5, 0.4),
		NumberSequenceKeypoint.new(1, 0)
	}
	sparkle.Color = ColorSequence.new(Color3.fromRGB(135, 206, 250))  -- Light sky blue sparkles
	sparkle.VelocityInheritance = 0.2
	sparkle.Parent = orb
	
	-- Additional shimmer effect
	local shimmer = Instance.new("ParticleEmitter")
	shimmer.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	shimmer.Rate = 10
	shimmer.Lifetime = NumberRange.new(0.5, 1)
	shimmer.Speed = NumberRange.new(0.5, 1)
	shimmer.SpreadAngle = Vector2.new(180, 180)
	shimmer.LightEmission = 1
	shimmer.Size = NumberSequence.new(0.2)
	shimmer.Color = ColorSequence.new(Color3.fromRGB(173, 216, 230))  -- Light blue shimmer
	shimmer.Parent = orb
	
	-- Heart particles
	local hearts = Instance.new("ParticleEmitter")
	hearts.Texture = "rbxasset://textures/particles/heart.dds"
	hearts.Rate = 2
	hearts.Lifetime = NumberRange.new(2, 3)
	hearts.Speed = NumberRange.new(0.5)
	hearts.SpreadAngle = Vector2.new(180, 180)
	hearts.LightEmission = 0.5
	hearts.Size = NumberSequence.new(0.3)
	hearts.Color = ColorSequence.new(Color3.fromRGB(176, 224, 230)) -- Powder blue
	hearts.Parent = orb
	
	-- Smart positioning
	local offset = getSmartOffset()
	orb.CFrame = dropPart.CFrame - Vector3.new(0, 1.75, 0) + offset
	print("Premium orb", orbCount, "spawned at:", orb.Position, "with offset:", offset)
	
	-- Dreamy float (FIXED SPEED - same as other droppers)
	local angle = math.random() * math.pi * 2
	orb.AssemblyLinearVelocity = Vector3.new(
		math.cos(angle) * 2,
		-12,  -- Same speed as Dropper 1
		math.sin(angle) * 2
	)
	
	-- Cloud transparency
	orb.Transparency = 0.1
	
	-- Set spawn time
	orb:SetAttribute("SpawnTime", tick())
	
	-- Parent to storage
	orb.Parent = PartStorage
	print("Orb parented to:", PartStorage:GetFullName())
	
	-- Magical entrance
	orb.Size = Vector3.new(0.2, 0.2, 0.2)
	core.Size = Vector3.new(0.1, 0.1, 0.1)
	
	TweenService:Create(orb,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = Vector3.new(1.8, 1.8, 1.8), Transparency = 0.1}
	):Play()
	
	TweenService:Create(core,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = Vector3.new(1, 1, 1)}
	):Play()
	
	-- Dreamy rotation
	local spin = Instance.new("BodyAngularVelocity")
	spin.AngularVelocity = Vector3.new(
		math.random(-1, 1),
		math.random(2, 4),
		math.random(-1, 1)
	)
	spin.MaxTorque = Vector3.new(2000, 2000, 2000)
	spin.Parent = orb
	
	-- Core pulse
	task.spawn(function()
		while orb.Parent do
			TweenService:Create(core,
				TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Size = Vector3.new(1.2, 1.2, 1.2), Transparency = 0.5}
			):Play()
			task.wait(2)
			if not orb.Parent then break end
			TweenService:Create(core,
				TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Size = Vector3.new(1, 1, 1), Transparency = 0.3}
			):Play()
			task.wait(2)
		end
	end)
	
	-- Remove spin after landing
	task.delay(1.5, function()
		if spin.Parent then
			spin:Destroy()
		end
	end)
	
	-- Track premium orb
	task.spawn(function()
		task.wait(1.5)
		if orb.Parent then
			local touching = orb:GetTouchingParts()
			if #touching > 0 then
				print("Premium orb", orbCount, "landed on", #touching, "parts")
				for i, part in ipairs(touching) do
					if i <= 3 then -- Only print first 3
						print("  -", part.Name)
					end
				end
			else
				print("Premium orb", orbCount, "still floating")
			end
		end
	end)
	
	-- Cleanup
	Debris:AddItem(orb, 25)
	
	-- Dreamy fade out
	task.delay(22, function()
		if orb.Parent then
			sparkle.Enabled = false
			shimmer.Enabled = false
			hearts.Enabled = false
			
			TweenService:Create(orb,
				TweenInfo.new(3, Enum.EasingStyle.Quad),
				{Transparency = 0.9, Size = Vector3.new(1.5, 1.5, 1.5)}
			):Play()
			
			TweenService:Create(core,
				TweenInfo.new(3, Enum.EasingStyle.Quad),
				{Transparency = 1, Size = Vector3.new(0.5, 0.5, 0.5)}
			):Play()
			
			TweenService:Create(pointLight,
				TweenInfo.new(3, Enum.EasingStyle.Linear),
				{Brightness = 0, Range = 0}
			):Play()
		end
	end)
end