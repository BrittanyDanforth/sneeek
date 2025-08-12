--[[
  🧷 Sanrio Character Takeover Shop – Tabbed Layout v2 (Upscaled + Standalone HK Talker)
  - Home tab: Large hero rotating through ALL items
  - Cash tab: Cinnamoroll blue overlay background + big white cards
  - Gamepasses tab: Kuromi lavender overlay background + big white cards
  - Standalone Hello Kitty talker (bottom-left), reliable typewriter + close button + auto hide
  - Stable events, debounced show/hide, FontFace throughout
]]

-- Services
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local localPlayer = Players.LocalPlayer

-- Utils
local function tween(instance: Instance?, info: TweenInfo, props: {[string]: any})
	if not instance then return nil end
	local t = TweenService:Create(instance, info, props)
	t:Play()
	return t
end

local function setFont(guiObject: TextLabel | TextButton, weight: Enum.FontWeight, size: number)
	guiObject.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", weight, Enum.FontStyle.Normal)
	guiObject.TextSize = size
end

local function blendTowardWhite(c: Color3, t: number): Color3
	return Color3.new(c.R + (1 - c.R) * t, c.G + (1 - c.G) * t, c.B + (1 - c.B) * t)
end

local function getBlur()
	local blur = Lighting:FindFirstChild("SanrioShopBlur")
	if blur and blur:IsA("BlurEffect") then return blur end
	blur = Instance.new("BlurEffect")
	blur.Name = "SanrioShopBlur"
	blur.Size = 0
	blur.Parent = Lighting
	return blur
end

-- Assets
local ASSETS = {
	paperTexture = "rbxassetid://0",
	badgeHello = "rbxassetid://0",
	badgeMelody = "rbxassetid://0",
	badgeKuromi = "rbxassetid://0",
	badgeCinna = "rbxassetid://0",

	iconCloseX = "rbxassetid://13516603909",
	iconBag    = "rbxassetid://6031280882",
	iconCash   = "rbxassetid://10709728059",
	iconPass   = "rbxassetid://10709727148",

	-- Optional themed assets
	hkPortrait    = "rbxassetid://8399407650",
	hkBowPattern  = "rbxassetid://0",       -- light gray bow tile for Home background
	bannerPlaid   = "rbxassetid://0",       -- faint red/white plaid for hero banner
	hkBowLarge    = "rbxassetid://0",       -- large bow graphic in hero corner
	skyTexture    = "rbxassetid://0",       -- painted sky for Cinnamoroll background
	cloudNineSlice= "rbxassetid://0",       -- 9-slice cloud frame for cash cards
	iconStar      = "rbxassetid://0",
	iconTeacup    = "rbxassetid://0",
	iconRoll      = "rbxassetid://0",
	iconSkull     = "rbxassetid://0",       -- Kuromi skull
	kuromiPattern = "rbxassetid://0",       -- dark repeating skull/chains pattern
}

-- Theme
local theme = {
	bg       = Color3.fromRGB(253, 252, 250),
	panel    = Color3.fromRGB(255, 255, 255),
	panelAlt = Color3.fromRGB(246, 248, 252),
	stroke   = Color3.fromRGB(222, 226, 235),
	text     = Color3.fromRGB(35, 38, 46),
	subtext  = Color3.fromRGB(120, 126, 140),
	scrollbar= Color3.fromRGB(180, 185, 200),

	kitty    = Color3.fromRGB(255, 64, 64),
	kuromiLav= Color3.fromRGB(200, 190, 255),
	kuromiInk= Color3.fromRGB(38, 38, 46),
	cinnaSky = Color3.fromRGB(186, 214, 255),
}

-- Data
local shopData = {
	cash = {
		{id = 3366419712, amount = 1000,  name = "1,000 Cash",  color = theme.cinnaSky},
		{id = 3366420012, amount = 5000,  name = "5,000 Cash",  color = theme.cinnaSky},
		{id = 3366420478, amount = 10000, name = "10,000 Cash", color = theme.cinnaSky},
		{id = 3366420800, amount = 25000, name = "25,000 Cash", color = theme.cinnaSky},
	},
	gamepasses = {
		{id = 123456789, name = "2x Cash",      price = 199, color = theme.kuromiLav},
		{id = 123456790, name = "VIP Pass",     price = 499, color = theme.kuromiLav},
		{id = 123456791, name = "Auto Collect", price = 299, color = theme.kuromiLav},
	}
}

-- GUI Root
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SanrioShopUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 1000
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Optional paper background
if ASSETS.paperTexture ~= "rbxassetid://0" then
	local paper = Instance.new("ImageLabel")
	paper.Name = "Paper"
	paper.Size = UDim2.fromScale(1, 1)
	paper.BackgroundTransparency = 1
	paper.Image = ASSETS.paperTexture
	paper.ImageTransparency = 0.93
	paper.ScaleType = Enum.ScaleType.Tile
	paper.TileSize = UDim2.fromOffset(140, 140)
	paper.Parent = screenGui
end

-- Dim + blur
local blur = getBlur()
local dim = Instance.new("Frame")
	dim.Name = "Dim"
	dim.Size = UDim2.fromScale(1, 1)
	dim.BackgroundColor3 = theme.bg
	dim.BackgroundTransparency = 1
	dim.Visible = false
	dim.ZIndex = 5
	dim.Parent = screenGui

-- Panel (upscaled)
local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.Size = UDim2.new(0, 980, 0, 860)
	panel.Position = UDim2.new(0.5, -490, 0.5, -430)
	panel.BackgroundColor3 = theme.panel
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.ZIndex = 6
	panel.Parent = screenGui

local panelCorner = Instance.new("UICorner") panelCorner.CornerRadius = UDim.new(0, 24) panelCorner.Parent = panel
local panelStroke = Instance.new("UIStroke") panelStroke.Color = theme.stroke panelStroke.Thickness = 1.5 panelStroke.Parent = panel

local panelShadow = Instance.new("ImageLabel")
	panelShadow.BackgroundTransparency = 1
	panelShadow.Image = "rbxassetid://6015897843"
	panelShadow.ImageTransparency = 0.7
	panelShadow.ScaleType = Enum.ScaleType.Slice
	panelShadow.SliceCenter = Rect.new(49, 49, 450, 450)
	panelShadow.Size = UDim2.new(1, 50, 1, 50)
	panelShadow.Position = UDim2.new(0, -25, 0, -15)
	panelShadow.ZIndex = 5
	panelShadow.Parent = panel

-- Header
local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, -24, 0, 88)
	header.Position = UDim2.new(0, 12, 0, 12)
	header.BackgroundColor3 = theme.panelAlt
	header.BorderSizePixel = 0
	header.ZIndex = 7
	header.Parent = panel

local headerCorner = Instance.new("UICorner") headerCorner.CornerRadius = UDim.new(0, 18) headerCorner.Parent = header
local headerStroke = Instance.new("UIStroke") headerStroke.Color = theme.stroke headerStroke.Thickness = 1 headerStroke.Parent = header

local kittyBadge = Instance.new("ImageLabel")
	kittyBadge.BackgroundTransparency = 1
	kittyBadge.Image = ASSETS.badgeHello
	kittyBadge.Size = UDim2.new(0, 46, 0, 46)
	kittyBadge.Position = UDim2.new(0, 16, 0.5, -23)
	kittyBadge.ZIndex = 8
	kittyBadge.Parent = header

local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 72, 0, 0)
	title.Size = UDim2.new(1, -140, 1, 0)
	title.Text = "Sanrio Shop"
	title.TextColor3 = theme.text
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 8
	title.Parent = header
setFont(title, Enum.FontWeight.SemiBold, 34)

local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "Close"
	closeBtn.Size = UDim2.new(0, 40, 0, 40)
	closeBtn.Position = UDim2.new(1, -56, 0.5, -20)
	closeBtn.BackgroundColor3 = Color3.fromRGB(235, 60, 60)
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.new(1,1,1)
	closeBtn.AutoButtonColor = false
	closeBtn.ZIndex = 9
	closeBtn.Parent = header
local closeRound = Instance.new("UICorner") closeRound.CornerRadius = UDim.new(1,0) closeRound.Parent = closeBtn
setFont(closeBtn, Enum.FontWeight.Bold, 20)

local closeIcon = Instance.new("ImageLabel")
	closeIcon.BackgroundTransparency = 1
	closeIcon.Image = ASSETS.iconCloseX
	closeIcon.ImageColor3 = Color3.new(0, 0, 0)
	closeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	closeIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	closeIcon.Size = UDim2.new(0, 24, 0, 24)
	closeIcon.ZIndex = 9
	closeIcon.Parent = closeBtn

-- Tabs
local TABBAR_Y = 12 + 88 + 10
local tabBar = Instance.new("Frame")
	tabBar.Name = "TabBar"
	tabBar.Size = UDim2.new(1, -24, 0, 52)
	tabBar.Position = UDim2.new(0, 12, 0, TABBAR_Y)
	tabBar.BackgroundTransparency = 1
	tabBar.ZIndex = 7
	tabBar.Parent = panel

local tabsList = Instance.new("UIListLayout")
	tabsList.FillDirection = Enum.FillDirection.Horizontal
	tabsList.HorizontalAlignment = Enum.HorizontalAlignment.Left
	tabsList.VerticalAlignment = Enum.VerticalAlignment.Center
	tabsList.Padding = UDim.new(0, 10)
	tabsList.Parent = tabBar

local function makeTabButton(text: string)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 156, 1, 0)
	btn.BackgroundColor3 = theme.panel
	btn.AutoButtonColor = false
	btn.Text = text
	btn.TextColor3 = theme.text
	btn.ZIndex = 8
	setFont(btn, Enum.FontWeight.SemiBold, 20)
	local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1, 0) c.Parent = btn
	local s = Instance.new("UIStroke") s.Color = theme.stroke s.Thickness = 1 s.Parent = btn
	return btn
end

local tabHome = makeTabButton("Home")
local tabCash = makeTabButton("Cash")
local tabPass = makeTabButton("Gamepasses")

tabHome.Parent = tabBar
local spacer = Instance.new("Frame") spacer.Size = UDim2.new(0, 10, 1, 0) spacer.BackgroundTransparency = 1 spacer.Parent = tabBar

tabCash.Parent = tabBar
local spacer2 = Instance.new("Frame") spacer2.Size = UDim2.new(0, 10, 1, 0) spacer2.BackgroundTransparency = 1 spacer2.Parent = tabBar

tabPass.Parent = tabBar

local function styleTabSelected(btn: TextButton, accent: Color3)
	btn.TextColor3 = accent
	for _, c in ipairs(btn:GetChildren()) do
		if c:IsA("UIStroke") then c.Color = accent end
	end
	btn.BackgroundColor3 = blendTowardWhite(accent, 0.9)
end

local function styleTabIdle(btn: TextButton)
	btn.TextColor3 = theme.text
	for _, c in ipairs(btn:GetChildren()) do
		if c:IsA("UIStroke") then c.Color = theme.stroke end
	end
	btn.BackgroundColor3 = theme.panel
end

-- Pages container
local CONTENT_TOP = TABBAR_Y + 52 + 10
local pages = Instance.new("Frame")
	pages.Name = "Pages"
	pages.BackgroundTransparency = 1
	pages.Size = UDim2.new(1, -24, 1, -(CONTENT_TOP + 12))
	pages.Position = UDim2.new(0, 12, 0, CONTENT_TOP)
	pages.ZIndex = 6
	pages.Parent = panel

local function makePage()
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 1, 0)
	f.BackgroundTransparency = 1
	f.Visible = false
	f.ZIndex = 6
	return f
end

local pageHome = makePage(); pageHome.Name = "Home"; pageHome.Parent = pages
local pageCash = makePage(); pageCash.Name = "Cash"; pageCash.Parent = pages
local pagePass = makePage(); pagePass.Name = "Pass"; pagePass.Parent = pages

local function showOnly(page: Frame)
	pageHome.Visible = (page == pageHome)
	pageCash.Visible = (page == pageCash)
	pagePass.Visible = (page == pagePass)
end

-- Accent overlay backgrounds (stronger theme)
local function makeOverlay(parent: Frame, color: Color3)
	local overlay = Instance.new("Frame")
	overlay.BackgroundColor3 = blendTowardWhite(color, 0.65)
	overlay.BorderSizePixel = 0
	overlay.Size = UDim2.new(1, -24, 1, -24)
	overlay.Position = UDim2.new(0, 12, 0, 12)
	overlay.ZIndex = 5
	overlay.Parent = parent
	local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 18) corner.Parent = overlay
	return overlay
end

local cashOverlay = makeOverlay(pageCash, theme.cinnaSky)
local passOverlay = makeOverlay(pagePass, theme.kuromiLav)

-- Animated sky background for Cash tab
if ASSETS.skyTexture ~= "rbxassetid://0" then
	local sky = Instance.new("ImageLabel")
	sky.Name = "SkyBg"
	sky.BackgroundTransparency = 1
	sky.Image = ASSETS.skyTexture
	sky.ImageTransparency = 0.07
	sky.Size = UDim2.new(1.4, 0, 1.2, 0)
	sky.Position = UDim2.new(-0.2, 0, -0.1, 0)
	sky.ZIndex = 4
	sky.Parent = pageCash
	task.spawn(function()
		local dir = 1
		while true do
			local x = sky.Position.X.Scale
			if x > -0.05 then dir = -1 elseif x < -0.25 then dir = 1 end
			sky.Position = UDim2.new(x + dir*0.0008, 0, sky.Position.Y.Scale, 0)
			task.wait(0.016)
		end
	end)
end

-- Kuromi dark mode background pattern
local kuromiBg = Instance.new("Frame")
kuromiBg.BackgroundColor3 = Color3.fromRGB(22,22,26)
kuromiBg.BorderSizePixel = 0
kuromiBg.Size = UDim2.new(1, 0, 1, 0)
kuromiBg.ZIndex = 4
kuromiBg.Parent = pagePass
if ASSETS.kuromiPattern ~= "rbxassetid://0" then
	local pat = Instance.new("ImageLabel")
	pat.BackgroundTransparency = 1
	pat.Image = ASSETS.kuromiPattern
	pat.ImageTransparency = 0.88
	pat.ImageColor3 = Color3.fromRGB(180, 170, 200)
	pat.ScaleType = Enum.ScaleType.Tile
	pat.TileSize = UDim2.fromOffset(80, 80)
	pat.Size = UDim2.new(1,0,1,0)
	pat.ZIndex = 4
	pat.Parent = pagePass
end

-- Sticker Card (bigger) with style variants: "cash" (cloud), "pass" (edgy)
local CARD_W, CARD_H = 320, 180

local function makeStickerCard(charBadgeId: string, accent: Color3, data: any, isPass: boolean, nameTextColor: Color3?, style: string?, indexForAlt: number?)
	style = style or (isPass and "pass" or "cash")
	local outer = Instance.new("Frame")
	outer.Size = UDim2.new(0, CARD_W, 0, CARD_H)
	outer.BackgroundTransparency = 1
	outer.BorderSizePixel = 0
	outer.ZIndex = 6

	-- Background container depending on style
	local bg
	if style == "cash" and ASSETS.cloudNineSlice ~= "rbxassetid://0" then
		bg = Instance.new("ImageLabel")
		bg.Name = "CloudBG"
		bg.BackgroundTransparency = 1
		bg.Image = ASSETS.cloudNineSlice
		bg.ScaleType = Enum.ScaleType.Slice
		bg.SliceCenter = Rect.new(24,24,104,104)
		bg.Size = UDim2.new(1, 0, 1, 0)
		bg.ZIndex = 6
		bg.Parent = outer
	else
		bg = Instance.new("Frame")
		bg.BackgroundColor3 = (style == "pass") and Color3.fromRGB(28,28,34) or Color3.new(1,1,1)
		bg.Size = UDim2.new(1, 0, 1, 0)
		bg.BorderSizePixel = 0
		bg.ZIndex = 6
		bg.Parent = outer
		local bgCorner = Instance.new("UICorner") bgCorner.CornerRadius = UDim.new(0, 20) bgCorner.Parent = bg
	end

	local bgStroke = Instance.new("UIStroke")
	bgStroke.Thickness = (style == "pass") and 3 or 1
	bgStroke.Color = (style == "pass") and Color3.fromRGB(255, 80, 180) or theme.stroke
	bgStroke.Transparency = (style == "pass") and 0.15 or 0.3
	bgStroke.Parent = bg

	local inner = Instance.new("Frame")
	inner.Size = UDim2.new(1, -18, 1, -18)
	inner.Position = UDim2.new(0, 9, 0, 9)
	inner.BackgroundColor3 = (style == "pass") and Color3.fromRGB(34,34,42) or theme.panelAlt
	inner.BorderSizePixel = 0
	inner.ZIndex = 7
	inner.Parent = bg
	local innerCorner = Instance.new("UICorner") innerCorner.CornerRadius = UDim.new(0, 16) innerCorner.Parent = inner
	local innerStroke = Instance.new("UIStroke") innerStroke.Color = (style == "pass") and Color3.fromRGB(200, 120, 220) or theme.stroke innerStroke.Thickness = 1 innerStroke.Parent = inner

	local stripe = Instance.new("Frame")
	stripe.Size = UDim2.new(1, 0, 0, 6)
	stripe.BackgroundColor3 = accent
	stripe.BorderSizePixel = 0
	stripe.ZIndex = 7
	stripe.Parent = inner

	if charBadgeId ~= "rbxassetid://0" then
		local badge = Instance.new("ImageLabel")
		badge.BackgroundTransparency = 1
		badge.Image = charBadgeId
		badge.Size = UDim2.new(0, 26, 0, 26)
		badge.Position = UDim2.new(1, -34, 0, 10)
		badge.ZIndex = 8
		badge.Parent = inner
	end

	local icon = Instance.new("ImageLabel")
	icon.BackgroundTransparency = 1
	if style == "pass" and ASSETS.iconSkull ~= "rbxassetid://0" then
		icon.Image = ASSETS.iconSkull
	else
		local cashIcons = {ASSETS.iconStar, ASSETS.iconTeacup, ASSETS.iconRoll, ASSETS.iconCash}
		local pick = cashIcons[math.random(1, #cashIcons)] or ASSETS.iconCash
		icon.Image = pick ~= "rbxassetid://0" and pick or (isPass and ASSETS.iconPass or ASSETS.iconCash)
	end
	icon.ImageColor3 = (style == "pass") and Color3.fromRGB(240,240,255) or accent
	icon.Size = UDim2.new(0, 46, 0, 46)
	icon.Position = UDim2.new(0, 14, 0, 24)
	icon.ZIndex = 8
	icon.Parent = inner

	local name = Instance.new("TextLabel")
	name.BackgroundTransparency = 1
	name.Text = data.name
	name.TextColor3 = nameTextColor or ((style == "pass") and Color3.fromRGB(240,240,250) or theme.text)
	name.TextXAlignment = Enum.TextXAlignment.Left
	name.Position = UDim2.new(0, 72, 0, 22)
	name.Size = UDim2.new(1, -84, 0, 26)
	name.ZIndex = 8
	name.Parent = inner
	if style == "pass" then
		name.FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
		name.TextSize = 20
	else
		setFont(name, Enum.FontWeight.SemiBold, 20)
	end

	local sub = Instance.new("TextLabel")
	sub.BackgroundTransparency = 1
	sub.Text = isPass and "Gamepass" or "Cash Bundle"
	sub.TextColor3 = (style == "pass") and Color3.fromRGB(200,200,220) or theme.subtext
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Position = UDim2.new(0, 72, 0, 52)
	sub.Size = UDim2.new(1, -84, 0, 20)
	sub.ZIndex = 8
	sub.Parent = inner
	if style == "pass" then
		sub.FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		sub.TextSize = 16
	else
		setFont(sub, Enum.FontWeight.Regular, 16)
	end

	local cta = Instance.new("TextButton")
	cta.AutoButtonColor = false
	cta.Size = UDim2.new(0, 146, 0, 42)
	cta.Position = UDim2.new(0, 14, 1, -54)
	cta.BackgroundColor3 = (style == "pass") and Color3.fromRGB(44,44,52) or blendTowardWhite(accent, 0.85)
	cta.Text = isPass and ("R$ " .. tostring(data.price)) or "Get"
	cta.TextColor3 = (style == "pass") and Color3.fromRGB(240,240,255) or accent
	cta.ZIndex = 9
	cta.Parent = inner
	local ctaCorner = Instance.new("UICorner") ctaCorner.CornerRadius = UDim.new(1, 0) ctaCorner.Parent = cta
	local ctaStroke = Instance.new("UIStroke") ctaStroke.Color = accent ctaStroke.Thickness = (style == "pass") and 2 or 2 ctaStroke.Transparency = 0.15 ctaStroke.Parent = cta
	if style == "pass" then
		cta.FontFace = Font.new("rbxasset://fonts/families/RobotoMono.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
		cta.TextSize = 20
	else
		setFont(cta, Enum.FontWeight.Bold, 20)
	end

	cta.MouseEnter:Connect(function()
		if style == "cash" then
			tween(outer, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(outer.Position.X.Scale, outer.Position.X.Offset, outer.Position.Y.Scale, outer.Position.Y.Offset - 4)})
		else
			tween(bgStroke, TweenInfo.new(0.1), {Thickness = 4})
		end
		tween(cta, TweenInfo.new(0.12), {BackgroundColor3 = (style == "pass") and Color3.fromRGB(52,52,62) or blendTowardWhite(accent, 0.9)})
	end)
	cta.MouseLeave:Connect(function()
		if style == "cash" then
			tween(outer, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(outer.Position.X.Scale, outer.Position.X.Offset, outer.Position.Y.Scale, outer.Position.Y.Offset + 4)})
		else
			tween(bgStroke, TweenInfo.new(0.1), {Thickness = 3})
		end
		tween(cta, TweenInfo.new(0.12), {BackgroundColor3 = (style == "pass") and Color3.fromRGB(44,44,52) or blendTowardWhite(accent, 0.85)})
	end)
	cta.MouseButton1Click:Connect(function()
		if isPass then
			MarketplaceService:PromptGamePassPurchase(localPlayer, data.id)
		else
			MarketplaceService:PromptProductPurchase(localPlayer, data.id)
		end
	end)

	-- Alternate tilt for pass cards
	if style == "pass" and indexForAlt then
		outer.Rotation = (indexForAlt % 2 == 0) and 2.5 or -2.5
	end

	return outer
end

-- Grid page builder
local function buildGrid(parent: Frame, items: {any}, isPass: boolean, char: {badgeId: string?, accent: Color3?, accentAdjust: ((Color3) -> Color3)?, darkText: Color3?})
	for _, c in ipairs(parent:GetChildren()) do
		if c:IsA("ScrollingFrame") then c:Destroy() end
	end
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -32, 1, -32)
	scroll.Position = UDim2.new(0, 16, 0, 16)
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 8
	scroll.ScrollBarImageColor3 = theme.scrollbar
	scroll.ZIndex = 6
	scroll.Parent = parent
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(0, CARD_W, 0, CARD_H)
	grid.CellPadding = UDim2.new(0, 16, 0, 16)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = scroll

	for idx, item in ipairs(items) do
		local accent = char.accent or item.color
		if char.accentAdjust then accent = char.accentAdjust(accent) end
		local styleName = isPass and "pass" or "cash"
		local card = makeStickerCard(char.badgeId or "rbxassetid://0", accent, item, isPass, char.darkText, styleName, idx)
		card.Parent = scroll
	end
	-- update canvas size after render
	task.delay(0.05, function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, grid.AbsoluteContentSize.Y + 16)
	end)
end

-- Pages content
-- Home hero (bigger)
local hero: Frame
local heroBadge: ImageLabel
local heroTitle: TextLabel
local heroDesc: TextLabel
local heroCTA: TextButton
local heroCTAStroke: UIStroke

local function buildHero(parent: Frame)
	hero = Instance.new("Frame")
	hero.Name = "Hero"
	hero.Size = UDim2.new(1, -24, 0, 220)
	hero.Position = UDim2.new(0, 12, 0, 0)
	hero.BackgroundColor3 = theme.panelAlt
	hero.BorderSizePixel = 0
	hero.ZIndex = 6
	hero.Parent = parent

	local heroCorner = Instance.new("UICorner") heroCorner.CornerRadius = UDim.new(0, 18) heroCorner.Parent = hero
	local heroStroke = Instance.new("UIStroke") heroStroke.Color = theme.stroke heroStroke.Thickness = 1 heroStroke.Parent = hero

	heroBadge = Instance.new("ImageLabel")
	heroBadge.BackgroundTransparency = 1
	heroBadge.Size = UDim2.new(0, 72, 0, 72)
	heroBadge.Position = UDim2.new(0, 24, 0.5, -36)
	heroBadge.ZIndex = 7
	heroBadge.Parent = hero

	heroTitle = Instance.new("TextLabel")
	heroTitle.BackgroundTransparency = 1
	heroTitle.Position = UDim2.new(0, 116, 0, 34)
	heroTitle.Size = UDim2.new(1, -300, 0, 40)
	heroTitle.TextXAlignment = Enum.TextXAlignment.Left
	heroTitle.TextColor3 = theme.text
	heroTitle.ZIndex = 7
	heroTitle.Parent = hero
	setFont(heroTitle, Enum.FontWeight.SemiBold, 30)

	heroDesc = Instance.new("TextLabel")
	heroDesc.BackgroundTransparency = 1
	heroDesc.Position = UDim2.new(0, 116, 0, 78)
	heroDesc.Size = UDim2.new(1, -300, 0, 30)
	heroDesc.TextXAlignment = Enum.TextXAlignment.Left
	heroDesc.TextColor3 = theme.subtext
	heroDesc.ZIndex = 7
	heroDesc.Parent = hero
	setFont(heroDesc, Enum.FontWeight.Regular, 20)

	heroCTA = Instance.new("TextButton")
	heroCTA.BackgroundColor3 = theme.panel
	heroCTA.AutoButtonColor = false
	heroCTA.Size = UDim2.new(0, 200, 0, 52)
	heroCTA.Position = UDim2.new(1, -220, 0.5, -26)
	heroCTA.Text = "Get"
	heroCTA.TextColor3 = theme.text
	heroCTA.ZIndex = 8
	heroCTA.Parent = hero
	local heroCTACorner = Instance.new("UICorner") heroCTACorner.CornerRadius = UDim.new(1, 0) heroCTACorner.Parent = heroCTA
	heroCTAStroke = Instance.new("UIStroke") heroCTAStroke.Color = theme.stroke heroCTAStroke.Thickness = 1 heroCTAStroke.Parent = heroCTA
	setFont(heroCTA, Enum.FontWeight.Bold, 22)
end

-- Build pages
buildHero(pageHome)

-- Home tab: subtle bow pattern background
if ASSETS.hkBowPattern ~= "rbxassetid://0" then
	local homePattern = Instance.new("ImageLabel")
	homePattern.Name = "HomePattern"
	homePattern.BackgroundTransparency = 1
	homePattern.Image = ASSETS.hkBowPattern
	homePattern.ImageColor3 = Color3.fromRGB(215,215,215)
	homePattern.ImageTransparency = 0.85
	homePattern.ScaleType = Enum.ScaleType.Tile
	homePattern.TileSize = UDim2.fromOffset(96,96)
	homePattern.Size = UDim2.new(1, 0, 1, 0)
	homePattern.ZIndex = 5
	homePattern.Parent = pageHome
end

-- Upgrade banner textures (plaid + bow)
if ASSETS.bannerPlaid ~= "rbxassetid://0" then
	local plaid = Instance.new("ImageLabel")
	plaid.BackgroundTransparency = 1
	plaid.Image = ASSETS.bannerPlaid
	plaid.ImageTransparency = 0.92
	plaid.ScaleType = Enum.ScaleType.Tile
	plaid.TileSize = UDim2.fromOffset(80,80)
	plaid.Size = UDim2.new(1, 0, 1, 0)
	plaid.ZIndex = 6
	plaid.Parent = hero
end
if ASSETS.hkBowLarge ~= "rbxassetid://0" then
	local bigBow = Instance.new("ImageLabel")
	bigBow.BackgroundTransparency = 1
	bigBow.Image = ASSETS.hkBowLarge
	bigBow.Size = UDim2.new(0, 110, 0, 110)
	bigBow.Position = UDim2.new(1, -120, 0, 10)
	bigBow.ZIndex = 7
	bigBow.Parent = hero
end

-- Home: Kitty's Favorites horizontal list
local function buildTopPicks(parent: Frame)
	local y = hero.AbsoluteSize.Y + 16
	local section = Instance.new("Frame")
	section.Name = "TopPicks"
	section.BackgroundTransparency = 1
	section.Size = UDim2.new(1, -24, 0, 200)
	section.Position = UDim2.new(0, 12, 0, 236)
	section.ZIndex = 6
	section.Parent = parent
	local titleLbl = Instance.new("TextLabel")
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = "Kitty's Favorites"
	titleLbl.TextColor3 = theme.text
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Position = UDim2.new(0, 0, 0, 0)
	titleLbl.Size = UDim2.new(1, 0, 0, 26)
	setFont(titleLbl, Enum.FontWeight.SemiBold, 22)
	titleLbl.Parent = section
	local scroll = Instance.new("ScrollingFrame")
	scroll.BackgroundTransparency = 1
	scroll.Size = UDim2.new(1, 0, 1, -28)
	scroll.Position = UDim2.new(0, 0, 0, 28)
	scroll.ScrollBarThickness = 6
	scroll.ScrollingDirection = Enum.ScrollingDirection.X
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.ZIndex = 6
	scroll.Parent = section
	local list = Instance.new("UIListLayout") list.FillDirection = Enum.FillDirection.Horizontal list.Padding = UDim.new(0, 12) list.Parent = scroll
	local pad = Instance.new("UIPadding") pad.PaddingLeft = UDim.new(0, 6) pad.Parent = scroll
	local picks = {}
	for i = 1, math.min(2, #shopData.cash) do table.insert(picks, {item=shopData.cash[i], isPass=false}) end
	for i = 1, math.min(2, #shopData.gamepasses) do table.insert(picks, {item=shopData.gamepasses[i], isPass=true}) end
	for idx, p in ipairs(picks) do
		local styleName = p.isPass and "pass" or "cash"
		local accent = p.item.color
		local badgeId = p.isPass and ASSETS.badgeKuromi or ASSETS.badgeCinna
		local card = makeStickerCard(badgeId, accent, p.item, p.isPass, nil, styleName, idx)
		card.Parent = scroll
	end
	task.delay(0.05, function()
		scroll.CanvasSize = UDim2.new(0, list.AbsoluteContentSize.X + 12, 0, 0)
	end)
end

buildTopPicks(pageHome)

local charCinna  = { badgeId = ASSETS.badgeCinna,  accent = theme.cinnaSky }
local charKuromi = { badgeId = ASSETS.badgeKuromi, accentAdjust = function(_) return theme.kuromiLav end, darkText = theme.kuromiInk }

buildGrid(pageCash, shopData.cash, false, charCinna)
buildGrid(pagePass, shopData.gamepasses, true, charKuromi)

-- Hero rotation from all items
local heroRot = {}
for _, item in ipairs(shopData.cash) do
	table.insert(heroRot, {
		badge = ASSETS.badgeCinna,
		title = item.name,
		desc = "Quick boost to help you progress",
		color = item.color or theme.cinnaSky,
		ref = {id = item.id, isPass = false},
	})
end
for _, item in ipairs(shopData.gamepasses) do
	table.insert(heroRot, {
		badge = ASSETS.badgeKuromi,
		title = item.name,
		desc = "Upgrade your power, permanently",
		color = item.color or theme.kuromiLav,
		ref = {id = item.id, isPass = true},
	})
end

local heroConn: RBXScriptConnection? = nil
local hIdx = 1

local function setHero(idx: number)
	local h = heroRot[idx]
	heroBadge.Image = h.badge
	heroTitle.Text = h.title
	heroTitle.TextColor3 = theme.text
	heroDesc.Text = h.desc
	heroDesc.TextColor3 = theme.subtext
	heroCTA.TextColor3 = h.color
	heroCTA.BackgroundColor3 = blendTowardWhite(h.color, 0.9)
	heroCTAStroke.Color = h.color

	if heroConn then heroConn:Disconnect() heroConn = nil end
	heroConn = heroCTA.MouseButton1Click:Connect(function()
		if h.ref.isPass then
			MarketplaceService:PromptGamePassPurchase(localPlayer, h.ref.id)
		else
			MarketplaceService:PromptProductPurchase(localPlayer, h.ref.id)
		end
	end)
end

setHero(hIdx)

task.spawn(function()
	while true do
		task.wait(4.6)
		hIdx = (hIdx % #heroRot) + 1
		tween(hero, TweenInfo.new(0.18), {BackgroundTransparency = 0.2})
		setHero(hIdx)
		tween(hero, TweenInfo.new(0.18), {BackgroundTransparency = 0})
	end
end)

-- Standalone Hello Kitty Talker (bottom-left, independent)
local function createHKTalkerStandalone(rootGui: ScreenGui)
	local messagesGeneral = {
		"Taking a little break? 🎀",
		"So many friendly choices here!",
		"Find a favorite yet? Everything is super cute!",
		"Hello! I love how cozy it feels here. 🌸",
		"Shopping with friends is the best! 💖",
	}
	local messagesCash = {
		"Apples are my favorite, but cash is useful too! 🍎",
		"A little boost can help when you need it most. 🎀",
		"Treat yourself to a small top-up — you earned it!",
		"Shiny coins make adventures easier! ✨",
		"Just a sprinkle of cash can help a lot! 💫",
	}
	local messagesPass = {
		"Upgrades make everything extra special! ✨",
		"Feeling brave? Try a power-up! 👀",
		"Perks make every day more fun!",
		"A little upgrade can go a long way! 🌟",
		"VIP is super comfy — like a warm hug! ☁️",
	}

	local container = Instance.new("Frame")
	container.Name = "HKTalker"
	container.Size = UDim2.new(0, 500, 0, 150)
	container.AnchorPoint = Vector2.new(0, 1)
	container.Position = UDim2.new(0, 20, 1, -20)
	container.BackgroundTransparency = 1
	container.Visible = false
	container.ZIndex = 100
	container.Parent = rootGui

	local portrait = Instance.new("ImageLabel")
	portrait.Name = "Portrait"
	portrait.BackgroundColor3 = theme.panel
	portrait.Image = ASSETS.hkPortrait
	portrait.Size = UDim2.new(0, 64, 0, 64)
	portrait.Position = UDim2.new(0, 0, 1, -64)
	portrait.AnchorPoint = Vector2.new(0, 1)
	portrait.BorderSizePixel = 0
	portrait.Visible = false
	portrait.ZIndex = 101
	portrait.Parent = container
	local portraitCorner = Instance.new("UICorner") portraitCorner.CornerRadius = UDim.new(1, 0) portraitCorner.Parent = portrait
	local portraitStroke = Instance.new("UIStroke") portraitStroke.Color = theme.kitty portraitStroke.Thickness = 2 portraitStroke.Parent = portrait

	local group = Instance.new("Frame")
	group.Name = "BubbleGroup"
	group.BackgroundTransparency = 1
	group.Size = UDim2.new(0, 410, 0, 130)
	group.Position = UDim2.new(0, 76, 1, 0)
	group.AnchorPoint = Vector2.new(0, 1)
	group.Visible = false
	group.ZIndex = 101
	group.Parent = container

	local shadow = Instance.new("ImageLabel")
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://6015897843"
	shadow.ImageTransparency = 0.75
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(49, 49, 450, 450)
	shadow.Size = UDim2.new(1, 22, 1, 22)
	shadow.Position = UDim2.new(0, -8, 0, -6)
	shadow.ZIndex = 100
	shadow.Parent = group

	local bubble = Instance.new("Frame")
	bubble.Name = "Bubble"
	bubble.BackgroundColor3 = theme.panel
	bubble.BorderSizePixel = 0
	bubble.Size = UDim2.new(1, -8, 1, -8)
	bubble.Position = UDim2.new(0, 0, 0, 0)
	bubble.ZIndex = 101
	bubble.Parent = group
	local bubbleCorner = Instance.new("UICorner") bubbleCorner.CornerRadius = UDim.new(0, 18) bubbleCorner.Parent = bubble
	local bubbleStroke = Instance.new("UIStroke") bubbleStroke.Color = theme.stroke bubbleStroke.Thickness = 1 bubbleStroke.Parent = bubble

	local tail = Instance.new("Frame")
	tail.Name = "Tail"
	tail.Size = UDim2.new(0, 16, 0, 16)
	tail.Position = UDim2.new(0, -7, 1, -30)
	tail.AnchorPoint = Vector2.new(0, 0)
	tail.BackgroundColor3 = theme.panel
	tail.BorderSizePixel = 0
	tail.Rotation = 45
	tail.ZIndex = 101
	tail.Parent = bubble
	local tailCorner = Instance.new("UICorner") tailCorner.CornerRadius = UDim.new(0, 4) tailCorner.Parent = tail
	local tailStroke = Instance.new("UIStroke") tailStroke.Color = theme.stroke tailStroke.Thickness = 1 tailStroke.Parent = tail

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Text"
	textLabel.BackgroundTransparency = 1
	textLabel.TextWrapped = true
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Top
	textLabel.Size = UDim2.new(1, -26, 1, -30)
	textLabel.Position = UDim2.new(0, 16, 0, 16)
	textLabel.TextColor3 = theme.text
	textLabel.ZIndex = 102
	textLabel.Parent = bubble
	setFont(textLabel, Enum.FontWeight.Regular, 19)

	local xBtn = Instance.new("TextButton")
	xBtn.Name = "Close"
	xBtn.BackgroundTransparency = 1
	xBtn.Size = UDim2.new(0, 28, 0, 28)
	xBtn.Position = UDim2.new(1, -36, 0, 6)
	xBtn.Text = ""
	xBtn.ZIndex = 103
	xBtn.Parent = bubble
	local xIcon = Instance.new("ImageLabel")
	xIcon.BackgroundTransparency = 1
	xIcon.Image = ASSETS.iconCloseX
	xIcon.ImageColor3 = Color3.fromRGB(50, 50, 50)
	xIcon.Size = UDim2.new(0, 20, 0, 20)
	xIcon.Position = UDim2.new(0.5, -10, 0.5, -10)
	xIcon.ZIndex = 104
	xIcon.Parent = xBtn

	-- Breathing
	task.spawn(function()
		while true do
			if portrait.Visible then
				tween(portrait, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.new(0, 66, 0, 66)})
				task.wait(1.2)
				tween(portrait, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = UDim2.new(0, 64, 0, 64)})
				task.wait(1.2)
			else
				task.wait(0.2)
			end
		end
	end)

	local showing = false
	local typeToken = 0
	local hideToken = 0

	local function pick(context: string): string
		if context == "cash" then
			return messagesCash[math.random(1, #messagesCash)]
		elseif context == "pass" then
			return messagesPass[math.random(1, #messagesPass)]
		else
			return messagesGeneral[math.random(1, #messagesGeneral)]
		end
	end

	local function typeText(full: string, speed: number)
		typeToken += 1
		local tok = typeToken
		textLabel.Text = ""
		for i = 1, #full do
			if tok ~= typeToken then return end
			textLabel.Text = string.sub(full, 1, i)
			task.wait(speed)
		end
	end

	local function hide()
		if not showing then return end
		showing = false
		typeToken += 1
		hideToken += 1
		tween(textLabel, TweenInfo.new(0.1), {TextTransparency = 1})
		tween(group, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 320, 0, 90)})
		tween(portrait, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), ImageTransparency = 1})
		task.wait(0.18)
		container.Visible = false
		portrait.Visible = false
		group.Visible = false
		textLabel.TextTransparency = 0
		portrait.Size = UDim2.new(0, 64, 0, 64)
	end

	xBtn.MouseButton1Click:Connect(hide)

	local function show(context: string)
		local msg = pick(context)
		container.Visible = true
		portrait.Visible = true
		group.Visible = true
		portrait.ImageTransparency = 0
		portrait.Size = UDim2.new(0, 0, 0, 0)
		group.Size = UDim2.new(0, 10, 0, 10)
		textLabel.Text = ""
		showing = true

		tween(portrait, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 64, 0, 64)})
		task.delay(0.06, function()
			tween(group, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 410, 0, 130)})
		end)
		task.delay(0.16, function()
			typeText(msg, 0.03)
		end)

		hideToken += 1
		local myToken = hideToken
		task.delay(6, function()
			if myToken ~= hideToken then return end
			-- auto hide after 6s
			hide()
		end)
	end

	-- Optional: periodic auto messages while panel is visible
	local autoConn = nil
	local function startAuto(getVisible: () -> boolean, getContext: () -> string, getOpenSeconds: () -> number)
		if autoConn then autoConn:Disconnect() autoConn = nil end
		autoConn = game:GetService("RunService").Heartbeat:Connect(function()
			local now = tick()
			local last = (container:GetAttribute("_last") or 0) :: number
			local interval = (container:GetAttribute("_interval") or 120) :: number
			local visible = getVisible()
			local openSecs = getOpenSeconds()
			-- Reset arming when not visible
			if not visible then
				container:SetAttribute("_last", 0)
				container:SetAttribute("_interval", 120)
				return
			end
			-- Require at least 120s since opening before first message
			if openSecs < 120 then return end
			-- First message exactly after gating
			if last == 0 then
				local ctx = getContext()
				show(ctx)
				container:SetAttribute("_last", now)
				container:SetAttribute("_interval", math.random(120, 210))
				return
			end
			if now - last >= interval then
				local ctx = getContext()
				show(ctx)
				container:SetAttribute("_last", now)
				container:SetAttribute("_interval", math.random(120, 210))
			end
		end)
	end

	return {
		Show = show,
		Hide = hide,
		StartAuto = startAuto,
	}
end

local hkTalker = createHKTalkerStandalone(screenGui)

-- Toggle button
local toggleBtn = Instance.new("ImageButton")
	toggleBtn.Name = "ShopToggle"
	toggleBtn.AnchorPoint = Vector2.new(1, 1)
	toggleBtn.Size = UDim2.new(0, 156, 0, 50)
	toggleBtn.Position = UDim2.new(1, -16, 1, -16)
	toggleBtn.BackgroundColor3 = theme.panel
	toggleBtn.AutoButtonColor = false
	toggleBtn.Image = ""
	toggleBtn.ZIndex = 10
	toggleBtn.Parent = screenGui
local toggleCorner = Instance.new("UICorner") toggleCorner.CornerRadius = UDim.new(1, 0) toggleCorner.Parent = toggleBtn
local toggleStroke = Instance.new("UIStroke") toggleStroke.Color = theme.stroke toggleStroke.Thickness = 1 toggleStroke.Parent = toggleBtn

local toggleIcon = Instance.new("ImageLabel")
	toggleIcon.BackgroundTransparency = 1
	toggleIcon.Image = (ASSETS.badgeHello ~= "rbxassetid://0") and ASSETS.badgeHello or ASSETS.iconBag
	toggleIcon.Size = UDim2.new(0, 22, 0, 22)
	toggleIcon.Position = UDim2.new(0, 12, 0.5, -11)
	toggleIcon.ImageColor3 = (ASSETS.badgeHello ~= "rbxassetid://0") and theme.kitty or theme.text
	toggleIcon.ZIndex = 11
	toggleIcon.Parent = toggleBtn

local toggleText = Instance.new("TextLabel")
	toggleText.BackgroundTransparency = 1
	toggleText.Size = UDim2.new(1, -50, 1, 0)
	toggleText.Position = UDim2.new(0, 44, 0, 0)
	toggleText.Text = "Shop"
	toggleText.TextColor3 = theme.text
	toggleText.TextXAlignment = Enum.TextXAlignment.Left
	toggleText.ZIndex = 11
	toggleText.Parent = toggleBtn
setFont(toggleText, Enum.FontWeight.SemiBold, 20)

-- Tabs logic
local currentTab = "Home"
local currentContext = "general"
local shopOpenAt = 0

local function selectTab(name: string)
	styleTabIdle(tabHome)
	styleTabIdle(tabCash)
	styleTabIdle(tabPass)

	if name == "Home" then
		styleTabSelected(tabHome, theme.kitty)
		showOnly(pageHome)
		currentTab = "Home"
		currentContext = "general"
	elseif name == "Cash" then
		styleTabSelected(tabCash, theme.cinnaSky)
		showOnly(pageCash)
		currentTab = "Cash"
		currentContext = "cash"
	elseif name == "Pass" then
		styleTabSelected(tabPass, theme.kuromiLav)
		showOnly(pagePass)
		currentTab = "Pass"
		currentContext = "pass"
	end
	-- removed immediate HK talker ping on tab switch
end

selectTab("Home")

tabHome.MouseButton1Click:Connect(function() selectTab("Home") end)

tabCash.MouseButton1Click:Connect(function() selectTab("Cash") end)

tabPass.MouseButton1Click:Connect(function() selectTab("Pass") end)

-- Show / Hide
local isAnimating = false

local function showShop()
	if isAnimating or panel.Visible then return end
	isAnimating = true
	toggleBtn.Visible = false
	dim.Visible = true
	panel.Visible = true
	dim.BackgroundTransparency = 1
	panel.Position = UDim2.new(0.5, -490, 0.52, -430)
	panel.Size = UDim2.new(0, 960, 0, 830)
	shopOpenAt = tick()

	tween(dim, TweenInfo.new(0.22), {BackgroundTransparency = 0.2})
	tween(blur, TweenInfo.new(0.22), {Size = 8})
	tween(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, -490, 0.5, -430),
		Size = UDim2.new(0, 980, 0, 860),
	})

	selectTab(currentTab)
	-- do not show talker immediately; StartAuto handles gating
	isAnimating = false
end

local function hideShop()
	if isAnimating or not panel.Visible then return end
	isAnimating = true
	hkTalker.Hide()
	tween(dim, TweenInfo.new(0.2), {BackgroundTransparency = 1})
	tween(blur, TweenInfo.new(0.2), {Size = 0})
	tween(panel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, -490, 0.53, -430),
		Size = UDim2.new(0, 960, 0, 830),
	})
	task.wait(0.2)
	dim.Visible = false
	panel.Visible = false
	shopOpenAt = 0
	toggleBtn.Visible = true
	isAnimating = false
end

-- Wiring

toggleBtn.MouseButton1Click:Connect(showShop)
closeBtn.MouseButton1Click:Connect(hideShop)

-- Hovers

toggleBtn.MouseEnter:Connect(function()
	tween(toggleBtn, TweenInfo.new(0.12), {Size = UDim2.new(0, 164, 0, 54)})
end)

toggleBtn.MouseLeave:Connect(function()
	tween(toggleBtn, TweenInfo.new(0.14), {Size = UDim2.new(0, 156, 0, 50)})
end)

closeBtn.MouseEnter:Connect(function()
	tween(closeIcon, TweenInfo.new(0.08), {ImageColor3 = Color3.fromRGB(25, 25, 25)})
end)

closeBtn.MouseLeave:Connect(function()
	tween(closeIcon, TweenInfo.new(0.1), {ImageColor3 = Color3.new(0, 0, 0)})
end)

-- Hotkey (M)
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.M then
		if panel.Visible then hideShop() else showShop() end
	end
end)

-- Start periodic talker messages while shop is visible (with 2-minute gating and random long intervals)
hkTalker.StartAuto(
	function() return panel.Visible end,
	function() return currentContext end,
	function() if panel.Visible and shopOpenAt > 0 then return tick() - shopOpenAt else return 0 end end
)

print("🧷 Tabbed Sanrio Shop v2 loaded (Upscaled + Strong Theming + Standalone HK Talker; HK waits 2 min)")