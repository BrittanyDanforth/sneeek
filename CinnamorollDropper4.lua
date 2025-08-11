--[[
	Cinnamoroll Dropper 4 - Donut Dropper
	Drops cute pastel donuts
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

-- Donut colors (pastel)
local COLORS = {
	Color3.fromRGB(255, 220, 230), -- Pink frosting
	Color3.fromRGB(220, 230, 255), -- Blue frosting
	Color3.fromRGB(255, 255, 220), -- Yellow frosting
	Color3.fromRGB(230, 220, 255), -- Purple frosting
	Color3.fromRGB(220, 255, 230), -- Mint frosting
}

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

local donutCount = 0

while true do
	task.wait(1) -- Medium drop rate
	donutCount = donutCount + 1
	
	-- Create donut
	local donut = Instance.new("Part")
	donut.Name = "KawaiiDonut"
	donut.Size = Vector3.new(2, 0.6, 2) -- Donut proportions
	donut.Material = Enum.Material.SmoothPlastic
	donut.Color = COLORS[math.random(1, #COLORS)]
	donut.TopSurface = Enum.SurfaceType.Smooth
	donut.BottomSurface = Enum.SurfaceType.Smooth
	
	-- Donut mesh
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.FileMesh
	mesh.MeshId = "rbxassetid://4602192163" -- Donut Headband mesh
	mesh.Scale = Vector3.new(0.8, 0.8, 0.8)
	mesh.Parent = donut
	
	-- Sweet glow
	local glow = Instance.new("PointLight")
	glow.Brightness = 0.4
	glow.Range = 5
	glow.Color = donut.Color
	glow.Parent = donut
	
	-- Sprinkles! (small parts)
	for i = 1, 3 do
		local sprinkle = Instance.new("Part")
		sprinkle.Name = "Sprinkle"
		sprinkle.Size = Vector3.new(0.1, 0.1, 0.2)
		sprinkle.Material = Enum.Material.Neon
		sprinkle.BrickColor = BrickColor.random()
		sprinkle.CanCollide = false
		sprinkle.Massless = true
		sprinkle.Parent = donut
		
		-- Weld sprinkle
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = donut
		weld.Part1 = sprinkle
		weld.Parent = donut
		
		-- Random position on donut
		sprinkle.CFrame = donut.CFrame * CFrame.new(
			math.random(-5, 5) * 0.1,
			0.3,
			math.random(-5, 5) * 0.1
		)
	end
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 30
	cash.Parent = donut
	
	-- Position
	donut.CFrame = dropPart.CFrame * CFrame.Angles(0, math.rad(math.random(0, 360)), 0) - Vector3.new(0, 2, 0)
	
	-- Set collision group
	pcall(function()
		donut.CollisionGroup = ORB_GROUP
	end)
	
	-- Donut physics
	donut.CustomPhysicalProperties = PhysicalProperties.new(
		0.3,  -- Light
		0.5,  -- Medium friction
		0.2,  -- Small bounce
		1, 1
	)
	
	-- Drop with spin
	donut.AssemblyLinearVelocity = Vector3.new(0, -14, 0)
	donut.AssemblyAngularVelocity = Vector3.new(0, 5, 0)
	
	-- Parent to storage
	donut.Parent = PartStorage
	
	-- Spawn animation
	mesh.Scale = Vector3.new(0, 0, 0)
	TweenService:Create(mesh,
		TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Scale = Vector3.new(0.8, 0.8, 0.8)}
	):Play()
	
	-- Sugar particles
	local sugar = Instance.new("ParticleEmitter")
	sugar.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sugar.Rate = 8
	sugar.Lifetime = NumberRange.new(0.5, 1)
	sugar.Speed = NumberRange.new(0.5, 1)
	sugar.SpreadAngle = Vector2.new(180, 180)
	sugar.Size = NumberSequence.new(0.1)
	sugar.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	sugar.LightEmission = 0.5
	sugar.VelocityInheritance = 0.5
	sugar.Parent = donut
	
	-- NO CLEANUP - Donuts stay until collected!
end