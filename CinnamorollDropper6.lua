--[[
	Cinnamoroll Dropper 6 - Premium Cookie Dropper
	Drops chocolate chip cookies with extra effects
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

-- Pattern for varied drops
local dropCount = 0

while true do
	task.wait(1.5) -- Drop rate
	dropCount = dropCount + 1
	
	-- Create premium cookie
	local cookie = Instance.new("Part")
	cookie.Name = "PremiumCookie"
	cookie.Size = Vector3.new(1, 5, 4)
	cookie.TopSurface = Enum.SurfaceType.Smooth
	cookie.BottomSurface = Enum.SurfaceType.Smooth
	cookie.Material = Enum.Material.SmoothPlastic
	cookie.BrickColor = BrickColor.new("Dark orange")
	
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
	mesh.Scale = Vector3.new(1.5, 1.5, 1.5) -- Bigger cookies!
	mesh.Parent = cookie
	
	-- Physics
	cookie.CustomPhysicalProperties = PhysicalProperties.new(
		0.15,  -- Slightly heavier
		0.7,   -- Good friction
		0.1,   -- Tiny bounce
		1, 1
	)
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 12
	cash.Parent = cookie
	
	-- Premium cookie glow
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 0.5
	pointLight.Range = 7
	pointLight.Color = Color3.fromRGB(255, 200, 120) -- Golden glow
	pointLight.Parent = cookie
	
	-- Add sparkle effect
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkle.Rate = 5
	sparkle.Lifetime = NumberRange.new(1, 2)
	sparkle.Speed = NumberRange.new(0.5)
	sparkle.SpreadAngle = Vector2.new(360, 360)
	sparkle.Size = NumberSequence.new(0.3)
	sparkle.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0)) -- Gold sparkles
	sparkle.LightEmission = 0.5
	sparkle.Parent = cookie
	
	-- Position with wobble pattern
	local wobbleX = math.sin(dropCount * 0.5) * 0.3
	local wobbleZ = math.cos(dropCount * 0.5) * 0.3
	cookie.CFrame = dropPart.CFrame - Vector3.new(wobbleX, 5, wobbleZ)
	
	-- Drop with tumble
	cookie.AssemblyLinearVelocity = Vector3.new(wobbleX * 2, -12, wobbleZ * 2)
	cookie.AssemblyAngularVelocity = Vector3.new(
		math.random(-3, 3),
		math.random(-3, 3),
		math.random(-3, 3)
	)
	
	-- Parent to storage
	cookie.Parent = PartStorage
	
	-- Premium spawn animation
	cookie.Transparency = 0.5
	mesh.Scale = Vector3.new(0.1, 0.1, 0.1)
	
	-- Pop into existence
	TweenService:Create(cookie,
		TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{Transparency = 0}
	):Play()
	
	TweenService:Create(mesh,
		TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{Scale = Vector3.new(1.5, 1.5, 1.5)}
	):Play()
	
	-- Flash effect
	pointLight.Brightness = 2
	TweenService:Create(pointLight,
		TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Brightness = 0.5}
	):Play()
	
	-- Chocolate chip particles!
	local chips = Instance.new("ParticleEmitter")
	chips.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	chips.Rate = 0
	chips.Speed = NumberRange.new(3, 5)
	chips.SpreadAngle = Vector2.new(360, 360)
	chips.Lifetime = NumberRange.new(0.8)
	chips.Size = NumberSequence.new(0.2)
	chips.Color = ColorSequence.new(Color3.fromRGB(92, 51, 23)) -- Dark chocolate
	chips.Parent = cookie
	chips:Emit(15)
	Debris:AddItem(chips, 1)
	
	-- NO CLEANUP - Premium cookies stay until collected!
end