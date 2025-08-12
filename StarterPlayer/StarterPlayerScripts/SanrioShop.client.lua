--[[
  🧷 Sanrio Character Takeover Shop – Polished Tabbed Layout
  - Home tab: Big hero at top, rotating through ALL items
  - Cash tab: Cinnamoroll-themed grid
  - Gamepasses tab: Kuromi-themed grid
  - Stable events, debounced show/hide, FontFace, robust Hello Kitty bubble
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
	tapeHello = "rbxassetid://0",
	tapeMelody = "rbxassetid://0",
	tapeKuromi = "rbxassetid://0",
	tapeCinna = "rbxassetid://0",

	badgeHello = "rbxassetid://0",
	badgeMelody = "rbxassetid://0",
	badgeKuromi = "rbxassetid://0",
	badgeCinna = "rbxassetid://0",

	iconCloseX = "rbxassetid://13516603909",
	iconBag    = "rbxassetid://6031280882",
	iconCash   = "rbxassetid://10709728059",
	iconPass   = "rbxassetid://10709727148",

	-- Hello Kitty portrait for the chat bubble (waving)
	hkPortrait = "rbxassetid://8399407671",
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
	melody   = Color3.fromRGB(255, 196, 214),
	kuromiLav= Color3.fromRGB(200, 190, 255),
	kuromiInk= Color3.fromRGB(38, 38, 46),
	cinnaSky = Color3.fromRGB(186, 214, 255),
	mint     = Color3.fromRGB(164, 234, 214),
	butter   = Color3.fromRGB(255, 221, 128),
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

-- Panel
local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.Size = UDim2.new(0, 740, 0, 720)
	panel.Position = UDim2.new(0.5, -370, 0.5, -360)
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
	header.Size = UDim2.new(1, -24, 0, 78)
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
	kittyBadge.Size = UDim2.new(0, 40, 0, 40)
	kittyBadge.Position = UDim2.new(0, 16, 0.5, -20)
	kittyBadge.ZIndex = 8
	kittyBadge.Parent = header

local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 64, 0, 0)
	title.Size = UDim2.new(1, -120, 1, 0)
	title.Text = "Sanrio Shop"
	title.TextColor3 = theme.text
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 8
	title.Parent = header
setFont(title, Enum.FontWeight.SemiBold, 30)

local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "Close"
	closeBtn.Size = UDim2.new(0, 36, 0, 36)
	closeBtn.Position = UDim2.new(1, -52, 0.5, -18)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = ""
	closeBtn.AutoButtonColor = false
	closeBtn.ZIndex = 9
	closeBtn.Parent = header

local closeIcon = Instance.new("ImageLabel")
	closeIcon.BackgroundTransparency = 1
	closeIcon.Image = ASSETS.iconCloseX
	closeIcon.ImageColor3 = Color3.new(0, 0, 0)
	closeIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	closeIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	closeIcon.Size = UDim2.new(0, 22, 0, 22)
	closeIcon.ZIndex = 9
	closeIcon.Parent = closeBtn

-- Tabs
local TABBAR_Y = 12 + 78 + 8
local tabBar = Instance.new("Frame")
	tabBar.Name = "TabBar"
	tabBar.Size = UDim2.new(1, -24, 0, 44)
	tabBar.Position = UDim2.new(0, 12, 0, TABBAR_Y)
	tabBar.BackgroundTransparency = 1
	tabBar.ZIndex = 7
	tabBar.Parent = panel

local tabsList = Instance.new("UIListLayout")
	tabsList.FillDirection = Enum.FillDirection.Horizontal
	tabsList.HorizontalAlignment = Enum.HorizontalAlignment.Left
	tabsList.VerticalAlignment = Enum.VerticalAlignment.Center
	tabsList.Padding = UDim.new(0, 8)
	tabsList.Parent = tabBar

local function makeTabButton(text: string)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 132, 1, 0)
	btn.BackgroundColor3 = theme.panel
	btn.AutoButtonColor = false
	btn.Text = text
	btn.TextColor3 = theme.text
	btn.ZIndex = 8
	setFont(btn, Enum.FontWeight.SemiBold, 18)
	local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1, 0) c.Parent = btn
	local s = Instance.new("UIStroke") s.Color = theme.stroke s.Thickness = 1 s.Parent = btn
	return btn
end

local tabHome = makeTabButton("Home")
local tabCash = makeTabButton("Cash")
local tabPass = makeTabButton("Gamepasses")

tabHome.Parent = tabBar
local spacer = Instance.new("Frame") spacer.Size = UDim2.new(0, 8, 1, 0) spacer.BackgroundTransparency = 1 spacer.Parent = tabBar

tabCash.Parent = tabBar
local spacer2 = Instance.new("Frame") spacer2.Size = UDim2.new(0, 8, 1, 0) spacer2.BackgroundTransparency = 1 spacer2.Parent = tabBar

tabPass.Parent = tabBar

local function styleTabSelected(btn: TextButton, accent: Color3)
	btn.TextColor3 = accent
	for _, c in ipairs(btn:GetChildren()) do
		if c:IsA("UIStroke") then c.Color = accent end
	end
	btn.BackgroundColor3 = blendTowardWhite(accent, 0.92)
end

local function styleTabIdle(btn: TextButton)
	btn.TextColor3 = theme.text
	for _, c in ipairs(btn:GetChildren()) do
		if c:IsA("UIStroke") then c.Color = theme.stroke end
	end
	btn.BackgroundColor3 = theme.panel
end

-- Pages container
local CONTENT_TOP = TABBAR_Y + 44 + 8
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

-- Sticker Card
local function makeStickerCard(charBadgeId: string, accent: Color3, data: any, isPass: boolean, nameTextColor: Color3?)
	local outer = Instance.new("Frame")
	outer.Size = UDim2.new(0, 230, 0, 140)
	outer.BackgroundColor3 = Color3.new(1, 1, 1)
	outer.BorderSizePixel = 0
	outer.ZIndex = 6
	local outerCorner = Instance.new("UICorner") outerCorner.CornerRadius = UDim.new(0, 20) outerCorner.Parent = outer
	local outerShadow = Instance.new("ImageLabel")
	outerShadow.BackgroundTransparency = 1
	outerShadow.Image = "rbxassetid://6015897843"
	outerShadow.ImageTransparency = 0.78
	outerShadow.ScaleType = Enum.ScaleType.Slice
	outerShadow.SliceCenter = Rect.new(49, 49, 450, 450)
	outerShadow.Size = UDim2.new(1, 24, 1, 24)
	outerShadow.Position = UDim2.new(0, -12, 0, -8)
	outerShadow.ZIndex = 5
	outerShadow.Parent = outer

	local inner = Instance.new("Frame")
	inner.Size = UDim2.new(1, -16, 1, -16)
	inner.Position = UDim2.new(0, 8, 0, 8)
	inner.BackgroundColor3 = theme.panelAlt
	inner.BorderSizePixel = 0
	inner.ZIndex = 6
	inner.Parent = outer
	local innerCorner = Instance.new("UICorner") innerCorner.CornerRadius = UDim.new(0, 16) innerCorner.Parent = inner
	local innerStroke = Instance.new("UIStroke") innerStroke.Color = theme.stroke innerStroke.Thickness = 1 innerStroke.Parent = inner

	local stripe = Instance.new("Frame")
	stripe.Size = UDim2.new(1, 0, 0, 5)
	stripe.BackgroundColor3 = accent
	stripe.BorderSizePixel = 0
	stripe.ZIndex = 6
	stripe.Parent = inner

	if charBadgeId ~= "rbxassetid://0" then
		local badge = Instance.new("ImageLabel")
		badge.BackgroundTransparency = 1
		badge.Image = charBadgeId
		badge.Size = UDim2.new(0, 24, 0, 24)
		badge.Position = UDim2.new(1, -30, 0, 8)
		badge.ZIndex = 7
		badge.Parent = inner
	end

	local icon = Instance.new("ImageLabel")
	icon.BackgroundTransparency = 1
	icon.Image = isPass and ASSETS.iconPass or ASSETS.iconCash
	icon.ImageColor3 = accent
	icon.Size = UDim2.new(0, 40, 0, 40)
	icon.Position = UDim2.new(0, 12, 0, 18)
	icon.ZIndex = 7
	icon.Parent = inner

	local name = Instance.new("TextLabel")
	name.BackgroundTransparency = 1
	name.Text = data.name
	name.TextColor3 = nameTextColor or theme.text
	name.TextXAlignment = Enum.TextXAlignment.Left
	name.Position = UDim2.new(0, 62, 0, 18)
	name.Size = UDim2.new(1, -74, 0, 22)
	name.ZIndex = 7
	name.Parent = inner
	setFont(name, Enum.FontWeight.SemiBold, 18)

	local sub = Instance.new("TextLabel")
	sub.BackgroundTransparency = 1
	sub.Text = isPass and "Gamepass" or "Cash Bundle"
	sub.TextColor3 = theme.subtext
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.Position = UDim2.new(0, 62, 0, 42)
	sub.Size = UDim2.new(1, -74, 0, 18)
	sub.ZIndex = 7
	sub.Parent = inner
	setFont(sub, Enum.FontWeight.Regular, 14)

	local cta = Instance.new("TextButton")
	cta.AutoButtonColor = false
	cta.Size = UDim2.new(0, 116, 0, 36)
	cta.Position = UDim2.new(0, 12, 1, -44)
	cta.BackgroundColor3 = blendTowardWhite(accent, 0.85)
	cta.Text = isPass and ("R$ " .. tostring(data.price)) or "Get"
	cta.TextColor3 = accent
	cta.ZIndex = 8
	cta.Parent = inner
	local ctaCorner = Instance.new("UICorner") ctaCorner.CornerRadius = UDim.new(1, 0) ctaCorner.Parent = cta
	local ctaStroke = Instance.new("UIStroke") ctaStroke.Color = accent ctaStroke.Thickness = 2 ctaStroke.Transparency = 0.15 ctaStroke.Parent = cta
	setFont(cta, Enum.FontWeight.Bold, 18)

	cta.MouseEnter:Connect(function()
		tween(cta, TweenInfo.new(0.12), {BackgroundColor3 = blendTowardWhite(accent, 0.9)})
	end)
	cta.MouseLeave:Connect(function()
		tween(cta, TweenInfo.new(0.12), {BackgroundColor3 = blendTowardWhite(accent, 0.85)})
	end)
	cta.MouseButton1Click:Connect(function()
		if isPass then
			MarketplaceService:PromptGamePassPurchase(localPlayer, data.id)
		else
			MarketplaceService:PromptProductPurchase(localPlayer, data.id)
		end
	end)

	return outer
end

-- Grid page builder
local function buildGrid(parent: Frame, items: {any}, isPass: boolean, char: {badgeId: string?, accent: Color3?, accentAdjust: ((Color3) -> Color3)?, darkText: Color3?})
	for _, c in ipairs(parent:GetChildren()) do if c:IsA("ScrollingFrame") then c:Destroy() end end
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, 0)
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 8
	scroll.ScrollBarImageColor3 = theme.scrollbar
	scroll.ZIndex = 6
	scroll.Parent = parent
	local pad = Instance.new("UIPadding") pad.PaddingTop = UDim.new(0, 6) pad.PaddingLeft = UDim.new(0, 6) pad.PaddingRight = UDim.new(0, 6) pad.PaddingBottom = UDim.new(0, 6) pad.Parent = scroll
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(0, 230, 0, 140)
	grid.CellPadding = UDim2.new(0, 12, 0, 12)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = scroll

	for _, item in ipairs(items) do
		local accent = char.accent or item.color
		if char.accentAdjust then accent = char.accentAdjust(accent) end
		local card = makeStickerCard(char.badgeId or "rbxassetid://0", accent, item, isPass, char.darkText)
		card.Parent = scroll
	end
	-- update canvas size after render
	task.delay(0.03, function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, grid.AbsoluteContentSize.Y + 12)
	end)
end

-- Pages content
-- Home hero (only element on Home)
local hero: Frame
local heroBadge: ImageLabel
local heroTitle: TextLabel
local heroDesc: TextLabel
local heroCTA: TextButton
local heroCTAStroke: UIStroke

local function buildHero(parent: Frame)
	hero = Instance.new("Frame")
	hero.Name = "Hero"
	hero.Size = UDim2.new(1, -24, 0, 156)
	hero.Position = UDim2.new(0, 12, 0, 0)
	hero.BackgroundColor3 = theme.panelAlt
	hero.BorderSizePixel = 0
	hero.ZIndex = 6
	hero.Parent = parent

	local heroCorner = Instance.new("UICorner") heroCorner.CornerRadius = UDim.new(0, 18) heroCorner.Parent = hero
	local heroStroke = Instance.new("UIStroke") heroStroke.Color = theme.stroke heroStroke.Thickness = 1 heroStroke.Parent = hero

	heroBadge = Instance.new("ImageLabel")
	heroBadge.BackgroundTransparency = 1
	heroBadge.Size = UDim2.new(0, 56, 0, 56)
	heroBadge.Position = UDim2.new(0, 18, 0.5, -28)
	heroBadge.ZIndex = 7
	heroBadge.Parent = hero

	heroTitle = Instance.new("TextLabel")
	heroTitle.BackgroundTransparency = 1
	heroTitle.Position = UDim2.new(0, 90, 0, 24)
	heroTitle.Size = UDim2.new(1, -240, 0, 32)
	heroTitle.TextXAlignment = Enum.TextXAlignment.Left
	heroTitle.TextColor3 = theme.text
	heroTitle.ZIndex = 7
	heroTitle.Parent = hero
	setFont(heroTitle, Enum.FontWeight.SemiBold, 26)

	heroDesc = Instance.new("TextLabel")
	heroDesc.BackgroundTransparency = 1
	heroDesc.Position = UDim2.new(0, 90, 0, 62)
	heroDesc.Size = UDim2.new(1, -240, 0, 26)
	heroDesc.TextXAlignment = Enum.TextXAlignment.Left
	heroDesc.TextColor3 = theme.subtext
	heroDesc.ZIndex = 7
	heroDesc.Parent = hero
	setFont(heroDesc, Enum.FontWeight.Regular, 18)

	heroCTA = Instance.new("TextButton")
	heroCTA.BackgroundColor3 = theme.panel
	heroCTA.AutoButtonColor = false
	heroCTA.Size = UDim2.new(0, 160, 0, 44)
	heroCTA.Position = UDim2.new(1, -176, 0.5, -22)
	heroCTA.Text = "Get"
	heroCTA.TextColor3 = theme.text
	heroCTA.ZIndex = 8
	heroCTA.Parent = hero
	local heroCTACorner = Instance.new("UICorner") heroCTACorner.CornerRadius = UDim.new(1, 0) heroCTACorner.Parent = heroCTA
	heroCTAStroke = Instance.new("UIStroke") heroCTAStroke.Color = theme.stroke heroCTAStroke.Thickness = 1 heroCTAStroke.Parent = heroCTA
	setFont(heroCTA, Enum.FontWeight.Bold, 20)
end

-- Build pages
buildHero(pageHome)

local charCinna  = { badgeId = ASSETS.badgeCinna,  accent = theme.cinnaSky }
local charKuromi = { badgeId = ASSETS.badgeKuromi, accentAdjust = function(_) return theme.kuromiLav end, darkText = theme.kuromiInk }

buildGrid(pageCash, shopData.cash, false, charCinna)
buildGrid(pagePass, shopData.gamepasses, true, charKuromi)

-- Hero rotation built from all items
local heroRot = {}
for _, item in ipairs(shopData.cash) do
	table.insert(heroRot, {
		badge = ASSETS.badgeCinna,
		title = item.name,
		desc = "Quick boost to help you progress",
		color = item.color or theme.cinnaSky,
		ref = {source = "cash", id = item.id, isPass = false},
	})
end
for _, item in ipairs(shopData.gamepasses) do
	table.insert(heroRot, {
		badge = ASSETS.badgeKuromi,
		title = item.name,
		desc = "Upgrade your power, permanently",
		color = item.color or theme.kuromiLav,
		ref = {source = "gamepasses", id = item.id, isPass = true},
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

-- Hello Kitty Bubble
local function createHelloKittyBubble(parentPanel: Frame)
	local messagesGeneral = {
		"Taking a little break? 🎀",
		"So many friendly choices here!",
		"Find a favorite yet? Everything is super cute!",
	}
	local messagesCash = {
		"Apples are my favorite, but cash is useful too! 🍎",
		"Sweet picks! A little boost goes a long way. 🎀",
	}
	local messagesPass = {
		"Upgrades make everything extra special! ✨",
		"Feeling brave? Try a power-up! 👀",
	}

	local container = Instance.new("Frame")
	container.Name = "HKBubble"
	container.Size = UDim2.new(0, 420, 0, 130)
	container.AnchorPoint = Vector2.new(0, 1)
	container.Position = UDim2.new(0, 16, 1, -16)
	container.BackgroundTransparency = 1
	container.Visible = false
	container.ZIndex = 20
	container.Parent = parentPanel

	local portrait = Instance.new("ImageLabel")
	portrait.Name = "Portrait"
	portrait.BackgroundColor3 = theme.panel
	portrait.Image = ASSETS.hkPortrait
	portrait.Size = UDim2.new(0, 56, 0, 56)
	portrait.Position = UDim2.new(0, 0, 1, -56)
	portrait.AnchorPoint = Vector2.new(0, 1)
	portrait.BorderSizePixel = 0
	portrait.Visible = false
	portrait.ZIndex = 21
	portrait.Parent = container
	local portraitCorner = Instance.new("UICorner") portraitCorner.CornerRadius = UDim.new(1, 0) portraitCorner.Parent = portrait
	local portraitStroke = Instance.new("UIStroke") portraitStroke.Color = theme.kitty portraitStroke.Thickness = 2 portraitStroke.Parent = portrait

	if ASSETS.hkPortrait == "rbxassetid://0" then
		local hkText = Instance.new("TextLabel")
		hkText.BackgroundTransparency = 1
		hkText.Size = UDim2.new(1, 0, 1, 0)
		hkText.Text = "HK"
		hkText.TextColor3 = theme.kitty
		hkText.ZIndex = 22
		hkText.Parent = portrait
		setFont(hkText, Enum.FontWeight.SemiBold, 18)
	end

	local group = Instance.new("Frame")
	group.Name = "BubbleGroup"
	group.BackgroundTransparency = 1
	group.Size = UDim2.new(0, 350, 0, 110)
	group.Position = UDim2.new(0, 60, 1, -8)
	group.AnchorPoint = Vector2.new(0, 1)
	group.Visible = false
	group.ZIndex = 21
	group.Parent = container

	local shadow = Instance.new("ImageLabel")
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://6015897843"
	shadow.ImageTransparency = 0.75
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(49, 49, 450, 450)
	shadow.Size = UDim2.new(1, 22, 1, 22)
	shadow.Position = UDim2.new(0, -8, 0, -6)
	shadow.ZIndex = 20
	shadow.Parent = group

	local bubble = Instance.new("Frame")
	bubble.Name = "Bubble"
	bubble.BackgroundColor3 = theme.panel
	bubble.BorderSizePixel = 0
	bubble.Size = UDim2.new(1, -8, 1, -8)
	bubble.Position = UDim2.new(0, 0, 0, 0)
	bubble.ZIndex = 21
	bubble.Parent = group
	local bubbleCorner = Instance.new("UICorner") bubbleCorner.CornerRadius = UDim.new(0, 18) bubbleCorner.Parent = bubble
	local bubbleStroke = Instance.new("UIStroke") bubbleStroke.Color = theme.stroke bubbleStroke.Thickness = 1 bubbleStroke.Parent = bubble

	local tail = Instance.new("Frame")
	tail.Name = "Tail"
	tail.Size = UDim2.new(0, 14, 0, 14)
	tail.Position = UDim2.new(0, -6, 1, -28)
	tail.AnchorPoint = Vector2.new(0, 0)
	tail.BackgroundColor3 = theme.panel
	tail.BorderSizePixel = 0
	tail.Rotation = 45
	tail.ZIndex = 21
	tail.Parent = bubble
	local tailCorner = Instance.new("UICorner") tailCorner.CornerRadius = UDim.new(0, 4) tailCorner.Parent = tail
	local tailStroke = Instance.new("UIStroke") tailStroke.Color = theme.stroke tailStroke.Thickness = 1 tailStroke.Parent = tail

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Text"
	textLabel.BackgroundTransparency = 1
	textLabel.TextWrapped = true
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Top
	textLabel.Size = UDim2.new(1, -20, 1, -24)
	textLabel.Position = UDim2.new(0, 16, 0, 14)
	textLabel.TextColor3 = theme.text
	textLabel.ZIndex = 22
	textLabel.Parent = bubble
	setFont(textLabel, Enum.FontWeight.Regular, 18)

	-- Breathing animation
	task.spawn(function()
		while true do
			if portrait.Visible then
				tween(portrait, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.new(0, 57, 0, 57)})
				task.wait(1.2)
				tween(portrait, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = UDim2.new(0, 56, 0, 56)})
				task.wait(1.2)
			else
				task.wait(0.2)
			end
		end
	end)

	local inputConnections: {RBXScriptConnection} = {}
	local showing = false
	local typewriterToken = 0

	local function disconnectInputs()
		for _, c in ipairs(inputConnections) do if c.Connected then c:Disconnect() end end
		table.clear(inputConnections)
	end

	local function typeText(full: string, speed: number)
		typewriterToken += 1
		local token = typewriterToken
		textLabel.Text = ""
		for i = 1, #full do
			if token ~= typewriterToken then return end
			textLabel.Text = string.sub(full, 1, i)
			task.wait(speed)
		end
	end

	local function hide()
		if not showing then return end
		showing = false
		typewriterToken += 1
		tween(textLabel, TweenInfo.new(0.12), {TextTransparency = 1})
		tween(group, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 280, 0, 90), Position = UDim2.new(0, 56, 1, -16)})
		task.wait(0.12)
		tween(group, TweenInfo.new(0.15), {BackgroundTransparency = 1})
		tween(bubble, TweenInfo.new(0.15), {BackgroundTransparency = 1})
		tween(shadow, TweenInfo.new(0.15), {ImageTransparency = 1})
		tween(portrait, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), ImageTransparency = 1})
		task.wait(0.18)
		container.Visible = false
		portrait.Visible = false
		textLabel.TextTransparency = 0
		bubble.BackgroundTransparency = 0
		shadow.ImageTransparency = 0.75
		portrait.Size = UDim2.new(0, 56, 0, 56)
		disconnectInputs()
	end

	local function pickMessage(context: string): string
		if context == "cash" then
			return messagesCash[math.random(1, #messagesCash)]
		elseif context == "pass" then
			return messagesPass[math.random(1, #messagesPass)]
		else
			return messagesGeneral[math.random(1, #messagesGeneral)]
		end
	end

	local function show(context: string)
		if showing then return end
		showing = true
		local msg = pickMessage(context)

		container.Visible = true
		portrait.Visible = true
		portrait.ImageTransparency = 0
		portrait.Size = UDim2.new(0, 0, 0, 0)

		group.Visible = true
		group.Size = UDim2.new(0, 10, 0, 10)
		group.Position = UDim2.new(0, 60, 1, -8)
		textLabel.TextTransparency = 0
		textLabel.Text = ""

		tween(portrait, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 56, 0, 56)})
		task.delay(0.08, function()
			tween(group, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 350, 0, 110)})
			tween(shadow, TweenInfo.new(0.2), {ImageTransparency = 0.7})
		end)
		task.delay(0.18, function()
			typeText(msg, 0.03)
		end)

		table.insert(inputConnections, UserInputService.InputBegan:Connect(function(_, gp)
			if gp then return end
			hide()
		end))
		table.insert(inputConnections, UserInputService.InputChanged:Connect(function(inp, gp)
			if gp then return end
			if inp.UserInputType == Enum.UserInputType.MouseMovement then hide() end
		end))
	end

	return { Show = show, Hide = hide }
end

local hkBubble = createHelloKittyBubble(panel)

-- Toggle button
local toggleBtn = Instance.new("ImageButton")
	toggleBtn.Name = "ShopToggle"
	toggleBtn.AnchorPoint = Vector2.new(1, 1)
	toggleBtn.Size = UDim2.new(0, 138, 0, 46)
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
	toggleIcon.Size = UDim2.new(0, 20, 0, 20)
	toggleIcon.Position = UDim2.new(0, 12, 0.5, -10)
	toggleIcon.ImageColor3 = (ASSETS.badgeHello ~= "rbxassetid://0") and theme.kitty or theme.text
	toggleIcon.ZIndex = 11
	toggleIcon.Parent = toggleBtn

local toggleText = Instance.new("TextLabel")
	toggleText.BackgroundTransparency = 1
	toggleText.Size = UDim2.new(1, -44, 1, 0)
	toggleText.Position = UDim2.new(0, 40, 0, 0)
	toggleText.Text = "Shop"
	toggleText.TextColor3 = theme.text
	toggleText.TextXAlignment = Enum.TextXAlignment.Left
	toggleText.ZIndex = 11
	toggleText.Parent = toggleBtn
setFont(toggleText, Enum.FontWeight.SemiBold, 18)

-- Tabs logic
local currentTab = "Home"
local currentContext = "general"

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
	dim.Visible = true
	panel.Visible = true
	dim.BackgroundTransparency = 1
	panel.Position = UDim2.new(0.5, -370, 0.52, -360)
	panel.Size = UDim2.new(0, 730, 0, 700)

	tween(dim, TweenInfo.new(0.22), {BackgroundTransparency = 0.2})
	tween(blur, TweenInfo.new(0.22), {Size = 8})
	tween(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, -370, 0.5, -360),
		Size = UDim2.new(0, 740, 0, 720),
	})

	-- Home default
	selectTab("Home")
	task.delay(0.6, function() hkBubble.Show(currentContext) end)
	isAnimating = false
end

local function hideShop()
	if isAnimating or not panel.Visible then return end
	isAnimating = true
	hkBubble.Hide()
	tween(dim, TweenInfo.new(0.2), {BackgroundTransparency = 1})
	tween(blur, TweenInfo.new(0.2), {Size = 0})
	tween(panel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, -370, 0.53, -360),
		Size = UDim2.new(0, 730, 0, 700),
	})
	task.wait(0.2)
	dim.Visible = false
	panel.Visible = false
	isAnimating = false
end

-- Wiring

toggleBtn.MouseButton1Click:Connect(showShop)
closeBtn.MouseButton1Click:Connect(hideShop)

-- Hovers

toggleBtn.MouseEnter:Connect(function()
	tween(toggleBtn, TweenInfo.new(0.12), {Size = UDim2.new(0, 144, 0, 48)})
end)

toggleBtn.MouseLeave:Connect(function()
	tween(toggleBtn, TweenInfo.new(0.14), {Size = UDim2.new(0, 138, 0, 46)})
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

print("🧷 Tabbed Sanrio Shop loaded (Home + Cash + Gamepasses)")