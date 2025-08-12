--[[
  🧷 Sanrio Character Takeover Shop – Professional Edition
  - Enhanced with better error handling, accessibility, and performance optimizations
  - Improved code organization and maintainability
  - Added subtle polish features and smoother animations
]]

-- Services
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local GuiService = game:GetService("GuiService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Constants
local ANIMATION_DEFAULTS = {
	FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	MEDIUM = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	SLOW = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	BOUNCE = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	SMOOTH = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
}

local MOBILE_THRESHOLD = 1024
local TYPEWRITER_SPEED = 0.025
local AUTO_MESSAGE_DELAY = 120
local HK_INITIAL_DELAY = 120

-- Utility Module
local Utils = {}

function Utils.tween(instance: Instance?, info: TweenInfo, props: {[string]: any}, callback: (() -> ())?): Tween?
	if not instance then return nil end
	local tween = TweenService:Create(instance, info, props)
	tween:Play()
	if callback then
		tween.Completed:Connect(callback)
	end
	return tween
end

function Utils.setFont(guiObject: TextLabel | TextButton, weight: Enum.FontWeight?, size: number?)
	weight = weight or Enum.FontWeight.Regular
	size = size or 14
	guiObject.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", weight, Enum.FontStyle.Normal)
	guiObject.TextSize = size
end

function Utils.blendColor(color1: Color3, color2: Color3, alpha: number): Color3
	alpha = math.clamp(alpha, 0, 1)
	return Color3.new(
		color1.R + (color2.R - color1.R) * alpha,
		color1.G + (color2.G - color1.G) * alpha,
		color1.B + (color2.B - color1.B) * alpha
	)
end

function Utils.isMobile(): boolean
	local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
	if not viewport then return false end
	return viewport.X <= MOBILE_THRESHOLD or GuiService:IsTenFootInterface()
end

function Utils.createSound(id: string, volume: number?): Sound
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Volume = volume or 0.5
	sound.Parent = SoundService
	return sound
end

function Utils.safeCall(func: () -> (), errorHandler: ((string) -> ())?)
	local success, err = pcall(func)
	if not success and errorHandler then
		errorHandler(tostring(err))
	end
	return success
end

-- Asset Manager with validation
local AssetManager = {}
AssetManager.assets = {
	paperTexture = "rbxassetid://3584103989",  -- Subtle paper texture
	badgeHello = "rbxassetid://17398522865",
	badgeMelody = "rbxassetid://17398525031",
	badgeKuromi = "rbxassetid://17398526388",
	badgeCinna = "rbxassetid://17398524224",
	
	iconCloseX = "rbxassetid://13516603909",
	iconBag = "rbxassetid://6031280882",
	iconCash = "rbxassetid://10709728059",
	iconPass = "rbxassetid://10709727148",
	
	hkPortrait = "rbxassetid://8399407650",
	
	-- Additional themed assets
	hkBowPattern = "rbxassetid://6022668879",  -- Bow pattern
	cloudTexture = "rbxassetid://7149254641",  -- Cloud texture for Cinnamoroll
	starPattern = "rbxassetid://6022668898",   -- Star pattern
	
	-- Sound effects (using actual Roblox sounds)
	soundClick = "rbxassetid://876939830",
	soundHover = "rbxassetid://12221990",
	soundOpen = "rbxassetid://9120458886",
	soundClose = "rbxassetid://9120462866",
	soundTypewriter = "rbxassetid://9113880610"
}

function AssetManager.getAsset(name: string): string
	return AssetManager.assets[name] or ""
end

function AssetManager.isValidAsset(id: string): boolean
	return id ~= "rbxassetid://0" and id ~= ""
end

-- Theme Manager
local ThemeManager = {}
ThemeManager.themes = {
	default = {
		bg = Color3.fromRGB(253, 252, 250),
		panel = Color3.fromRGB(255, 255, 255),
		panelAlt = Color3.fromRGB(246, 248, 252),
		stroke = Color3.fromRGB(222, 226, 235),
		text = Color3.fromRGB(35, 38, 46),
		subtext = Color3.fromRGB(120, 126, 140),
		scrollbar = Color3.fromRGB(180, 185, 200),
		
		kitty = Color3.fromRGB(255, 64, 64),
		kuromiLav = Color3.fromRGB(200, 190, 255),
		kuromiInk = Color3.fromRGB(38, 38, 46),
		cinnaSky = Color3.fromRGB(186, 214, 255),
		
		success = Color3.fromRGB(76, 175, 80),
		warning = Color3.fromRGB(255, 152, 0),
		error = Color3.fromRGB(244, 67, 54)
	}
}

ThemeManager.currentTheme = "default"

function ThemeManager.getColor(colorName: string): Color3
	local theme = ThemeManager.themes[ThemeManager.currentTheme]
	return theme[colorName] or Color3.new(1, 1, 1)
end

-- Shop Data Manager
local ShopDataManager = {}
ShopDataManager.data = {
	cash = {
		{id = 3366419712, amount = 1000, name = "1,000 Cash", icon = "rbxassetid://0", description = "A small boost to get you started"},
		{id = 3366420012, amount = 5000, name = "5,000 Cash", icon = "rbxassetid://0", description = "Perfect for mid-game purchases"},
		{id = 3366420478, amount = 10000, name = "10,000 Cash", icon = "rbxassetid://0", description = "A significant cash injection"},
		{id = 3366420800, amount = 25000, name = "25,000 Cash", icon = "rbxassetid://0", description = "Maximum value bundle"}
	},
	gamepasses = {
		{id = 123456789, name = "2x Cash", price = 199, icon = "rbxassetid://0", description = "Double all cash earned"},
		{id = 123456790, name = "VIP Pass", price = 499, icon = "rbxassetid://0", description = "Exclusive VIP benefits"},
		{id = 123456791, name = "Auto Collect", price = 299, icon = "rbxassetid://0", description = "Automatically collect rewards"}
	}
}

function ShopDataManager.getProductInfo(id: number)
	local success, info = pcall(function()
		return MarketplaceService:GetProductInfo(id, Enum.InfoType.Product)
	end)
	return success and info or nil
end

function ShopDataManager.getGamePassInfo(id: number)
	local success, info = pcall(function()
		return MarketplaceService:GetProductInfo(id, Enum.InfoType.GamePass)
	end)
	return success and info or nil
end

-- Sound Manager
local SoundManager = {}
SoundManager.sounds = {}
SoundManager.enabled = true

function SoundManager:init()
	local function safeCreateSound(assetId: string, volume: number)
		if AssetManager.isValidAsset(assetId) then
			return Utils.createSound(assetId, volume)
		end
		return nil
	end
	
	self.sounds.click = safeCreateSound(AssetManager.assets.soundClick, 0.4)
	self.sounds.hover = safeCreateSound(AssetManager.assets.soundHover, 0.2)
	self.sounds.open = safeCreateSound(AssetManager.assets.soundOpen, 0.5)
	self.sounds.close = safeCreateSound(AssetManager.assets.soundClose, 0.5)
	self.sounds.typewriter = safeCreateSound(AssetManager.assets.soundTypewriter, 0.1)
end

function SoundManager:play(soundName: string)
	if not self.enabled then return end
	local sound = self.sounds[soundName]
	if sound then
		sound:Play()
	end
end

-- Initialize Sound Manager
SoundManager:init()

-- UI Component Factory
local UIFactory = {}

function UIFactory.createFrame(props: {[string]: any}): Frame
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = props.BackgroundColor3 or ThemeManager.getColor("panel")
	frame.BackgroundTransparency = props.BackgroundTransparency or 0
	frame.BorderSizePixel = 0
	frame.Size = props.Size or UDim2.new(1, 0, 1, 0)
	frame.Position = props.Position or UDim2.new(0, 0, 0, 0)
	frame.AnchorPoint = props.AnchorPoint or Vector2.new(0, 0)
	frame.Name = props.Name or "Frame"
	frame.ZIndex = props.ZIndex or 1
	frame.Visible = props.Visible ~= false
	
	if props.CornerRadius then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = props.CornerRadius
		corner.Parent = frame
	end
	
	if props.Stroke then
		local stroke = Instance.new("UIStroke")
		stroke.Color = props.Stroke.Color or ThemeManager.getColor("stroke")
		stroke.Thickness = props.Stroke.Thickness or 1
		stroke.Transparency = props.Stroke.Transparency or 0
		stroke.Parent = frame
	end
	
	if props.Shadow then
		UIFactory.addShadow(frame, props.Shadow)
	end
	
	return frame
end

function UIFactory.createTextLabel(props: {[string]: any}): TextLabel
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Text = props.Text or ""
	label.TextColor3 = props.TextColor3 or ThemeManager.getColor("text")
	label.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Center
	label.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
	label.Size = props.Size or UDim2.new(1, 0, 1, 0)
	label.Position = props.Position or UDim2.new(0, 0, 0, 0)
	label.AnchorPoint = props.AnchorPoint or Vector2.new(0, 0)
	label.Name = props.Name or "TextLabel"
	label.ZIndex = props.ZIndex or 1
	label.TextScaled = props.TextScaled or false
	label.TextWrapped = props.TextWrapped ~= false
	label.RichText = props.RichText or false
	
	Utils.setFont(label, props.FontWeight or Enum.FontWeight.Regular, props.TextSize or 14)
	
	return label
end

function UIFactory.createTextButton(props: {[string]: any}): TextButton
	local button = Instance.new("TextButton")
	button.BackgroundColor3 = props.BackgroundColor3 or ThemeManager.getColor("panel")
	button.BackgroundTransparency = props.BackgroundTransparency or 0
	button.BorderSizePixel = 0
	button.Text = props.Text or ""
	button.TextColor3 = props.TextColor3 or ThemeManager.getColor("text")
	button.Size = props.Size or UDim2.new(0, 100, 0, 40)
	button.Position = props.Position or UDim2.new(0, 0, 0, 0)
	button.AnchorPoint = props.AnchorPoint or Vector2.new(0, 0)
	button.Name = props.Name or "TextButton"
	button.ZIndex = props.ZIndex or 1
	button.AutoButtonColor = false
	
	Utils.setFont(button, props.FontWeight or Enum.FontWeight.Medium, props.TextSize or 16)
	
	if props.CornerRadius then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = props.CornerRadius
		corner.Parent = button
	end
	
	if props.Stroke then
		local stroke = Instance.new("UIStroke")
		stroke.Color = props.Stroke.Color or ThemeManager.getColor("stroke")
		stroke.Thickness = props.Stroke.Thickness or 1
		stroke.Transparency = props.Stroke.Transparency or 0
		stroke.Parent = button
	end
	
	-- Add hover effects
	if props.HoverEffects ~= false then
		UIFactory.addHoverEffects(button, props)
	end
	
	-- Add click sound
	if props.ClickSound ~= false then
		button.MouseButton1Click:Connect(function()
			SoundManager:play("click")
		end)
	end
	
	return button
end

function UIFactory.createImageLabel(props: {[string]: any}): ImageLabel
	local image = Instance.new("ImageLabel")
	image.BackgroundTransparency = 1
	image.Image = props.Image or ""
	image.ImageColor3 = props.ImageColor3 or Color3.new(1, 1, 1)
	image.ImageTransparency = props.ImageTransparency or 0
	image.ScaleType = props.ScaleType or Enum.ScaleType.Fit
	image.Size = props.Size or UDim2.new(0, 100, 0, 100)
	image.Position = props.Position or UDim2.new(0, 0, 0, 0)
	image.AnchorPoint = props.AnchorPoint or Vector2.new(0, 0)
	image.Name = props.Name or "ImageLabel"
	image.ZIndex = props.ZIndex or 1
	
	if props.CornerRadius then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = props.CornerRadius
		corner.Parent = image
	end
	
	return image
end

function UIFactory.createScrollingFrame(props: {[string]: any}): ScrollingFrame
	local scroll = Instance.new("ScrollingFrame")
	scroll.BackgroundTransparency = props.BackgroundTransparency or 1
	scroll.BorderSizePixel = 0
	scroll.Size = props.Size or UDim2.new(1, 0, 1, 0)
	scroll.Position = props.Position or UDim2.new(0, 0, 0, 0)
	scroll.CanvasSize = props.CanvasSize or UDim2.new(0, 0, 0, 0)
	scroll.ScrollBarThickness = props.ScrollBarThickness or 8
	scroll.ScrollBarImageColor3 = props.ScrollBarImageColor3 or ThemeManager.getColor("scrollbar")
	scroll.ScrollingDirection = props.ScrollingDirection or Enum.ScrollingDirection.Y
	scroll.Name = props.Name or "ScrollingFrame"
	scroll.ZIndex = props.ZIndex or 1
	
	if props.Layout then
		local layout = props.Layout.Type == "Grid" and Instance.new("UIGridLayout") or Instance.new("UIListLayout")
		for prop, value in pairs(props.Layout) do
			if prop ~= "Type" and layout[prop] ~= nil then
				layout[prop] = value
			end
		end
		layout.Parent = scroll
	end
	
	if props.Padding then
		local padding = Instance.new("UIPadding")
		padding.PaddingTop = props.Padding.Top or UDim.new(0, 0)
		padding.PaddingBottom = props.Padding.Bottom or UDim.new(0, 0)
		padding.PaddingLeft = props.Padding.Left or UDim.new(0, 0)
		padding.PaddingRight = props.Padding.Right or UDim.new(0, 0)
		padding.Parent = scroll
	end
	
	return scroll
end

function UIFactory.addShadow(instance: GuiObject, shadowProps: {[string]: any}?)
	local props = shadowProps or {}
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://6015897843"
	shadow.ImageTransparency = props.Transparency or 0.7
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(49, 49, 450, 450)
	shadow.Size = UDim2.new(1, props.Offset or 50, 1, props.Offset or 50)
	shadow.Position = UDim2.new(0, -(props.Offset or 50)/2, 0, -(props.Offset or 50)/2 + (props.YOffset or 0))
	shadow.ZIndex = instance.ZIndex - 1
	shadow.Parent = instance
	return shadow
end

function UIFactory.addHoverEffects(button: GuiButton, props: {[string]: any}?)
	local originalSize = button.Size
	local originalColor = button.BackgroundColor3
	local hoverScale = props and props.HoverScale or 1.05
	local hoverBrightness = props and props.HoverBrightness or 1.1
	
	button.MouseEnter:Connect(function()
		SoundManager:play("hover")
		Utils.tween(button, ANIMATION_DEFAULTS.FAST, {
			Size = UDim2.new(
				originalSize.X.Scale * hoverScale,
				originalSize.X.Offset * hoverScale,
				originalSize.Y.Scale * hoverScale,
				originalSize.Y.Offset * hoverScale
			),
			BackgroundColor3 = Color3.new(
				math.min(originalColor.R * hoverBrightness, 1),
				math.min(originalColor.G * hoverBrightness, 1),
				math.min(originalColor.B * hoverBrightness, 1)
			)
		})
	end)
	
	button.MouseLeave:Connect(function()
		Utils.tween(button, ANIMATION_DEFAULTS.FAST, {
			Size = originalSize,
			BackgroundColor3 = originalColor
		})
	end)
end

-- Create main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SanrioShopUI_Professional"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 1000
screenGui.Parent = playerGui

-- Add paper background texture
if AssetManager.isValidAsset(AssetManager.assets.paperTexture) then
	local paperBg = Instance.new("ImageLabel")
	paperBg.Name = "PaperBackground"
	paperBg.Size = UDim2.fromScale(1, 1)
	paperBg.BackgroundTransparency = 1
	paperBg.Image = AssetManager.assets.paperTexture
	paperBg.ImageTransparency = 0.93
	paperBg.ScaleType = Enum.ScaleType.Tile
	paperBg.TileSize = UDim2.fromOffset(200, 200)
	paperBg.ZIndex = 1
	paperBg.Parent = screenGui
end

-- Blur Manager
local BlurManager = {}
BlurManager.blur = nil

function BlurManager:getBlur()
	if self.blur then return self.blur end
	
	local existingBlur = Lighting:FindFirstChild("SanrioShopBlur")
	if existingBlur and existingBlur:IsA("BlurEffect") then
		self.blur = existingBlur
		return self.blur
	end
	
	self.blur = Instance.new("BlurEffect")
	self.blur.Name = "SanrioShopBlur"
	self.blur.Size = 0
	self.blur.Parent = Lighting
	
	return self.blur
end

function BlurManager:show(targetSize: number?)
	local blur = self:getBlur()
	Utils.tween(blur, ANIMATION_DEFAULTS.MEDIUM, {Size = targetSize or 10})
end

function BlurManager:hide()
	local blur = self:getBlur()
	Utils.tween(blur, ANIMATION_DEFAULTS.MEDIUM, {Size = 0})
end

-- Create background dim
local dimOverlay = UIFactory.createFrame({
	Name = "DimOverlay",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 1,
	Visible = false,
	ZIndex = 5
})
dimOverlay.Parent = screenGui

-- Create main panel
local mainPanel = UIFactory.createFrame({
	Name = "MainPanel",
	Size = UDim2.new(0, 980, 0, 860),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = ThemeManager.getColor("panel"),
	CornerRadius = UDim.new(0, 24),
	Stroke = {Thickness = 1.5},
	Shadow = {Offset = 60, YOffset = 10},
	Visible = false,
	ZIndex = 10
})
mainPanel.Parent = screenGui

-- Add responsive scaling
local uiScale = Instance.new("UIScale")
uiScale.Parent = mainPanel

local function updateUIScale()
	local camera = workspace.CurrentCamera
	if not camera then return end
	
	local viewportSize = camera.ViewportSize
	local minDimension = math.min(viewportSize.X, viewportSize.Y)
	local scaleFactor = math.clamp(minDimension / 1080, 0.7, 1.2)
	
	-- Adjust for mobile
	if Utils.isMobile() then
		scaleFactor = scaleFactor * 0.9
	end
	
	uiScale.Scale = scaleFactor
end

-- Connect viewport size changes
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	local camera = workspace.CurrentCamera
	if camera then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateUIScale)
		updateUIScale()
	end
end)

if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateUIScale)
	updateUIScale()
end

-- Create header
local header = UIFactory.createFrame({
	Name = "Header",
	Size = UDim2.new(1, -24, 0, 88),
	Position = UDim2.new(0, 12, 0, 12),
	BackgroundColor3 = ThemeManager.getColor("panelAlt"),
	CornerRadius = UDim.new(0, 18),
	Stroke = {},
	ZIndex = 11
})
header.Parent = mainPanel

-- Add gradient to header
local headerGradient = Instance.new("UIGradient")
headerGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(250, 250, 250))
}
headerGradient.Rotation = 90
headerGradient.Parent = header

-- Header content
local kittyBadge = UIFactory.createImageLabel({
	Name = "KittyBadge",
	Image = AssetManager.assets.badgeHello,
	Size = UDim2.new(0, 46, 0, 46),
	Position = UDim2.new(0, 16, 0.5, 0),
	AnchorPoint = Vector2.new(0, 0.5),
	ZIndex = 12
})
kittyBadge.Parent = header

-- Animate badge rotation
task.spawn(function()
	while true do
		Utils.tween(kittyBadge, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Rotation = 5
		})
		task.wait(2)
		Utils.tween(kittyBadge, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Rotation = -5
		})
		task.wait(2)
	end
end)

local title = UIFactory.createTextLabel({
	Name = "Title",
	Text = "Sanrio Shop",
	Position = UDim2.new(0, 72, 0, 0),
	Size = UDim2.new(1, -140, 1, 0),
	TextXAlignment = Enum.TextXAlignment.Left,
	FontWeight = Enum.FontWeight.Bold,
	TextSize = 36,
	ZIndex = 12
})
title.Parent = header

-- Close button with improved styling
local closeButton = UIFactory.createTextButton({
	Name = "CloseButton",
	Size = UDim2.new(0, 40, 0, 40),
	Position = UDim2.new(1, -56, 0.5, 0),
	AnchorPoint = Vector2.new(0, 0.5),
	BackgroundColor3 = Color3.fromRGB(235, 60, 60),
	Text = "",
	CornerRadius = UDim.new(1, 0),
	ZIndex = 13,
	HoverScale = 1.1,
	HoverBrightness = 1.2
})
closeButton.Parent = header

local closeIcon = UIFactory.createImageLabel({
	Name = "CloseIcon",
	Image = AssetManager.assets.iconCloseX,
	ImageColor3 = Color3.new(1, 1, 1),
	Size = UDim2.new(0, 20, 0, 20),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	ZIndex = 14
})
closeIcon.Parent = closeButton

-- Tab System
local TabSystem = {}
TabSystem.tabs = {}
TabSystem.pages = {}
TabSystem.currentTab = nil

function TabSystem:createTab(name: string, icon: string?, accent: Color3?)
	local tabButton = UIFactory.createTextButton({
		Name = name .. "Tab",
		Text = name,
		Size = UDim2.new(0, 156, 1, 0),
		BackgroundColor3 = ThemeManager.getColor("panel"),
		TextColor3 = ThemeManager.getColor("text"),
		CornerRadius = UDim.new(1, 0),
		Stroke = {},
		FontWeight = Enum.FontWeight.Medium,
		TextSize = 20,
		ZIndex = 12
	})
	
	if icon and AssetManager.isValidAsset(icon) then
		local iconImage = UIFactory.createImageLabel({
			Name = "Icon",
			Image = icon,
			Size = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(0, 12, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			ImageColor3 = ThemeManager.getColor("text"),
			ZIndex = 13
		})
		iconImage.Parent = tabButton
		
		tabButton.Text = ""
		local textLabel = UIFactory.createTextLabel({
			Name = "Text",
			Text = name,
			Position = UDim2.new(0, 40, 0, 0),
			Size = UDim2.new(1, -52, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			FontWeight = Enum.FontWeight.Medium,
			TextSize = 20,
			ZIndex = 13
		})
		textLabel.Parent = tabButton
	end
	
	self.tabs[name] = {
		button = tabButton,
		accent = accent or ThemeManager.getColor("kitty"),
		icon = icon
	}
	
	return tabButton
end

function TabSystem:createPage(name: string)
	local page = UIFactory.createFrame({
		Name = name .. "Page",
		BackgroundTransparency = 1,
		Visible = false,
		ZIndex = 11
	})
	
	self.pages[name] = page
	return page
end

function TabSystem:selectTab(name: string)
	if self.currentTab == name then return end
	
	-- Deselect all tabs
	for tabName, tabData in pairs(self.tabs) do
		local btn = tabData.button
		local isSelected = tabName == name
		
		Utils.tween(btn, ANIMATION_DEFAULTS.FAST, {
			BackgroundColor3 = isSelected and Utils.blendColor(tabData.accent, Color3.new(1, 1, 1), 0.9) or ThemeManager.getColor("panel"),
			TextColor3 = isSelected and tabData.accent or ThemeManager.getColor("text")
		})
		
		local stroke = btn:FindFirstChildOfClass("UIStroke")
		if stroke then
			Utils.tween(stroke, ANIMATION_DEFAULTS.FAST, {
				Color = isSelected and tabData.accent or ThemeManager.getColor("stroke"),
				Thickness = isSelected and 2 or 1
			})
		end
		
		-- Update icon color if exists
		local icon = btn:FindFirstChild("Icon")
		if icon and icon:IsA("ImageLabel") then
			Utils.tween(icon, ANIMATION_DEFAULTS.FAST, {
				ImageColor3 = isSelected and tabData.accent or ThemeManager.getColor("text")
			})
		end
		
		local textLabel = btn:FindFirstChild("Text")
		if textLabel and textLabel:IsA("TextLabel") then
			Utils.tween(textLabel, ANIMATION_DEFAULTS.FAST, {
				TextColor3 = isSelected and tabData.accent or ThemeManager.getColor("text")
			})
		end
	end
	
	-- Hide all pages
	for _, page in pairs(self.pages) do
		page.Visible = false
	end
	
	-- Show selected page with animation
	local selectedPage = self.pages[name]
	if selectedPage then
		selectedPage.Visible = true
		selectedPage.Position = UDim2.new(0, 0, 0, 20)
		Utils.tween(selectedPage, ANIMATION_DEFAULTS.BOUNCE, {
			Position = UDim2.new(0, 0, 0, 0)
		})
	end
	
	self.currentTab = name
	SoundManager:play("click")
end

-- Create tab bar
local tabBar = UIFactory.createFrame({
	Name = "TabBar",
	Size = UDim2.new(1, -24, 0, 52),
	Position = UDim2.new(0, 12, 0, 110),
	BackgroundTransparency = 1,
	ZIndex = 11
})
tabBar.Parent = mainPanel

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0, 10)
tabLayout.Parent = tabBar

-- Create tabs
local homeTab = TabSystem:createTab("Home", AssetManager.assets.iconBag, ThemeManager.getColor("kitty"))
homeTab.Parent = tabBar

local cashTab = TabSystem:createTab("Cash", AssetManager.assets.iconCash, ThemeManager.getColor("cinnaSky"))
cashTab.Parent = tabBar

local passTab = TabSystem:createTab("Gamepasses", AssetManager.assets.iconPass, ThemeManager.getColor("kuromiLav"))
passTab.Parent = tabBar

-- Create pages container
local pagesContainer = UIFactory.createFrame({
	Name = "PagesContainer",
	Size = UDim2.new(1, -24, 1, -174),
	Position = UDim2.new(0, 12, 0, 174),
	BackgroundTransparency = 1,
	ZIndex = 10
})
pagesContainer.Parent = mainPanel

-- Create pages
local homePage = TabSystem:createPage("Home")
homePage.Parent = pagesContainer

local cashPage = TabSystem:createPage("Cash")
cashPage.Parent = pagesContainer

local passPage = TabSystem:createPage("Gamepasses")
passPage.Parent = pagesContainer

-- Shop Item Card Component
local function createShopItemCard(itemData: {[string]: any}, itemType: string, themeData: {[string]: any}): Frame
	local cardTheme = {
		cash = {
			bg = Color3.new(1, 1, 1),
			stroke = ThemeManager.getColor("stroke"),
			icon = ThemeManager.getColor("cinnaSky"),
			button = Utils.blendColor(ThemeManager.getColor("cinnaSky"), Color3.new(1, 1, 1), 0.8)
		},
		pass = {
			bg = Color3.fromRGB(28, 28, 34),
			stroke = Color3.fromRGB(255, 80, 180),
			icon = Color3.fromRGB(240, 240, 255),
			button = Color3.fromRGB(44, 44, 52)
		}
	}
	
	local theme = cardTheme[itemType] or cardTheme.cash
	
	local card = UIFactory.createFrame({
		Name = "ItemCard",
		Size = UDim2.new(0, 320, 0, 180),
		BackgroundColor3 = theme.bg,
		CornerRadius = UDim.new(0, 20),
		Stroke = {Color = theme.stroke, Thickness = itemType == "pass" and 3 or 1, Transparency = itemType == "pass" and 0.15 or 0.3},
		Shadow = {Offset = 30, Transparency = 0.5},
		ZIndex = 12
	})
	
	-- Inner content frame
	local inner = UIFactory.createFrame({
		Name = "Inner",
		Size = UDim2.new(1, -18, 1, -18),
		Position = UDim2.new(0, 9, 0, 9),
		BackgroundColor3 = itemType == "pass" and Color3.fromRGB(34, 34, 42) or ThemeManager.getColor("panelAlt"),
		CornerRadius = UDim.new(0, 16),
		Stroke = {Color = itemType == "pass" and Color3.fromRGB(200, 120, 220) or ThemeManager.getColor("stroke")},
		ZIndex = 13
	})
	inner.Parent = card
	
	-- Accent stripe
	local stripe = UIFactory.createFrame({
		Name = "Stripe",
		Size = UDim2.new(1, 0, 0, 6),
		BackgroundColor3 = themeData.accent or theme.icon,
		ZIndex = 14
	})
	stripe.Parent = inner
	
	-- Character badge
	if themeData.badge and AssetManager.isValidAsset(themeData.badge) then
		local badge = UIFactory.createImageLabel({
			Name = "Badge",
			Image = themeData.badge,
			Size = UDim2.new(0, 26, 0, 26),
			Position = UDim2.new(1, -34, 0, 10),
			ZIndex = 15
		})
		badge.Parent = inner
	end
	
	-- Item icon
	local iconImage = itemData.icon and AssetManager.isValidAsset(itemData.icon) and itemData.icon or (itemType == "pass" and AssetManager.assets.iconPass or AssetManager.assets.iconCash)
	local icon = UIFactory.createImageLabel({
		Name = "Icon",
		Image = iconImage,
		ImageColor3 = theme.icon,
		Size = UDim2.new(0, 46, 0, 46),
		Position = UDim2.new(0, 14, 0, 24),
		ZIndex = 15
	})
	icon.Parent = inner
	
	-- Item name
	local itemName = UIFactory.createTextLabel({
		Name = "ItemName",
		Text = itemData.name,
		TextColor3 = itemType == "pass" and Color3.fromRGB(240, 240, 250) or ThemeManager.getColor("text"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 72, 0, 22),
		Size = UDim2.new(1, -84, 0, 26),
		FontWeight = Enum.FontWeight.SemiBold,
		TextSize = 20,
		ZIndex = 15
	})
	itemName.Parent = inner
	
	-- Item description
	local description = UIFactory.createTextLabel({
		Name = "Description",
		Text = itemData.description or (itemType == "pass" and "Gamepass" or "Cash Bundle"),
		TextColor3 = itemType == "pass" and Color3.fromRGB(200, 200, 220) or ThemeManager.getColor("subtext"),
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.new(0, 72, 0, 52),
		Size = UDim2.new(1, -84, 0, 40),
		FontWeight = Enum.FontWeight.Regular,
		TextSize = 14,
		TextWrapped = true,
		ZIndex = 15
	})
	description.Parent = inner
	
	-- Purchase button
	local purchaseButton = UIFactory.createTextButton({
		Name = "PurchaseButton",
		Size = UDim2.new(0, 146, 0, 42),
		Position = UDim2.new(0, 14, 1, -54),
		BackgroundColor3 = theme.button,
		Text = itemType == "pass" and ("R$ " .. tostring(itemData.price)) or "Purchase",
		TextColor3 = itemType == "pass" and Color3.fromRGB(240, 240, 255) or (themeData.accent or theme.icon),
		CornerRadius = UDim.new(1, 0),
		Stroke = {Color = themeData.accent or theme.icon, Thickness = 2, Transparency = 0.15},
		FontWeight = Enum.FontWeight.Bold,
		TextSize = 20,
		ZIndex = 16
	})
	purchaseButton.Parent = inner
	
	-- Add purchase functionality
	purchaseButton.MouseButton1Click:Connect(function()
		Utils.safeCall(function()
			if itemType == "pass" then
				MarketplaceService:PromptGamePassPurchase(localPlayer, itemData.id)
			else
				MarketplaceService:PromptProductPurchase(localPlayer, itemData.id)
			end
		end, function(err)
			warn("Purchase error:", err)
		end)
	end)
	
	-- Card hover effect
	local originalPosition = card.Position
	card.MouseEnter:Connect(function()
		Utils.tween(card, ANIMATION_DEFAULTS.MEDIUM, {
			Position = UDim2.new(
				originalPosition.X.Scale,
				originalPosition.X.Offset,
				originalPosition.Y.Scale,
				originalPosition.Y.Offset - 5
			)
		})
		
		local shadow = card:FindFirstChild("Shadow")
		if shadow then
			Utils.tween(shadow, ANIMATION_DEFAULTS.MEDIUM, {
				ImageTransparency = 0.3,
				Size = UDim2.new(1, 70, 1, 70),
				Position = UDim2.new(0, -35, 0, -25)
			})
		end
	end)
	
	card.MouseLeave:Connect(function()
		Utils.tween(card, ANIMATION_DEFAULTS.MEDIUM, {
			Position = originalPosition
		})
		
		local shadow = card:FindFirstChild("Shadow")
		if shadow then
			Utils.tween(shadow, ANIMATION_DEFAULTS.MEDIUM, {
				ImageTransparency = 0.5,
				Size = UDim2.new(1, 60, 1, 60),
				Position = UDim2.new(0, -30, 0, -20)
			})
		end
	end)
	
	return card
end

-- Build Home Page
local function buildHomePage()
	-- Add decorative background pattern
	if AssetManager.isValidAsset(AssetManager.assets.hkBowPattern) then
		local pattern = Instance.new("ImageLabel")
		pattern.Name = "BowPattern"
		pattern.BackgroundTransparency = 1
		pattern.Image = AssetManager.assets.hkBowPattern
		pattern.ImageTransparency = 0.92
		pattern.ImageColor3 = Color3.fromRGB(255, 200, 200)
		pattern.ScaleType = Enum.ScaleType.Tile
		pattern.TileSize = UDim2.fromOffset(120, 120)
		pattern.Size = UDim2.fromScale(1, 1)
		pattern.ZIndex = 11
		pattern.Parent = homePage
	end
	
	-- Hero section
	local heroSection = UIFactory.createFrame({
		Name = "HeroSection",
		Size = UDim2.new(1, -24, 0, 220),
		Position = UDim2.new(0, 12, 0, 0),
		BackgroundColor3 = ThemeManager.getColor("panelAlt"),
		CornerRadius = UDim.new(0, 18),
		Stroke = {},
		Shadow = {Offset = 40, Transparency = 0.6},
		ZIndex = 12
	})
	heroSection.Parent = homePage
	
	-- Hero gradient with sparkle effect
	local heroGradient = Instance.new("UIGradient")
	heroGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Utils.blendColor(ThemeManager.getColor("kitty"), Color3.new(1, 1, 1), 0.95)),
		ColorSequenceKeypoint.new(0.5, Utils.blendColor(ThemeManager.getColor("kitty"), Color3.new(1, 1, 1), 0.98)),
		ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
	}
	heroGradient.Rotation = 45
	heroGradient.Parent = heroSection
	
	-- Animated gradient rotation
	task.spawn(function()
		while heroSection.Parent do
			local t = tick()
			heroGradient.Rotation = 45 + math.sin(t * 0.5) * 10
			task.wait(0.1)
		end
	end)
	
	-- Hero content will be populated by rotation system
	local heroBadge = UIFactory.createImageLabel({
		Name = "HeroBadge",
		Size = UDim2.new(0, 72, 0, 72),
		Position = UDim2.new(0, 24, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		ZIndex = 13
	})
	heroBadge.Parent = heroSection
	
	local heroTitle = UIFactory.createTextLabel({
		Name = "HeroTitle",
		Position = UDim2.new(0, 116, 0, 34),
		Size = UDim2.new(1, -300, 0, 40),
		TextXAlignment = Enum.TextXAlignment.Left,
		FontWeight = Enum.FontWeight.Bold,
		TextSize = 32,
		ZIndex = 13
	})
	heroTitle.Parent = heroSection
	
	local heroDesc = UIFactory.createTextLabel({
		Name = "HeroDesc",
		Position = UDim2.new(0, 116, 0, 78),
		Size = UDim2.new(1, -300, 0, 50),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = ThemeManager.getColor("subtext"),
		FontWeight = Enum.FontWeight.Regular,
		TextSize = 18,
		TextWrapped = true,
		ZIndex = 13
	})
	heroDesc.Parent = heroSection
	
	local heroCTA = UIFactory.createTextButton({
		Name = "HeroCTA",
		Size = UDim2.new(0, 200, 0, 52),
		Position = UDim2.new(1, -220, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Text = "Get Now",
		CornerRadius = UDim.new(1, 0),
		FontWeight = Enum.FontWeight.Bold,
		TextSize = 22,
		ZIndex = 14
	})
	heroCTA.Parent = heroSection
	
	-- Featured items section
	local featuredSection = UIFactory.createFrame({
		Name = "FeaturedSection",
		Size = UDim2.new(1, -24, 0, 260),
		Position = UDim2.new(0, 12, 0, 236),
		BackgroundTransparency = 1,
		ZIndex = 12
	})
	featuredSection.Parent = homePage
	
	local featuredTitle = UIFactory.createTextLabel({
		Name = "Title",
		Text = "✨ Featured Items",
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 30),
		FontWeight = Enum.FontWeight.Bold,
		TextSize = 24,
		ZIndex = 13
	})
	featuredTitle.Parent = featuredSection
	
	local featuredScroll = UIFactory.createScrollingFrame({
		Name = "FeaturedScroll",
		Size = UDim2.new(1, 0, 1, -40),
		Position = UDim2.new(0, 0, 0, 40),
		ScrollingDirection = Enum.ScrollingDirection.X,
		ScrollBarThickness = 6,
		Layout = {
			Type = "List",
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 16)
		},
		Padding = {Left = UDim.new(0, 8), Right = UDim.new(0, 8)},
		ZIndex = 13
	})
	featuredScroll.Parent = featuredSection
	
	-- Add featured items (mix of cash and gamepasses)
	local featuredItems = {}
	for i = 1, math.min(2, #ShopDataManager.data.cash) do
		table.insert(featuredItems, {item = ShopDataManager.data.cash[i], type = "cash"})
	end
	for i = 1, math.min(2, #ShopDataManager.data.gamepasses) do
		table.insert(featuredItems, {item = ShopDataManager.data.gamepasses[i], type = "pass"})
	end
	
	for _, featured in ipairs(featuredItems) do
		local themeData = featured.type == "cash" and {
			badge = AssetManager.assets.badgeCinna,
			accent = ThemeManager.getColor("cinnaSky")
		} or {
			badge = AssetManager.assets.badgeKuromi,
			accent = ThemeManager.getColor("kuromiLav")
		}
		
		local card = createShopItemCard(featured.item, featured.type, themeData)
		card.Parent = featuredScroll
	end
	
	-- Update canvas size
	task.wait()
	local layout = featuredScroll:FindFirstChildOfClass("UIListLayout")
	if layout then
		featuredScroll.CanvasSize = UDim2.new(0, layout.AbsoluteContentSize.X + 16, 0, 0)
	end
	
	-- Hero rotation system
	local heroRotationData = {}
	
	-- Add cash items to rotation
	for _, item in ipairs(ShopDataManager.data.cash) do
		table.insert(heroRotationData, {
			badge = AssetManager.assets.badgeCinna,
			title = item.name,
			desc = item.description or "Get an instant cash boost to accelerate your progress!",
			color = ThemeManager.getColor("cinnaSky"),
			item = item,
			type = "cash"
		})
	end
	
	-- Add gamepass items to rotation
	for _, item in ipairs(ShopDataManager.data.gamepasses) do
		table.insert(heroRotationData, {
			badge = AssetManager.assets.badgeKuromi,
			title = item.name,
			desc = item.description or "Unlock permanent upgrades and exclusive features!",
			color = ThemeManager.getColor("kuromiLav"),
			item = item,
			type = "pass"
		})
	end
	
	local currentHeroIndex = 1
	local heroConnection = nil
	
	local function updateHeroContent(index: number)
		local data = heroRotationData[index]
		if not data then return end
		
		heroBadge.Image = data.badge
		heroTitle.Text = data.title
		heroDesc.Text = data.desc
		
		Utils.tween(heroCTA, ANIMATION_DEFAULTS.FAST, {
			BackgroundColor3 = Utils.blendColor(data.color, Color3.new(1, 1, 1), 0.9),
			TextColor3 = data.color
		})
		
		local ctaStroke = heroCTA:FindFirstChildOfClass("UIStroke")
		if ctaStroke then
			Utils.tween(ctaStroke, ANIMATION_DEFAULTS.FAST, {
				Color = data.color
			})
		else
			local stroke = Instance.new("UIStroke")
			stroke.Color = data.color
			stroke.Thickness = 2
			stroke.Parent = heroCTA
		end
		
		-- Update CTA click handler
		if heroConnection then
			heroConnection:Disconnect()
		end
		
		heroConnection = heroCTA.MouseButton1Click:Connect(function()
			Utils.safeCall(function()
				if data.type == "pass" then
					MarketplaceService:PromptGamePassPurchase(localPlayer, data.item.id)
				else
					MarketplaceService:PromptProductPurchase(localPlayer, data.item.id)
				end
			end, function(err)
				warn("Hero purchase error:", err)
			end)
		end)
	end
	
	-- Start hero rotation
	updateHeroContent(currentHeroIndex)
	
	task.spawn(function()
		while true do
			task.wait(5)
			currentHeroIndex = (currentHeroIndex % #heroRotationData) + 1
			
			-- Fade transition
			Utils.tween(heroSection, ANIMATION_DEFAULTS.FAST, {BackgroundTransparency = 0.3})
			task.wait(0.15)
			updateHeroContent(currentHeroIndex)
			Utils.tween(heroSection, ANIMATION_DEFAULTS.FAST, {BackgroundTransparency = 0})
		end
	end)
end

-- Build Cash Page
local function buildCashPage()
	-- Add themed background
	local bgOverlay = UIFactory.createFrame({
		Name = "BgOverlay",
		Size = UDim2.new(1, -24, 1, -24),
		Position = UDim2.new(0, 12, 0, 12),
		BackgroundColor3 = Utils.blendColor(ThemeManager.getColor("cinnaSky"), Color3.new(1, 1, 1), 0.7),
		CornerRadius = UDim.new(0, 18),
		ZIndex = 11
	})
	bgOverlay.Parent = cashPage
	
	-- Add gradient
	local bgGradient = Instance.new("UIGradient")
	bgGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(0.5, Utils.blendColor(ThemeManager.getColor("cinnaSky"), Color3.new(1, 1, 1), 0.9)),
		ColorSequenceKeypoint.new(1, Utils.blendColor(ThemeManager.getColor("cinnaSky"), Color3.new(1, 1, 1), 0.8))
	}
	bgGradient.Rotation = 90
	bgGradient.Parent = bgOverlay
	
	-- Add floating cloud decorations
	if AssetManager.isValidAsset(AssetManager.assets.cloudTexture) then
		for i = 1, 3 do
			local cloud = Instance.new("ImageLabel")
			cloud.Name = "Cloud" .. i
			cloud.BackgroundTransparency = 1
			cloud.Image = AssetManager.assets.cloudTexture
			cloud.ImageTransparency = 0.85
			cloud.Size = UDim2.fromOffset(150 + i * 30, 80 + i * 15)
			cloud.Position = UDim2.fromScale(0.1 + i * 0.3, 0.05 + i * 0.15)
			cloud.ZIndex = 11
			cloud.Parent = cashPage
			
			-- Floating animation
			task.spawn(function()
				local startX = cloud.Position.X.Scale
				while cloud.Parent do
					local t = tick()
					cloud.Position = UDim2.fromScale(
						startX + math.sin(t * 0.2 + i) * 0.05,
						cloud.Position.Y.Scale + math.sin(t * 0.3 + i * 2) * 0.02
					)
					task.wait(0.1)
				end
			end)
		end
	end
	
	-- Create scrolling frame for cash items
	local cashScroll = UIFactory.createScrollingFrame({
		Name = "CashScroll",
		Size = UDim2.new(1, -32, 1, -32),
		Position = UDim2.new(0, 16, 0, 16),
		Layout = {
			Type = "Grid",
			CellSize = UDim2.new(0, 320, 0, 180),
			CellPadding = UDim2.new(0, 16, 0, 16),
			HorizontalAlignment = Enum.HorizontalAlignment.Center
		},
		ZIndex = 12
	})
	cashScroll.Parent = cashPage
	
	-- Add cash items
	for _, item in ipairs(ShopDataManager.data.cash) do
		local card = createShopItemCard(item, "cash", {
			badge = AssetManager.assets.badgeCinna,
			accent = ThemeManager.getColor("cinnaSky")
		})
		card.Parent = cashScroll
	end
	
	-- Update canvas size
	task.wait()
	local layout = cashScroll:FindFirstChildOfClass("UIGridLayout")
	if layout then
		cashScroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 32)
	end
end

-- Build Gamepasses Page
local function buildGamepassesPage()
	-- Add dark themed background
	local bgFrame = UIFactory.createFrame({
		Name = "BgFrame",
		BackgroundColor3 = Color3.fromRGB(22, 22, 26),
		ZIndex = 11
	})
	bgFrame.Parent = passPage
	
	local bgOverlay = UIFactory.createFrame({
		Name = "BgOverlay",
		Size = UDim2.new(1, -24, 1, -24),
		Position = UDim2.new(0, 12, 0, 12),
		BackgroundColor3 = Utils.blendColor(ThemeManager.getColor("kuromiLav"), Color3.new(1, 1, 1), 0.85),
		CornerRadius = UDim.new(0, 18),
		ZIndex = 11
	})
	bgOverlay.Parent = passPage
	
	-- Add gradient with darker tones
	local bgGradient = Instance.new("UIGradient")
	bgGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 34, 42)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(44, 44, 52)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 28, 34))
	}
	bgGradient.Rotation = 135
	bgGradient.Parent = bgOverlay
	
	-- Add edgy star decorations
	if AssetManager.isValidAsset(AssetManager.assets.starPattern) then
		local stars = Instance.new("ImageLabel")
		stars.Name = "StarPattern"
		stars.BackgroundTransparency = 1
		stars.Image = AssetManager.assets.starPattern
		stars.ImageTransparency = 0.9
		stars.ImageColor3 = ThemeManager.getColor("kuromiLav")
		stars.ScaleType = Enum.ScaleType.Tile
		stars.TileSize = UDim2.fromOffset(100, 100)
		stars.Size = UDim2.fromScale(1, 1)
		stars.ZIndex = 11
		stars.Parent = passPage
		
		-- Rotating stars effect
		task.spawn(function()
			while stars.Parent do
				stars.Rotation = stars.Rotation + 0.1
				task.wait(0.1)
			end
		end)
	end
	
	-- Create scrolling frame for gamepass items
	local passScroll = UIFactory.createScrollingFrame({
		Name = "PassScroll",
		Size = UDim2.new(1, -32, 1, -32),
		Position = UDim2.new(0, 16, 0, 16),
		Layout = {
			Type = "Grid",
			CellSize = UDim2.new(0, 320, 0, 180),
			CellPadding = UDim2.new(0, 16, 0, 16),
			HorizontalAlignment = Enum.HorizontalAlignment.Center
		},
		ZIndex = 12
	})
	passScroll.Parent = passPage
	
	-- Add gamepass items with alternating rotation
	for idx, item in ipairs(ShopDataManager.data.gamepasses) do
		local card = createShopItemCard(item, "pass", {
			badge = AssetManager.assets.badgeKuromi,
			accent = ThemeManager.getColor("kuromiLav")
		})
		
		-- Add slight rotation for visual interest
		card.Rotation = (idx % 2 == 0) and 2 or -2
		card.Parent = passScroll
	end
	
	-- Update canvas size
	task.wait()
	local layout = passScroll:FindFirstChildOfClass("UIGridLayout")
	if layout then
		passScroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 32)
	end
end

-- Build all pages
buildHomePage()
buildCashPage()
buildGamepassesPage()

-- Connect tab buttons
homeTab.MouseButton1Click:Connect(function()
	TabSystem:selectTab("Home")
end)

cashTab.MouseButton1Click:Connect(function()
	TabSystem:selectTab("Cash")
end)

passTab.MouseButton1Click:Connect(function()
	TabSystem:selectTab("Gamepasses")
end)

-- Hello Kitty Talker System
local HKTalker = {}
HKTalker.messages = {
	general = {
		"Hello! Welcome to our special shop! 🎀",
		"Everything here is made with love! 💖",
		"Take your time browsing around! 🌸",
		"I hope you find something you like! ✨",
		"Shopping with friends is always fun! 🎪"
	},
	cash = {
		"A little cash can go a long way! 💰",
		"These bundles are super helpful! 🎁",
		"Treat yourself to something nice! 🍎",
		"Every adventure needs some coins! ✨",
		"Save up for something special! 💫"
	},
	gamepasses = {
		"Upgrades make everything better! 🌟",
		"These powers are really cool! 👀",
		"VIP treatment is always nice! 👑",
		"Permanent upgrades are the best! 🎯",
		"Level up your experience! 🚀"
	}
}

function HKTalker:create()
	local container = UIFactory.createFrame({
		Name = "HKTalkerContainer",
		Size = UDim2.new(0, 500, 0, 150),
		Position = UDim2.new(0, 20, 1, -20),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		Visible = false,
		ZIndex = 100
	})
	container.Parent = screenGui
	
	-- Portrait
	local portrait = UIFactory.createImageLabel({
		Name = "Portrait",
		Image = AssetManager.assets.hkPortrait,
		Size = UDim2.new(0, 64, 0, 64),
		Position = UDim2.new(0, 0, 1, 0),
		AnchorPoint = Vector2.new(0, 1),
		CornerRadius = UDim.new(1, 0),
		ZIndex = 101
	})
	portrait.BackgroundColor3 = ThemeManager.getColor("panel")
	portrait.Parent = container
	
	local portraitStroke = Instance.new("UIStroke")
	portraitStroke.Color = ThemeManager.getColor("kitty")
	portraitStroke.Thickness = 2
	portraitStroke.Parent = portrait
	
	-- Bubble group
	local bubbleGroup = UIFactory.createFrame({
		Name = "BubbleGroup",
		Size = UDim2.new(0, 410, 0, 130),
		Position = UDim2.new(0, 76, 1, 0),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		Visible = false,
		ZIndex = 101
	})
	bubbleGroup.Parent = container
	
	-- Shadow
	UIFactory.addShadow(bubbleGroup, {Offset = 30, Transparency = 0.6})
	
	-- Bubble
	local bubble = UIFactory.createFrame({
		Name = "Bubble",
		Size = UDim2.new(1, -8, 1, -8),
		BackgroundColor3 = ThemeManager.getColor("panel"),
		CornerRadius = UDim.new(0, 18),
		Stroke = {},
		ZIndex = 102
	})
	bubble.Parent = bubbleGroup
	
	-- Tail
	local tail = UIFactory.createFrame({
		Name = "Tail",
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(0, -7, 1, -30),
		BackgroundColor3 = ThemeManager.getColor("panel"),
		Rotation = 45,
		CornerRadius = UDim.new(0, 4),
		ZIndex = 102
	})
	tail.Parent = bubble
	
	local tailStroke = Instance.new("UIStroke")
	tailStroke.Color = ThemeManager.getColor("stroke")
	tailStroke.Thickness = 1
	tailStroke.Parent = tail
	
	-- Text
	local textLabel = UIFactory.createTextLabel({
		Name = "Message",
		Size = UDim2.new(1, -26, 1, -30),
		Position = UDim2.new(0, 16, 0, 16),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		FontWeight = Enum.FontWeight.Regular,
		TextSize = 19,
		TextWrapped = true,
		ZIndex = 103
	})
	textLabel.Parent = bubble
	
	-- Close button
	local closeBtn = UIFactory.createTextButton({
		Name = "CloseBtn",
		Size = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(1, -36, 0, 6),
		BackgroundTransparency = 1,
		Text = "",
		ZIndex = 104
	})
	closeBtn.Parent = bubble
	
	local closeIcon = UIFactory.createImageLabel({
		Name = "Icon",
		Image = AssetManager.assets.iconCloseX,
		ImageColor3 = Color3.fromRGB(150, 150, 150),
		Size = UDim2.new(0, 20, 0, 20),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 105
	})
	closeIcon.Parent = closeBtn
	
	-- Breathing animation
	task.spawn(function()
		while true do
			if portrait.Visible then
				Utils.tween(portrait, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Size = UDim2.new(0, 68, 0, 68)
				})
				task.wait(1.5)
				Utils.tween(portrait, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
					Size = UDim2.new(0, 64, 0, 64)
				})
				task.wait(1.5)
			else
				task.wait(0.5)
			end
		end
	end)
	
	self.container = container
	self.portrait = portrait
	self.bubbleGroup = bubbleGroup
	self.textLabel = textLabel
	self.closeBtn = closeBtn
	self.isShowing = false
	self.typewriterActive = false
	
	return self
end

function HKTalker:typewrite(text: string, callback: (() -> ())?)
	self.typewriterActive = true
	self.textLabel.Text = ""
	
	for i = 1, #text do
		if not self.typewriterActive then break end
		self.textLabel.Text = string.sub(text, 1, i)
		SoundManager:play("typewriter")
		task.wait(TYPEWRITER_SPEED)
	end
	
	self.typewriterActive = false
	if callback then callback() end
end

function HKTalker:show(context: string?)
	if self.isShowing then return end
	
	context = context or "general"
	local messages = self.messages[context] or self.messages.general
	local message = messages[math.random(1, #messages)]
	
	self.isShowing = true
	self.container.Visible = true
	self.portrait.Visible = true
	self.bubbleGroup.Visible = true
	
	-- Animate in
	self.portrait.Size = UDim2.new(0, 0, 0, 0)
	self.bubbleGroup.Size = UDim2.new(0, 10, 0, 10)
	
	Utils.tween(self.portrait, ANIMATION_DEFAULTS.BOUNCE, {
		Size = UDim2.new(0, 64, 0, 64)
	})
	
	task.wait(0.1)
	
	Utils.tween(self.bubbleGroup, ANIMATION_DEFAULTS.BOUNCE, {
		Size = UDim2.new(0, 410, 0, 130)
	})
	
	task.wait(0.2)
	
	self:typewrite(message)
	
	-- Auto-hide after delay
	task.delay(6, function()
		if self.isShowing then
			self:hide()
		end
	end)
end

function HKTalker:hide()
	if not self.isShowing then return end
	
	self.isShowing = false
	self.typewriterActive = false
	
	Utils.tween(self.bubbleGroup, ANIMATION_DEFAULTS.FAST, {
		Size = UDim2.new(0, 320, 0, 90),
		BackgroundTransparency = 1
	})
	
	Utils.tween(self.portrait, ANIMATION_DEFAULTS.FAST, {
		Size = UDim2.new(0, 0, 0, 0),
		ImageTransparency = 1
	})
	
	task.wait(0.2)
	
	self.container.Visible = false
	self.portrait.ImageTransparency = 0
	self.bubbleGroup.BackgroundTransparency = 0
end

-- Initialize HK Talker
local hkTalker = HKTalker:create()

-- Connect close button
hkTalker.closeBtn.MouseButton1Click:Connect(function()
	hkTalker:hide()
end)

-- Auto-show logic
local shopOpenTime = 0
local lastMessageTime = 0

local function checkAutoMessage()
	if not mainPanel.Visible then 
		shopOpenTime = 0
		return 
	end
	
	local currentTime = tick()
	local timeSinceOpen = currentTime - shopOpenTime
	local timeSinceLastMessage = currentTime - lastMessageTime
	
	-- Wait for initial delay before first message
	if timeSinceOpen < HK_INITIAL_DELAY then return end
	
	-- Show message if enough time has passed
	if timeSinceLastMessage >= AUTO_MESSAGE_DELAY then
		local context = TabSystem.currentTab == "Cash" and "cash" or 
		               TabSystem.currentTab == "Gamepasses" and "gamepasses" or 
		               "general"
		hkTalker:show(context)
		lastMessageTime = currentTime
	end
end

-- Run auto-message checker
RunService.Heartbeat:Connect(checkAutoMessage)

-- Shop Toggle Button
local toggleButton = UIFactory.createTextButton({
	Name = "ShopToggle",
	Size = UDim2.new(0, 156, 0, 50),
	Position = UDim2.new(1, -16, 1, -16),
	AnchorPoint = Vector2.new(1, 1),
	BackgroundColor3 = ThemeManager.getColor("panel"),
	Text = "",
	CornerRadius = UDim.new(1, 0),
	Stroke = {},
	Shadow = {Offset = 20},
	ZIndex = 10
})
toggleButton.Parent = screenGui

local toggleIcon = UIFactory.createImageLabel({
	Name = "Icon",
	Image = AssetManager.isValidAsset(AssetManager.assets.badgeHello) and AssetManager.assets.badgeHello or AssetManager.assets.iconBag,
	ImageColor3 = AssetManager.isValidAsset(AssetManager.assets.badgeHello) and ThemeManager.getColor("kitty") or ThemeManager.getColor("text"),
	Size = UDim2.new(0, 24, 0, 24),
	Position = UDim2.new(0, 12, 0.5, 0),
	AnchorPoint = Vector2.new(0, 0.5),
	ZIndex = 11
})
toggleIcon.Parent = toggleButton

local toggleText = UIFactory.createTextLabel({
	Name = "Text",
	Text = "Shop",
	Size = UDim2.new(1, -50, 1, 0),
	Position = UDim2.new(0, 44, 0, 0),
	TextXAlignment = Enum.TextXAlignment.Left,
	FontWeight = Enum.FontWeight.SemiBold,
	TextSize = 20,
	ZIndex = 11
})
toggleText.Parent = toggleButton

-- Shop visibility management
local ShopManager = {}
ShopManager.isOpen = false
ShopManager.isAnimating = false

function ShopManager:open()
	if self.isOpen or self.isAnimating then return end
	
	self.isAnimating = true
	self.isOpen = true
	
	-- Hide toggle button
	toggleButton.Visible = false
	
	-- Show dim and panel
	dimOverlay.Visible = true
	mainPanel.Visible = true
	
	-- Reset positions and transparency
	dimOverlay.BackgroundTransparency = 1
	mainPanel.Position = UDim2.new(0.5, 0, 0.52, 0)
	mainPanel.Size = UDim2.new(0, 960, 0, 830)
	
	-- Animate in
	BlurManager:show(10)
	Utils.tween(dimOverlay, ANIMATION_DEFAULTS.MEDIUM, {BackgroundTransparency = 0.3})
	Utils.tween(mainPanel, ANIMATION_DEFAULTS.SLOW, {
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 980, 0, 860)
	})
	
	-- Play sound
	SoundManager:play("open")
	
	-- Select default tab
	TabSystem:selectTab("Home")
	
	-- Update shop open time
	shopOpenTime = tick()
	lastMessageTime = tick()
	
	task.wait(0.35)
	self.isAnimating = false
end

function ShopManager:close()
	if not self.isOpen or self.isAnimating then return end
	
	self.isAnimating = true
	self.isOpen = false
	
	-- Hide talker
	hkTalker:hide()
	
	-- Animate out
	BlurManager:hide()
	Utils.tween(dimOverlay, ANIMATION_DEFAULTS.FAST, {BackgroundTransparency = 1})
	Utils.tween(mainPanel, ANIMATION_DEFAULTS.FAST, {
		Position = UDim2.new(0.5, 0, 0.53, 0),
		Size = UDim2.new(0, 960, 0, 830)
	})
	
	-- Play sound
	SoundManager:play("close")
	
	task.wait(0.2)
	
	-- Hide elements
	dimOverlay.Visible = false
	mainPanel.Visible = false
	toggleButton.Visible = true
	
	-- Reset shop open time
	shopOpenTime = 0
	
	self.isAnimating = false
end

function ShopManager:toggle()
	if self.isOpen then
		self:close()
	else
		self:open()
	end
end

-- Connect buttons
toggleButton.MouseButton1Click:Connect(function()
	ShopManager:open()
end)

closeButton.MouseButton1Click:Connect(function()
	ShopManager:close()
end)

-- Keyboard shortcut
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.M then
		ShopManager:toggle()
	end
end)

-- Hover effects for toggle button
toggleButton.MouseEnter:Connect(function()
	Utils.tween(toggleButton, ANIMATION_DEFAULTS.FAST, {
		Size = UDim2.new(0, 164, 0, 54)
	})
end)

toggleButton.MouseLeave:Connect(function()
	Utils.tween(toggleButton, ANIMATION_DEFAULTS.FAST, {
		Size = UDim2.new(0, 156, 0, 50)
	})
end)

-- Memory cleanup on character removal
localPlayer.CharacterRemoving:Connect(function()
	if screenGui then
		screenGui:Destroy()
	end
	if BlurManager.blur then
		BlurManager.blur:Destroy()
	end
end)

print("🎀 Sanrio Shop UI Professional Edition loaded successfully!")
print("Press 'M' to toggle the shop or click the button in the bottom-right corner.")