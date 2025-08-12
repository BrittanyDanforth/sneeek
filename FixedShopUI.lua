-- Fixed Shop UI - Clean and Working
-- Place in: StarterPlayer/StarterPlayerScripts

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Shop data
local shopData = {
	cash = {
		{id = 3366419712, amount = 1000, name = "1,000 Cash", color = Color3.fromRGB(85, 255, 127)},
		{id = 3366420012, amount = 5000, name = "5,000 Cash", color = Color3.fromRGB(85, 170, 255)},
		{id = 3366420478, amount = 10000, name = "10,000 Cash", color = Color3.fromRGB(170, 85, 255)},
		{id = 3366420800, amount = 25000, name = "25,000 Cash", color = Color3.fromRGB(255, 170, 0)},
	},
	gamepasses = {
		-- Add your gamepass IDs here
		{id = 123456789, name = "2x Cash", price = 199, color = Color3.fromRGB(255, 128, 0)},
		{id = 123456790, name = "VIP Pass", price = 499, color = Color3.fromRGB(255, 215, 0)},
		{id = 123456791, name = "Auto Collect", price = 299, color = Color3.fromRGB(0, 255, 127)},
	}
}

local currentTab = "cash"

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShopUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Dark background overlay
local darkBg = Instance.new("Frame")
darkBg.Name = "DarkBg"
darkBg.Size = UDim2.new(1, 0, 1, 0)
darkBg.BackgroundColor3 = Color3.new(0, 0, 0)
darkBg.BackgroundTransparency = 0.5
darkBg.Visible = false
darkBg.Parent = screenGui

-- Main shop window
local shopFrame = Instance.new("Frame")
shopFrame.Name = "ShopFrame"
shopFrame.Size = UDim2.new(0, 450, 0, 550)
shopFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
shopFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
shopFrame.BorderSizePixel = 0
shopFrame.Visible = false
shopFrame.Parent = screenGui

local shopCorner = Instance.new("UICorner")
shopCorner.CornerRadius = UDim.new(0, 12)
shopCorner.Parent = shopFrame

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 60)
header.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
header.BorderSizePixel = 0
header.Parent = shopFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 20)
headerFix.Position = UDim2.new(0, 0, 1, -20)
headerFix.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
headerFix.BorderSizePixel = 0
headerFix.Parent = header

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 20, 0, 0)
title.BackgroundTransparency = 1
title.Text = "SHOP"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 28
title.TextColor3 = Color3.new(1, 1, 1)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -50, 0.5, -20)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 24
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Parent = header

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 8)
closeBtnCorner.Parent = closeBtn

-- Tab buttons
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, -40, 0, 50)
tabFrame.Position = UDim2.new(0, 20, 0, 70)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = shopFrame

local cashTab = Instance.new("TextButton")
cashTab.Size = UDim2.new(0.5, -5, 1, 0)
cashTab.Position = UDim2.new(0, 0, 0, 0)
cashTab.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
cashTab.Text = "CASH"
cashTab.Font = Enum.Font.SourceSansBold
cashTab.TextSize = 20
cashTab.TextColor3 = Color3.new(1, 1, 1)
cashTab.Parent = tabFrame

local cashTabCorner = Instance.new("UICorner")
cashTabCorner.CornerRadius = UDim.new(0, 8)
cashTabCorner.Parent = cashTab

local gamepassTab = Instance.new("TextButton")
gamepassTab.Size = UDim2.new(0.5, -5, 1, 0)
gamepassTab.Position = UDim2.new(0.5, 5, 0, 0)
gamepassTab.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
gamepassTab.Text = "GAMEPASSES"
gamepassTab.Font = Enum.Font.SourceSansBold
gamepassTab.TextSize = 20
gamepassTab.TextColor3 = Color3.fromRGB(200, 200, 200)
gamepassTab.Parent = tabFrame

local gamepassTabCorner = Instance.new("UICorner")
gamepassTabCorner.CornerRadius = UDim.new(0, 8)
gamepassTabCorner.Parent = gamepassTab

-- Items container
local itemsContainer = Instance.new("ScrollingFrame")
itemsContainer.Size = UDim2.new(1, -40, 1, -150)
itemsContainer.Position = UDim2.new(0, 20, 0, 130)
itemsContainer.BackgroundTransparency = 1
itemsContainer.ScrollBarThickness = 8
itemsContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
itemsContainer.BorderSizePixel = 0
itemsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
itemsContainer.Parent = shopFrame

local itemsLayout = Instance.new("UIListLayout")
itemsLayout.Padding = UDim.new(0, 10)
itemsLayout.Parent = itemsContainer

-- Toggle button (better design)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 100, 0, 50)
toggleBtn.Position = UDim2.new(1, -120, 1, -70)
toggleBtn.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
toggleBtn.Text = "SHOP"
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 24
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Parent = screenGui

local toggleBtnCorner = Instance.new("UICorner")
toggleBtnCorner.CornerRadius = UDim.new(0, 25)
toggleBtnCorner.Parent = toggleBtn

-- Add icon to toggle button
local shopIcon = Instance.new("TextLabel")
shopIcon.Size = UDim2.new(0, 30, 0, 30)
shopIcon.Position = UDim2.new(0, 10, 0.5, -15)
shopIcon.BackgroundTransparency = 1
shopIcon.Text = "$"
shopIcon.Font = Enum.Font.SourceSansBold
shopIcon.TextSize = 28
shopIcon.TextColor3 = Color3.new(1, 1, 1)
shopIcon.Parent = toggleBtn

-- Adjust text position
toggleBtn.Text = "      SHOP"

-- Create item function
local function createItem(data, isGamepass)
	local item = Instance.new("Frame")
	item.Size = UDim2.new(1, 0, 0, 100)
	item.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	item.BorderSizePixel = 0
	
	local itemCorner = Instance.new("UICorner")
	itemCorner.CornerRadius = UDim.new(0, 8)
	itemCorner.Parent = item
	
	-- Color accent
	local accent = Instance.new("Frame")
	accent.Size = UDim2.new(0, 5, 1, 0)
	accent.BackgroundColor3 = data.color
	accent.BorderSizePixel = 0
	accent.Parent = item
	
	local accentCorner = Instance.new("UICorner")
	accentCorner.CornerRadius = UDim.new(0, 8)
	accentCorner.Parent = accent
	
	-- Item name
	local itemName = Instance.new("TextLabel")
	itemName.Size = UDim2.new(0.6, -20, 0, 30)
	itemName.Position = UDim2.new(0, 20, 0, 15)
	itemName.BackgroundTransparency = 1
	itemName.Text = data.name
	itemName.Font = Enum.Font.SourceSansBold
	itemName.TextSize = 22
	itemName.TextColor3 = Color3.new(1, 1, 1)
	itemName.TextXAlignment = Enum.TextXAlignment.Left
	itemName.Parent = item
	
	-- Description
	local desc = Instance.new("TextLabel")
	desc.Size = UDim2.new(0.6, -20, 0, 20)
	desc.Position = UDim2.new(0, 20, 0, 45)
	desc.BackgroundTransparency = 1
	desc.Text = isGamepass and "Permanent upgrade!" or "Instant delivery!"
	desc.Font = Enum.Font.SourceSans
	desc.TextSize = 16
	desc.TextColor3 = Color3.fromRGB(180, 180, 180)
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.Parent = item
	
	-- Buy button
	local buyBtn = Instance.new("TextButton")
	buyBtn.Size = UDim2.new(0, 120, 0, 40)
	buyBtn.Position = UDim2.new(1, -140, 0.5, -20)
	buyBtn.BackgroundColor3 = data.color
	buyBtn.Font = Enum.Font.SourceSansBold
	buyBtn.TextSize = 20
	buyBtn.TextColor3 = Color3.new(1, 1, 1)
	buyBtn.Parent = item
	
	if isGamepass then
		buyBtn.Text = "R$" .. data.price
	else
		buyBtn.Text = "BUY"
	end
	
	local buyBtnCorner = Instance.new("UICorner")
	buyBtnCorner.CornerRadius = UDim.new(0, 8)
	buyBtnCorner.Parent = buyBtn
	
	-- Buy button click
	buyBtn.MouseButton1Click:Connect(function()
		if isGamepass then
			MarketplaceService:PromptGamePassPurchase(player, data.id)
		else
			MarketplaceService:PromptProductPurchase(player, data.id)
		end
	end)
	
	-- Hover effect
	buyBtn.MouseEnter:Connect(function()
		TweenService:Create(buyBtn, TweenInfo.new(0.2), {
			Size = UDim2.new(0, 130, 0, 44)
		}):Play()
	end)
	
	buyBtn.MouseLeave:Connect(function()
		TweenService:Create(buyBtn, TweenInfo.new(0.2), {
			Size = UDim2.new(0, 120, 0, 40)
		}):Play()
	end)
	
	return item
end

-- Load items function
local function loadItems(tab)
	-- Clear existing items
	for _, child in pairs(itemsContainer:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	-- Load new items
	local items = tab == "cash" and shopData.cash or shopData.gamepasses
	for _, data in pairs(items) do
		local item = createItem(data, tab == "gamepasses")
		item.Parent = itemsContainer
	end
	
	-- Update canvas size
	itemsContainer.CanvasSize = UDim2.new(0, 0, 0, #items * 110)
end

-- Tab switching
cashTab.MouseButton1Click:Connect(function()
	currentTab = "cash"
	cashTab.BackgroundColor3 = Color3.fromRGB(85, 170, 255)
	cashTab.TextColor3 = Color3.new(1, 1, 1)
	gamepassTab.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	gamepassTab.TextColor3 = Color3.fromRGB(200, 200, 200)
	loadItems("cash")
end)

gamepassTab.MouseButton1Click:Connect(function()
	currentTab = "gamepasses"
	gamepassTab.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
	gamepassTab.TextColor3 = Color3.new(1, 1, 1)
	cashTab.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	cashTab.TextColor3 = Color3.fromRGB(200, 200, 200)
	loadItems("gamepasses")
end)

-- Show/hide shop
local function showShop()
	darkBg.Visible = true
	shopFrame.Visible = true
	loadItems(currentTab)
end

local function hideShop()
	darkBg.Visible = false
	shopFrame.Visible = false
end

-- Button clicks
toggleBtn.MouseButton1Click:Connect(showShop)
closeBtn.MouseButton1Click:Connect(hideShop)
darkBg.MouseButton1Click:Connect(hideShop)

-- Toggle button hover
toggleBtn.MouseEnter:Connect(function()
	TweenService:Create(toggleBtn, TweenInfo.new(0.2), {
		Size = UDim2.new(0, 110, 0, 55),
		BackgroundColor3 = Color3.fromRGB(100, 185, 255)
	}):Play()
end)

toggleBtn.MouseLeave:Connect(function()
	TweenService:Create(toggleBtn, TweenInfo.new(0.2), {
		Size = UDim2.new(0, 100, 0, 50),
		BackgroundColor3 = Color3.fromRGB(85, 170, 255)
	}):Play()
end)

print("Fixed Shop UI loaded!")