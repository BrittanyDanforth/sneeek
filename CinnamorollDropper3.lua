--[[
	Cinnamoroll Dropper 3 - Premium Kawaii Style
	Fixed: Collides with conveyor/ground but not players
	WITH DEBUG PRINTS
	HEAVILY OPTIMIZED: Removed complex effects, reduced particles and lighting
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

-- Premium Cinnamoroll palette (TONED DOWN Blue-themed)
local COLORS = {
	Color3.fromRGB(125, 186, 230),    -- Softer light sky blue
	Color3.fromRGB(153, 196, 210),    -- Muted light blue
	Color3.fromRGB(100, 139, 207),    -- Softer cornflower blue
	Color3.fromRGB(80, 120, 160),     -- Muted steel blue
	Color3.fromRGB(156, 204, 210),    -- Gentle powder blue
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
	orb.Material = Enum.Material.Neon  -- Back to Neon but controlled
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

	-- REDUCED Premium lighting
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 0.8   -- Reduced from 2
	pointLight.Range = 5          -- Reduced from 10
	pointLight.Color = Color3.fromRGB(125, 186, 230)  -- Softer light sky blue glow
	pointLight.Parent = orb

	-- POLISH: Multi-layer premium effect
	-- Inner glass core
	local innerCore = Instance.new("Part")
	innerCore.Name = "InnerCore"
	innerCore.Shape = Enum.PartType.Ball
	innerCore.Material = Enum.Material.Glass
	innerCore.Size = Vector3.new(1.2, 1.2, 1.2)
	innerCore.Color = Color3.fromRGB(100, 149, 237)  -- Darker blue core
	innerCore.Transparency = 0.4
	innerCore.Reflectance = 0.5
	innerCore.CanCollide = false
	innerCore.Massless = true
	innerCore.Parent = orb
	
	local weld1 = Instance.new("WeldConstraint")
	weld1.Part0 = orb
	weld1.Part1 = innerCore
	weld1.Parent = orb
	
	-- Outer aura
	local outerAura = Instance.new("Part")
	outerAura.Name = "OuterAura"
	outerAura.Shape = Enum.PartType.Ball
	outerAura.Material = Enum.Material.ForceField
	outerAura.Size = Vector3.new(2.2, 2.2, 2.2)
	outerAura.Color = Color3.fromRGB(173, 216, 230)
	outerAura.Transparency = 0.8
	outerAura.CanCollide = false
	outerAura.Massless = true
	outerAura.Parent = orb
	
	local weld2 = Instance.new("WeldConstraint")
	weld2.Part0 = orb
	weld2.Part1 = outerAura
	weld2.Parent = orb
	
	-- Highlight for extra pop
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(135, 206, 250)
	highlight.FillTransparency = 0.7
	highlight.OutlineColor = Color3.fromRGB(70, 130, 180)
	highlight.OutlineTransparency = 0.3
	highlight.Parent = orb

	-- REDUCED Blue sparkles (as requested but toned down)
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkle.Rate = 5          -- Reduced from 20
	sparkle.Lifetime = NumberRange.new(1, 2)
	sparkle.Speed = NumberRange.new(1, 3)
	sparkle.SpreadAngle = Vector2.new(360, 360)
	sparkle.LightEmission = 0.7  -- Reduced from 1
	sparkle.LightInfluence = 0
	sparkle.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.2),  -- Smaller
		NumberSequenceKeypoint.new(0.5, 0.3),
		NumberSequenceKeypoint.new(1, 0)
	}
	sparkle.Color = ColorSequence.new(Color3.fromRGB(125, 186, 230))  -- Softer light sky blue sparkles
	sparkle.VelocityInheritance = 0.2
	sparkle.Parent = orb

	-- REMOVED shimmer effect for performance

	-- MINIMAL Heart particles
	local hearts = Instance.new("ParticleEmitter")
	hearts.Texture = "rbxasset://textures/particles/heart.dds"
	hearts.Rate = 1           -- Reduced from 2
	hearts.Lifetime = NumberRange.new(2, 3)
	hearts.Speed = NumberRange.new(0.5)
	hearts.SpreadAngle = Vector2.new(180, 180)
	hearts.LightEmission = 0.3  -- Reduced from 0.5
	hearts.Size = NumberSequence.new(0.2)  -- Smaller
	hearts.Color = ColorSequence.new(Color3.fromRGB(156, 204, 210)) -- Gentle powder blue
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

	-- Premium cloud transparency
	orb.Transparency = 0  -- Completely opaque for visibility

	-- Set spawn time
	orb:SetAttribute("SpawnTime", tick())

	-- Parent to storage
	orb.Parent = PartStorage
	print("Orb parented to:", PartStorage:GetFullName())

	-- SIMPLIFIED entrance animation
	orb.Size = Vector3.new(0.2, 0.2, 0.2)

	TweenService:Create(orb,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = Vector3.new(1.8, 1.8, 1.8), Transparency = 0}
	):Play()

	-- POLISH: Premium spawn flash
	pointLight.Brightness = 3 -- Bright magical flash
	TweenService:Create(pointLight,
		TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Brightness = 0.8} -- Back to normal
	):Play()

	-- POLISH: Dream ring spawn effect
	local spawnRing = Instance.new("ParticleEmitter")
	spawnRing.Texture = "rbxassetid://262979222" -- Ring texture
	spawnRing.Rate = 0
	spawnRing.Speed = NumberRange.new(0)
	spawnRing.Lifetime = NumberRange.new(0.5)
	spawnRing.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(1, 3.5) -- Premium larger ring
	})
	spawnRing.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(0.5, 0.4),
		NumberSequenceKeypoint.new(1, 1)
	})
	spawnRing.Color = ColorSequence.new(Color3.fromRGB(135, 206, 250)) -- Light sky blue
	spawnRing.LightEmission = 0.5
	spawnRing.Parent = orb
	spawnRing:Emit(2) -- Double ring for premium
	Debris:AddItem(spawnRing, 1)

	-- REMOVED spinning effect for performance

	-- REMOVED core pulse animation

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

	-- Simple fade out
	task.delay(22, function()
		if orb.Parent then
			sparkle.Enabled = false
			hearts.Enabled = false

			-- POLISH: Premium dream burst death
			-- Emit final particles
			sparkle:Emit(15)
			hearts:Emit(5)
			
			-- Create dream burst effect
			local dreamBurst = Instance.new("ParticleEmitter")
			dreamBurst.Texture = "rbxasset://textures/particles/sparkles_main.dds"
			dreamBurst.Rate = 0
			dreamBurst.Speed = NumberRange.new(5, 8)
			dreamBurst.SpreadAngle = Vector2.new(360, 360)
			dreamBurst.Lifetime = NumberRange.new(0.8)
			dreamBurst.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.5),
				NumberSequenceKeypoint.new(0.5, 0.3),
				NumberSequenceKeypoint.new(1, 0)
			})
			dreamBurst.Color = ColorSequence.new(Color3.fromRGB(135, 206, 250))
			dreamBurst.LightEmission = 1
			dreamBurst.Parent = orb
			dreamBurst:Emit(20)
			
			-- Shrink with twist
			TweenService:Create(orb,
				TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				{Size = Vector3.new(0, 0, 0), Transparency = 0.3}
			):Play()
			
			-- Flash then fade light
			pointLight.Brightness = 2
			TweenService:Create(pointLight,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad),
				{Brightness = 0, Range = 0}
			):Play()
		end
	end)
end