--[[
	Simple Clean Dropper v1 - Basic ($10)
	No lag, no ugly effects, just clean orbs
--]]

local Debris = game:GetService("Debris")
local PartStorage = workspace:WaitForChild("PartStorage")

-- Configuration
local DROP_RATE = 1.2
local DROP_VALUE = 10
local DROP_LIFETIME = 20

-- Create simple orb
local function createOrb()
	local orb = Instance.new("Part")
	orb.Name = "CashOrb"
	orb.Shape = Enum.PartType.Ball
	orb.Material = Enum.Material.Neon
	orb.Size = Vector3.new(1.5, 1.5, 1.5)
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	orb.Color = Color3.fromRGB(135, 206, 250) -- Light blue
	orb.Transparency = 0.3
	
	-- Simple physics - no crazy bouncing
	orb.CustomPhysicalProperties = PhysicalProperties.new(
		1,    -- Normal density
		0.5,  -- Normal friction
		0.1,  -- Low bounce
		1,
		1
	)
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = DROP_VALUE
	cash.Parent = orb
	
	-- Simple glow
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 1
	pointLight.Range = 5
	pointLight.Color = orb.Color
	pointLight.Parent = orb
	
	-- Position with small random offset
	local dropPart = script.Parent:WaitForChild("Drop")
	orb.CFrame = dropPart.CFrame - Vector3.new(
		math.random(-2, 2) * 0.1,
		1.5,
		math.random(-2, 2) * 0.1
	)
	
	-- Small downward velocity only
	orb.AssemblyLinearVelocity = Vector3.new(0, -5, 0)
	
	-- Set spawn time for cleanup
	orb:SetAttribute("SpawnTime", tick())
	
	-- Parent to storage
	orb.Parent = PartStorage
	
	-- Cleanup
	Debris:AddItem(orb, DROP_LIFETIME)
end

-- Main loop
while true do
	createOrb()
	task.wait(DROP_RATE)
end