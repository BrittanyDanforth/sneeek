--[[
  🧷 Sanrio Character Takeover Shop – Sticker Book Edition + Built‑in Hello Kitty Chat Bubble (Polished)
  - Fonts use FontFace (no deprecated Enum.Font)
  - Stable hero CTA connections (no duplicate prompts)
  - Debounced show/hide, robust tween helpers
  - Consistent theming per section (Cinnamoroll for cash, Kuromi for passes)
  - Hello Kitty bubble z-ordering and typewriter cancellation fixed
]]

-- Services
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local localPlayer = Players.LocalPlayer

-- Utility: guarded tween (returns tween; safely handles missing instance)
local function tween(instance: Instance?, info: TweenInfo, props: {[string]: any})
	if not instance then return nil end
	local t = TweenService:Create(instance, info, props)
	t:Play()
	return t
end

-- Utility: modern font
local function setFont(guiObject: TextLabel | TextButton, weight: Enum.FontWeight, size: number)
	guiObject.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", weight, Enum.FontStyle.Normal)
	guiObject.TextSize = size
end

-- Utility: colors
local function blendTowardWhite(c: Color3, t: number): Color3
	return Color3.new(c.R + (1 - c.R) * t, c.G + (1 - c.G) * t, c.B + (1 - c.B) * t)
end

-- Lighting blur (singleton)
local function getBlur()
	local blur = Lighting:FindFirstChild("SanrioShopBlur")
	if blur and blur:IsA("BlurEffect") then return blur end
	blur = Instance.new("BlurEffect")
	blur.Name = "SanrioShopBlur"
	blur.Size = 0
	blur.Parent = Lighting
	return blur
end

-- Assets (replace if desired)
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

local specialsRefs = {
	{source = "cash", idx = 2, label = "Starter Boost"},
	{source = "gamepasses", idx = 1, label = "Top Pick"},
}

-- Root GUI
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

-- Main panel
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

-- Soft shadow
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

-- Close button
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

-- Washi header factory
local function makeTapeHeader(parent: Instance, text: string, tapeImage: string)
	local container = Instance.new("Frame")
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(1, -24, 0, 42)
	container.ZIndex = 7
	container.Parent = parent

	if tapeImage ~= "rbxassetid://0" then
		local tape = Instance.new("ImageLabel")
		tape.BackgroundTransparency = 1
		tape.Image = tapeImage
		tape.Size = UDim2.new(0, 180, 0, 28)
		tape.Position = UDim2.new(0, 8, 0, 2)
		tape.Rotation = math.random(-2, 2)
		tape.ImageTransparency = 0.1
		tape.ZIndex = 7
		tape.Parent = container
	end

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Position = UDim2.new(0, 16, 0, 0)
	lbl.Size = UDim2.new(1, -24, 1, 0)
	lbl.Text = text
	lbl.TextColor3 = theme.text
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 8
	lbl.Parent = container
	setFont(lbl, Enum.FontWeight.SemiBold, 22)

	return container
end

-- Hero banner
local hero = Instance.new("Frame")
	hero.Name = "Hero"
	hero.Size = UDim2.new(1, -24, 0, 156)
	hero.Position = UDim2.new(0, 12, 0, 102)
	hero.BackgroundColor3 = theme.panelAlt
	hero.BorderSizePixel = 0
	hero.ZIndex = 6
	hero.Parent = panel

local heroCorner = Instance.new("UICorner") heroCorner.CornerRadius = UDim.new(0, 18) heroCorner.Parent = hero
local heroStroke = Instance.new("UIStroke") heroStroke.Color = theme.stroke heroStroke.Thickness = 1 heroStroke.Parent = hero

local heroBadge = Instance.new("ImageLabel")
	heroBadge.BackgroundTransparency = 1
	heroBadge.Size = UDim2.new(0, 56, 0, 56)
	heroBadge.Position = UDim2.new(0, 18, 0.5, -28)
	heroBadge.ZIndex = 7
	heroBadge.Parent = hero

local heroTitle = Instance.new("TextLabel")
	heroTitle.BackgroundTransparency = 1
	heroTitle.Position = UDim2.new(0, 90, 0, 24)
	heroTitle.Size = UDim2.new(1, -240, 0, 32)
	heroTitle.TextXAlignment = Enum.TextXAlignment.Left
	heroTitle.TextColor3 = theme.text
	heroTitle.ZIndex = 7
	heroTitle.Parent = hero
setFont(heroTitle, Enum.FontWeight.SemiBold, 26)

local heroDesc = Instance.new("TextLabel")
	heroDesc.BackgroundTransparency = 1
	heroDesc.Position = UDim2.new(0, 90, 0, 62)
	heroDesc.Size = UDim2.new(1, -240, 0, 26)
	heroDesc.TextXAlignment = Enum.TextXAlignment.Left
	heroDesc.TextColor3 = theme.subtext
	heroDesc.ZIndex = 7
	heroDesc.Parent = hero
setFont(heroDesc, Enum.FontWeight.Regular, 18)

local heroCTA = Instance.new("TextButton")
	heroCTA.BackgroundColor3 = theme.panel
	heroCTA.AutoButtonColor = false
	heroCTA.Size = UDim2.new(0, 160, 0, 44)
	heroCTA.Position = UDim2.new(1, -176, 0.5, -22)
	heroCTA.Text = "Get"
	heroCTA.TextColor3 = theme.text
	heroCTA.ZIndex = 8
	heroCTA.Parent = hero
local heroCTACorner = Instance.new("UICorner") heroCTACorner.CornerRadius = UDim.new(1, 0) heroCTACorner.Parent = heroCTA
local heroCTAStroke = Instance.new("UIStroke") heroCTAStroke.Color = theme.stroke heroCTAStroke.Thickness = 1 heroCTAStroke.Parent = heroCTA
setFont(heroCTA, Enum.FontWeight.Bold, 20)

-- Content area
local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.new(1, -24, 1, -(102 + 156 + 24 + 18))
	content.Position = UDim2.new(0, 12, 0, 102 + 156 + 12)
	content.BackgroundTransparency = 1
	content.ZIndex = 6
	content.Parent = panel

-- Sections
local headerKitty = makeTapeHeader(content, "Specials (Hello Kitty)", ASSETS.tapeHello)

local kittyScroll = Instance.new("ScrollingFrame")
	kittyScroll.Name = "KittyScroll"
	kittyScroll.Size = UDim2.new(1, 0, 0, 160)
	kittyScroll.Position = UDim2.new(0, 0, 0, 42)
	kittyScroll.BackgroundTransparency = 1
	kittyScroll.ScrollBarThickness = 6
	kittyScroll.ScrollBarImageColor3 = theme.scrollbar
	kittyScroll.HorizontalScrollBarInset = Enum.ScrollBarInset.Always
	kittyScroll.ScrollingDirection = Enum.ScrollingDirection.X
	kittyScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	kittyScroll.ZIndex = 6
	kittyScroll.Parent = content
local kittyList = Instance.new("UIListLayout") kittyList.FillDirection = Enum.FillDirection.Horizontal kittyList.Padding = UDim.new(0, 12) kittyList.Parent = kittyScroll
local kittyPad = Instance.new("UIPadding") kittyPad.PaddingLeft = UDim.new(0, 6) kittyPad.Parent = kittyScroll

local melodyHeader = makeTapeHeader(content, "Cash Bundles (Cinnamoroll)", ASSETS.tapeCinna)
melodyHeader.Position = UDim2.new(0, 0, 0, 42 + 160 + 18)

local cashScroll = Instance.new("ScrollingFrame")
	cashScroll.Name = "CashScroll"
	cashScroll.Size = UDim2.new(1, 0, 0, 160)
	cashScroll.Position = UDim2.new(0, 0, 0, 42 + 160 + 18 + 42)
	cashScroll.BackgroundTransparency = 1
	cashScroll.ScrollBarThickness = 6
	cashScroll.ScrollBarImageColor3 = theme.scrollbar
	cashScroll.HorizontalScrollBarInset = Enum.ScrollBarInset.Always
	cashScroll.ScrollingDirection = Enum.ScrollingDirection.X
	cashScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	cashScroll.ZIndex = 6
	cashScroll.Parent = content
local cashList = Instance.new("UIListLayout") cashList.FillDirection = Enum.FillDirection.Horizontal cashList.Padding = UDim.new(0, 12) cashList.Parent = cashScroll
local cashPad = Instance.new("UIPadding") cashPad.PaddingLeft = UDim.new(0, 6) cashPad.Parent = cashScroll

local kuromiHeader = makeTapeHeader(content, "Gamepasses (Kuromi)", ASSETS.tapeKuromi)
kuromiHeader.Position = UDim2.new(0, 0, 0, 42 + 160 + 18 + 42 + 160 + 18)

local passScroll = Instance.new("ScrollingFrame")
	passScroll.Name = "PassScroll"
	passScroll.Size = UDim2.new(1, 0, 0, 160)
	passScroll.Position = UDim2.new(0, 0, 0, 42 + 160 + 18 + 42 + 160 + 18 + 42)
	passScroll.BackgroundTransparency = 1
	passScroll.ScrollBarThickness = 6
	passScroll.ScrollBarImageColor3 = theme.scrollbar
	passScroll.HorizontalScrollBarInset = Enum.ScrollBarInset.Always
	passScroll.ScrollingDirection = Enum.ScrollingDirection.X
	passScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	passScroll.ZIndex = 6
	passScroll.Parent = content
local passList = Instance.new("UIListLayout") passList.FillDirection = Enum.FillDirection.Horizontal passList.Padding = UDim.new(0, 12) passList.Parent = passScroll
local passPad = Instance.new("UIPadding") passPad.PaddingLeft = UDim.new(0, 6) passPad.Parent = passScroll

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

-- Sticker card
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

	outer.MouseEnter:Connect(function()
		outer.ZIndex = 9
		inner.ZIndex = 10
		tween(outer, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 1.5, Position = UDim2.new(outer.Position.X.Scale, outer.Position.X.Offset, outer.Position.Y.Scale, outer.Position.Y.Offset - 2)})
		tween(outerShadow, TweenInfo.new(0.14), {ImageTransparency = 0.65})
	end)
	outer.MouseLeave:Connect(function()
		tween(outer, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 0, Position = UDim2.new(outer.Position.X.Scale, outer.Position.X.Offset, outer.Position.Y.Scale, outer.Position.Y.Offset + 2)})
		tween(outerShadow, TweenInfo.new(0.14), {ImageTransparency = 0.78})
	end)

	return outer
end

-- Fill helpers
local function specialsFromRefs()
	local arr = {}
	for _, s in ipairs(specialsRefs) do
		local src = (s.source == "cash") and shopData.cash or shopData.gamepasses
		local item = src[s.idx]
		if item then
			local copy = {}
			for k, v in pairs(item) do copy[k] = v end
			copy.name = (s.label or "Special") .. ": " .. item.name
			copy.color = blendTowardWhite(copy.color, 0.15)
			table.insert(arr, copy)
		end
	end
	return arr
end

local function clearScroll(scroll: ScrollingFrame)
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
end

local function fillScroll(scroll: ScrollingFrame, list: UIListLayout, items: {any}, isPass: boolean, char: {badgeId: string?, accent: Color3?, accentAdjust: ((Color3) -> Color3)?, darkText: Color3?})
	clearScroll(scroll)
	for _, item in ipairs(items) do
		local accent = char.accent or item.color
		if char.accentAdjust then accent = char.accentAdjust(accent) end
		local card = makeStickerCard(char.badgeId or "rbxassetid://0", accent, item, isPass, char.darkText)
		card.Parent = scroll
	end
	task.wait()
	scroll.CanvasSize = UDim2.new(0, list.AbsoluteContentSize.X + 12, 0, 0)
end

-- Character themes per section
local charKitty  = { badgeId = ASSETS.badgeHello,  accent = theme.kitty }
local charCinna  = { badgeId = ASSETS.badgeCinna,  accent = theme.cinnaSky }
local charKuromi = { badgeId = ASSETS.badgeKuromi, accentAdjust = function(_) return theme.kuromiLav end, darkText = theme.kuromiInk }

local function populateAll()
	fillScroll(kittyScroll, kittyList, specialsFromRefs(), false, charKitty)
	fillScroll(cashScroll,  cashList,  shopData.cash,      false, charCinna)
	fillScroll(passScroll,  passList,  shopData.gamepasses, true,  charKuromi)
end

-- Hero rotation with single connection management
local heroRot = {
	{who = "Hello Kitty", badge = ASSETS.badgeHello,  title = "Welcome!",     desc = "Handpicked specials for you", color = theme.kitty,     ref = {source = "cash", idx = 2, isPass = false}},
	{who = "Cinnamoroll", badge = ASSETS.badgeCinna,  title = "Cash Treats",  desc = "Sweet bundles to boost you",  color = theme.cinnaSky,  ref = {source = "cash", idx = 4, isPass = false}},
	{who = "Kuromi",      badge = ASSETS.badgeKuromi, title = "Power Passes", desc = "Mischievous upgrades",        color = theme.kuromiLav, ref = {source = "gamepasses", idx = 1, isPass = true}},
}

local function refItemOf(ref)
	local src = (ref.source == "cash") and shopData.cash or shopData.gamepasses
	return src[ref.idx], ref.isPass
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
	local refItem, isPass = refItemOf(h.ref)
	heroConn = heroCTA.MouseButton1Click:Connect(function()
		if refItem then
			if isPass then
				MarketplaceService:PromptGamePassPurchase(localPlayer, refItem.id)
			else
				MarketplaceService:PromptProductPurchase(localPlayer, refItem.id)
			end
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

-- Hello Kitty Bubble (robust)
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

	-- Breathing animation (gentle)
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
		typewriterToken += 1 -- cancel typing
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

-- Hover context
local currentContext = "general"
kittyScroll.MouseEnter:Connect(function() currentContext = "general" end)
cashScroll.MouseEnter:Connect(function() currentContext = "cash" end)
passScroll.MouseEnter:Connect(function() currentContext = "pass" end)

-- Debounce show/hide
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

	populateAll()
	task.delay(0.7, function() hkBubble.Show(currentContext) end)
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

print("🧷 Shop + Hello Kitty Bubble loaded (polished)")