--[[
	Cinnamoroll Dropper 2 - Enhanced Kawaii Style
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
print("=== CINNAMOROLL DROPPER 2 DEBUG ===")
print("Script location:", script:GetFullName())
print("Script parent:", script.Parent.Name, "Class:", script.Parent.ClassName)
print("Script grandparent:", script.Parent.Parent and script.Parent.Parent.Name or "nil")
print("Full path:", script:GetFullName())

-- Find the Drop part
local dropPart = script.Parent:WaitForChild("Drop")
print("Drop part found at:", dropPart:GetFullName())

-- Cinnamoroll palette
local COLORS = {
	Color3.fromRGB(255, 255, 255),    -- Pure white
	Color3.fromRGB(220, 240, 255),    -- Soft blue-white
	Color3.fromRGB(255, 240, 245),    -- Soft pink-white
	Color3.fromRGB(240, 248, 255),    -- Alice blue
}

-- Pattern for anti-stacking
local dropPattern = 1

-- Create collision groups
local ORB_GROUP = "CinnamorollOrbs"
local PLAYER_GROUP = "Players"

pcall(function()
	PhysicsService:CreateCollisionGroup(ORB_GROUP)
	PhysicsService:CreateCollisionGroup(PLAYER_GROUP)
	PhysicsService:CollisionGroupSetCollidable(ORB_GROUP, PLAYER_GROUP, false)
	PhysicsService:CollisionGroupSetCollidable(ORB_GROUP, ORB_GROUP, false)
	print("Collision groups set up for Dropper 2")
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

local orbCount = 0

while true do
	task.wait(1) -- Faster drops
	
	orbCount = orbCount + 1
	print("\n--- Dropper 2: Creating Orb #" .. orbCount .. " ---")
	
	-- Create fluffy orb
	local orb = Instance.new("Part")
	orb.Name = "CinnamorollCloud_" .. orbCount
	orb.Shape = Enum.PartType.Ball
	orb.Material = Enum.Material.Neon
	orb.Size = Vector3.new(1.6, 1.6, 1.6)
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	orb.Color = COLORS[math.random(1, #COLORS)]
	
	-- COLLISION FIXED!
	orb.CanCollide = true -- Now collides with conveyor
	orb.CanTouch = true
	orb.CanQuery = true
	
	-- Set collision group
	pcall(function()
		PhysicsService:SetPartCollisionGroup(orb, ORB_GROUP)
		print("Orb", orbCount, "collision group set")
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
	
	-- Enhanced glow
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 1.5
	pointLight.Range = 7
	pointLight.Color = Color3.fromRGB(200, 230, 255)
	pointLight.Parent = orb
	
	-- Removed the square outline - just using glow effect
	
	-- Kawaii sparkles
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkle.Rate = 8
	sparkle.Lifetime = NumberRange.new(0.5, 1)
	sparkle.Speed = NumberRange.new(0.5, 1)
	sparkle.SpreadAngle = Vector2.new(180, 180)
	sparkle.LightEmission = 1
	sparkle.LightInfluence = 0
	sparkle.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 0)
	}
	sparkle.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	sparkle.Parent = orb
	
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
	
	orb.CFrame = dropPart.CFrame - Vector3.new(0, 1.75, 0) + offset
	print("Orb", orbCount, "spawned at:", orb.Position)
	
	-- Float down gently
	orb.AssemblyLinearVelocity = Vector3.new(
		offset.X * 2,
		-10,  -- Gentle float
		offset.Z * 2
	)
	
	-- Semi-transparent cloud
	orb.Transparency = 0.15
	
	-- Set spawn time
	orb:SetAttribute("SpawnTime", tick())
	
	-- Parent to storage
	orb.Parent = PartStorage
	
	-- Bounce spawn animation
	orb.Size = Vector3.new(0.4, 0.4, 0.4)
	local spawnTween = TweenService:Create(orb,
		TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{Size = Vector3.new(1.6, 1.6, 1.6)}
	)
	spawnTween:Play()
	
	-- Removed spinning - orbs just float down peacefully
	
	-- Track orb briefly
	task.spawn(function()
		task.wait(1)
		if orb.Parent then
			local touching = orb:GetTouchingParts()
			if #touching > 0 then
				print("Orb", orbCount, "landed on:")
				for _, part in ipairs(touching) do
					print("  -", part.Name)
				end
			end
		end
	end)
	
	-- Cleanup
	Debris:AddItem(orb, 22)
	
	-- Fade out
	task.delay(20, function()
		if orb.Parent then
			sparkle.Enabled = false
			TweenService:Create(orb,
				TweenInfo.new(2, Enum.EasingStyle.Linear),
				{Transparency = 0.8}
			):Play()
		end
	end)
end