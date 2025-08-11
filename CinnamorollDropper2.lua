--[[
	Cinnamoroll Dropper 2 - Enhanced Cloud Style
	Ball orbs with cloud-like effects and particles
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

-- Cinnamoroll cloud color palette  
local COLORS = {
	Color3.fromRGB(255, 250, 250), -- Snow White
	Color3.fromRGB(248, 248, 255), -- Ghost White
	Color3.fromRGB(240, 248, 255), -- Alice Blue
	Color3.fromRGB(230, 243, 255), -- Soft Cinnamon Blue
	Color3.fromRGB(255, 240, 245), -- Lavender Blush
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

local cloudCount = 0

while true do
	task.wait(0.8) -- Slightly faster than Dropper 1
	cloudCount = cloudCount + 1
	
	-- Create cloud ball
	local cloud = Instance.new("Part")
	cloud.Name = "CloudOrb_" .. cloudCount
	cloud.Shape = Enum.PartType.Ball
	cloud.Material = Enum.Material.ForceField -- Cloud-like material
	cloud.Size = Vector3.new(1.8, 1.8, 1.8) -- Bigger than basic
	cloud.Color = COLORS[math.random(1, #COLORS)]
	cloud.Transparency = 0.2 -- Slightly see-through like clouds
	cloud.TopSurface = Enum.SurfaceType.Smooth
	cloud.BottomSurface = Enum.SurfaceType.Smooth
	cloud.CanCollide = true
	cloud.CanTouch = true
	cloud.CanQuery = true
	
	-- Set collision group
	pcall(function()
		cloud.CollisionGroup = ORB_GROUP
	end)
	
	-- Floating physics
	cloud.CustomPhysicalProperties = PhysicalProperties.new(
		0.1, -- Very light like a cloud
		0.3, -- Low friction
		0.8, -- High bounce
		1, 1
	)
	
	-- Cloud mist particles
	local mist = Instance.new("ParticleEmitter")
	mist.Texture = "rbxasset://textures/particles/smoke_main.dds"
	mist.Rate = 10
	mist.Lifetime = NumberRange.new(2, 3)
	mist.Speed = NumberRange.new(0.5, 1)
	mist.SpreadAngle = Vector2.new(30, 30)
	mist.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	mist.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.7),
		NumberSequenceKeypoint.new(1, 1)
	}
	mist.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 1.5)
	}
	mist.LightEmission = 0.8
	mist.Parent = cloud
	
	-- Sparkle particles
	local sparkles = Instance.new("ParticleEmitter")
	sparkles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkles.Rate = 15
	sparkles.Lifetime = NumberRange.new(1, 2)
	sparkles.Speed = NumberRange.new(0.5)
	sparkles.SpreadAngle = Vector2.new(45, 45)
	sparkles.Color = ColorSequence.new(Color3.fromRGB(173, 216, 230))
	sparkles.LightEmission = 0.7
	sparkles.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 0)
	}
	sparkles.Parent = cloud
	
	-- Soft glow
	local glow = Instance.new("PointLight")
	glow.Brightness = 0.8
	glow.Range = 8
	glow.Color = Color3.fromRGB(173, 216, 230)
	glow.Parent = cloud
	
	-- Add selection sphere for soft outline
	local selection = Instance.new("SelectionSphere")
	selection.Adornee = cloud
	selection.Color3 = Color3.fromRGB(173, 216, 230)
	selection.SurfaceTransparency = 1
	selection.Transparency = 0.4
	selection.Parent = cloud
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 30 -- Higher than basic
	cash.Parent = cloud
	
	-- Position at dropper
	cloud.CFrame = dropPart.CFrame * CFrame.new(0, -2, 0)
	
	-- Gentle float down
	cloud.AssemblyLinearVelocity = Vector3.new(0, -5, 0) -- Slower fall
	
	-- Parent to workspace
	cloud.Parent = PartStorage
	
	-- Spawn animation
	cloud.Size = Vector3.new(0.5, 0.5, 0.5)
	cloud.Transparency = 0.8
	
	TweenService:Create(cloud,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = Vector3.new(1.8, 1.8, 1.8), Transparency = 0.2}
	):Play()
	
	-- Flash effect
	glow.Brightness = 2
	TweenService:Create(glow,
		TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Brightness = 0.8}
	):Play()
	
	-- NO CLEANUP - Clouds stay until collected!
end