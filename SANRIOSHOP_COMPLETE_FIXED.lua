--[[
  🎀 SANRIO SHOP - COMPLETE FIXED VERSION
  A fully functional shop UI with proper structure
--]]

-- Services
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Constants
local SHOP_DATA = {
	cash = {
		{id = 1685858326, name = "1,000 Cash", price = 10, icon = "rbxassetid://14303438127"},
		{id = 1685858395, name = "10,000 Cash", price = 50, icon = "rbxassetid://14303464435"},
		{id = 1685858511, name = "100K Cash", price = 100, icon = "rbxassetid://14303416937"},
		{id = 1685858619, name = "1M Cash", price = 250, icon = "rbxassetid://14303427225"},
		{id = 1685858708, name = "10M Cash", price = 500, icon = "rbxassetid://14303424333"},
		{id = 1685858778, name = "100M Cash", price = 1000, icon = "rbxassetid://14303421476"},
	},
	gamepasses = {
		{id = 836482884, name = "2x Cash", price = 399, icon = "rbxassetid://14303651131"},
		{id = 836490103, name = "VIP", price = 799, icon = "rbxassetid://14303642090"},
		{id = 836492167, name = "Auto Collect", price = 599, icon = "rbxassetid://14303654408"},
	}
}

-- Theme colors
local THEMES = {
	kitty = {
		primary = Color3.fromRGB(237, 28, 36),
		secondary = Color3.fromRGB(255, 182, 193),
		background = Color3.fromRGB(255, 250, 250),
		text = Color3.fromRGB(40, 40, 40)
	},
	cinna = {
		primary = Color3.fromRGB(135, 206, 250),
		secondary = Color3.fromRGB(255, 255, 255),
		background = Color3.fromRGB(240, 248, 255),
		text = Color3.fromRGB(0, 50, 100)
	},
	kuromi = {
		primary = Color3.fromRGB(138, 43, 226),
		secondary = Color3.fromRGB(255, 192, 203),
		background = Color3.fromRGB(48, 25, 52),
		text = Color3.fromRGB(255, 240, 255)
	}
}

local currentTheme = THEMES.kitty

-- Create main UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SanrioShop"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Dark overlay (hidden by default)
local overlay = Instance.new("Frame")
overlay.Name = "Overlay"
overlay.BackgroundColor3 = Color3.new(0, 0, 0)
overlay.BackgroundTransparency = 1
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.Visible = false
overlay.Parent = screenGui

-- Main shop frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.BackgroundColor3 = currentTheme.background
mainFrame.Size = UDim2.new(0, 800, 0, 600)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Visible = false
mainFrame.Parent = overlay

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 20)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = currentTheme.primary
mainStroke.Thickness = 3
mainStroke.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.BackgroundColor3 = currentTheme.primary
header.Size = UDim2.new(1, 0, 0, 80)
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 20)
headerCorner.Parent = header

local bottomFix = Instance.new("Frame")
bottomFix.BackgroundColor3 = currentTheme.primary
bottomFix.Size = UDim2.new(1, 0, 0, 20)
bottomFix.Position = UDim2.new(0, 0, 1, -20)
bottomFix.BorderSizePixel = 0
bottomFix.Parent = header

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Text = "🎀 Sanrio Shop 🎀"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Size = UDim2.new(0.6, 0, 0.6, 0)
title.Position = UDim2.new(0.2, 0, 0.2, 0)
title.Parent = header

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.BackgroundColor3 = Color3.new(1, 1, 1)
closeButton.BackgroundTransparency = 0.9
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextScaled = true
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(1, -50, 0.5, -20)
closeButton.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 10)
closeCorner.Parent = closeButton

-- Tab container
local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.BackgroundTransparency = 1
tabContainer.Size = UDim2.new(1, -20, 0, 50)
tabContainer.Position = UDim2.new(0, 10, 0, 90)
tabContainer.Parent = mainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 10)
tabLayout.Parent = tabContainer

-- Create tabs
local tabs = {}
local tabNames = {"Cash", "Gamepasses"}
local activeTab = nil

for i, tabName in ipairs(tabNames) do
	local tab = Instance.new("TextButton")
	tab.Name = tabName
	tab.BackgroundColor3 = currentTheme.secondary
	tab.Text = tabName
	tab.TextColor3 = currentTheme.text
	tab.Font = Enum.Font.GothamBold
	tab.TextScaled = true
	tab.Size = UDim2.new(0, 150, 1, 0)
	tab.AutoButtonColor = false
	tab.Parent = tabContainer
	
	local tabCorner = Instance.new("UICorner")
	tabCorner.CornerRadius = UDim.new(0, 10)
	tabCorner.Parent = tab
	
	local tabPadding = Instance.new("UIPadding")
	tabPadding.PaddingTop = UDim.new(0, 10)
	tabPadding.PaddingBottom = UDim.new(0, 10)
	tabPadding.Parent = tab
	
	tabs[tabName] = tab
end

-- Content area
local contentArea = Instance.new("ScrollingFrame")
contentArea.Name = "ContentArea"
contentArea.BackgroundColor3 = currentTheme.background
contentArea.BackgroundTransparency = 0.5
contentArea.Size = UDim2.new(1, -20, 1, -160)
contentArea.Position = UDim2.new(0, 10, 0, 150)
contentArea.ScrollBarThickness = 8
contentArea.ScrollBarImageColor3 = currentTheme.primary
contentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
contentArea.Parent = mainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 10)
contentCorner.Parent = contentArea

local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingTop = UDim.new(0, 10)
contentPadding.PaddingBottom = UDim.new(0, 10)
contentPadding.PaddingLeft = UDim.new(0, 10)
contentPadding.PaddingRight = UDim.new(0, 10)
contentPadding.Parent = contentArea

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 180, 0, 220)
gridLayout.CellPadding = UDim2.new(0, 15, 0, 15)
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.Parent = contentArea

-- Update canvas size when content changes
gridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	contentArea.CanvasSize = UDim2.new(0, 0, 0, gridLayout.AbsoluteContentSize.Y + 20)
end)

-- Create item card
local function createItemCard(itemData, itemType)
	local card = Instance.new("Frame")
	card.BackgroundColor3 = Color3.new(1, 1, 1)
	card.Parent = contentArea
	
	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 12)
	cardCorner.Parent = card
	
	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = currentTheme.primary
	cardStroke.Thickness = 2
	cardStroke.Transparency = 0.5
	cardStroke.Parent = card
	
	-- Icon
	local icon = Instance.new("ImageLabel")
	icon.BackgroundTransparency = 1
	icon.Image = itemData.icon
	icon.Size = UDim2.new(0, 80, 0, 80)
	icon.Position = UDim2.new(0.5, -40, 0, 20)
	icon.Parent = card
	
	-- Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = itemData.name
	nameLabel.TextColor3 = currentTheme.text
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextScaled = true
	nameLabel.Size = UDim2.new(0.9, 0, 0, 30)
	nameLabel.Position = UDim2.new(0.05, 0, 0, 110)
	nameLabel.Parent = card
	
	-- Price
	local priceLabel = Instance.new("TextLabel")
	priceLabel.BackgroundTransparency = 1
	priceLabel.Text = itemType == "cash" and ("R$" .. itemData.price) or (itemData.price .. " Robux")
	priceLabel.TextColor3 = currentTheme.primary
	priceLabel.Font = Enum.Font.Gotham
	priceLabel.TextScaled = true
	priceLabel.Size = UDim2.new(0.9, 0, 0, 25)
	priceLabel.Position = UDim2.new(0.05, 0, 0, 140)
	priceLabel.Parent = card
	
	-- Buy button
	local buyButton = Instance.new("TextButton")
	buyButton.BackgroundColor3 = currentTheme.primary
	buyButton.Text = "Buy"
	buyButton.TextColor3 = Color3.new(1, 1, 1)
	buyButton.Font = Enum.Font.GothamBold
	buyButton.TextScaled = true
	buyButton.Size = UDim2.new(0.8, 0, 0, 35)
	buyButton.Position = UDim2.new(0.1, 0, 1, -45)
	buyButton.AutoButtonColor = false
	buyButton.Parent = card
	
	local buyCorner = Instance.new("UICorner")
	buyCorner.CornerRadius = UDim.new(0, 8)
	buyCorner.Parent = buyButton
	
	-- Hover effects
	card.MouseEnter:Connect(function()
		TweenService:Create(cardStroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
		TweenService:Create(card, TweenInfo.new(0.2), {Position = UDim2.new(0, 0, 0, -5)}):Play()
	end)
	
	card.MouseLeave:Connect(function()
		TweenService:Create(cardStroke, TweenInfo.new(0.2), {Transparency = 0.5}):Play()
		TweenService:Create(card, TweenInfo.new(0.2), {Position = UDim2.new(0, 0, 0, 0)}):Play()
	end)
	
	-- Buy button click
	buyButton.MouseButton1Click:Connect(function()
		if itemType == "cash" then
			MarketplaceService:PromptProductPurchase(localPlayer, itemData.id)
		else
			MarketplaceService:PromptGamePassPurchase(localPlayer, itemData.id)
		end
	end)
	
	-- Button hover
	buyButton.MouseEnter:Connect(function()
		TweenService:Create(buyButton, TweenInfo.new(0.2), {BackgroundColor3 = currentTheme.secondary}):Play()
	end)
	
	buyButton.MouseLeave:Connect(function()
		TweenService:Create(buyButton, TweenInfo.new(0.2), {BackgroundColor3 = currentTheme.primary}):Play()
	end)
	
	return card
end

-- Load content for tab
local function loadTabContent(tabName)
	-- Clear existing content
	for _, child in ipairs(contentArea:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	-- Update tab appearances
	for name, tab in pairs(tabs) do
		if name == tabName then
			tab.BackgroundColor3 = currentTheme.primary
			tab.TextColor3 = Color3.new(1, 1, 1)
		else
			tab.BackgroundColor3 = currentTheme.secondary
			tab.TextColor3 = currentTheme.text
		end
	end
	
	-- Load items
	local items = tabName == "Cash" and SHOP_DATA.cash or SHOP_DATA.gamepasses
	local itemType = tabName == "Cash" and "cash" or "gamepasses"
	
	for _, itemData in ipairs(items) do
		createItemCard(itemData, itemType)
	end
end

-- Tab click handlers
for tabName, tab in pairs(tabs) do
	tab.MouseButton1Click:Connect(function()
		loadTabContent(tabName)
		activeTab = tabName
	end)
end

-- Shop manager
local ShopManager = {
	isOpen = false,
	isAnimating = false
}

function ShopManager:open()
	if self.isOpen or self.isAnimating then return end
	self.isAnimating = true
	self.isOpen = true
	
	overlay.Visible = true
	mainFrame.Visible = true
	
	-- Reset position and transparency
	mainFrame.Position = UDim2.new(0.5, 0, -0.5, 0)
	overlay.BackgroundTransparency = 1
	
	-- Animate in
	TweenService:Create(overlay, TweenInfo.new(0.3), {BackgroundTransparency = 0.5}):Play()
	TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, 0, 0.5, 0)
	}):Play()
	
	-- Load default tab
	loadTabContent("Cash")
	activeTab = "Cash"
	
	wait(0.4)
	self.isAnimating = false
end

function ShopManager:close()
	if not self.isOpen or self.isAnimating then return end
	self.isAnimating = true
	
	-- Animate out
	TweenService:Create(overlay, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
	TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Position = UDim2.new(0.5, 0, 1.5, 0)
	}):Play()
	
	wait(0.3)
	
	overlay.Visible = false
	mainFrame.Visible = false
	self.isOpen = false
	self.isAnimating = false
end

-- Close button handler
closeButton.MouseButton1Click:Connect(function()
	ShopManager:close()
end)

-- Keyboard controls
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.M then
		if ShopManager.isOpen then
			ShopManager:close()
		else
			ShopManager:open()
		end
	elseif input.KeyCode == Enum.KeyCode.Escape and ShopManager.isOpen then
		ShopManager:close()
	end
end)

-- Initialize
screenGui.Parent = playerGui

print("✨ Sanrio Shop loaded! Press M to open")