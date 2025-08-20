-- Money Shop Client Script (Sanrio-inspired UI, with polished Gamepasses)
-- Place in: StarterPlayer/StarterPlayerScripts/CreateMoneyShop.client.lua

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Sanrio-inspired design tokens (My Melody default theme)
local THEME = {
    Palette = {
        BackgroundPrimary = Color3.fromRGB(253, 242, 250),
        PanelFill = Color3.fromRGB(247, 214, 225),
        Accent = Color3.fromRGB(248, 189, 195),
        AccentDark = Color3.fromRGB(191, 141, 142),
        NeutralDark = Color3.fromRGB(30, 24, 26),
        White = Color3.fromRGB(255, 255, 255),
    },
    Typography = {
        Header = Enum.Font.Cartoon,
        Body = Enum.Font.Gotham,
        Button = Enum.Font.Cartoon,
    },
    Strokes = {
        DefaultThickness = 2,
        LineJoinMode = Enum.LineJoinMode.Round,
    },
    Motion = {
        Transition = 0.3,
        Quick = 0.15,
    },
}

-- Currency products (replace IDs)
local products = {
    {id = 3366419712, amount = 1000, icon = "★"},
    {id = 3366420012, amount = 5000, icon = "★★"},
    {id = 3366420478, amount = 10000, icon = "★★★"},
    {id = 3366420800, amount = 25000, icon = "MAX"},
}

-- Gamepasses
local PASS_2X_CASH = 1398974710
local gamepasses = {
    {id = PASS_2X_CASH, name = "2x Cash", icon = "💰", desc = "Double your tycoon cash."},
}

local function formatNumber(n)
    local formatted = tostring(n)
    while true do
        local nf, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        formatted = nf
        if k == 0 then break end
    end
    return formatted
end

-- Root
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MoneyShop_Sanrio"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local overlay = Instance.new("TextButton")
overlay.Name = "Overlay"
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.new(0, 0, 0)
overlay.BackgroundTransparency = 1
overlay.Text = ""
overlay.AutoButtonColor = false
overlay.Visible = false
overlay.Modal = false
overlay.ZIndex = 5
overlay.Parent = screenGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.fromScale(0.9, 0.8)
mainFrame.Position = UDim2.fromScale(0.5, 0.5)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = THEME.Palette.BackgroundPrimary
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.ZIndex = 10
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0.06, 0)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = THEME.Strokes.DefaultThickness
mainStroke.LineJoinMode = THEME.Strokes.LineJoinMode
mainStroke.Color = THEME.Palette.AccentDark
mainStroke.Transparency = 0.5
mainStroke.Parent = mainFrame

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, THEME.Palette.BackgroundPrimary:Lerp(THEME.Palette.White, 0.06)),
    ColorSequenceKeypoint.new(1, THEME.Palette.PanelFill)
}
gradient.Rotation = 90
gradient.Parent = mainFrame

local mainPadding = Instance.new("UIPadding")
mainPadding.PaddingTop = UDim.new(0, 12)
mainPadding.PaddingBottom = UDim.new(0, 12)
mainPadding.PaddingLeft = UDim.new(0, 12)
mainPadding.PaddingRight = UDim.new(0, 12)
mainPadding.Parent = mainFrame

-- Header + Tabs
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 72)
header.BackgroundTransparency = 1
header.ZIndex = 11
header.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 32)
title.Position = UDim2.new(0, 12, 0, 4)
title.BackgroundTransparency = 1
title.Text = "Shop"
title.TextColor3 = THEME.Palette.AccentDark
title.TextStrokeColor3 = THEME.Palette.White
title.TextStrokeTransparency = 0.7
title.Font = THEME.Typography.Header
title.TextSize = 30
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 11
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -60, 0, 20)
subtitle.Position = UDim2.new(0, 12, 0, 40)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Get a little boost — all cozy and cute!"
subtitle.TextColor3 = THEME.Palette.NeutralDark
subtitle.TextTransparency = 0.1
subtitle.TextStrokeTransparency = 1
subtitle.Font = THEME.Typography.Body
subtitle.TextSize = 18
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.ZIndex = 11
subtitle.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 44, 0, 44)
closeBtn.Position = UDim2.new(1, -56, 0, 14)
closeBtn.BackgroundColor3 = THEME.Palette.Accent
closeBtn.Text = "✕"
closeBtn.TextColor3 = THEME.Palette.White
closeBtn.Font = THEME.Typography.Button
closeBtn.TextSize = 20
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 12
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0.5, 0)
closeCorner.Parent = closeBtn

local tabs = Instance.new("Frame")
tabs.Name = "Tabs"
tabs.Size = UDim2.new(1, -24, 0, 36)
tabs.Position = UDim2.new(0, 12, 0, 72)
tabs.BackgroundTransparency = 1
tabs.ZIndex = 11
tabs.Parent = mainFrame

local function makeTabButton(text, x)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 120, 1, 0)
    b.Position = UDim2.new(0, x, 0, 0)
    b.BackgroundColor3 = THEME.Palette.PanelFill
    b.Text = text
    b.TextColor3 = THEME.Palette.NeutralDark
    b.Font = THEME.Typography.Button
    b.TextSize = 18
    b.AutoButtonColor = false
    local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0.3, 0) c.Parent = b
    local s = Instance.new("UIStroke") s.Thickness = THEME.Strokes.DefaultThickness s.Color = THEME.Palette.AccentDark s.Parent = b
    b.Parent = tabs
    return b
end

local currencyTabBtn = makeTabButton("Currency", 0)
local gamepassTabBtn = makeTabButton("Gamepasses", 132)

-- Currency container
local currencyList = Instance.new("ScrollingFrame")
currencyList.Name = "CurrencyContainer"
currencyList.Size = UDim2.new(1, 0, 1, -120)
currencyList.Position = UDim2.fromOffset(0, 112)
currencyList.BackgroundTransparency = 1
currencyList.ScrollBarThickness = 4
currencyList.ScrollBarImageColor3 = THEME.Palette.AccentDark
currencyList.BorderSizePixel = 0
currencyList.CanvasSize = UDim2.new(0, 0, 0, 0)
currencyList.ZIndex = 10
currencyList.Parent = mainFrame

local curPad = Instance.new("UIPadding")
curPad.PaddingTop = UDim.new(0, 12)
curPad.PaddingBottom = UDim.new(0, 12)
curPad.PaddingLeft = UDim.new(0, 12)
curPad.PaddingRight = UDim.new(0, 12)
curPad.Parent = currencyList

local curLayout = Instance.new("UIListLayout")
curLayout.SortOrder = Enum.SortOrder.LayoutOrder
curLayout.Padding = UDim.new(0, 12)
curLayout.FillDirection = Enum.FillDirection.Vertical
curLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
curLayout.Parent = currencyList

local function updateCurrencyCanvas()
    currencyList.CanvasSize = UDim2.new(0, 0, 0, curLayout.AbsoluteContentSize.Y + 24)
end
curLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCurrencyCanvas)

-- Gamepass container
local gpList = Instance.new("ScrollingFrame")
gpList.Name = "GamepassContainer"
gpList.Size = currencyList.Size
gpList.Position = currencyList.Position
gpList.BackgroundTransparency = 1
gpList.ScrollBarThickness = 4
gpList.ScrollBarImageColor3 = THEME.Palette.AccentDark
gpList.BorderSizePixel = 0
gpList.CanvasSize = UDim2.new(0, 0, 0, 0)
gpList.ZIndex = 10
gpList.Visible = false
gpList.Parent = mainFrame

local gpPad = Instance.new("UIPadding")
gpPad.PaddingTop = UDim.new(0, 12)
gpPad.PaddingBottom = UDim.new(0, 12)
gpPad.PaddingLeft = UDim.new(0, 12)
gpPad.PaddingRight = UDim.new(0, 12)
gpPad.Parent = gpList

local gpLayout = Instance.new("UIListLayout")
gpLayout.SortOrder = Enum.SortOrder.LayoutOrder
gpLayout.Padding = UDim.new(0, 12)
gpLayout.FillDirection = Enum.FillDirection.Vertical
gpLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
gpLayout.Parent = gpList

local function updateGpCanvas()
    gpList.CanvasSize = UDim2.new(0, 0, 0, gpLayout.AbsoluteContentSize.Y + 24)
end
gpLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateGpCanvas)

-- Renderers
local function renderCurrency()
    for _, child in ipairs(currencyList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    for i, product in ipairs(products) do
        local card = Instance.new("Frame")
        card.Name = "Product" .. i
        card.Size = UDim2.new(1, -8, 0, 96)
        card.BackgroundColor3 = THEME.Palette.PanelFill
        card.BorderSizePixel = 0
        card.LayoutOrder = i
        card.ZIndex = 10
        card.Parent = currencyList

        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0.12, 0)
        cardCorner.Parent = card

        local cardStroke = Instance.new("UIStroke")
        cardStroke.Thickness = THEME.Strokes.DefaultThickness
        cardStroke.Color = THEME.Palette.AccentDark
        cardStroke.Transparency = 0.4
        cardStroke.Parent = card

        local iconBg = Instance.new("Frame")
        iconBg.Size = UDim2.fromOffset(72, 72)
        iconBg.Position = UDim2.new(0, 12, 0.5, -36)
        iconBg.BackgroundColor3 = THEME.Palette.Accent
        iconBg.Parent = card

        local iconCorner = Instance.new("UICorner")
        iconCorner.CornerRadius = UDim.new(0.25, 0)
        iconCorner.Parent = iconBg

        local iconStroke = Instance.new("UIStroke")
        iconStroke.Thickness = THEME.Strokes.DefaultThickness
        iconStroke.Color = THEME.Palette.AccentDark
        iconStroke.Parent = iconBg

        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.fromScale(1, 1)
        icon.BackgroundTransparency = 1
        icon.Text = product.icon
        icon.TextColor3 = THEME.Palette.White
        icon.TextStrokeColor3 = THEME.Palette.AccentDark
        icon.TextStrokeTransparency = 0.4
        icon.Font = THEME.Typography.Header
        icon.TextSize = 28
        icon.Parent = iconBg

        local amountLabel = Instance.new("TextLabel")
        amountLabel.Size = UDim2.new(1, -220, 0, 28)
        amountLabel.Position = UDim2.new(0, 100, 0, 16)
        amountLabel.BackgroundTransparency = 1
        amountLabel.Text = formatNumber(product.amount) .. " Cash"
        amountLabel.TextColor3 = THEME.Palette.NeutralDark
        amountLabel.Font = THEME.Typography.Body
        amountLabel.TextSize = 20
        amountLabel.TextXAlignment = Enum.TextXAlignment.Left
        amountLabel.Parent = card

        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -220, 0, 20)
        desc.Position = UDim2.new(0, 100, 0, 48)
        desc.BackgroundTransparency = 1
        desc.Text = "Instant delivery"
        desc.TextColor3 = THEME.Palette.NeutralDark
        desc.TextTransparency = 0.15
        desc.Font = THEME.Typography.Body
        desc.TextSize = 16
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = card

        local buyBtn = Instance.new("TextButton")
        buyBtn.Size = UDim2.fromOffset(96, 44)
        buyBtn.Position = UDim2.new(1, -112, 0.5, -22)
        buyBtn.BackgroundColor3 = THEME.Palette.Accent
        buyBtn.Text = "Buy"
        buyBtn.TextColor3 = THEME.Palette.White
        buyBtn.Font = THEME.Typography.Button
        buyBtn.TextSize = 18
        buyBtn.AutoButtonColor = false
        buyBtn.ZIndex = 12
        buyBtn.Parent = card

        local buyCorner = Instance.new("UICorner")
        buyCorner.CornerRadius = UDim.new(0.5, 0)
        buyCorner.Parent = buyBtn

        local buyScale = Instance.new("UIScale")
        buyScale.Scale = 1
        buyScale.Parent = buyBtn

        buyBtn.MouseEnter:Connect(function()
            TweenService:Create(buyBtn, TweenInfo.new(THEME.Motion.Quick), {BackgroundColor3 = THEME.Palette.Accent:lerp(THEME.Palette.White, 0.08)}):Play()
            TweenService:Create(buyScale, TweenInfo.new(THEME.Motion.Quick), {Scale = 1.05}):Play()
        end)
        buyBtn.MouseLeave:Connect(function()
            TweenService:Create(buyBtn, TweenInfo.new(THEME.Motion.Quick), {BackgroundColor3 = THEME.Palette.Accent}):Play()
            TweenService:Create(buyScale, TweenInfo.new(THEME.Motion.Quick), {Scale = 1}):Play()
        end)

        buyBtn.MouseButton1Click:Connect(function()
            MarketplaceService:PromptProductPurchase(player, product.id)
            buyBtn.Text = "+" .. formatNumber(product.amount)
            task.delay(THEME.Motion.Quick, function()
                buyBtn.Text = "Buy"
            end)
        end)
    end
    updateCurrencyCanvas()
end

local function renderGamepasses()
    for _, child in ipairs(gpList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    for i, gp in ipairs(gamepasses) do
        local card = Instance.new("Frame")
        card.Name = "Gamepass" .. i
        card.Size = UDim2.new(1, -8, 0, 96)
        card.BackgroundColor3 = THEME.Palette.PanelFill
        card.BorderSizePixel = 0
        card.LayoutOrder = i
        card.ZIndex = 10
        card.Parent = gpList

        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0.12, 0)
        cardCorner.Parent = card

        local cardStroke = Instance.new("UIStroke")
        cardStroke.Thickness = THEME.Strokes.DefaultThickness
        cardStroke.Color = THEME.Palette.AccentDark
        cardStroke.Transparency = 0.4
        cardStroke.Parent = card

        local iconBg = Instance.new("Frame")
        iconBg.Size = UDim2.fromOffset(72, 72)
        iconBg.Position = UDim2.new(0, 12, 0.5, -36)
        iconBg.BackgroundColor3 = THEME.Palette.Accent
        iconBg.Parent = card

        local iconCorner = Instance.new("UICorner")
        iconCorner.CornerRadius = UDim.new(0.25, 0)
        iconCorner.Parent = iconBg

        local iconStroke = Instance.new("UIStroke")
        iconStroke.Thickness = THEME.Strokes.DefaultThickness
        iconStroke.Color = THEME.Palette.AccentDark
        iconStroke.Parent = iconBg

        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.fromScale(1, 1)
        icon.BackgroundTransparency = 1
        icon.Text = gp.icon
        icon.TextColor3 = THEME.Palette.White
        icon.TextStrokeColor3 = THEME.Palette.AccentDark
        icon.TextStrokeTransparency = 0.4
        icon.Font = THEME.Typography.Header
        icon.TextSize = 28
        icon.Parent = iconBg

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -220, 0, 28)
        nameLabel.Position = UDim2.new(0, 100, 0, 16)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = gp.name
        nameLabel.TextColor3 = THEME.Palette.NeutralDark
        nameLabel.Font = THEME.Typography.Body
        nameLabel.TextSize = 20
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = card

        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -220, 0, 20)
        desc.Position = UDim2.new(0, 100, 0, 48)
        desc.BackgroundTransparency = 1
        desc.Text = gp.desc
        desc.TextColor3 = THEME.Palette.NeutralDark
        desc.TextTransparency = 0.15
        desc.Font = THEME.Typography.Body
        desc.TextSize = 16
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = card

        local buyBtn = Instance.new("TextButton")
        buyBtn.Size = UDim2.fromOffset(120, 44)
        buyBtn.Position = UDim2.new(1, -136, 0.5, -22)
        buyBtn.BackgroundColor3 = THEME.Palette.Accent
        buyBtn.Text = "Buy"
        buyBtn.TextColor3 = THEME.Palette.White
        buyBtn.Font = THEME.Typography.Button
        buyBtn.TextSize = 18
        buyBtn.AutoButtonColor = false
        buyBtn.ZIndex = 12
        buyBtn.Parent = card

        local buyCorner = Instance.new("UICorner")
        buyCorner.CornerRadius = UDim.new(0.5, 0)
        buyCorner.Parent = buyBtn

        local buyScale = Instance.new("UIScale")
        buyScale.Scale = 1
        buyScale.Parent = buyBtn

        local owned = false
        if gp.id and gp.id > 0 then
            pcall(function()
                owned = MarketplaceService:UserOwnsGamePassAsync(player.UserId, gp.id)
            end)
        end
        if owned then
            buyBtn.Text = "Owned ✓"
            buyBtn.BackgroundColor3 = THEME.Palette.PanelFill
            buyBtn.TextColor3 = THEME.Palette.NeutralDark
            buyBtn.Active = false
        else
            buyBtn.MouseButton1Click:Connect(function()
                if gp.id and gp.id > 0 then
                    MarketplaceService:PromptGamePassPurchase(player, gp.id)
                end
            end)
            buyBtn.MouseEnter:Connect(function()
                TweenService:Create(buyBtn, TweenInfo.new(THEME.Motion.Quick), {BackgroundColor3 = THEME.Palette.Accent:lerp(THEME.Palette.White, 0.08)}):Play()
                TweenService:Create(buyScale, TweenInfo.new(THEME.Motion.Quick), {Scale = 1.05}):Play()
            end)
            buyBtn.MouseLeave:Connect(function()
                TweenService:Create(buyBtn, TweenInfo.new(THEME.Motion.Quick), {BackgroundColor3 = THEME.Palette.Accent}):Play()
                TweenService:Create(buyScale, TweenInfo.new(THEME.Motion.Quick), {Scale = 1}):Play()
            end)
        end
    end
    updateGpCanvas()
end

-- Toggle button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Size = UDim2.fromOffset(70, 70)
toggleBtn.Position = UDim2.new(1, -90, 1, -90)
toggleBtn.AnchorPoint = Vector2.new(1, 1)
toggleBtn.BackgroundColor3 = THEME.Palette.Accent
toggleBtn.Text = "★"
toggleBtn.TextSize = 32
toggleBtn.Font = THEME.Typography.Button
toggleBtn.TextColor3 = THEME.Palette.White
toggleBtn.AutoButtonColor = false
toggleBtn.ZIndex = 15
toggleBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0.5, 0)
toggleCorner.Parent = toggleBtn

-- Show / Hide
local function showShop()
    overlay.Visible = true
    overlay.Modal = true
    mainFrame.Visible = true
    TweenService:Create(overlay, TweenInfo.new(THEME.Motion.Transition), {BackgroundTransparency = 0.3}):Play()
    local scale = mainFrame:FindFirstChild("UIScale") or Instance.new("UIScale")
    scale.Scale = 0.9
    scale.Parent = mainFrame
    TweenService:Create(scale, TweenInfo.new(THEME.Motion.Transition, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
end

local function hideShop()
    local overlayTween = TweenService:Create(overlay, TweenInfo.new(THEME.Motion.Quick), {BackgroundTransparency = 1})
    overlayTween.Completed:Connect(function() overlay.Visible = false overlay.Modal = false end)
    overlayTween:Play()
    local scale = mainFrame:FindFirstChild("UIScale") or Instance.new("UIScale")
    scale.Scale = 1 scale.Parent = mainFrame
    local tween = TweenService:Create(scale, TweenInfo.new(THEME.Motion.Quick, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.95})
    tween.Completed:Connect(function() mainFrame.Visible = false scale.Scale = 1 end)
    tween:Play()
end

-- Tabs
local function setActiveTab(tab)
    local sel = THEME.Palette.Accent
    local idle = THEME.Palette.PanelFill
    if tab == "currency" then
        currencyList.Visible = true
        gpList.Visible = false
        currencyTabBtn.BackgroundColor3 = sel
        currencyTabBtn.TextColor3 = THEME.Palette.White
        gamepassTabBtn.BackgroundColor3 = idle
        gamepassTabBtn.TextColor3 = THEME.Palette.NeutralDark
    else
        currencyList.Visible = false
        gpList.Visible = true
        currencyTabBtn.BackgroundColor3 = idle
        currencyTabBtn.TextColor3 = THEME.Palette.NeutralDark
        gamepassTabBtn.BackgroundColor3 = sel
        gamepassTabBtn.TextColor3 = THEME.Palette.White
    end
end

currencyTabBtn.MouseButton1Click:Connect(function() setActiveTab("currency") end)
gamepassTabBtn.MouseButton1Click:Connect(function() setActiveTab("gamepasses") end)

-- Events
toggleBtn.MouseButton1Click:Connect(function()
    renderCurrency()
    renderGamepasses()
    setActiveTab("gamepasses") -- open directly to gamepasses as requested
    showShop()
end)
closeBtn.MouseButton1Click:Connect(hideShop)
overlay.MouseButton1Click:Connect(hideShop)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, id, ok)
    if p ~= player then return end
    if ok then renderGamepasses() end
end)

print("Money Shop UI (Sanrio, polished) with Gamepasses ready.")

