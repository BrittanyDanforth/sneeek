--[[
	Simple Clean Dropper v2 - Mid Tier ($15)
	Based on the good-looking Dropper 2 but simplified
--]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local PartStorage = workspace:WaitForChild("PartStorage")

-- Configuration
local DROP_RATE = 1
local DROP_VALUE = 15
local DROP_LIFETIME = 20

-- Create clean orb with glow
local function createOrb()
	local orb = Instance.new("Part")
	orb.Name = "CashOrb"
	orb.Shape = Enum.PartType.Ball
	orb.Material = Enum.Material.Neon
	orb.Size = Vector3.new(1.6, 1.6, 1.6)
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	orb.Color = Color3.fromRGB(100, 149, 237) -- Cornflower blue
	orb.Transparency = 0.2
	
	-- Better physics
	orb.CustomPhysicalProperties = PhysicalProperties.new(
		0.8,  -- Lighter
		0.4,  -- Less friction
		0.15, -- Small bounce
		1,
		1
	)
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = DROP_VALUE
	cash.Parent = orb
	
	-- Nice glow
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 2
	pointLight.Range = 6
	pointLight.Color = orb.Color
	pointLight.Parent = orb
	
	-- Simple outer glow (no weld needed)
	local glow = Instance.new("Part")
	glow.Name = "Glow"
	glow.Shape = Enum.PartType.Ball
	glow.Material = Enum.Material.ForceField
	glow.Size = Vector3.new(2, 2, 2)
	glow.Color = orb.Color
	glow.Transparency = 0.8
	glow.CanCollide = false
	glow.Massless = true
	glow.CFrame = orb.CFrame
	glow.Parent = orb
	
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = orb
	weld.Part1 = glow
	weld.Parent = orb
	
	-- Position with offset
	local dropPart = script.Parent:WaitForChild("Drop")
	orb.CFrame = dropPart.CFrame - Vector3.new(
		math.random(-3, 3) * 0.1,
		1.5,
		math.random(-3, 3) * 0.1
	)
	
	-- Controlled velocity
	orb.AssemblyLinearVelocity = Vector3.new(
		math.random(-2, 2),
		-8,
		math.random(-2, 2)
	)
	
	-- Set spawn time
	orb:SetAttribute("SpawnTime", tick())
	
	-- Parent to storage
	orb.Parent = PartStorage
	
	-- Simple spawn animation
	orb.Size = Vector3.new(0.8, 0.8, 0.8)
	TweenService:Create(orb,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = Vector3.new(1.6, 1.6, 1.6)}
	):Play()
	
	-- Cleanup
	Debris:AddItem(orb, DROP_LIFETIME)
end

-- Main loop
while true do
	createOrb()
	task.wait(DROP_RATE)
end