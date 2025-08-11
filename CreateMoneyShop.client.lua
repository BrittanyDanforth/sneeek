-- Money Shop Client Script (Creates Purchase GUI)
-- Place in: StarterPlayer/StarterPlayerScripts/CreateMoneyShop.client.lua

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Product IDs with your actual IDs
local products = {
	{id = 3366419712, amount = 1000, icon = "$", color = Color3.fromRGB(134, 239, 172)},
	{id = 3366420012, amount = 5000, icon = "$$", color = Color3.fromRGB(147, 197, 253)},
	{id = 3366420478, amount = 10000, icon = "$$$", color = Color3.fromRGB(196, 167, 231)},
	{id = 3366420800, amount = 25000, icon = "MAX", color = Color3.fromRGB(252, 211, 77)},
}

-- Format numbers with commas
local function formatNumber(n)
	local formatted = tostring(n)
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then break end
	end
	return formatted
end

-- Create the GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MoneyShop"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Create dark overlay (hidden by default)
local overlay = Instance.new("TextButton")
overlay.Name = "Overlay"
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.new(0, 0, 0)
overlay.BackgroundTransparency = 1
overlay.Text = ""
overlay.AutoButtonColor = false
overlay.Visible = false -- Hidden by default
overlay.Modal = false -- Don't block input when invisible
overlay.Parent = screenGui

-- Main shop frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(17, 24, 39)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Add rounded corners
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

-- Add gradient
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

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 30, 0, 0)
title.BackgroundTransparency = 1
title.Text = "CASH SHOP"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 28
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Subtitle
local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -60, 0, 20)
subtitle.Position = UDim2.new(0, 30, 0, 45)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Purchase cash to boost your tycoon!"
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

-- Products container
local container = Instance.new("ScrollingFrame")
container.Name = "ProductsContainer"
container.Size = UDim2.new(1, -40, 1, -100)
container.Position = UDim2.new(0, 20, 0, 90)
container.BackgroundTransparency = 1
container.ScrollBarThickness = 4
container.ScrollBarImageColor3 = Color3.fromRGB(55, 65, 81)
container.BorderSizePixel = 0
container.CanvasSize = UDim2.new(0, 0, 0, 440) -- Set canvas size for 4 products
container.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 12)
listLayout.Parent = container

-- Create product cards
print("Creating", #products, "product cards")
for i, product in ipairs(products) do
	local card = Instance.new("Frame")
	card.Name = "Product" .. i
	card.Size = UDim2.new(1, -8, 0, 100)
	card.BackgroundColor3 = Color3.fromRGB(31, 41, 55)
	card.BorderSizePixel = 0
	card.Parent = container
	print("Created product card", i, "for", product.amount, "cash")
	
	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 12)
	cardCorner.Parent = card
	
	-- Icon background
	local iconBg = Instance.new("Frame")
	iconBg.Size = UDim2.new(0, 70, 0, 70)
	iconBg.Position = UDim2.new(0, 15, 0.5, -35)
	iconBg.BackgroundColor3 = product.color
	iconBg.BackgroundTransparency = 0.8
	iconBg.Parent = card
	
	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0, 12)
	iconCorner.Parent = iconBg
	
	-- Icon
	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.new(1, 0, 1, 0)
	icon.BackgroundTransparency = 1
	icon.Text = product.icon
	icon.TextColor3 = product.color
	icon.Font = Enum.Font.Gotham
	icon.TextSize = 32
	icon.Parent = iconBg
	
	-- Amount label
	local amountLabel = Instance.new("TextLabel")
	amountLabel.Size = UDim2.new(0, 150, 0, 30)
	amountLabel.Position = UDim2.new(0, 100, 0, 20)
	amountLabel.BackgroundTransparency = 1
	amountLabel.Text = formatNumber(product.amount) .. " Cash"
	amountLabel.TextColor3 = Color3.new(1, 1, 1)
	amountLabel.Font = Enum.Font.GothamBold
	amountLabel.TextSize = 20
	amountLabel.TextXAlignment = Enum.TextXAlignment.Left
	amountLabel.Parent = card
	
	-- Description
	local desc = Instance.new("TextLabel")
	desc.Size = UDim2.new(0, 150, 0, 20)
	desc.Position = UDim2.new(0, 100, 0, 50)
	desc.BackgroundTransparency = 1
	desc.Text = "Instant delivery"
	desc.TextColor3 = Color3.fromRGB(156, 163, 175)
	desc.Font = Enum.Font.Gotham
	desc.TextSize = 14
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.Parent = card
	
	-- Buy button
	local buyBtn = Instance.new("TextButton")
	buyBtn.Size = UDim2.new(0, 80, 0, 36)
	buyBtn.Position = UDim2.new(1, -95, 0.5, -18)
	buyBtn.BackgroundColor3 = product.color
	buyBtn.Text = "BUY"
	buyBtn.TextColor3 = Color3.new(1, 1, 1)
	buyBtn.Font = Enum.Font.GothamBold
	buyBtn.TextSize = 16
	buyBtn.AutoButtonColor = false
	buyBtn.Parent = card
	
	local buyCorner = Instance.new("UICorner")
	buyCorner.CornerRadius = UDim.new(0, 8)
	buyCorner.Parent = buyBtn
	
	-- Hover effects
	local originalColor = product.color
	buyBtn.MouseEnter:Connect(function()
		TweenService:Create(buyBtn, TweenInfo.new(0.2), {
			BackgroundColor3 = originalColor:Lerp(Color3.new(1, 1, 1), 0.2)
		}):Play()
	end)
	
	buyBtn.MouseLeave:Connect(function()
		TweenService:Create(buyBtn, TweenInfo.new(0.2), {
			BackgroundColor3 = originalColor
		}):Play()
	end)
	
	-- Purchase handler
	buyBtn.MouseButton1Click:Connect(function()
		MarketplaceService:PromptProductPurchase(player, product.id)
	end)
end

-- Toggle button (floating cash icon)
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

-- Add shadow to toggle button
local toggleShadow = Instance.new("ImageLabel")
toggleShadow.Name = "Shadow"
toggleShadow.Size = UDim2.new(1, 20, 1, 20)
toggleShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
toggleShadow.AnchorPoint = Vector2.new(0.5, 0.5)
toggleShadow.BackgroundTransparency = 1
toggleShadow.Image = "rbxassetid://1316045217"
toggleShadow.ImageColor3 = Color3.new(0, 0, 0)
toggleShadow.ImageTransparency = 0.8
toggleShadow.ScaleType = Enum.ScaleType.Slice
toggleShadow.SliceCenter = Rect.new(10, 10, 118, 118)
toggleShadow.Parent = toggleBtn

-- Animation functions
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
	-- Fade out overlay
	local overlayTween = TweenService:Create(overlay, TweenInfo.new(0.2), {
		BackgroundTransparency = 1
	})
	
	overlayTween.Completed:Connect(function()
		overlay.Visible = false -- Hide overlay when fade completes
	end)
	
	overlayTween:Play()
	
	-- Animate main frame
	local tween = TweenService:Create(mainFrame, TweenInfo.new(0.2), {
		Size = UDim2.new(0, 400, 0, 450),
		Position = UDim2.new(0.5, -200, 0.5, -225)
	})
	
	tween.Completed:Connect(function()
		mainFrame.Visible = false
	end)
	
	tween:Play()
end

-- Button handlers
toggleBtn.MouseButton1Click:Connect(showShop)
closeBtn.MouseButton1Click:Connect(hideShop)
overlay.MouseButton1Click:Connect(hideShop)

-- Hover effect for toggle button
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

-- Close button hover
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

print("Money Shop UI loaded!")