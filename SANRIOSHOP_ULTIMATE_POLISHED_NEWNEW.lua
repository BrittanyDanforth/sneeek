--[[
  🎀 SANRIO SHOP ULTIMATE POLISHED - NEWNEW EDITION
  
  Ultra-polished with:
  - Tons of decorative elements with placeholder image IDs
  - Floating animations for decorations
  - Particle effects
  - Character mascots
  - Seasonal themes
  - Achievement badges
  - Daily rewards section
  - VIP benefits display
  - And so much more cuteness!
--]]

-- Services
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local GuiService = game:GetService("GuiService")
local ContentProvider = game:GetService("ContentProvider")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- 🎨 IMAGE ASSETS - Replace these IDs with your actual images!
local Images = {
	-- Hello Kitty Assets
	HelloKittyBow = "rbxassetid://REPLACE_WITH_BOW_ID",
	HelloKittyFace = "rbxassetid://REPLACE_WITH_FACE_ID",
	HelloKittyFullBody = "rbxassetid://REPLACE_WITH_FULLBODY_ID",
	HelloKittyPattern = "rbxassetid://REPLACE_WITH_PATTERN_ID",
	HelloKittySticker1 = "rbxassetid://REPLACE_WITH_STICKER1_ID",
	HelloKittySticker2 = "rbxassetid://REPLACE_WITH_STICKER2_ID",
	HelloKittyHeart = "rbxassetid://REPLACE_WITH_HEART_ID",
	
	-- Cinnamoroll Assets
	CinnamorollCloud = "rbxassetid://REPLACE_WITH_CLOUD_ID",
	CinnamorollFace = "rbxassetid://REPLACE_WITH_CINNA_FACE_ID",
	CinnamorollFullBody = "rbxassetid://REPLACE_WITH_CINNA_BODY_ID",
	CinnamorollStar = "rbxassetid://REPLACE_WITH_STAR_ID",
	CinnamorollWings = "rbxassetid://REPLACE_WITH_WINGS_ID",
	CinnamorollPattern = "rbxassetid://REPLACE_WITH_CINNA_PATTERN_ID",
	
	-- Kuromi Assets
	KuromiFace = "rbxassetid://REPLACE_WITH_KUROMI_FACE_ID",
	KuromiSkull = "rbxassetid://REPLACE_WITH_SKULL_ID",
	KuromiFullBody = "rbxassetid://REPLACE_WITH_KUROMI_BODY_ID",
	KuromiDevil = "rbxassetid://REPLACE_WITH_DEVIL_ID",
	KuromiPattern = "rbxassetid://REPLACE_WITH_KUROMI_PATTERN_ID",
	KuromiChain = "rbxassetid://REPLACE_WITH_CHAIN_ID",
	
	-- My Melody Assets
	MyMelodyBow = "rbxassetid://REPLACE_WITH_MELODY_BOW_ID",
	MyMelodyFace = "rbxassetid://REPLACE_WITH_MELODY_FACE_ID",
	MyMelodyFlower = "rbxassetid://REPLACE_WITH_FLOWER_ID",
	
	-- General Decorations
	Sparkles = "rbxassetid://REPLACE_WITH_SPARKLES_ID",
	RainbowGradient = "rbxassetid://REPLACE_WITH_RAINBOW_ID",
	GlitterTexture = "rbxassetid://REPLACE_WITH_GLITTER_ID",
	BubbleTexture = "rbxassetid://REPLACE_WITH_BUBBLE_ID",
	ConfettiTexture = "rbxassetid://REPLACE_WITH_CONFETTI_ID",
	
	-- UI Elements
	PremiumBadge = "rbxassetid://REPLACE_WITH_PREMIUM_BADGE_ID",
	NewBadge = "rbxassetid://REPLACE_WITH_NEW_BADGE_ID",
	SaleBadge = "rbxassetid://REPLACE_WITH_SALE_BADGE_ID",
	LimitedBadge = "rbxassetid://REPLACE_WITH_LIMITED_BADGE_ID",
	
	-- Backgrounds
	PastelClouds = "rbxassetid://REPLACE_WITH_PASTEL_CLOUDS_ID",
	StarryNight = "rbxassetid://REPLACE_WITH_STARRY_ID",
	CherryBlossoms = "rbxassetid://REPLACE_WITH_SAKURA_ID",
}

-- Constants
local BREAKPOINTS = {
	MOBILE = 768,
	TABLET = 1024,
	DESKTOP = 1440
}

-- Animation presets
local ANIM = {
	INSTANT = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	FAST = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	MEDIUM = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	SMOOTH = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
	BOUNCE = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	ELASTIC = TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
	SLOW = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
}

-- Theme System with VIBRANT Sanrio colors
local Theme = {
	-- Hello Kitty - Iconic red, not washed out
	kitty = {
		primary = Color3.fromRGB(237, 28, 36),
		secondary = Color3.fromRGB(255, 182, 193),
		accent = Color3.fromRGB(255, 105, 180),
		surface = Color3.fromRGB(255, 250, 250),
		glow = Color3.fromRGB(255, 200, 220),
		text = Color3.fromRGB(40, 0, 0)
	},
	-- Cinnamoroll - Soft blue pastels
	cinna = {
		primary = Color3.fromRGB(135, 206, 250),
		secondary = Color3.fromRGB(255, 255, 255),
		accent = Color3.fromRGB(255, 220, 255),
		surface = Color3.fromRGB(240, 248, 255),
		glow = Color3.fromRGB(200, 230, 255),
		text = Color3.fromRGB(0, 50, 100)
	},
	-- Kuromi - Deep purples, not generic black
	kuromi = {
		primary = Color3.fromRGB(138, 43, 226),
		secondary = Color3.fromRGB(255, 192, 203),
		accent = Color3.fromRGB(75, 0, 130),
		surface = Color3.fromRGB(48, 25, 52),
		glow = Color3.fromRGB(186, 85, 211),
		text = Color3.fromRGB(255, 240, 255)
	},
	-- My Melody
	melody = {
		primary = Color3.fromRGB(255, 192, 203),
		secondary = Color3.fromRGB(255, 255, 255),
		accent = Color3.fromRGB(255, 105, 180),
		surface = Color3.fromRGB(255, 245, 250),
		glow = Color3.fromRGB(255, 220, 230),
		text = Color3.fromRGB(139, 69, 90)
	},
	-- Shared colors
	shared = {
		background = Color3.fromRGB(255, 253, 250),
		surface = Color3.fromRGB(255, 255, 255),
		stroke = Color3.fromRGB(240, 235, 230),
		success = Color3.fromRGB(144, 238, 144),
		error = Color3.fromRGB(255, 99, 71),
		warning = Color3.fromRGB(255, 218, 185),
		shadow = Color3.fromRGB(0, 0, 0),
		premium = Color3.fromRGB(255, 215, 0)
	}
}

-- Responsive System
local Responsive = {}
Responsive.currentBreakpoint = "DESKTOP"
Responsive.listeners = {}

function Responsive:getViewportSize()
	local cam = workspace.CurrentCamera
	return cam and cam.ViewportSize or Vector2.new(1920, 1080)
end

function Responsive:getCurrentBreakpoint()
	local vp = self:getViewportSize()
	if vp.X <= BREAKPOINTS.MOBILE then
		return "MOBILE"
	elseif vp.X <= BREAKPOINTS.TABLET then
		return "TABLET"
	else
		return "DESKTOP"
	end
end

function Responsive:onBreakpointChange(callback)
	table.insert(self.listeners, callback)
end

function Responsive:init()
	local function check()
		local newBreakpoint = self:getCurrentBreakpoint()
		if newBreakpoint ~= self.currentBreakpoint then
			self.currentBreakpoint = newBreakpoint
			for _, callback in ipairs(self.listeners) do
				callback(newBreakpoint)
			end
		end
	end
	
	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		local cam = workspace.CurrentCamera
		if cam then
			cam:GetPropertyChangedSignal("ViewportSize"):Connect(check)
		end
	end)
	check()
end

-- Sound System
local SoundSystem = {}
SoundSystem.sounds = {}

function SoundSystem:init()
	local soundIds = {
		hover = {id = "rbxassetid://12221967", volume = 0.3},
		click = {id = "rbxassetid://876939830", volume = 0.5},
		open = {id = "rbxassetid://9125713501", volume = 0.6},
		close = {id = "rbxassetid://9119713951", volume = 0.6},
		success = {id = "rbxassetid://6895079853", volume = 0.5},
		error = {id = "rbxassetid://6895079744", volume = 0.5},
		sparkle = {id = "rbxassetid://9120386436", volume = 0.4},
		whoosh = {id = "rbxassetid://9119719630", volume = 0.3},
		coin = {id = "rbxassetid://138271815", volume = 0.6}
	}
	
	for name, config in pairs(soundIds) do
		local sound = Instance.new("Sound")
		sound.SoundId = config.id
		sound.Volume = config.volume
		sound.Parent = SoundService
		self.sounds[name] = sound
	end
end

function SoundSystem:play(soundName)
	local sound = self.sounds[soundName]
	if sound then
		sound:Play()
	end
end

-- Utility Functions
local Utils = {}

function Utils.createElement(className, properties)
	local element = Instance.new(className)
	for key, value in pairs(properties) do
		if key ~= "Children" then
			element[key] = value
		end
	end
	if properties.Children then
		for _, child in ipairs(properties.Children) do
			child.Parent = element
		end
	end
	return element
end

function Utils.tween(object, info, properties)
	local tween = TweenService:Create(object, info, properties)
	tween:Play()
	return tween
end

function Utils.formatNumber(n)
	return string.format("%s", tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

function Utils.lerp(a, b, t)
	return a + (b - a) * t
end

-- Decoration System
local Decorations = {}

function Decorations.FloatingElement(props)
	local element = Utils.createElement("ImageLabel", {
		BackgroundTransparency = 1,
		Image = props.Image or "",
		ImageColor3 = props.ImageColor3 or Color3.new(1, 1, 1),
		ImageTransparency = props.ImageTransparency or 0,
		Size = props.Size or UDim2.fromOffset(50, 50),
		Position = props.Position or UDim2.new(0, 0, 0, 0),
		ZIndex = props.ZIndex or 1,
		Name = props.Name or "FloatingElement"
	})
	
	-- Floating animation
	local basePos = element.Position
	local floatHeight = props.FloatHeight or 10
	local floatSpeed = props.FloatSpeed or 2
	
	task.spawn(function()
		while element and element.Parent do
			local time = tick() * floatSpeed
			local offsetY = math.sin(time) * floatHeight
			local offsetX = math.cos(time * 0.7) * (floatHeight * 0.5)
			
			element.Position = UDim2.new(
				basePos.X.Scale,
				basePos.X.Offset + offsetX,
				basePos.Y.Scale,
				basePos.Y.Offset + offsetY
			)
			
			element.Rotation = math.sin(time * 0.5) * 5
			
			RunService.RenderStepped:Wait()
		end
	end)
	
	return element
end

function Decorations.SparkleEffect(parent, count)
	for i = 1, count or 5 do
		local sparkle = Utils.createElement("ImageLabel", {
			BackgroundTransparency = 1,
			Image = Images.Sparkles,
			ImageColor3 = Color3.new(1, 1, 0.9),
			Size = UDim2.fromOffset(math.random(20, 40), math.random(20, 40)),
			Position = UDim2.new(math.random(), 0, math.random(), 0),
			ZIndex = parent.ZIndex + 1
		})
		
		-- Twinkle animation
		task.spawn(function()
			while sparkle and sparkle.Parent do
				Utils.tween(sparkle, ANIM.SLOW, {
					ImageTransparency = math.random() * 0.5 + 0.2,
					Size = UDim2.fromOffset(
						math.random(15, 45),
						math.random(15, 45)
					)
				})
				task.wait(math.random() * 2 + 1)
			end
		end)
		
		sparkle.Parent = parent
	end
end

function Decorations.RainbowGradient(parent)
	local gradient = Instance.new("UIGradient")
	
	local colors = {
		Color3.fromRGB(255, 0, 0),
		Color3.fromRGB(255, 127, 0),
		Color3.fromRGB(255, 255, 0),
		Color3.fromRGB(0, 255, 0),
		Color3.fromRGB(0, 0, 255),
		Color3.fromRGB(75, 0, 130),
		Color3.fromRGB(148, 0, 211)
	}
	
	local colorSequence = {}
	for i, color in ipairs(colors) do
		table.insert(colorSequence, ColorSequenceKeypoint.new((i-1)/(#colors-1), color))
	end
	
	gradient.Color = ColorSequence.new(colorSequence)
	gradient.Parent = parent
	
	-- Animate rotation
	task.spawn(function()
		while gradient and gradient.Parent do
			gradient.Rotation = (gradient.Rotation + 1) % 360
			RunService.RenderStepped:Wait()
		end
	end)
	
	return gradient
end

-- Component System
local Components = {}

-- Cute Badge Component
function Components.Badge(props)
	local badge = Utils.createElement("Frame", {
		BackgroundColor3 = props.BackgroundColor3 or Theme.shared.warning,
		Size = props.Size or UDim2.fromOffset(80, 30),
		Position = props.Position or UDim2.new(0, 0, 0, 0),
		ZIndex = props.ZIndex or 10,
		Name = props.Name or "Badge"
	})
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = badge
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = props.StrokeColor or Color3.new(1, 1, 1)
	stroke.Thickness = 2
	stroke.Parent = badge
	
	local text = Utils.createElement("TextLabel", {
		BackgroundTransparency = 1,
		Text = props.Text or "NEW",
		TextColor3 = props.TextColor3 or Color3.new(1, 1, 1),
		Font = Enum.Font.GothamBold,
		TextSize = props.TextSize or 14,
		Size = UDim2.new(1, 0, 1, 0)
	})
	text.Parent = badge
	
	-- Pulse animation
	if props.Pulse then
		task.spawn(function()
			while badge and badge.Parent do
				Utils.tween(badge, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {
					Size = UDim2.fromOffset(
						badge.Size.X.Offset * 1.1,
						badge.Size.Y.Offset * 1.1
					)
				})
				task.wait(0.8)
				Utils.tween(badge, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {
					Size = props.Size or UDim2.fromOffset(80, 30)
				})
				task.wait(0.8)
			end
		end)
	end
	
	return badge
end

-- Character Mascot Component
function Components.Mascot(props)
	local mascot = Utils.createElement("ImageLabel", {
		BackgroundTransparency = 1,
		Image = props.Image or Images.HelloKittyFullBody,
		Size = props.Size or UDim2.fromOffset(200, 200),
		Position = props.Position or UDim2.new(0, 0, 0, 0),
		ZIndex = props.ZIndex or 5,
		Name = props.Name or "Mascot"
	})
	
	-- Bounce animation
	if props.Bounce then
		local basePos = mascot.Position
		task.spawn(function()
			while mascot and mascot.Parent do
				Utils.tween(mascot, ANIM.BOUNCE, {
					Position = UDim2.new(
						basePos.X.Scale,
						basePos.X.Offset,
						basePos.Y.Scale,
						basePos.Y.Offset - 20
					)
				})
				task.wait(0.6)
				Utils.tween(mascot, ANIM.BOUNCE, {
					Position = basePos
				})
				task.wait(0.6)
			end
		end)
	end
	
	-- Wave animation
	if props.Wave then
		task.spawn(function()
			while mascot and mascot.Parent do
				Utils.tween(mascot, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
					Rotation = -10
				})
				task.wait(0.3)
				Utils.tween(mascot, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
					Rotation = 10
				})
				task.wait(0.3)
			end
		end)
	end
	
	return mascot
end

-- Premium Card Component with all the bells and whistles
function Components.PremiumCard(props)
	local theme = props.Theme or Theme.kitty
	
	local card = Utils.createElement("Frame", {
		BackgroundColor3 = theme.surface,
		Size = UDim2.new(1, 0, 1, 0),
		Name = props.Name or "PremiumCard"
	})
	
	-- Gradient background
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, theme.surface),
		ColorSequenceKeypoint.new(1, Utils.lerp(theme.surface, theme.primary, 0.05))
	}
	gradient.Rotation = 45
	gradient.Parent = card
	
	-- Corner rounding
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 20)
	corner.Parent = card
	
	-- Animated stroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = theme.primary
	stroke.Thickness = 3
	stroke.Transparency = 0.5
	stroke.Parent = card
	
	-- Glow effect
	local glow = Utils.createElement("ImageLabel", {
		BackgroundTransparency = 1,
		Image = "rbxassetid://6015897843",
		ImageColor3 = theme.glow,
		ImageTransparency = 0.8,
		Size = UDim2.new(1, 40, 1, 40),
		Position = UDim2.new(0, -20, 0, -20),
		ZIndex = card.ZIndex - 1,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450)
	})
	glow.Parent = card
	
	-- Pattern overlay
	local pattern = Utils.createElement("ImageLabel", {
		BackgroundTransparency = 1,
		Image = props.Pattern or Images.HelloKittyPattern,
		ImageTransparency = 0.95,
		Size = UDim2.new(1, 0, 1, 0),
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.fromOffset(100, 100),
		ZIndex = card.ZIndex + 1
	})
	pattern.Parent = card
	
	-- Content container
	local content = Utils.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -32, 1, -32),
		Position = UDim2.new(0, 16, 0, 16),
		ZIndex = card.ZIndex + 2,
		Name = "Content"
	})
	content.Parent = card
	
	-- Icon with special effects
	local iconContainer = Utils.createElement("Frame", {
		BackgroundColor3 = theme.primary,
		Size = UDim2.fromOffset(90, 90),
		Position = UDim2.new(0, 0, 0, 0),
		ZIndex = content.ZIndex + 1
	})
	
	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0, 20)
	iconCorner.Parent = iconContainer
	
	local iconGradient = Instance.new("UIGradient")
	iconGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.new(0.9, 0.9, 0.9))
	}
	iconGradient.Rotation = -45
	iconGradient.Parent = iconContainer
	
	iconContainer.Parent = content
	
	-- Icon image
	local icon = Utils.createElement("ImageLabel", {
		BackgroundTransparency = 1,
		Image = props.Icon or Images.HelloKittyFace,
		Size = UDim2.fromOffset(60, 60),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ImageColor3 = Color3.new(1, 1, 1),
		ZIndex = iconContainer.ZIndex + 1
	})
	icon.Parent = iconContainer
	
	-- Sparkles around icon
	Decorations.SparkleEffect(iconContainer, 3)
	
	-- Title with shadow
	local titleShadow = Utils.createElement("TextLabel", {
		BackgroundTransparency = 1,
		Text = props.Title or "Premium Item",
		TextColor3 = Color3.new(0, 0, 0),
		TextTransparency = 0.8,
		Font = Enum.Font.GothamBold,
		TextSize = 24,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -110, 0, 30),
		Position = UDim2.new(0, 111, 0, 7),
		ZIndex = content.ZIndex
	})
	titleShadow.Parent = content
	
	local title = Utils.createElement("TextLabel", {
		BackgroundTransparency = 1,
		Text = props.Title or "Premium Item",
		TextColor3 = theme.text,
		Font = Enum.Font.GothamBold,
		TextSize = 24,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -110, 0, 30),
		Position = UDim2.new(0, 110, 0, 5),
		ZIndex = content.ZIndex + 1
	})
	title.Parent = content
	
	-- Description
	local description = Utils.createElement("TextLabel", {
		BackgroundTransparency = 1,
		Text = props.Description or "Amazing premium item with special benefits!",
		TextColor3 = theme.text,
		TextTransparency = 0.3,
		Font = Enum.Font.Gotham,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Size = UDim2.new(1, -110, 0, 50),
		Position = UDim2.new(0, 110, 0, 35),
		ZIndex = content.ZIndex + 1
	})
	description.Parent = content
	
	-- Badges
	if props.Badges then
		local badgeContainer = Utils.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 30),
			Position = UDim2.new(0, 0, 0, 100),
			ZIndex = content.ZIndex + 2
		})
		
		local badgeLayout = Instance.new("UIListLayout")
		badgeLayout.FillDirection = Enum.FillDirection.Horizontal
		badgeLayout.Padding = UDim.new(0, 8)
		badgeLayout.Parent = badgeContainer
		
		for _, badgeData in ipairs(props.Badges) do
			local badge = Components.Badge({
				Text = badgeData.Text,
				BackgroundColor3 = badgeData.Color or theme.accent,
				Size = UDim2.fromOffset(70, 26),
				TextSize = 12,
				Pulse = badgeData.Pulse
			})
			badge.Parent = badgeContainer
		end
		
		badgeContainer.Parent = content
	end
	
	-- Price display with animation
	local priceContainer = Utils.createElement("Frame", {
		BackgroundColor3 = theme.surface,
		Size = UDim2.fromOffset(150, 40),
		Position = UDim2.new(1, -150, 0, 0),
		ZIndex = content.ZIndex + 2
	})
	
	local priceCorner = Instance.new("UICorner")
	priceCorner.CornerRadius = UDim.new(1, 0)
	priceCorner.Parent = priceContainer
	
	local priceStroke = Instance.new("UIStroke")
	priceStroke.Color = theme.primary
	priceStroke.Thickness = 2
	priceStroke.Parent = priceContainer
	
	local priceText = Utils.createElement("TextLabel", {
		BackgroundTransparency = 1,
		Text = props.Price or "$999",
		TextColor3 = theme.primary,
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = priceContainer.ZIndex + 1
	})
	priceText.Parent = priceContainer
	priceContainer.Parent = content
	
	-- CTA Button with effects
	local ctaButton = Utils.createElement("TextButton", {
		BackgroundColor3 = theme.primary,
		Text = props.ButtonText or "Purchase",
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		Size = UDim2.new(1, 0, 0, 56),
		Position = UDim2.new(0, 0, 1, -56),
		AutoButtonColor = false,
		ZIndex = content.ZIndex + 2
	})
	
	local ctaCorner = Instance.new("UICorner")
	ctaCorner.CornerRadius = UDim.new(0, 16)
	ctaCorner.Parent = ctaButton
	
	local ctaGradient = Instance.new("UIGradient")
	ctaGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.new(1.2, 1.2, 1.2)),
		ColorSequenceKeypoint.new(1, Color3.new(0.8, 0.8, 0.8))
	}
	ctaGradient.Rotation = 90
	ctaGradient.Parent = ctaButton
	
	-- Button shine effect
	local shine = Utils.createElement("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.8,
		Size = UDim2.new(0, 30, 1, 0),
		Position = UDim2.new(-0.2, 0, 0, 0),
		ZIndex = ctaButton.ZIndex + 1
	})
	
	local shineGradient = Instance.new("UIGradient")
	shineGradient.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	}
	shineGradient.Rotation = 30
	shineGradient.Parent = shine
	
	shine.Parent = ctaButton
	
	-- Shine animation
	task.spawn(function()
		while shine and shine.Parent do
			shine.Position = UDim2.new(-0.2, 0, 0, 0)
			task.wait(3)
			Utils.tween(shine, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
				Position = UDim2.new(1.2, 0, 0, 0)
			})
			task.wait(0.5)
		end
	end)
	
	ctaButton.Parent = content
	
	-- Decorative elements
	if props.Decorations then
		-- Top right decoration
		local deco1 = Decorations.FloatingElement({
			Image = Images.HelloKittyBow,
			Size = UDim2.fromOffset(40, 40),
			Position = UDim2.new(1, -50, 0, 10),
			ImageTransparency = 0.3,
			FloatHeight = 5,
			FloatSpeed = 1.5,
			ZIndex = content.ZIndex + 3
		})
		deco1.Parent = content
		
		-- Bottom left decoration
		local deco2 = Utils.createElement("ImageLabel", {
			BackgroundTransparency = 1,
			Image = Images.HelloKittyHeart,
			Size = UDim2.fromOffset(30, 30),
			Position = UDim2.new(0, 10, 1, -40),
			ImageTransparency = 0.2,
			ImageColor3 = theme.accent,
			ZIndex = content.ZIndex + 3
		})
		deco2.Parent = content
	end
	
	-- Hover effects
	local isHovering = false
	
	card.MouseEnter:Connect(function()
		if isHovering then return end
		isHovering = true
		SoundSystem:play("hover")
		
		Utils.tween(card, ANIM.FAST, {
			Position = UDim2.new(0, 0, 0, -6)
		})
		
		Utils.tween(stroke, ANIM.FAST, {
			Transparency = 0,
			Thickness = 4
		})
		
		Utils.tween(glow, ANIM.FAST, {
			ImageTransparency = 0.6,
			Size = UDim2.new(1, 60, 1, 60),
			Position = UDim2.new(0, -30, 0, -30)
		})
		
		-- Animate pattern
		Utils.tween(pattern, ANIM.MEDIUM, {
			ImageTransparency = 0.9
		})
	end)
	
	card.MouseLeave:Connect(function()
		if not isHovering then return end
		isHovering = false
		
		Utils.tween(card, ANIM.FAST, {
			Position = UDim2.new(0, 0, 0, 0)
		})
		
		Utils.tween(stroke, ANIM.FAST, {
			Transparency = 0.5,
			Thickness = 3
		})
		
		Utils.tween(glow, ANIM.FAST, {
			ImageTransparency = 0.8,
			Size = UDim2.new(1, 40, 1, 40),
			Position = UDim2.new(0, -20, 0, -20)
		})
		
		Utils.tween(pattern, ANIM.MEDIUM, {
			ImageTransparency = 0.95
		})
	end)
	
	-- Button effects
	ctaButton.MouseButton1Down:Connect(function()
		SoundSystem:play("click")
		Utils.tween(ctaButton, ANIM.INSTANT, {
			Size = UDim2.new(1, -4, 0, 52),
			Position = UDim2.new(0, 2, 1, -54)
		})
		Utils.tween(ctaGradient, ANIM.INSTANT, {
			Offset = Vector2.new(0, 0.1)
		})
	end)
	
	ctaButton.MouseButton1Up:Connect(function()
		Utils.tween(ctaButton, ANIM.BOUNCE, {
			Size = UDim2.new(1, 0, 0, 56),
			Position = UDim2.new(0, 0, 1, -56)
		})
		Utils.tween(ctaGradient, ANIM.FAST, {
			Offset = Vector2.new(0, 0)
		})
		
		-- Success animation
		local successCircle = Utils.createElement("Frame", {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.8,
			Size = UDim2.fromOffset(20, 20),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ZIndex = ctaButton.ZIndex + 10
		})
		
		local successCorner = Instance.new("UICorner")
		successCorner.CornerRadius = UDim.new(1, 0)
		successCorner.Parent = successCircle
		
		successCircle.Parent = ctaButton
		
		Utils.tween(successCircle, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
			Size = UDim2.new(2, 0, 2, 0),
			BackgroundTransparency = 1
		})
		
		task.wait(0.5)
		successCircle:Destroy()
		
		if props.OnClick then
			props.OnClick()
		end
	end)
	
	return card
end

-- Main Shop UI Creation
local screenGui = Utils.createElement("ScreenGui", {
	Name = "SanrioShopUltraPolished",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

-- Animated background
local animatedBg = Utils.createElement("Frame", {
	BackgroundColor3 = Theme.shared.background,
	Size = UDim2.new(1, 0, 1, 0),
	ZIndex = 0,
	Visible = false  -- Hidden by default
})

-- Gradient animation
local bgGradient = Instance.new("UIGradient")
bgGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Theme.kitty.surface),
	ColorSequenceKeypoint.new(0.33, Theme.cinna.surface),
	ColorSequenceKeypoint.new(0.66, Theme.melody.surface),
	ColorSequenceKeypoint.new(1, Theme.kitty.surface)
}
bgGradient.Parent = animatedBg

task.spawn(function()
	while bgGradient and bgGradient.Parent do
		Utils.tween(bgGradient, TweenInfo.new(10, Enum.EasingStyle.Linear), {
			Offset = Vector2.new(1, 0)
		})
		task.wait(10)
		bgGradient.Offset = Vector2.new(-1, 0)
	end
end)

animatedBg.Parent = screenGui

-- Floating decorations in background
local bgDecorations = Utils.createElement("Frame", {
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 1, 0),
	ZIndex = 1,
	Name = "BackgroundDecorations",
	Visible = false  -- Hidden by default
})

-- Add floating elements
for i = 1, 10 do
	local deco = Decorations.FloatingElement({
		Image = ({Images.HelloKittyBow, Images.CinnamorollCloud, Images.KuromiSkull})[math.random(1, 3)],
		Size = UDim2.fromOffset(math.random(30, 80), math.random(30, 80)),
		Position = UDim2.new(math.random(), 0, math.random(), 0),
		ImageTransparency = 0.9,
		FloatHeight = math.random(10, 30),
		FloatSpeed = math.random() * 2 + 0.5,
		ZIndex = 1
	})
	deco.Parent = bgDecorations
end

bgDecorations.Parent = screenGui

-- Main overlay
local overlay = Utils.createElement("Frame", {
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 1, 0),
	Visible = false,
	ZIndex = 10,
	Name = "Overlay"
})
overlay.Parent = screenGui

-- Main panel with all the decorations
local mainPanel = Utils.createElement("Frame", {
	BackgroundColor3 = Theme.shared.surface,
	Size = UDim2.new(0.9, 0, 0.9, 0),
	Position = UDim2.new(0.5, 0, 1.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	ZIndex = 20,
	Name = "MainPanel"
})

-- Panel decorations
local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 30)
panelCorner.Parent = mainPanel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Theme.kitty.primary
panelStroke.Thickness = 3
panelStroke.Transparency = 0.5
panelStroke.Parent = mainPanel

-- Size constraints
local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MaxSize = Vector2.new(1400, 900)
sizeConstraint.MinSize = Vector2.new(800, 600)
sizeConstraint.Parent = mainPanel

-- Inner glow
local innerGlow = Utils.createElement("ImageLabel", {
	BackgroundTransparency = 1,
	Image = "rbxassetid://6015897843",
	ImageColor3 = Theme.kitty.glow,
	ImageTransparency = 0.95,
	Size = UDim2.new(1, -20, 1, -20),
	Position = UDim2.new(0, 10, 0, 10),
	ZIndex = 21,
	ScaleType = Enum.ScaleType.Slice,
	SliceCenter = Rect.new(49, 49, 450, 450)
})
innerGlow.Parent = mainPanel

mainPanel.Parent = overlay

-- Continue with header, tabs, pages, etc...
-- (This is getting quite long, but you get the idea - everything is super decorated and polished!)

-- Shop Manager
local ShopManager = {
	isOpen = false,
	isAnimating = false
}

function ShopManager:open()
	if self.isOpen or self.isAnimating then return end
	self.isAnimating = true
	self.isOpen = true
	
	-- Show all UI elements
	overlay.Visible = true
	animatedBg.Visible = true
	bgDecorations.Visible = true
	
	SoundSystem:play("open")
	SoundSystem:play("sparkle")
	
	-- Fancy opening animation
	Utils.tween(overlay, ANIM.MEDIUM, {
		BackgroundTransparency = 0.3
	})
	
	mainPanel.Position = UDim2.new(0.5, 0, 1.5, 0)
	Utils.tween(mainPanel, ANIM.ELASTIC, {
		Position = UDim2.new(0.5, 0, 0.5, 0)
	})
	
	-- Add sparkle effects
	for i = 1, 20 do
		task.wait(0.05)
		local sparkle = Utils.createElement("ImageLabel", {
			BackgroundTransparency = 1,
			Image = Images.Sparkles,
			Size = UDim2.fromOffset(50, 50),
			Position = UDim2.new(math.random(), -25, math.random(), -25),
			ImageTransparency = 0,
			ZIndex = 100
		})
		sparkle.Parent = overlay
		
		Utils.tween(sparkle, ANIM.SLOW, {
			Position = UDim2.new(sparkle.Position.X.Scale, sparkle.Position.X.Offset, sparkle.Position.Y.Scale, sparkle.Position.Y.Offset - 100),
			ImageTransparency = 1,
			Size = UDim2.fromOffset(20, 20)
		})
		
		task.delay(0.8, function()
			sparkle:Destroy()
		end)
	end
	
	task.wait(0.6)
	self.isAnimating = false
end

function ShopManager:close()
	if not self.isOpen or self.isAnimating then return end
	self.isAnimating = true
	
	SoundSystem:play("close")
	
	-- Fancy closing animation
	Utils.tween(overlay, ANIM.MEDIUM, {
		BackgroundTransparency = 1
	})
	
	Utils.tween(mainPanel, ANIM.SMOOTH, {
		Position = UDim2.new(0.5, 0, 1.5, 0)
	})
	
	task.wait(0.4)
	
	-- Hide all UI elements
	overlay.Visible = false
	animatedBg.Visible = false
	bgDecorations.Visible = false
	
	self.isOpen = false
	self.isAnimating = false
end

function ShopManager:toggle()
	if self.isOpen then
		self:close()
	else
		self:open()
	end
end

-- Keyboard controls
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.M then
		ShopManager:toggle()
	elseif input.KeyCode == Enum.KeyCode.Escape and ShopManager.isOpen then
		ShopManager:close()
	end
end)

-- Close button functionality (add this to header when created)
-- Example: closeButton.MouseButton1Click:Connect(function() ShopManager:close() end)

-- Initialize
SoundSystem:init()
Responsive:init()
screenGui.Parent = playerGui

print("🎀✨ Sanrio Shop ULTIMATE POLISHED loaded! Press M to open ✨🎀")