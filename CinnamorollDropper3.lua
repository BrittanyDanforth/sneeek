--[[
	Cinnamoroll Dropper 3 - Premium Kawaii Style
	Dreamy cloud orbs with rainbow sparkles and hearts
--]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- Wait for PartStorage
task.wait(2)
local PartStorage = workspace:WaitForChild("PartStorage")

-- Premium Cinnamoroll palette
local COLORS = {
	Color3.fromRGB(255, 255, 255),    -- Pure white
	Color3.fromRGB(255, 240, 250),    -- Lavender blush
	Color3.fromRGB(240, 248, 255),    -- Alice blue
	Color3.fromRGB(255, 250, 240),    -- Floral white
	Color3.fromRGB(250, 240, 255),    -- Ghost white with pink
}

-- Smart positioning
local recentPositions = {}
local MAX_MEMORY = 3

local function getSmartOffset()
	local offset = Vector3.new(
		(math.random() - 0.5) * 0.6,
		0,
		(math.random() - 0.5) * 0.6
	)
	
	-- Avoid recent positions
	for _, pos in ipairs(recentPositions) do
		if (offset - pos).Magnitude < 0.2 then
			offset = offset + Vector3.new(
				(math.random() - 0.5) * 0.3,
				0,
				(math.random() - 0.5) * 0.3
			)
		end
	end
	
	table.insert(recentPositions, offset)
	if #recentPositions > MAX_MEMORY then
		table.remove(recentPositions, 1)
	end
	
	return offset
end

while true do
	task.wait(0.8) -- Premium faster drops
	
	-- Create dreamy orb
	local orb = Instance.new("Part")
	orb.Name = "CinnamorollDream"
	orb.Shape = Enum.PartType.Ball
	orb.Material = Enum.Material.Neon
	orb.Size = Vector3.new(1.8, 1.8, 1.8)
	orb.TopSurface = Enum.SurfaceType.Smooth
	orb.BottomSurface = Enum.SurfaceType.Smooth
	orb.Color = COLORS[math.random(1, #COLORS)]
	
	-- NO COLLISION - Float like clouds!
	orb.CanCollide = false
	orb.CanTouch = true
	orb.CanQuery = false
	
	-- Dream-like physics
	orb.CustomPhysicalProperties = PhysicalProperties.new(
		0.1,  -- Ultra light
		0.2,  -- Smooth friction
		0,    -- No bounce - soft landing
		1, 1
	)
	
	-- Cash value
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = 30
	cash.Parent = orb
	
	-- Premium lighting
	local pointLight = Instance.new("PointLight")
	pointLight.Brightness = 2
	pointLight.Range = 10
	pointLight.Color = Color3.fromRGB(220, 240, 255)
	pointLight.Parent = orb
	
	-- Inner star core
	local core = Instance.new("Part")
	core.Name = "Core"
	core.Shape = Enum.PartType.Ball
	core.Material = Enum.Material.Neon
	core.Size = Vector3.new(1, 1, 1)
	core.Color = Color3.fromRGB(255, 220, 240) -- Soft pink core
	core.Transparency = 0.3
	core.CanCollide = false
	core.Massless = true
	core.Parent = orb
	
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = orb
	weld.Part1 = core
	weld.Parent = orb
	
	-- Rainbow sparkles
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkle.Rate = 15
	sparkle.Lifetime = NumberRange.new(1, 2)
	sparkle.Speed = NumberRange.new(1, 2)
	sparkle.SpreadAngle = Vector2.new(360, 360)
	sparkle.LightEmission = 1
	sparkle.LightInfluence = 0
	sparkle.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.4),
		NumberSequenceKeypoint.new(0.5, 0.5),
		NumberSequenceKeypoint.new(1, 0)
	}
	sparkle.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 220)),    -- Pink
		ColorSequenceKeypoint.new(0.33, Color3.fromRGB(200, 220, 255)), -- Blue
		ColorSequenceKeypoint.new(0.66, Color3.fromRGB(255, 255, 200)), -- Yellow
		ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 200, 255))     -- Purple
	}
	sparkle.VelocityInheritance = 0.2
	sparkle.Parent = orb
	
	-- Heart particles
	local hearts = Instance.new("ParticleEmitter")
	hearts.Texture = "rbxasset://textures/particles/heart.dds"
	hearts.Rate = 2
	hearts.Lifetime = NumberRange.new(2, 3)
	hearts.Speed = NumberRange.new(0.5)
	hearts.SpreadAngle = Vector2.new(180, 180)
	hearts.LightEmission = 0.5
	hearts.Size = NumberSequence.new(0.3)
	hearts.Color = ColorSequence.new(Color3.fromRGB(255, 182, 193)) -- Light pink
	hearts.Parent = orb
	
	-- Smart positioning
	local dropPart = script.Parent:WaitForChild("Drop")
	local offset = getSmartOffset()
	orb.CFrame = dropPart.CFrame - Vector3.new(0, 1.75, 0) + offset
	
	-- Dreamy float
	local angle = math.random() * math.pi * 2
	orb.AssemblyLinearVelocity = Vector3.new(
		math.cos(angle) * 2,
		-8,  -- Very gentle float
		math.sin(angle) * 2
	)
	
	-- Cloud transparency
	orb.Transparency = 0.1
	
	-- Set spawn time
	orb:SetAttribute("SpawnTime", tick())
	
	-- Parent to storage
	orb.Parent = PartStorage
	
	-- Magical entrance
	orb.Size = Vector3.new(0.2, 0.2, 0.2)
	core.Size = Vector3.new(0.1, 0.1, 0.1)
	
	TweenService:Create(orb,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = Vector3.new(1.8, 1.8, 1.8), Transparency = 0.1}
	):Play()
	
	TweenService:Create(core,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = Vector3.new(1, 1, 1)}
	):Play()
	
	-- Dreamy rotation
	local spin = Instance.new("BodyAngularVelocity")
	spin.AngularVelocity = Vector3.new(
		math.random(-1, 1),
		math.random(2, 4),
		math.random(-1, 1)
	)
	spin.MaxTorque = Vector3.new(2000, 2000, 2000)
	spin.Parent = orb
	
	-- Core pulse
	task.spawn(function()
		while orb.Parent do
			TweenService:Create(core,
				TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Size = Vector3.new(1.2, 1.2, 1.2), Transparency = 0.5}
			):Play()
			task.wait(2)
			if not orb.Parent then break end
			TweenService:Create(core,
				TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Size = Vector3.new(1, 1, 1), Transparency = 0.3}
			):Play()
			task.wait(2)
		end
	end)
	
	-- Remove spin after landing
	task.delay(1.5, function()
		if spin.Parent then
			spin:Destroy()
		end
	end)
	
	-- Cleanup
	Debris:AddItem(orb, 25)
	
	-- Dreamy fade out
	task.delay(22, function()
		if orb.Parent then
			sparkle.Enabled = false
			hearts.Enabled = false
			
			TweenService:Create(orb,
				TweenInfo.new(3, Enum.EasingStyle.Quad),
				{Transparency = 0.9, Size = Vector3.new(1.5, 1.5, 1.5)}
			):Play()
			
			TweenService:Create(core,
				TweenInfo.new(3, Enum.EasingStyle.Quad),
				{Transparency = 1, Size = Vector3.new(0.5, 0.5, 0.5)}
			):Play()
			
			TweenService:Create(pointLight,
				TweenInfo.new(3, Enum.EasingStyle.Linear),
				{Brightness = 0, Range = 0}
			):Play()
		end
	end)
end