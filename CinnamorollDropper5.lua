--[[
	Cinnamoroll Dropper 5 - Cookie Dropper
	Drops delicious cookie meshes
	NO CLEANUP - Cookies stay until collected
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
local meshID = "http://www.roblox.com/asset?id=160003363"
local textureID = "http://www.roblox.com/asset/?id=192068356"

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

-- Cookie rotation pattern
local rotationAngle = 0

while true do
	task.wait(1.5) -- Drop rate
	
	-- Create cookie
	local cookie = Instance.new("Part")
	cookie.Name = "Cookie"
	cookie.Size = Vector3.new(1, 5, 4) -- Cookie size
	cookie.TopSurface = Enum.SurfaceType.Smooth
	cookie.BottomSurface = Enum.SurfaceType.Smooth
	cookie.Material = Enum.Material.SmoothPlastic
	cookie.BrickColor = BrickColor.new("Cork")
	
	-- Collision settings
	cookie.CanCollide = true
	cookie.CanTouch = true
	cookie.CanQuery = true
	
	-- Set collision group
	pcall(function()
		cookie.CollisionGroup = ORB_GROUP
	end)
	
	-- Cookie mesh
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshId = meshID
	mesh.TextureId = textureID
	mesh.Scale = Vector3.new(1.2, 1.2, 1.2)
	mesh.Parent = cookie
	
	-- Physics (cookies are light!)
	cookie.CustomPhysicalProperties = PhysicalProperties.new(
		0.1,  -- Very light
		0.8,  -- High friction (crumbly)
		0,    -- No bounce
		1, 1
	)
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 12
	cash.Parent = cookie
	
	-- Cookie glow
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 0.3
	pointLight.Range = 5
	pointLight.Color = Color3.fromRGB(255, 224, 178) -- Warm cookie color
	pointLight.Parent = cookie
	
	-- Position with rotation
	cookie.CFrame = dropPart.CFrame * CFrame.Angles(0, math.rad(rotationAngle), 0) - Vector3.new(0, 5, 0)
	rotationAngle = (rotationAngle + 45) % 360
	
	-- Drop with slight spin
	cookie.AssemblyLinearVelocity = Vector3.new(0, -10, 0)
	cookie.AssemblyAngularVelocity = Vector3.new(0, 2, 0)
	
	-- Parent to storage
	cookie.Parent = PartStorage
	
	-- Spawn animation (cookie rises from oven!)
	cookie.Size = Vector3.new(0.5, 2.5, 2)
	mesh.Scale = Vector3.new(0.5, 0.5, 0.5)
	
	local growTween = TweenService:Create(mesh,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Scale = Vector3.new(1.2, 1.2, 1.2)}
	)
	growTween:Play()
	
	-- Cookie crumb particles
	local crumbs = Instance.new("ParticleEmitter")
	crumbs.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	crumbs.Rate = 20
	crumbs.Lifetime = NumberRange.new(0.5, 1)
	crumbs.Speed = NumberRange.new(1, 2)
	crumbs.SpreadAngle = Vector2.new(180, 180)
	crumbs.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(1, 0)
	}
	crumbs.Color = ColorSequence.new(Color3.fromRGB(139, 90, 43)) -- Brown crumbs
	crumbs.VelocityInheritance = 0.5
	crumbs.Parent = cookie
	
	-- Stop crumbs after spawn
	task.wait(0.3)
	crumbs.Enabled = false
	Debris:AddItem(crumbs, 2)
	
	-- NO CLEANUP - Cookies stay until collected!
end