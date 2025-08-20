-- Money Shop Client Script (Dark style, Gamepasses only)
-- Place in: StarterPlayer/StarterPlayerScripts/CreateMoneyShop.client.lua

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Configure your gamepasses here
local PASS_2X_CASH = 1398974710
local PASS_AUTO_COLLECT = 0        -- TODO: set your Auto Collect Cash pass ID
local PASS_RAINBOW_CARPET = 0      -- TODO: set your Rainbow Carpet pass ID

local gamepasses = {
    {id = PASS_2X_CASH,        name = "2x Cash",          icon = "💰", desc = "Double all cash earnings."},
    {id = PASS_AUTO_COLLECT,   name = "Auto Collect Cash", icon = "🧲", desc = "Automatically collect your cash."},
    {id = PASS_RAINBOW_CARPET, name = "Rainbow Carpet",    icon = "🌈", desc = "Summon a rainbow carpet tool."},
}

-- Root GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MoneyShop"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Overlay
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

-- Main shop frame (dark style)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(17, 24, 39)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(17, 24, 39)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(31, 41, 55))
}
gradient.Rotation = 90
gradient.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 80)
header.BackgroundTransparency = 1
header.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 30, 0, 0)
title.BackgroundTransparency = 1
title.Text = "GAMEPASSES"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 28
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -60, 0, 20)
subtitle.Position = UDim2.new(0, 30, 0, 45)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Enhance your experience with premium perks"
subtitle.TextColor3 = Color3.fromRGB(156, 163, 175)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 14
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -50, 0, 20)
closeBtn.BackgroundColor3 = Color3.fromRGB(55, 65, 81)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(156, 163, 175)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.AutoButtonColor = false
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

-- Gamepasses container
local container = Instance.new("ScrollingFrame")
container.Name = "GamepassContainer"
container.Size = UDim2.new(1, -40, 1, -100)
container.Position = UDim2.new(0, 20, 0, 90)
container.BackgroundTransparency = 1
container.ScrollBarThickness = 4
container.ScrollBarImageColor3 = Color3.fromRGB(55, 65, 81)
container.BorderSizePixel = 0
container.CanvasSize = UDim2.new(0, 0, 0, 0)
container.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 12)
listLayout.Parent = container

local function updateCanvas()
    container.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 12)
end
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

-- Create gamepass cards (older dark look)
local function renderGamepasses()
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    for i, gp in ipairs(gamepasses) do
        local card = Instance.new("Frame")
        card.Name = "Gamepass" .. i
        card.Size = UDim2.new(1, -8, 0, 100)
        card.BackgroundColor3 = Color3.fromRGB(31, 41, 55)
        card.BorderSizePixel = 0
        card.Parent = container

        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0, 12)
        cardCorner.Parent = card

        -- Icon background
        local iconBg = Instance.new("Frame")
        iconBg.Size = UDim2.new(0, 70, 0, 70)
        iconBg.Position = UDim2.new(0, 15, 0.5, -35)
        iconBg.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
        iconBg.BackgroundTransparency = 0.2
        iconBg.Parent = card

        local iconCorner = Instance.new("UICorner")
        iconCorner.CornerRadius = UDim.new(0, 12)
        iconCorner.Parent = iconBg

        -- Icon
        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.new(1, 0, 1, 0)
        icon.BackgroundTransparency = 1
        icon.Text = gp.icon
        icon.TextColor3 = Color3.fromRGB(255, 255, 255)
        icon.Font = Enum.Font.Gotham
        icon.TextSize = 28
        icon.Parent = iconBg

        -- Name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0, 200, 0, 30)
        nameLabel.Position = UDim2.new(0, 100, 0, 20)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = gp.name
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 20
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = card

        -- Description
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -220, 0, 20)
        desc.Position = UDim2.new(0, 100, 0, 50)
        desc.BackgroundTransparency = 1
        desc.Text = gp.desc
        desc.TextColor3 = Color3.fromRGB(156, 163, 175)
        desc.Font = Enum.Font.Gotham
        desc.TextSize = 14
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = card

        -- Buy/Owned button
        local buyBtn = Instance.new("TextButton")
        buyBtn.Size = UDim2.new(0, 100, 0, 36)
        buyBtn.Position = UDim2.new(1, -120, 0.5, -18)
        buyBtn.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
        buyBtn.Text = "BUY"
        buyBtn.TextColor3 = Color3.new(1, 1, 1)
        buyBtn.Font = Enum.Font.GothamBold
        buyBtn.TextSize = 16
        buyBtn.AutoButtonColor = false
        buyBtn.Parent = card

        local buyCorner = Instance.new("UICorner")
        buyCorner.CornerRadius = UDim.new(0, 8)
        buyCorner.Parent = buyBtn

        -- Owned state
        local owned = false
        if gp.id and gp.id > 0 then
            pcall(function()
                owned = MarketplaceService:UserOwnsGamePassAsync(player.UserId, gp.id)
            end)
        end
        if owned then
            buyBtn.Text = "OWNED"
            buyBtn.BackgroundColor3 = Color3.fromRGB(55, 65, 81)
            buyBtn.TextColor3 = Color3.fromRGB(156, 163, 175)
            buyBtn.Active = false
        else
            buyBtn.MouseEnter:Connect(function()
                TweenService:Create(buyBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(79, 150, 266)
                }):Play()
            end)
            buyBtn.MouseLeave:Connect(function()
                TweenService:Create(buyBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(59, 130, 246)
                }):Play()
            end)
            buyBtn.MouseButton1Click:Connect(function()
                if gp.id and gp.id > 0 then
                    MarketplaceService:PromptGamePassPurchase(player, gp.id)
                end
            end)
        end
    end
    updateCanvas()
end

-- Toggle button (floating)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Size = UDim2.new(0, 70, 0, 70)
toggleBtn.Position = UDim2.new(0, 20, 1, -90)
toggleBtn.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
toggleBtn.Text = "$"
toggleBtn.TextSize = 35
toggleBtn.Font = Enum.Font.Gotham
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0.5, 0)
toggleCorner.Parent = toggleBtn

-- Show/hide animations
local function showShop()
    overlay.Visible = true
    mainFrame.Visible = true
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.Size = UDim2.new(0, 400, 0, 450)

    -- Fade in overlay
    TweenService:Create(overlay, TweenInfo.new(0.3), {
        BackgroundTransparency = 0.3
    }):Play()

    -- Animate main frame
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 400, 0, 500)
    }):Play()
end

local function hideShop()
    local overlayTween = TweenService:Create(overlay, TweenInfo.new(0.2), {
        BackgroundTransparency = 1
    })
    overlayTween.Completed:Connect(function()
        overlay.Visible = false
    end)
    overlayTween:Play()

    local tween = TweenService:Create(mainFrame, TweenInfo.new(0.2), {
        Size = UDim2.new(0, 400, 0, 450),
        Position = UDim2.new(0.5, -200, 0.5, -225)
    })
    tween.Completed:Connect(function()
        mainFrame.Visible = false
    end)
    tween:Play()
end

-- Events
toggleBtn.MouseButton1Click:Connect(function()
    renderGamepasses()
    showShop()
end)
closeBtn.MouseButton1Click:Connect(hideShop)
overlay.MouseButton1Click:Connect(hideShop)

-- Refresh owned state after purchase
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, id, wasPurchased)
    if p ~= player then return end
    if wasPurchased then
        renderGamepasses()
    end
end)

-- Hover effects for buttons
toggleBtn.MouseEnter:Connect(function()
    TweenService:Create(toggleBtn, TweenInfo.new(0.2), {
        Size = UDim2.new(0, 75, 0, 75),
        BackgroundColor3 = Color3.fromRGB(79, 150, 266)
    }):Play()
end)

toggleBtn.MouseLeave:Connect(function()
    TweenService:Create(toggleBtn, TweenInfo.new(0.2), {
        Size = UDim2.new(0, 70, 0, 70),
        BackgroundColor3 = Color3.fromRGB(59, 130, 246)
    }):Play()
end)

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(239, 68, 68),
        TextColor3 = Color3.new(1, 1, 1)
    }):Play()
end)

closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(55, 65, 81),
        TextColor3 = Color3.fromRGB(156, 163, 175)
    }):Play()
end)

print("Gamepass Shop UI loaded (dark style)")

