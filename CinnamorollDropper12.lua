--[[
	Cinnamoroll Dropper 12 - Candy Drop Style
	Drops rainbow Cinnamoroll candies
	NO CLEANUP - Candies stay until collected
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

-- Candy colors
local CANDY_COLORS = {
	Color3.fromRGB(255, 200, 220), -- Pink candy
	Color3.fromRGB(200, 220, 255), -- Blue candy
	Color3.fromRGB(255, 255, 200), -- Yellow candy
	Color3.fromRGB(220, 200, 255), -- Purple candy
	Color3.fromRGB(200, 255, 220), -- Mint candy
}

local candyIndex = 1

while true do
	task.wait(1.5) -- Drop rate
	
	-- Create candy
	local candy = Instance.new("Part")
	candy.Name = "CinnamorollCandy"
	candy.Shape = Enum.PartType.Ball
	candy.Size = Vector3.new(1.3, 1.3, 1.3)
	candy.Material = Enum.Material.Plastic
	candy.Color = CANDY_COLORS[candyIndex]
	candy.TopSurface = Enum.SurfaceType.Smooth
	candy.BottomSurface = Enum.SurfaceType.Smooth
	
	candyIndex = (candyIndex % #CANDY_COLORS) + 1
	
	-- Collision settings
	candy.CanCollide = true
	candy.CanTouch = true
	candy.CanQuery = true
	
	-- Set collision group
	pcall(function()
		candy.CollisionGroup = ORB_GROUP
	end)
	
	-- Candy physics
	candy.CustomPhysicalProperties = PhysicalProperties.new(
		0.3,  -- Light
		0.5,  -- Medium friction
		0.5,  -- Bouncy candy
		1, 1
	)
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 100
	cash.Parent = candy
	
	-- Candy shine
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 0.5
	pointLight.Range = 7
	pointLight.Color = candy.Color
	pointLight.Parent = candy
	
	-- Glossy reflection
	candy.Reflectance = 0.3
	
	-- Candy wrapper shine
	local selection = Instance.new("SelectionBox")
	selection.Adornee = candy
	selection.Color3 = Color3.fromRGB(255, 255, 255)
	selection.LineThickness = 0.02
	selection.Transparency = 0.7
	selection.Parent = candy
	
	-- Sugar sparkles
	local sparkles = Instance.new("ParticleEmitter")
	sparkles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkles.Rate = 12
	sparkles.Lifetime = NumberRange.new(0.5, 1)
	sparkles.Speed = NumberRange.new(1, 2)
	sparkles.SpreadAngle = Vector2.new(180, 180)
	sparkles.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 0)
	}
	sparkles.Color = ColorSequence.new(candy.Color)
	sparkles.LightEmission = 0.6
	sparkles.Parent = candy
	
	-- Swirl pattern
	local swirl = Instance.new("Decal")
	swirl.Texture = "rbxasset://textures/ui/Scroll/scroll-middle.png"
	swirl.Color3 = Color3.fromRGB(255, 255, 255)
	swirl.Transparency = 0.7
	swirl.Face = Enum.NormalId.Front
	swirl.Parent = candy
	
	-- Position with spin
	candy.CFrame = dropPart.CFrame * CFrame.Angles(
		0,
		math.rad(candyIndex * 72),
		0
	) - Vector3.new(0, 5, 0)
	
	-- Drop with candy tumble
	candy.AssemblyLinearVelocity = Vector3.new(
		math.random(-2, 2),
		-11,
		math.random(-2, 2)
	)
	candy.AssemblyAngularVelocity = Vector3.new(
		math.random(-4, 4),
		8,
		math.random(-4, 4)
	)
	
	-- Parent to storage
	candy.Parent = PartStorage
	
	-- Spawn animation (unwrap effect)
	candy.Size = Vector3.new(0, 0, 0)
	candy.Transparency = 0.5
	
	TweenService:Create(candy,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = Vector3.new(1.3, 1.3, 1.3), Transparency = 0}
	):Play()
	
	-- Flash
	pointLight.Brightness = 1.5
	TweenService:Create(pointLight,
		TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Brightness = 0.5}
	):Play()
	
	-- Sparkle burst
	sparkles:Emit(30)
	
	-- Continuous spin
	task.spawn(function()
		while candy.Parent do
			candy.AssemblyAngularVelocity = candy.AssemblyAngularVelocity + Vector3.new(0, 0.5, 0)
			task.wait(0.1)
		end
	end)
	
	-- NO CLEANUP - Candies stay until collected!
end