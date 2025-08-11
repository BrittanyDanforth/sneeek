--[[
	Cinnamoroll Dropper 1 - Basic Kawaii Style
	Cute cloud-like orbs that don't collide with players/other orbs
--]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- Wait for PartStorage
task.wait(2)
local PartStorage = workspace:WaitForChild("PartStorage")

-- Cinnamoroll colors (white, baby blue, soft pink)
local COLORS = {
	Color3.fromRGB(255, 255, 255),    -- Pure white
	Color3.fromRGB(220, 240, 255),    -- Soft blue-white
	Color3.fromRGB(245, 250, 255),    -- Ice white
}

while true do
	task.wait(1.2) -- Drop rate
	
	-- Create cute orb
	local orb = Instance.new("Part")
	orb.Name = "CinnamorollOrb"
	orb.Shape = Enum.PartType.Ball
	orb.Material = Enum.Material.Neon
	orb.Size = Vector3.new(1.4, 1.4, 1.4)
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	orb.Color = COLORS[math.random(1, #COLORS)]
	
	-- NO COLLISION with players or other orbs!
	orb.CanCollide = false
	orb.CanTouch = true
	orb.CanQuery = false
	
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
	
	-- Soft glow
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 1
	pointLight.Range = 5
	pointLight.Color = Color3.fromRGB(200, 230, 255) -- Soft blue glow
	pointLight.Parent = orb
	
	-- Position with small offset
	local dropPart = script.Parent:WaitForChild("Drop")
	local offsetX = math.random(-2, 2) * 0.1
	local offsetZ = math.random(-2, 2) * 0.1
	orb.CFrame = dropPart.CFrame - Vector3.new(offsetX, 1.75, offsetZ)
	
	-- Gentle drop
	orb.AssemblyLinearVelocity = Vector3.new(0, -12, 0)
	
	-- Cloud-like transparency
	orb.Transparency = 0.2
	
	-- Set spawn time for cleanup
	orb:SetAttribute("SpawnTime", tick())
	
	-- Parent to storage
	orb.Parent = PartStorage
	
	-- Simple spawn effect
	orb.Size = Vector3.new(0.7, 0.7, 0.7)
	local spawnTween = TweenService:Create(orb,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = Vector3.new(1.4, 1.4, 1.4)}
	)
	spawnTween:Play()
	
	-- Cleanup
	Debris:AddItem(orb, 20)
end