--[[
	Cinnamoroll Dropper 8 - Cloud Drop Style
	Drops fluffy cloud-like Cinnamoroll orbs
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

-- Cinnamoroll cloud colors
local COLORS = {
	Color3.fromRGB(240, 248, 255),    -- Alice blue (cloud white)
	Color3.fromRGB(230, 240, 255),    -- Light sky blue
	Color3.fromRGB(255, 240, 245),    -- Lavender blush
	Color3.fromRGB(240, 255, 255),    -- Azure
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

-- Cloud pattern
local cloudPhase = 0

while true do
	task.wait(0.5) -- Fast drops!
	
	-- Create cloud orb
	local orb = Instance.new("Part")
	orb.Name = "CloudOrb"
	orb.Shape = Enum.PartType.Ball
	orb.Size = Vector3.new(1.3, 1.3, 1.3)
	orb.Material = Enum.Material.SmoothPlastic
	orb.Color = COLORS[math.random(1, #COLORS)]
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	
	-- Collision settings
	orb.CanCollide = true
	orb.CanTouch = true
	orb.CanQuery = true
	
	-- Set collision group
	pcall(function()
		orb.CollisionGroup = ORB_GROUP
	end)
	
	-- Cloud physics
	orb.CustomPhysicalProperties = PhysicalProperties.new(
		0.1,  -- Very light like a cloud
		0.6,  -- Medium friction
		0.2,  -- Small bounce
		1, 1
	)
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 100
	cash.Parent = orb
	
	-- Cloud glow
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 0.4
	pointLight.Range = 6
	pointLight.Color = Color3.fromRGB(230, 240, 255) -- Soft blue
	pointLight.Parent = orb
	
	-- Cloud transparency
	orb.Transparency = 0.3
	
	-- Cloud particles
	local clouds = Instance.new("ParticleEmitter")
	clouds.Texture = "rbxasset://textures/particles/smoke_main.dds"
	clouds.Rate = 5
	clouds.Lifetime = NumberRange.new(1, 2)
	clouds.Speed = NumberRange.new(0.5)
	clouds.SpreadAngle = Vector2.new(180, 180)
	clouds.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	}
	clouds.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(1, 1)
	}
	clouds.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	clouds.VelocityInheritance = 0.5
	clouds.Parent = orb
	
	-- Position with drift
	cloudPhase = cloudPhase + 0.5
	local driftX = math.sin(cloudPhase) * 0.3
	local driftZ = math.cos(cloudPhase) * 0.3
	orb.CFrame = dropPart.CFrame - Vector3.new(driftX, 1.4, driftZ)
	
	-- Float down gently
	orb.AssemblyLinearVelocity = Vector3.new(driftX, -8, driftZ)
	
	-- Parent to storage
	orb.Parent = PartStorage
	
	-- Spawn animation (puff into existence)
	orb.Size = Vector3.new(0.3, 0.3, 0.3)
	
	TweenService:Create(orb,
		TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{Size = Vector3.new(1.3, 1.3, 1.3)}
	):Play()
	
	-- Flash
	pointLight.Brightness = 0.8
	TweenService:Create(pointLight,
		TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Brightness = 0.4}
	):Play()
	
	-- NO CLEANUP - Cloud orbs stay until collected!
end