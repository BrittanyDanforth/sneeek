--[[
	Cinnamoroll Dropper 1 - Basic Kawaii Style
	Fixed: Collides with conveyor/ground but not players
	WITH EXTENSIVE DEBUG PRINTS
	OPTIMIZED: Reduced brightness and performance impact
--]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")

-- Wait for PartStorage
task.wait(2)
local PartStorage = workspace:WaitForChild("PartStorage")

-- DEBUG: Print script location
print("=== CINNAMOROLL DROPPER 1 DEBUG ===")
print("Script location:", script:GetFullName())
print("Script parent:", script.Parent.Name, "Class:", script.Parent.ClassName)
print("Script grandparent:", script.Parent.Parent and script.Parent.Parent.Name or "nil")
print("Script great-grandparent:", script.Parent.Parent and script.Parent.Parent.Parent and script.Parent.Parent.Parent.Name or "nil")

-- Find the Drop part
local dropPart = script.Parent:WaitForChild("Drop")
print("Drop part found at:", dropPart:GetFullName())

-- Try to find conveyor
local conveyor = nil
local function findConveyor()
	-- Check parent
	conveyor = script.Parent:FindFirstChild("Conveyor") or script.Parent:FindFirstChild("Conv")
	if conveyor then
		print("Found conveyor in parent:", conveyor:GetFullName())
		return
	end

	-- Check siblings
	for _, sibling in pairs(script.Parent:GetChildren()) do
		if sibling.Name:lower():find("conv") then
			conveyor = sibling
			print("Found conveyor as sibling:", conveyor:GetFullName())
			return
		end
	end

	-- Check grandparent
	if script.Parent.Parent then
		conveyor = script.Parent.Parent:FindFirstChild("Conveyor") or script.Parent.Parent:FindFirstChild("Conv")
		if conveyor then
			print("Found conveyor in grandparent:", conveyor:GetFullName())
			return
		end
	end

	print("WARNING: Could not find conveyor!")
end
findConveyor()

-- Cinnamoroll colors (TONED DOWN - less saturated for less eye strain)
local COLORS = {
	Color3.fromRGB(153, 196, 210),    -- Muted light blue
	Color3.fromRGB(125, 186, 215),    -- Softer sky blue
	Color3.fromRGB(156, 204, 210),    -- Gentle powder blue
	Color3.fromRGB(100, 139, 207),    -- Softer cornflower blue
}

-- Create collision groups if they don't exist
local ORB_GROUP = "CinnamorollOrbs"
local PLAYER_GROUP = "Players"

pcall(function()
	PhysicsService:CreateCollisionGroup(ORB_GROUP)
	PhysicsService:CreateCollisionGroup(PLAYER_GROUP)
	-- Orbs don't collide with players
	PhysicsService:CollisionGroupSetCollidable(ORB_GROUP, PLAYER_GROUP, false)
	-- Orbs don't collide with each other
	PhysicsService:CollisionGroupSetCollidable(ORB_GROUP, ORB_GROUP, false)
	print("Collision groups created successfully!")
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

-- Setup existing players
for _, player in ipairs(game.Players:GetPlayers()) do
	if player.Character then
		setupPlayer(player.Character)
	end
end

local orbCount = 0

while true do
	task.wait(1.2) -- Drop rate

	orbCount = orbCount + 1
	print("\n--- Creating Orb #" .. orbCount .. " ---")

	-- Create cute orb
	local orb = Instance.new("Part")
	orb.Name = "CinnamorollOrb_" .. orbCount
	orb.Shape = Enum.PartType.Ball
	orb.Material = Enum.Material.SmoothPlastic  -- Solid material with nice look
	orb.Size = Vector3.new(1.4, 1.4, 1.4)
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	orb.Color = COLORS[math.random(1, #COLORS)]

	-- COLLISION: On for world, off for players
	orb.CanCollide = true -- CHANGED: Now collides with conveyor!
	orb.CanTouch = true
	orb.CanQuery = true

	-- Set collision group
	pcall(function()
		PhysicsService:SetPartCollisionGroup(orb, ORB_GROUP)
		print("Orb collision group set to:", ORB_GROUP)
	end)

	-- Light weight for smooth movement
	orb.CustomPhysicalProperties = PhysicalProperties.new(
		0.3,  -- Very light density
		0.5,  -- Medium friction
		0.1,  -- Low bounce
		1, 1
	)

	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 10
	cash.Parent = orb

	-- REDUCED GLOW - less bright, smaller range
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 0.4  -- Reduced from 1
	pointLight.Range = 3         -- Reduced from 5
	pointLight.Color = Color3.fromRGB(180, 210, 235)  -- Softer blue
	pointLight.Parent = orb

	-- Position with small offset
	local offsetX = math.random(-2, 2) * 0.1
	local offsetZ = math.random(-2, 2) * 0.1
	orb.CFrame = dropPart.CFrame - Vector3.new(offsetX, 1.75, offsetZ)

	print("Orb spawned at:", orb.Position)
	print("Drop part position:", dropPart.Position)

	-- Gentle drop
	orb.AssemblyLinearVelocity = Vector3.new(0, -12, 0)

	-- Cloud-like transparency
	orb.Transparency = 0.1  -- Slightly transparent but still very visible

	-- Set spawn time for cleanup
	orb:SetAttribute("SpawnTime", tick())

	-- Parent to storage
	orb.Parent = PartStorage
	print("Orb parented to:", orb.Parent:GetFullName())

	-- Simple spawn effect
	orb.Size = Vector3.new(0.7, 0.7, 0.7)
	local spawnTween = TweenService:Create(orb,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = Vector3.new(1.4, 1.4, 1.4)}
	)
	spawnTween:Play()

	-- Track orb for 2 seconds
	local startY = orb.Position.Y
	task.spawn(function()
		for i = 1, 4 do
			task.wait(0.5)
			if orb.Parent then
				local currentY = orb.Position.Y
				local fallen = startY - currentY
				print("Orb", orbCount, "after", i*0.5, "seconds: Y =", currentY, "Fallen:", fallen, "studs")

				-- Check what it's touching
				local touching = orb:GetTouchingParts()
				if #touching > 0 then
					print("  Touching", #touching, "parts:")
					for _, part in ipairs(touching) do
						print("    -", part.Name, "at", part:GetFullName())
					end
				end
			else
				print("Orb", orbCount, "was collected/destroyed")
				break
			end
		end
	end)

	-- Cleanup
	Debris:AddItem(orb, 20)
end