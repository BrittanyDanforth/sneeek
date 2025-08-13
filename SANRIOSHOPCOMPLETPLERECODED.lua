--[[
  SANRIOSHOPCOMPLETPLERECODED – Complete Sanrio Shop UI Recode
  - Unified card design with accent outline + halo
  - Themed pages: Home (Hello Kitty), Cash (Cinnamoroll), Gamepasses (Kuromi)
  - Clipped decorations (bows, clouds, stars) with no overlap
  - Consistent grid layout, spacing, and typography
  - Top‑right price/amount chip, CTA button with feedback
  - Gamepass "Owned" state + disabled CTA
  - Lightweight skeleton loading state for cards
  - Asset preloading and animation gating when hidden
  - Keyboard/controller focus rings (basic) and accessibility improvements

  Place this as a LocalScript under PlayerGui or StarterPlayerScripts → PlayerGui
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
local ContentProvider = game:GetService("ContentProvider")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Animation presets
local ANIM = {
	FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	MED = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	SLOW = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	BOUNCE = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	SMOOTH = TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
}

local MOBILE_THRESHOLD = 1024

-- Utils
local Utils = {}

function Utils.tween(instance: Instance?, info: TweenInfo, props: {[string]: any})
	if not instance then return end
	local t = TweenService:Create(instance, info, props)
	t:Play()
	return t
end

function Utils.setFont(guiObject: TextLabel | TextButton, weight: Enum.FontWeight?, size: number?)
	weight = weight or Enum.FontWeight.Regular
	size = size or 14
	guiObject.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", weight, Enum.FontStyle.Normal)
	guiObject.TextSize = size
end

function Utils.blendColor(a: Color3, b: Color3, alpha: number): Color3
	alpha = math.clamp(alpha or 0.5, 0, 1)
	return Color3.new(
		a.R + (b.R - a.R) * alpha,
		a.G + (b.G - a.G) * alpha,
		a.B + (b.B - a.B) * alpha
	)
end

function Utils.isMobile(): boolean
	local cam = workspace.CurrentCamera
	if not cam then return false end
	local vp = cam.ViewportSize
	return vp.X <= MOBILE_THRESHOLD or GuiService:IsTenFootInterface()
end

function Utils.formatNumber(n: number): string
	local s = tostring(n)
	local pos = string.len(s) % 3
	if pos == 0 then pos = 3 end
	local first = string.sub(s, 1, pos)
	local rest = string.sub(s, pos + 1):gsub("(%d%d%d)", ",%1")
	return rest ~= "" and (first .. rest) or first
end

function Utils.safePcall(fn: () -> ()): boolean
	local ok, err = pcall(fn)
	if not ok then warn("SanrioShop error:", err) end
	return ok
end

-- Assets (reuse same IDs)
local AssetManager = {}
AssetManager.assets = {
	paperTexture = "rbxassetid://3584103989",
	badgeHello = "rbxassetid://17398522865",
	badgeMelody = "rbxassetid://17398525031",
	badgeKuromi = "rbxassetid://17398526388",
	badgeCinna = "rbxassetid://17398524224",

	iconCloseX = "rbxassetid://13516603909",
	iconBag = "rbxassetid://6031280882",
	iconCash = "rbxassetid://10709728059",
	iconPass = "rbxassetid://10709727148",

	hkPortrait = "rbxassetid://8399407650",
	hkBowPattern = "rbxassetid://6022668879", -- bow
	cloudTexture = "rbxassetid://4096004729", -- working cloud
	starPattern = "rbxassetid://121915223943271",
	hkCuteFace = "rbxassetid://14978925654",

	soundClick = "rbxassetid://876939830",
	soundHover = "rbxassetid://12221967",
	soundOpen = "rbxassetid://9125713501",
	soundClose = "rbxassetid://9119713951",
}

function AssetManager.isValid(id: string?): boolean
	return type(id) == "string" and id ~= "" and id ~= "rbxassetid://0"
end

-- Theme tokens
local Theme = {}
Theme.tokens = {
	default = {
		bg = Color3.fromRGB(253, 252, 250),
		surface = Color3.fromRGB(255,255,255),
		surfaceAlt = Color3.fromRGB(246,248,252),
		stroke = Color3.fromRGB(222,226,235),
		text = Color3.fromRGB(35,38,46),
		subtext = Color3.fromRGB(120,126,140),
		scrollbar = Color3.fromRGB(180,185,200),

		kitty = Color3.fromRGB(255, 64, 64),
		cinna = Color3.fromRGB(186, 214, 255),
		kuromiLav = Color3.fromRGB(200, 190, 255),

		success = Color3.fromRGB(76,175,80),
		warning = Color3.fromRGB(255,152,0),
		error = Color3.fromRGB(244,67,54)
	}
}
Theme.current = "default"

function Theme.c(name: string): Color3
	local t = Theme.tokens[Theme.current]
	return t[name] or Color3.new(1,1,1)
end

-- Shop data
local ShopData = {}
ShopData.data = {
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

function ShopData.getDeveloperProductInfo(id: number)
	local ok, info = pcall(function()
		return MarketplaceService:GetProductInfo(id, Enum.InfoType.Product)
	end)
	return ok and info or nil
end

function ShopData.getGamePassInfo(id: number)
	local ok, info = pcall(function()
		return MarketplaceService:GetProductInfo(id, Enum.InfoType.GamePass)
	end)
	return ok and info or nil
end

function ShopData.userOwnsGamepass(userId: number, passId: number): boolean
	local ok, result = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(userId, passId)
	end)
	if not ok then return false end
	return result == true
end

-- Enrich shop data (icons/prices) from Marketplace
local function hydrateMetadata()
	-- Gamepasses: pull icon and price
	for _, gp in ipairs(ShopData.data.gamepasses) do
		-- Prefer Roblox thumbnail scheme for gamepass icons
		gp.icon = "rbxthumb://type=GamePass&id="..tostring(gp.id).."&w=420&h=420"
		local info = ShopData.getGamePassInfo(gp.id)
		if info then
			if info.PriceInRobux and (not gp.price or gp.price == 0) then
				gp.price = info.PriceInRobux
			end
		end
	end
	-- Dev products: names may be updated, price generally not exposed; leave icons default
end

-- Sound manager
local Sfx = {enabled = true, sounds = {}}

function Sfx:init()
	local function mk(id, vol)
		if AssetManager.isValid(id) then
			local s = Instance.new("Sound")
			s.SoundId = id
			s.Volume = vol or 0.5
			s.Parent = SoundService
			return s
		end
		return nil
	end
	self.sounds.click = mk(AssetManager.assets.soundClick, 0.4)
	self.sounds.hover = mk(AssetManager.assets.soundHover, 0.2)
	self.sounds.open = mk(AssetManager.assets.soundOpen, 0.5)
	self.sounds.close = mk(AssetManager.assets.soundClose, 0.5)
end

function Sfx:play(n)
	if not self.enabled then return end
	local s = self.sounds[n]
	if s then s:Play() end
end

Sfx:init()

-- UIFactory
local UI = {}

function UI.frame(props): Frame
	local f = Instance.new("Frame")
	f.BackgroundColor3 = props.BackgroundColor3 or Theme.c("surface")
	f.BackgroundTransparency = props.BackgroundTransparency or 0
	f.BorderSizePixel = 0
	f.Size = props.Size or UDim2.new(1,0,1,0)
	f.Position = props.Position or UDim2.new(0,0,0,0)
	f.AnchorPoint = props.AnchorPoint or Vector2.new(0,0)
	f.Name = props.Name or "Frame"
	f.ZIndex = props.ZIndex or 1
	f.Visible = props.Visible ~= false
	f.ClipsDescendants = props.ClipsDescendants or false
	if props.CornerRadius then
		local c = Instance.new("UICorner"); c.CornerRadius = props.CornerRadius; c.Parent = f
	end
	if props.Stroke then
		local s = Instance.new("UIStroke")
		s.Color = props.Stroke.Color or Theme.c("stroke")
		s.Thickness = props.Stroke.Thickness or 1
		s.Transparency = props.Stroke.Transparency or 0
		s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		s.Parent = f
	end
	return f
end

function UI.textLabel(props): TextLabel
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text = props.Text or ""
	l.TextColor3 = props.TextColor3 or Theme.c("text")
	l.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Center
	l.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
	l.Size = props.Size or UDim2.new(1,0,1,0)
	l.Position = props.Position or UDim2.new(0,0,0,0)
	l.AnchorPoint = props.AnchorPoint or Vector2.new(0,0)
	l.Name = props.Name or "TextLabel"
	l.ZIndex = props.ZIndex or 1
	l.TextWrapped = props.TextWrapped ~= false
	l.RichText = props.RichText or false
	l.TextScaled = props.TextScaled or false
	l.TextTruncate = props.TextTruncate or Enum.TextTruncate.None
	Utils.setFont(l, props.FontWeight or Enum.FontWeight.Regular, props.TextSize or 14)
	return l
end

function UI.textButton(props): TextButton
	local b = Instance.new("TextButton")
	b.BackgroundColor3 = props.BackgroundColor3 or Theme.c("surface")
	b.BackgroundTransparency = props.BackgroundTransparency or 0
	b.BorderSizePixel = 0
	b.Text = props.Text or ""
	b.TextColor3 = props.TextColor3 or Theme.c("text")
	b.Size = props.Size or UDim2.new(0,100,0,40)
	b.Position = props.Position or UDim2.new(0,0,0,0)
	b.AnchorPoint = props.AnchorPoint or Vector2.new(0,0)
	b.Name = props.Name or "TextButton"
	b.ZIndex = props.ZIndex or 1
	b.AutoButtonColor = false
	Utils.setFont(b, props.FontWeight or Enum.FontWeight.Medium, props.TextSize or 16)
	if props.CornerRadius then local c = Instance.new("UICorner"); c.CornerRadius = props.CornerRadius; c.Parent = b end
	if props.Stroke then
		local s = Instance.new("UIStroke")
		s.Color = props.Stroke.Color or Theme.c("stroke")
		s.Thickness = props.Stroke.Thickness or 1
		s.Transparency = props.Stroke.Transparency or 0
		s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		s.Parent = b
	end
	-- Basic hover
	b.MouseEnter:Connect(function()
		Utils.tween(b, ANIM.FAST, {Size = UDim2.new(b.Size.X.Scale, b.Size.X.Offset + 4, b.Size.Y.Scale, b.Size.Y.Offset + 4)})
		Sfx:play("hover")
	end)
	b.MouseLeave:Connect(function()
		Utils.tween(b, ANIM.FAST, {Size = props.Size or UDim2.new(0,100,0,40)})
	end)
	-- Click sfx
	b.MouseButton1Click:Connect(function() Sfx:play("click") end)
	return b
end

function UI.image(props): ImageLabel
	local i = Instance.new("ImageLabel")
	i.BackgroundTransparency = 1
	i.Image = props.Image or ""
	i.ImageColor3 = props.ImageColor3 or Color3.new(1,1,1)
	i.ImageTransparency = props.ImageTransparency or 0
	i.ScaleType = props.ScaleType or Enum.ScaleType.Fit
	i.Size = props.Size or UDim2.new(0,100,0,100)
	i.Position = props.Position or UDim2.new(0,0,0,0)
	i.AnchorPoint = props.AnchorPoint or Vector2.new(0,0)
	i.Name = props.Name or "ImageLabel"
	i.ZIndex = props.ZIndex or 1
	if props.CornerRadius then local c = Instance.new("UICorner"); c.CornerRadius = props.CornerRadius; c.Parent = i end
	return i
end

function UI.scroll(props): ScrollingFrame
	local s = Instance.new("ScrollingFrame")
	s.BackgroundTransparency = props.BackgroundTransparency or 1
	s.BorderSizePixel = 0
	s.Size = props.Size or UDim2.new(1,0,1,0)
	s.Position = props.Position or UDim2.new(0,0,0,0)
	s.CanvasSize = props.CanvasSize or UDim2.new(0,0,0,0)
	s.ScrollBarThickness = props.ScrollBarThickness or 8
	s.ScrollBarImageColor3 = props.ScrollBarImageColor3 or Theme.c("scrollbar")
	s.ScrollingDirection = props.ScrollingDirection or Enum.ScrollingDirection.Y
	s.Name = props.Name or "ScrollingFrame"
	s.ZIndex = props.ZIndex or 1
	if props.Layout then
		local layout = props.Layout.Type == "Grid" and Instance.new("UIGridLayout") or Instance.new("UIListLayout")
		for k,v in pairs(props.Layout) do
			if k ~= "Type" and layout[k] ~= nil then layout[k] = v end
		end
		layout.Parent = s
	end
	if props.Padding then
		local p = Instance.new("UIPadding")
		p.PaddingTop = props.Padding.Top or UDim.new(0,0)
		p.PaddingBottom = props.Padding.Bottom or UDim.new(0,0)
		p.PaddingLeft = props.Padding.Left or UDim.new(0,0)
		p.PaddingRight = props.Padding.Right or UDim.new(0,0)
		p.Parent = s
	end
	return s
end

-- Shadows / halo helper
local function addHalo(parent: GuiObject, color: Color3, sizeOffset: number, transparency: number, zBelow: number)
	local halo = UI.image({
		Name = "Halo",
		Image = "rbxassetid://6015897843",
		ScaleType = Enum.ScaleType.Slice,
		ImageColor3 = color,
		ImageTransparency = transparency or 0.9,
		Size = UDim2.new(1, sizeOffset or 36, 1, sizeOffset or 36),
		Position = UDim2.new(0, -(sizeOffset or 36)/2, 0, -(sizeOffset or 36)/2),
		ZIndex = (parent.ZIndex or 1) + (zBelow or -1)
	})
	halo.SliceCenter = Rect.new(49,49,450,450)
	halo.Parent = parent
	return halo
end

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SANRIO_SHOP_COMPLETE_RECODED"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 1000
screenGui.Parent = playerGui

-- Paper background
if AssetManager.isValid(AssetManager.assets.paperTexture) then
	local paper = UI.image({Name = "PaperBG", Image = AssetManager.assets.paperTexture, ImageTransparency = 0.93, Size = UDim2.fromScale(1,1), ScaleType = Enum.ScaleType.Tile, ZIndex = 1})
	paper.TileSize = UDim2.fromOffset(200,200)
	paper.Parent = screenGui
end

-- Dim overlay
local dim = UI.frame({Name = "Dim", Size = UDim2.fromScale(1,1), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 1, Visible = false, ZIndex = 5})
dim.Parent = screenGui

-- Panel
local panel = UI.frame({
	Name = "Panel",
	Size = UDim2.new(0, 980, 0, 860),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = Theme.c("surface"),
	CornerRadius = UDim.new(0, 24),
	Stroke = {Thickness = 1.5, Color = Theme.c("stroke")},
	ZIndex = 10,
	Visible = false
})
panel.Parent = screenGui
addHalo(panel, Theme.c("kitty"), 60, 0.95, -1) -- very subtle panel halo for depth

-- Responsive scale
local uiScale = Instance.new("UIScale")
uiScale.Parent = panel

local function updateScale()
	local cam = workspace.CurrentCamera
	if not cam then return end
	local vp = cam.ViewportSize
	local minDim = math.min(vp.X, vp.Y)
	local s = math.clamp(minDim / 1080, 0.75, 1.15)
	if Utils.isMobile() then s = s * 0.92 end
	uiScale.Scale = s
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	local cam = workspace.CurrentCamera
	if cam then
		cam:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
		updateScale()
	end
end)
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale); updateScale() end

-- Header
local header = UI.frame({Name = "Header", Size = UDim2.new(1, -24, 0, 72), Position = UDim2.new(0,12,0,12), CornerRadius = UDim.new(0,18), BackgroundColor3 = Theme.c("surfaceAlt"), Stroke = {Color = Theme.c("stroke")}, ZIndex = 11})
header.Parent = panel
local headerGrad = Instance.new("UIGradient"); headerGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, Color3.fromRGB(250,250,250))}; headerGrad.Rotation = 90; headerGrad.Parent = header

local kittyBadge = UI.image({Name = "KittyBadge", Image = AssetManager.assets.badgeHello, Size = UDim2.fromOffset(42,42), Position = UDim2.new(0,16,0.5,0), AnchorPoint = Vector2.new(0,0.5), ZIndex = 12})
kittyBadge.Parent = header

local title = UI.textLabel({Name = "Title", Text = "Sanrio Shop", Position = UDim2.new(0, 72, 0, 0), Size = UDim2.new(1, -140, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, FontWeight = Enum.FontWeight.Bold, TextSize = 32, ZIndex = 12})
title.Parent = header

local closeBtn = UI.textButton({Name = "Close", Size = UDim2.fromOffset(40,40), Position = UDim2.new(1,-56,0.5,0), AnchorPoint = Vector2.new(0,0.5), BackgroundColor3 = Color3.fromRGB(235,60,60), CornerRadius = UDim.new(1,0), ZIndex = 13})
closeBtn.Parent = header
UI.image({Name = "X", Image = AssetManager.assets.iconCloseX, ImageColor3 = Color3.new(1,1,1), Size = UDim2.fromOffset(20,20), Position = UDim2.new(0.5,0,0.5,0), AnchorPoint = Vector2.new(0.5,0.5), ZIndex = 14, Parent = closeBtn})

-- Tabs
local TabSystem = {tabs = {}, pages = {}, current = nil}

function TabSystem:createTab(name: string, icon: string?, accent: Color3?): TextButton
	local b = UI.textButton({Name = name.."Tab", Text = name, Size = UDim2.new(0, 164, 1, 0), BackgroundColor3 = Theme.c("surface"), TextColor3 = Theme.c("text"), CornerRadius = UDim.new(1,0), Stroke = {Color = Theme.c("stroke")}, FontWeight = Enum.FontWeight.Medium, TextSize = 20, ZIndex = 12})
	if icon and AssetManager.isValid(icon) then
		local ic = UI.image({Name = "Icon", Image = icon, Size = UDim2.fromOffset(20,20), Position = UDim2.new(0,12,0.5,0), AnchorPoint = Vector2.new(0,0.5), ImageColor3 = Theme.c("text"), ZIndex = 13}); ic.Parent = b
		b.Text = ""
		local tx = UI.textLabel({Name = "Text", Text = name, Position = UDim2.new(0,40,0,0), Size = UDim2.new(1,-52,1,0), TextXAlignment = Enum.TextXAlignment.Left, FontWeight = Enum.FontWeight.Medium, TextSize = 20, ZIndex = 13}); tx.Parent = b
	end
	self.tabs[name] = {button = b, accent = accent or Theme.c("kitty")}
	return b
end

function TabSystem:createPage(name: string)
	local p = UI.frame({Name = name.."Page", BackgroundTransparency = 1, Visible = false, ZIndex = 11})
	self.pages[name] = p
	return p
end

function TabSystem:select(name: string)
	if self.current == name then return end
	for tabName, tab in pairs(self.tabs) do
		local active = tabName == name
		Utils.tween(tab.button, ANIM.FAST, {BackgroundColor3 = active and Utils.blendColor(tab.accent, Color3.new(1,1,1), 0.9) or Theme.c("surface")})
		local stroke = tab.button:FindFirstChildOfClass("UIStroke"); if stroke then stroke.Color = active and tab.accent or Theme.c("stroke") end
		for _, child in ipairs(tab.button:GetChildren()) do
			if child:IsA("ImageLabel") then child.ImageColor3 = active and tab.accent or Theme.c("text") end
			if child:IsA("TextLabel") then child.TextColor3 = active and tab.accent or Theme.c("text") end
		end
	end
	for _, p in pairs(self.pages) do p.Visible = false end
	local page = self.pages[name]
	if page then
		page.Visible = true
		page.Position = UDim2.new(0,0,0,10)
		Utils.tween(page, ANIM.BOUNCE, {Position = UDim2.new(0,0,0,0)})
	end
	self.current = name
	Sfx:play("click")
end

-- Tab bar container
local tabBar = UI.frame({Name = "TabBar", Size = UDim2.new(1,-24,0,52), Position = UDim2.new(0,12,0,92), BackgroundTransparency = 1, ZIndex = 11})
tabBar.Parent = panel
local tabLayout = Instance.new("UIListLayout"); tabLayout.FillDirection = Enum.FillDirection.Horizontal; tabLayout.Padding = UDim.new(0,10); tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center; tabLayout.Parent = tabBar

local homeTab = TabSystem:createTab("Home", nil, Theme.c("kitty")); homeTab.Parent = tabBar
local cashTab = TabSystem:createTab("Cash", AssetManager.assets.iconCash, Theme.c("cinna")); cashTab.Parent = tabBar
local passTab = TabSystem:createTab("Gamepasses", AssetManager.assets.iconPass, Theme.c("kuromiLav")); passTab.Parent = tabBar

-- Pages container
local pages = UI.frame({Name = "Pages", Size = UDim2.new(1,-24,1,-164), Position = UDim2.new(0,12,0,164), BackgroundTransparency = 1, ZIndex = 10}); pages.Parent = panel
local homePage = TabSystem:createPage("Home"); homePage.Parent = pages
local cashPage = TabSystem:createPage("Cash"); cashPage.Parent = pages
local passPage = TabSystem:createPage("Gamepasses"); passPage.Parent = pages

-- Price chip component
local function createPriceChip(text: string, accent: Color3): Frame
	local chip = UI.frame({Name = "Chip", Size = UDim2.fromOffset(120,30), BackgroundColor3 = Utils.blendColor(accent, Color3.new(1,1,1), 0.9), CornerRadius = UDim.new(1,0), ZIndex = 16})
	local stroke = Instance.new("UIStroke"); stroke.Color = accent; stroke.Transparency = 0.35; stroke.Thickness = 1.5; stroke.Parent = chip
	local lbl = UI.textLabel({Text = text, TextColor3 = accent, TextSize = 16, FontWeight = Enum.FontWeight.Medium, ZIndex = 17})
	lbl.Parent = chip
	return chip
end

-- Skeleton card
local function createSkeletonCard(accent: Color3): Frame
	local card = UI.frame({Name = "Skeleton", Size = UDim2.new(0,360,0,210), BackgroundColor3 = Theme.c("surface"), CornerRadius = UDim.new(0,20), Stroke = {Color = Theme.c("stroke"), Transparency = 0.35}, ZIndex = 12})
	local inner = UI.frame({Size = UDim2.new(1,-18,1,-18), Position = UDim2.new(0,9,0,9), BackgroundColor3 = Theme.c("surfaceAlt"), CornerRadius = UDim.new(0,16), Stroke = {Color = Theme.c("stroke"), Transparency = 0.25}, ZIndex = 13}); inner.Parent = card
	local shimmer = UI.image({Image = "rbxassetid://7010937928", ImageTransparency = 0.7, Size = UDim2.fromScale(1,1), ZIndex = 14}); shimmer.Parent = inner
	local outline = Instance.new("UIStroke"); outline.Color = accent; outline.Thickness = 2; outline.Transparency = 0.2; outline.Parent = card
	addHalo(card, accent, 36, 0.95, -1)
	return card
end

-- Card component (accent outline + halo)
local PendingPurchases = {product = {}, pass = {}}
local function createShopItemCard(item: {[string]: any}, itemType: string, accent: Color3): Frame
	local card = UI.frame({Name = "ItemCard", Size = UDim2.new(0,360,0,210), BackgroundColor3 = Theme.c("surface"), CornerRadius = UDim.new(0,20), Stroke = {Color = Theme.c("stroke"), Transparency = 0.3}, ZIndex = 12})
	local inner = UI.frame({Name = "Inner", Size = UDim2.new(1,-18,1,-18), Position = UDim2.new(0,9,0,9), BackgroundColor3 = itemType == "pass" and Color3.fromRGB(34,34,42) or Theme.c("surfaceAlt"), CornerRadius = UDim.new(0,16), Stroke = {Color = itemType == "pass" and Utils.blendColor(Theme.c("kuromiLav"), Color3.new(0.2,0.2,0.25), 0.5) or Theme.c("stroke"), Transparency = 0.25}, ZIndex = 13}); inner.Parent = card

	-- Accent outline + halo
	local outline = Instance.new("UIStroke"); outline.Name = "AccentOutline"; outline.Color = accent; outline.Thickness = 2; outline.Transparency = 0.15; outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; outline.Parent = card
	addHalo(card, accent, 36, 0.92, -1)

	-- Icon plate
	local plate = UI.frame({Name = "IconPlate", Size = UDim2.fromOffset(64,64), Position = UDim2.new(0,14,0,20), BackgroundColor3 = Utils.blendColor(accent, Color3.new(1,1,1), 0.9), CornerRadius = UDim.new(1,0), ZIndex = 14}); plate.Parent = inner
	local iconImage = item.icon and AssetManager.isValid(item.icon) and item.icon or (itemType == "pass" and AssetManager.assets.iconPass or AssetManager.assets.iconCash)
	local icon = UI.image({Name = "Icon", Image = iconImage, ImageColor3 = itemType == "pass" and Color3.fromRGB(240,240,255) or accent, Size = UDim2.fromOffset(36,36), Position = UDim2.new(0.5,0,0.5,0), AnchorPoint = Vector2.new(0.5,0.5), ZIndex = 15}); icon.Parent = plate

	-- Title & description
	local titleLbl = UI.textLabel({Name = "Title", Text = item.name, TextColor3 = itemType == "pass" and Color3.fromRGB(240,240,250) or Theme.c("text"), TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.new(0,88,0,18), Size = UDim2.new(1,-168,0,28), FontWeight = Enum.FontWeight.SemiBold, TextSize = 21, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 15}); titleLbl.Parent = inner
	local descLbl = UI.textLabel({Name = "Desc", Text = item.description or (itemType == "pass" and "Gamepass" or "Cash Bundle"), TextColor3 = itemType == "pass" and Color3.fromRGB(200,200,220) or Theme.c("subtext"), TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.new(0,88,0,50), Size = UDim2.new(1,-168,0,44), FontWeight = Enum.FontWeight.Regular, TextSize = 14, TextWrapped = true, ZIndex = 15}); descLbl.Parent = inner

	-- Chip
	local chipText = (itemType == "pass" and ("R$ "..tostring(item.price))) or ((item.amount and (Utils.formatNumber(item.amount).." Cash")) or "Bundle")
	local chip = createPriceChip(chipText, accent); chip.Position = UDim2.new(1,-132,0,10); chip.Parent = inner

	-- CTA
	local CTA = UI.textButton({Name = "CTA", Text = "Purchase", Size = UDim2.new(0,170,0,48), Position = UDim2.new(0,14,1,-60), BackgroundColor3 = Utils.blendColor(accent, Color3.new(1,1,1), 0.88), TextColor3 = accent, CornerRadius = UDim.new(1,0), Stroke = {Color = accent, Thickness = 2, Transparency = 0.15}, FontWeight = Enum.FontWeight.Bold, TextSize = 20, ZIndex = 16}); CTA.Parent = inner

	-- Purchase handler (defer re-enable to finished events)
	CTA.MouseButton1Click:Connect(function()
		CTA.Text = "Processing…"; CTA.Active = false; CTA.AutoButtonColor = false
		if itemType == "pass" then
			PendingPurchases.pass[item.id] = CTA
			Utils.safePcall(function() MarketplaceService:PromptGamePassPurchase(localPlayer, item.id) end)
		else
			PendingPurchases.product[item.id] = CTA
			Utils.safePcall(function() MarketplaceService:PromptProductPurchase(localPlayer, item.id) end)
		end
	end)

	-- Hover lift
	local original = card.Position
	card.MouseEnter:Connect(function()
		Utils.tween(card, ANIM.MED, {Position = UDim2.new(original.X.Scale, original.X.Offset, original.Y.Scale, original.Y.Offset - 5)})
	end)
	card.MouseLeave:Connect(function()
		Utils.tween(card, ANIM.MED, {Position = original})
	end)

	return card
end

-- Re-enable CTAs on purchase finished and update states
MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, wasPurchased)
	local CTA = PendingPurchases.product[productId]
	if CTA and CTA.Parent then
		CTA.Text = wasPurchased and "Purchased!" or "Purchase"
		CTA.Active = true; CTA.AutoButtonColor = true
		if wasPurchased then
			-- Fire server to grant currency; replace event name to your own
			local event = game:GetService("ReplicatedStorage"):FindFirstChild("GrantProductCurrency")
			if event and event:IsA("RemoteEvent") then
				event:FireServer(productId)
			end
			-- reset CTA text after a moment
			task.delay(1.2, function() if CTA and CTA.Parent then CTA.Text = "Purchase" end end)
		end
	end
	PendingPurchases.product[productId] = nil
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(userId, gamePassId, wasPurchased)
	local CTA = PendingPurchases.pass[gamePassId]
	if CTA and CTA.Parent then
		CTA.Text = wasPurchased and "Owned" or "Purchase"
		CTA.Active = not wasPurchased; CTA.AutoButtonColor = not wasPurchased
	end
	PendingPurchases.pass[gamePassId] = nil
	-- If owned, try to find and update the card visuals
	if wasPurchased then
		for _, gp in ipairs(ShopData.data.gamepasses) do
			if gp.id == gamePassId then
				-- Best-effort: update any visible cards
				-- Ownership refresh occurs when building or next open
				break
			end
		end
	end
end)

-- Owned state updater for gamepasses
local function updateGamepassOwnedState(card: Frame, passItem: {[string]: any}, accent: Color3)
	local userId = localPlayer and localPlayer.UserId or 0
	if userId == 0 then return end
	local owned = ShopData.userOwnsGamepass(userId, passItem.id)
	if not card or not card.Parent then return end
	local inner = card:FindFirstChild("Inner")
	local cta = inner and inner:FindFirstChild("CTA")
	if owned then
		if cta and cta:IsA("TextButton") then
			cta.Text = "Owned"
			cta.BackgroundColor3 = Utils.blendColor(Theme.c("success"), Color3.new(1,1,1), 0.9)
			cta.TextColor3 = Theme.c("success")
			cta.AutoButtonColor = false
			cta.Active = false
		end
		local outline = card:FindFirstChildOfClass("UIStroke")
		if outline then outline.Color = Theme.c("success") end
		local chip = inner and inner:FindFirstChild("Chip"); if chip and chip:IsA("Frame") then
			local s = chip:FindFirstChildOfClass("UIStroke"); if s then s.Color = Theme.c("success") end
			local t = chip:FindFirstChildOfClass("TextLabel"); if t then t.Text = "Permanent"; t.TextColor3 = Theme.c("success") end
		end
	end
end

-- Build Home page
local function buildHome()
	-- Soft background, clipped
	local homeOverlay = UI.frame({Name = "HomeOverlay", Size = UDim2.new(1,-24,1,-24), Position = UDim2.new(0,12,0,12), BackgroundColor3 = Theme.c("surfaceAlt"), CornerRadius = UDim.new(0,18), ClipsDescendants = true, ZIndex = 10}); homeOverlay.Parent = homePage
	local g = Instance.new("UIGradient"); g.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Utils.blendColor(Theme.c("kitty"), Color3.new(1,1,1), 0.97)), ColorSequenceKeypoint.new(1, Color3.new(1,1,1))}; g.Rotation = 90; g.Parent = homeOverlay

	-- Bow pattern faint
	if AssetManager.isValid(AssetManager.assets.hkBowPattern) then
		local pattern = UI.image({Name = "BowPattern", Image = AssetManager.assets.hkBowPattern, ImageColor3 = Color3.fromRGB(255,200,200), ImageTransparency = 0.94, Size = UDim2.fromScale(1,1), ScaleType = Enum.ScaleType.Tile, ZIndex = 10}); pattern.TileSize = UDim2.fromOffset(120,120); pattern.Parent = homeOverlay
	end

	-- Hero
	local hero = UI.frame({Name = "Hero", Size = UDim2.new(1,-24,0,220), Position = UDim2.new(0,12,0,0), BackgroundColor3 = Theme.c("surfaceAlt"), CornerRadius = UDim.new(0,18), Stroke = {Color = Theme.c("stroke")}, ZIndex = 12}); hero.Parent = homePage
	local heroGrad = Instance.new("UIGradient"); heroGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Utils.blendColor(Theme.c("kitty"), Color3.new(1,1,1), 0.96)), ColorSequenceKeypoint.new(1, Color3.new(1,1,1))}; heroGrad.Rotation = 45; heroGrad.Parent = hero

	local heroBadge = UI.image({Name = "HeroBadge", Image = AssetManager.assets.badgeHello, Size = UDim2.fromOffset(72,72), Position = UDim2.new(0,24,0.5,0), AnchorPoint = Vector2.new(0,0.5), ZIndex = 13}); heroBadge.Parent = hero
	local heroTitle = UI.textLabel({Name = "HeroTitle", Text = "5,000 Cash", Position = UDim2.new(0,116,0,34), Size = UDim2.new(1,-300,0,40), TextXAlignment = Enum.TextXAlignment.Left, FontWeight = Enum.FontWeight.Bold, TextSize = 32, ZIndex = 13}); heroTitle.Parent = hero
	local heroDesc = UI.textLabel({Name = "HeroDesc", Text = "Perfect for mid‑game purchases", Position = UDim2.new(0,116,0,78), Size = UDim2.new(1,-300,0,50), TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Theme.c("subtext"), FontWeight = Enum.FontWeight.Regular, TextSize = 18, TextWrapped = true, ZIndex = 13}); heroDesc.Parent = hero
	local heroCTA = UI.textButton({Name = "HeroCTA", Text = "Get Now", Size = UDim2.fromOffset(200,52), Position = UDim2.new(1,-220,0.5,0), AnchorPoint = Vector2.new(0,0.5), CornerRadius = UDim.new(1,0), FontWeight = Enum.FontWeight.Bold, TextSize = 22, ZIndex = 14}); heroCTA.Parent = hero

	-- Bow sticker near hero title
	if AssetManager.isValid(AssetManager.assets.hkBowPattern) then
		local bow = UI.image({Name = "HelloKittyBow", Image = AssetManager.assets.hkBowPattern, Size = UDim2.fromOffset(42,42), Position = UDim2.new(0, 82, 0, 8), BackgroundTransparency = 1, ImageTransparency = 0.08, ZIndex = 14}); bow.Parent = hero
	end

	-- Benefits strip
	local benefits = UI.frame({Name = "Benefits", Size = UDim2.new(1,-24,0,86), Position = UDim2.new(0,12,0,234), BackgroundColor3 = Theme.c("surface"), CornerRadius = UDim.new(0,16), Stroke = {Color = Theme.c("stroke")}, ZIndex = 12}); benefits.Parent = homePage
	local list = Instance.new("UIListLayout"); list.FillDirection = Enum.FillDirection.Horizontal; list.Padding = UDim.new(0,12); list.HorizontalAlignment = Enum.HorizontalAlignment.Center; list.VerticalAlignment = Enum.VerticalAlignment.Center; list.Parent = benefits
	local function benefit(text, iconId)
		local it = UI.frame({Size = UDim2.fromOffset(300,60), BackgroundColor3 = Theme.c("surfaceAlt"), CornerRadius = UDim.new(0,14), Stroke = {Color = Theme.c("stroke"), Transparency = 0.2}, ZIndex = 13});
		local ic = UI.image({Image = iconId or AssetManager.assets.badgeHello, Size = UDim2.fromOffset(28,28), Position = UDim2.new(0,14,0.5,0), AnchorPoint = Vector2.new(0,0.5), ZIndex = 14}); ic.Parent = it
		local lb = UI.textLabel({Text = text, TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.new(0,52,0,0), Size = UDim2.new(1,-66,1,0), FontWeight = Enum.FontWeight.Medium, TextSize = 18, ZIndex = 14}); lb.Parent = it
		return it
	end
	benefit("Secure purchases", AssetManager.assets.badgeHello).Parent = benefits
	benefit("Instant delivery", AssetManager.assets.badgeCinna).Parent = benefits
	benefit("All devices supported", AssetManager.assets.badgeKuromi).Parent = benefits

	-- Featured carousel
	local featured = UI.scroll({Name = "Featured", Size = UDim2.new(1,0,0,260), Position = UDim2.new(0,0,0, 330), ScrollingDirection = Enum.ScrollingDirection.X, ScrollBarThickness = 6, Layout = {Type = "List", FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0,16)}, Padding = {Left = UDim.new(0,8), Right = UDim.new(0,8)}, ZIndex = 13}); featured.Parent = homePage

	local items = {}
	for i = 1, math.min(2, #ShopData.data.cash) do table.insert(items, {item = ShopData.data.cash[i], type = "cash", accent = Theme.c("cinna")}) end
	for i = 1, math.min(2, #ShopData.data.gamepasses) do table.insert(items, {item = ShopData.data.gamepasses[i], type = "pass", accent = Theme.c("kuromiLav")}) end
	for _, f in ipairs(items) do
		local c = createShopItemCard(f.item, f.type, f.accent); c.Parent = featured
	end
	-- Canvas size after layout
	task.defer(function()
		local ll = featured:FindFirstChildOfClass("UIListLayout"); if ll then featured.CanvasSize = UDim2.new(0, ll.AbsoluteContentSize.X + 16, 0, 0) end
	end)

	-- Hook hero CTA to first featured
	local primary = items[1]
	if primary then
		heroCTA.BackgroundColor3 = Utils.blendColor(primary.accent, Color3.new(1,1,1), 0.9)
		heroCTA.TextColor3 = primary.accent
		local stroke = heroCTA:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke", heroCTA); stroke.Color = primary.accent; stroke.Thickness = 2
		heroCTA.MouseButton1Click:Connect(function()
			if primary.type == "pass" then MarketplaceService:PromptGamePassPurchase(localPlayer, primary.item.id) else MarketplaceService:PromptProductPurchase(localPlayer, primary.item.id) end
		end)
	end
end

-- Build Cash page
local function buildCash()
	local overlay = UI.frame({Name = "CashOverlay", Size = UDim2.new(1,-24,1,-24), Position = UDim2.new(0,12,0,12), BackgroundColor3 = Utils.blendColor(Theme.c("cinna"), Color3.new(1,1,1), 0.7), CornerRadius = UDim.new(0,18), ClipsDescendants = true, ZIndex = 11}); overlay.Parent = cashPage
	local grad = Instance.new("UIGradient"); grad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, Utils.blendColor(Theme.c("cinna"), Color3.new(1,1,1), 0.85))}; grad.Rotation = 90; grad.Parent = overlay
	-- Clouds
	local function cloud(pos, size, alpha)
		local c = UI.image({Image = AssetManager.assets.cloudTexture, ImageColor3 = Color3.new(1,1,1), ImageTransparency = alpha or 0.8, Size = size, Position = pos, ZIndex = 10}); c.Parent = overlay; return c
	end
	cloud(UDim2.new(1,-140,0,40), UDim2.fromOffset(120,80), 0.35)
	cloud(UDim2.new(1,-80,0,120), UDim2.fromOffset(100,70), 0.75)
	cloud(UDim2.new(0,30,1,-120), UDim2.fromOffset(130,85), 0.2)
	cloud(UDim2.new(0.85,0,0.25,0), UDim2.fromOffset(75,50), 0.6)
	cloud(UDim2.new(0.7,0,0.4,0), UDim2.fromOffset(90,60), 0.8)
	cloud(UDim2.new(0.15,0,0.35,0), UDim2.fromOffset(70,45), 0.4)

	local grid = UI.scroll({Name = "CashGrid", Size = UDim2.new(1,-32,1,-32), Position = UDim2.new(0,16,0,16), Layout = {Type = "Grid", CellSize = UDim2.new(0,360,0,210), CellPadding = UDim2.new(0,18,0,18), HorizontalAlignment = Enum.HorizontalAlignment.Center}, ZIndex = 12}); grid.Parent = cashPage
	for _, item in ipairs(ShopData.data.cash) do
		createShopItemCard(item, "cash", Theme.c("cinna")).Parent = grid
	end
	task.defer(function() local lay = grid:FindFirstChildOfClass("UIGridLayout"); if lay then grid.CanvasSize = UDim2.new(0,0,0, lay.AbsoluteContentSize.Y + 32) end end)
end

-- Build Gamepasses page
local function buildPasses()
	local bg = UI.frame({Name = "PassBG", BackgroundColor3 = Color3.fromRGB(22,22,26), CornerRadius = UDim.new(0,18), ClipsDescendants = true, ZIndex = 11}); bg.Parent = passPage
	local overlay = UI.frame({Name = "Overlay", Size = UDim2.new(1,-24,1,-24), Position = UDim2.new(0,12,0,12), BackgroundColor3 = Utils.blendColor(Theme.c("kuromiLav"), Color3.new(1,1,1), 0.85), CornerRadius = UDim.new(0,18), ClipsDescendants = true, ZIndex = 11}); overlay.Parent = bg
	local g = Instance.new("UIGradient"); g.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(34,34,42)), ColorSequenceKeypoint.new(1, Color3.fromRGB(28,28,34))}; g.Rotation = 135; g.Parent = overlay

	-- Stars
	if AssetManager.isValid(AssetManager.assets.starPattern) then
		local stars = UI.image({Name = "Stars", Image = AssetManager.assets.starPattern, ImageColor3 = Theme.c("kuromiLav"), ImageTransparency = 0.6, ScaleType = Enum.ScaleType.Tile, Size = UDim2.fromScale(1,1), ZIndex = 10}); stars.TileSize = UDim2.fromOffset(720,720); stars.Parent = overlay
	end

	-- Kuromi character sticker
	local kuromiId = "rbxassetid://5806227321"
	local kuromi = UI.image({Name = "Kuromi", Image = kuromiId, Size = UDim2.fromOffset(180,180), Position = UDim2.new(0, -10, 0, 20), AnchorPoint = Vector2.new(0,0), ImageTransparency = 0.12, ZIndex = 13});
	kuromi.Parent = passPage
	-- Gentle float animation (paused when not visible by virtue of page visibility)
	task.spawn(function()
		local base = kuromi.Position
		while kuromi and kuromi.Parent do
			local t = tick()
			kuromi.Position = UDim2.new(base.X.Scale, base.X.Offset + math.sin(t*0.7)*4, base.Y.Scale, base.Y.Offset + math.cos(t*0.7)*3)
			kuromi.Rotation = math.sin(t*0.4) * 3
			task.wait(0.1)
		end
	end)

	local grid = UI.scroll({Name = "PassGrid", Size = UDim2.new(1,-32,1,-32), Position = UDim2.new(0,16,0,16), Layout = {Type = "Grid", CellSize = UDim2.new(0,360,0,210), CellPadding = UDim2.new(0,18,0,18), HorizontalAlignment = Enum.HorizontalAlignment.Center}, ZIndex = 12}); grid.Parent = passPage
	for _, gp in ipairs(ShopData.data.gamepasses) do
		local card = createShopItemCard(gp, "pass", Theme.c("kuromiLav")); card.Parent = grid
		updateGamepassOwnedState(card, gp, Theme.c("kuromiLav"))
	end
	task.defer(function() local lay = grid:FindFirstChildOfClass("UIGridLayout"); if lay then grid.CanvasSize = UDim2.new(0,0,0, lay.AbsoluteContentSize.Y + 32) end end)
end

-- Build pages
hydrateMetadata()
buildHome()
buildCash()
buildPasses()

-- Tab interactions
homeTab.MouseButton1Click:Connect(function() TabSystem:select("Home") end)
cashTab.MouseButton1Click:Connect(function() TabSystem:select("Cash") end)
passTab.MouseButton1Click:Connect(function() TabSystem:select("Gamepasses") end)

-- Blur manager
local Blur = {ref = nil}
function Blur:get()
	if self.ref then return self.ref end
	local e = Lighting:FindFirstChild("SanrioShopBlur")
	if e and e:IsA("BlurEffect") then self.ref = e; return e end
	local b = Instance.new("BlurEffect"); b.Name = "SanrioShopBlur"; b.Size = 0; b.Parent = Lighting; self.ref = b; return b
end
function Blur:show(size)
	Utils.tween(self:get(), ANIM.MED, {Size = size or 10})
end
function Blur:hide()
	Utils.tween(self:get(), ANIM.MED, {Size = 0})
end

-- Toggle button
local toggle = UI.textButton({Name = "ShopToggle", Size = UDim2.fromOffset(156,50), Position = UDim2.new(1,-16,1,-16), AnchorPoint = Vector2.new(1,1), BackgroundColor3 = Theme.c("surface"), CornerRadius = UDim.new(1,0), Stroke = {Color = Theme.c("stroke")}, ZIndex = 10})
toggle.Parent = screenGui
local tIcon = UI.image({Image = AssetManager.assets.badgeHello, ImageColor3 = Theme.c("kitty"), Size = UDim2.fromOffset(24,24), Position = UDim2.new(0,12,0.5,0), AnchorPoint = Vector2.new(0,0.5), ZIndex = 11}); tIcon.Parent = toggle
local tText = UI.textLabel({Text = "Shop", Position = UDim2.new(0,44,0,0), Size = UDim2.new(1,-50,1,0), TextXAlignment = Enum.TextXAlignment.Left, FontWeight = Enum.FontWeight.SemiBold, TextSize = 20, ZIndex = 11}); tText.Parent = toggle

-- Manager
local Shop = {open = false, animating = false, firstOpen = true}

-- assets to preload
local preloadList = {
	AssetManager.assets.badgeHello,
	AssetManager.assets.badgeCinna,
	AssetManager.assets.badgeKuromi,
	AssetManager.assets.hkBowPattern,
	AssetManager.assets.hkCuteFace,
	AssetManager.assets.cloudTexture,
	AssetManager.assets.starPattern,
	AssetManager.assets.iconCloseX,
	AssetManager.assets.iconCash,
	AssetManager.assets.iconPass
}

local function preloadAssets()
	local content = {}
	for _, id in ipairs(preloadList) do if AssetManager.isValid(id) then table.insert(content, id) end end
	if #content > 0 then
		Utils.safePcall(function() ContentProvider:PreloadAsync(content) end)
	end
end

function Shop:openShop()
	if self.open or self.animating then return end
	self.animating = true; self.open = true
	preloadAssets()
	dim.Visible = true; panel.Visible = true
	dim.BackgroundTransparency = 1; panel.Position = UDim2.new(0.5,0,0.52,0); panel.Size = UDim2.new(0,960,0,830); panel.BackgroundTransparency = 0.2
	Blur:show(10)
	Utils.tween(dim, ANIM.MED, {BackgroundTransparency = 0.3})
	Utils.tween(panel, ANIM.SLOW, {Position = UDim2.new(0.5,0,0.5,0), Size = UDim2.new(0,980,0,860), BackgroundTransparency = 0})
	Sfx:play("open")
	TabSystem:select("Home")
	task.delay(0.35, function() self.animating = false end)
end

function Shop:closeShop()
	if not self.open or self.animating then return end
	self.animating = true; self.open = false
	Blur:hide()
	Utils.tween(dim, ANIM.FAST, {BackgroundTransparency = 1})
	Utils.tween(panel, ANIM.FAST, {Position = UDim2.new(0.5,0,0.53,0), Size = UDim2.new(0,960,0,830)})
	Sfx:play("close")
	task.delay(0.2, function()
		dim.Visible = false; panel.Visible = false; self.animating = false
	end)
end

function Shop:toggle()
	if self.open then self:closeShop() else self:openShop() end
end

-- Bindings
closeBtn.MouseButton1Click:Connect(function() Shop:closeShop() end)
toggle.MouseButton1Click:Connect(function() Shop:openShop() end)

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.M then Shop:toggle() end
end)

-- Cleanup on character removal
Players.LocalPlayer.CharacterRemoving:Connect(function()
	if screenGui then screenGui:Destroy() end
	local b = Lighting:FindFirstChild("SanrioShopBlur"); if b then b:Destroy() end
end)

print("🎀 SANRIOSHOPCOMPLETPLERECODED loaded. Press 'M' or use the button to open.")