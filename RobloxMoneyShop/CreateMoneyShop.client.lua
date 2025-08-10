-- Money Shop Client Script (Creates Purchase GUI)
-- Place in: StarterPlayer/StarterPlayerScripts/CreateMoneyShop.client.lua
--
-- This creates a simple money shop GUI automatically when a player joins
-- IMPORTANT: Replace the product IDs below with your actual Developer Product IDs

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local player = Players.LocalPlayer

local productIds = {
    Small = 12345678,   -- 1k Cash (REPLACE WITH YOUR PRODUCT ID)
    Medium = 23456789,  -- 10k Cash (REPLACE WITH YOUR PRODUCT ID)
    Large = 34567890,   -- 50k Cash (REPLACE WITH YOUR PRODUCT ID)
}

-- Create the GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MoneyShop"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Create container frame
local container = Instance.new("Frame")
container.Name = "ShopContainer"
container.Size = UDim2.new(0, 240, 0, 300)
container.Position = UDim2.new(0, 20, 0.5, -150)
container.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
container.BorderSizePixel = 0
container.Parent = screenGui

-- Add rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = container

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "💰 MONEY SHOP"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = container

-- Helper function to create shop buttons
local function makeButton(text, productId, position)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 60)
    btn.Position = position
    btn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.Text = text
    btn.AutoButtonColor = true
    btn.Parent = container
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        MarketplaceService:PromptProductPurchase(player, productId)
    end)
    
    return btn
end

-- Create shop buttons
makeButton("💵 1,000 Cash", productIds.Small, UDim2.new(0, 10, 0, 60))
makeButton("💰 10,000 Cash", productIds.Medium, UDim2.new(0, 10, 0, 130))
makeButton("💎 50,000 Cash", productIds.Large, UDim2.new(0, 10, 0, 200))

-- Optional: Add a close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "✖"
closeBtn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
closeBtn.Font = Enum.Font.Gotham
closeBtn.TextSize = 18
closeBtn.Parent = container

closeBtn.MouseButton1Click:Connect(function()
    container.Visible = false
end)

-- Optional: Add a toggle button to show/hide shop
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 60, 0, 60)
toggleBtn.Position = UDim2.new(0, 20, 1, -80)
toggleBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
toggleBtn.Text = "💰"
toggleBtn.TextSize = 30
toggleBtn.Font = Enum.Font.Gotham
toggleBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 30)
toggleCorner.Parent = toggleBtn

toggleBtn.MouseButton1Click:Connect(function()
    container.Visible = not container.Visible
end)