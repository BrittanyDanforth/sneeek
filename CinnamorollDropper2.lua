--[[
	Cinnamoroll Dropper 2 - Enhanced Kawaii Style
	Fluffy cloud orbs with sparkles, no collision
--]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- Wait for PartStorage
task.wait(2)
local PartStorage = workspace:WaitForChild("PartStorage")

-- Cinnamoroll palette
local COLORS = {
	Color3.fromRGB(255, 255, 255),    -- Pure white
	Color3.fromRGB(220, 240, 255),    -- Soft blue-white
	Color3.fromRGB(255, 240, 245),    -- Soft pink-white
	Color3.fromRGB(240, 248, 255),    -- Alice blue
}

-- Pattern for anti-stacking
local dropPattern = 1

while true do
	task.wait(1) -- Faster drops
	
	-- Create fluffy orb
	local orb = Instance.new("Part")
	orb.Name = "CinnamorollCloud"
	orb.Shape = Enum.PartType.Ball
	orb.Material = Enum.Material.Neon
	orb.Size = Vector3.new(1.6, 1.6, 1.6)
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	orb.Color = COLORS[math.random(1, #COLORS)]
	
	-- NO COLLISION!
	orb.CanCollide = false
	orb.CanTouch = true
	orb.CanQuery = false
	
	-- Fluffy physics
	orb.CustomPhysicalProperties = PhysicalProperties.new(
		0.2,  -- Super light like a cloud
		0.3,  -- Low friction
		0,    -- No bounce
		1, 1
	)
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 15
	cash.Parent = orb
	
	-- Enhanced glow
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 1.5
	pointLight.Range = 7
	pointLight.Color = Color3.fromRGB(200, 230, 255)
	pointLight.Parent = orb
	
	-- Cloud outline (ForceField for soft glow)
	local glow = Instance.new("SelectionBox")
	glow.Adornee = orb
	glow.Color3 = Color3.fromRGB(173, 216, 230)
	glow.LineThickness = 0.1
	glow.Transparency = 0.5
	glow.Parent = orb
	
	-- Kawaii sparkles
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkle.Rate = 8
	sparkle.Lifetime = NumberRange.new(0.5, 1)
	sparkle.Speed = NumberRange.new(0.5, 1)
	sparkle.SpreadAngle = Vector2.new(180, 180)
	sparkle.LightEmission = 1
	sparkle.LightInfluence = 0
	sparkle.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 0)
	}
	sparkle.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	sparkle.Parent = orb
	
	-- Pattern positioning
	local dropPart = script.Parent:WaitForChild("Drop")
	local patterns = {
		Vector3.new(0.2, 0, 0.2),
		Vector3.new(-0.2, 0, 0.2),
		Vector3.new(0.2, 0, -0.2),
		Vector3.new(-0.2, 0, -0.2),
		Vector3.new(0, 0, 0),
	}
	local offset = patterns[dropPattern]
	dropPattern = (dropPattern % #patterns) + 1
	
	orb.CFrame = dropPart.CFrame - Vector3.new(0, 1.75, 0) + offset
	
	-- Float down gently
	orb.AssemblyLinearVelocity = Vector3.new(
		offset.X * 2,
		-10,  -- Gentle float
		offset.Z * 2
	)
	
	-- Semi-transparent cloud
	orb.Transparency = 0.15
	
	-- Set spawn time
	orb:SetAttribute("SpawnTime", tick())
	
	-- Parent to storage
	orb.Parent = PartStorage
	
	-- Bounce spawn animation
	orb.Size = Vector3.new(0.4, 0.4, 0.4)
	local spawnTween = TweenService:Create(orb,
		TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{Size = Vector3.new(1.6, 1.6, 1.6)}
	)
	spawnTween:Play()
	
	-- Gentle rotation
	local spin = Instance.new("BodyAngularVelocity")
	spin.AngularVelocity = Vector3.new(0, 2, 0)
	spin.MaxTorque = Vector3.new(0, math.huge, 0)
	spin.Parent = orb
	
	-- Remove spin after landing
	task.delay(1, function()
		if spin.Parent then
			spin:Destroy()
		end
	end)
	
	-- Cleanup
	Debris:AddItem(orb, 22)
	
	-- Fade out
	task.delay(20, function()
		if orb.Parent then
			sparkle.Enabled = false
			TweenService:Create(orb,
				TweenInfo.new(2, Enum.EasingStyle.Linear),
				{Transparency = 0.8}
			):Play()
		end
	end)
end