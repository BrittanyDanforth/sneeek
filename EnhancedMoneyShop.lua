-- Enhanced Shop Client Script (Money + Gamepasses)
-- Place in: StarterPlayer/StarterPlayerScripts/EnhancedMoneyShop.client.lua

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Shop sections
local shopSections = {
	{
		name = "CASH",
		icon = "💰",
		color = Color3.fromRGB(34, 197, 94),
		items = {
			{id = 3366419712, amount = 1000, name = "Starter Pack", icon = "💵", color = Color3.fromRGB(134, 239, 172), type = "product"},
			{id = 3366420012, amount = 5000, name = "Value Bundle", icon = "💰", color = Color3.fromRGB(147, 197, 253), type = "product"},
			{id = 3366420478, amount = 10000, name = "Big Spender", icon = "💎", color = Color3.fromRGB(196, 167, 231), type = "product"},
			{id = 3366420800, amount = 25000, name = "Whale Pack", icon = "👑", color = Color3.fromRGB(252, 211, 77), type = "product"},
		}
	},
	{
		name = "GAMEPASSES",
		icon = "⭐",
		color = Color3.fromRGB(59, 130, 246),
		items = {
			-- Add your gamepass IDs here
			{id = 123456789, name = "2x Cash", description = "Double all cash earnings!", icon = "x2", color = Color3.fromRGB(251, 146, 60), type = "gamepass", price = 199},
			{id = 123456790, name = "VIP", description = "Exclusive VIP benefits!", icon = "VIP", color = Color3.fromRGB(217, 70, 239), type = "gamepass", price = 499},
			{id = 123456791, name = "Auto Collect", description = "Auto collect dropped cash!", icon = "🤖", color = Color3.fromRGB(34, 197, 94), type = "gamepass", price = 299},
		}
	}
}

-- Current section
local currentSection = 1

-- Format numbers
local function formatNumber(n)
	n = tonumber(n) or 0
	if n >= 1000000 then
		return string.format("%.1fM", n / 1000000)
	elseif n >= 1000 then
		return string.format("%.1fK", n / 1000)
	else
		return tostring(n)
	end
end

-- Create the GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EnhancedShop"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Create dark overlay
local overlay = Instance.new("TextButton")
overlay.Name = "Overlay"
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.new(0, 0, 0)
overlay.BackgroundTransparency = 1
overlay.Text = ""
overlay.AutoButtonColor = false
overlay.Visible = false
overlay.ZIndex = 5
overlay.Parent = screenGui

-- Main shop frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 500, 0, 600)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.ZIndex = 10
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 20)
mainCorner.Parent = mainFrame

-- Add subtle gradient
local mainGradient = Instance.new("UIGradient")
mainGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 23, 42)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 41, 59))
}
mainGradient.Rotation = 90
mainGradient.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 140)
header.BackgroundTransparency = 1
header.Parent = mainFrame

-- Close button (modern style)
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(1, -20, 0, 20)
closeBtn.AnchorPoint = Vector2.new(1, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(148, 163, 184)
closeBtn.Font = Enum.Font.Gotham
closeBtn.TextSize = 20
closeBtn.AutoButtonColor = false
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeBtn

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 40)
title.Position = UDim2.new(0, 20, 0, 20)
title.BackgroundTransparency = 1
title.Text = "TYCOON SHOP"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 32
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Section tabs
local tabsFrame = Instance.new("Frame")
tabsFrame.Name = "Tabs"
tabsFrame.Size = UDim2.new(1, -40, 0, 50)
tabsFrame.Position = UDim2.new(0, 20, 0, 70)
tabsFrame.BackgroundTransparency = 1
tabsFrame.Parent = header

local tabsLayout = Instance.new("UIListLayout")
tabsLayout.FillDirection = Enum.FillDirection.Horizontal
tabsLayout.Padding = UDim.new(0, 10)
tabsLayout.Parent = tabsFrame

local tabs = {}

for i, section in ipairs(shopSections) do
	local tab = Instance.new("TextButton")
	tab.Name = "Tab" .. i
	tab.Size = UDim2.new(0, 150, 1, 0)
	tab.BackgroundColor3 = i == 1 and section.color or Color3.fromRGB(30, 41, 59)
	tab.BackgroundTransparency = i == 1 and 0 or 0.5
	tab.Text = section.icon .. " " .. section.name
	tab.TextColor3 = i == 1 and Color3.new(1, 1, 1) or Color3.fromRGB(148, 163, 184)
	tab.Font = Enum.Font.GothamBold
	tab.TextSize = 16
	tab.AutoButtonColor = false
	tab.Parent = tabsFrame
	
	local tabCorner = Instance.new("UICorner")
	tabCorner.CornerRadius = UDim.new(0, 10)
	tabCorner.Parent = tab
	
	tabs[i] = tab
end

-- Content frame
local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, -40, 1, -160)
contentFrame.Position = UDim2.new(0, 20, 0, 140)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Products container
local container = Instance.new("ScrollingFrame")
container.Name = "ItemsContainer"
container.Size = UDim2.new(1, 0, 1, 0)
container.BackgroundTransparency = 1
container.ScrollBarThickness = 6
container.ScrollBarImageColor3 = Color3.fromRGB(51, 65, 85)
container.BorderSizePixel = 0
container.Parent = contentFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 12)
listLayout.Parent = container

-- Function to create item cards
local function createItemCard(item, index)
	local card = Instance.new("Frame")
	card.Name = "Item" .. index
	card.Size = UDim2.new(1, 0, 0, 120)
	card.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
	card.BorderSizePixel = 0
	
	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 12)
	cardCorner.Parent = card
	
	-- Add subtle border
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(51, 65, 85)
	stroke.Thickness = 1
	stroke.Transparency = 0.5
	stroke.Parent = card
	
	-- Icon container
	local iconContainer = Instance.new("Frame")
	iconContainer.Size = UDim2.new(0, 80, 0, 80)
	iconContainer.Position = UDim2.new(0, 20, 0.5, -40)
	iconContainer.BackgroundColor3 = item.color
	iconContainer.BackgroundTransparency = 0.85
	iconContainer.Parent = card
	
	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0, 16)
	iconCorner.Parent = iconContainer
	
	-- Icon
	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.new(1, 0, 1, 0)
	icon.BackgroundTransparency = 1
	icon.Text = item.icon
	icon.TextColor3 = item.color
	icon.Font = Enum.Font.Gotham
	icon.TextSize = item.type == "gamepass" and 24 or 36
	icon.Parent = iconContainer
	
	-- Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0, 200, 0, 24)
	nameLabel.Position = UDim2.new(0, 120, 0, 20)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = item.name or (formatNumber(item.amount) .. " Cash")
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 18
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = card
	
	-- Description
	local desc = Instance.new("TextLabel")
	desc.Size = UDim2.new(0, 200, 0, 40)
	desc.Position = UDim2.new(0, 120, 0, 48)
	desc.BackgroundTransparency = 1
	desc.Text = item.description or "Instant delivery!"
	desc.TextColor3 = Color3.fromRGB(148, 163, 184)
	desc.Font = Enum.Font.Gotham
	desc.TextSize = 14
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.TextWrapped = true
	desc.Parent = card
	
	-- Buy button
	local buyBtn = Instance.new("TextButton")
	buyBtn.Size = UDim2.new(0, 100, 0, 40)
	buyBtn.Position = UDim2.new(1, -20, 0.5, -20)
	buyBtn.AnchorPoint = Vector2.new(1, 0.5)
	buyBtn.BackgroundColor3 = item.color
	buyBtn.Font = Enum.Font.GothamBold
	buyBtn.TextSize = 16
	buyBtn.TextColor3 = Color3.new(1, 1, 1)
	buyBtn.AutoButtonColor = false
	buyBtn.Parent = card
	
	if item.type == "gamepass" then
		buyBtn.Text = item.price .. " R$"
	else
		buyBtn.Text = "BUY"
	end
	
	local buyCorner = Instance.new("UICorner")
	buyCorner.CornerRadius = UDim.new(0, 10)
	buyCorner.Parent = buyBtn
	
	-- Add gradient to button
	local btnGradient = Instance.new("UIGradient")
	btnGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.new(0.9, 0.9, 0.9))
	}
	btnGradient.Rotation = 90
	btnGradient.Parent = buyBtn
	
	-- Hover effects
	card.MouseEnter:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(41, 55, 77)
		}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.2), {
			Transparency = 0
		}):Play()
	end)
	
	card.MouseLeave:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(30, 41, 59)
		}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.2), {
			Transparency = 0.5
		}):Play()
	end)
	
	buyBtn.MouseEnter:Connect(function()
		TweenService:Create(buyBtn, TweenInfo.new(0.2), {
			Size = UDim2.new(0, 110, 0, 44)
		}):Play()
	end)
	
	buyBtn.MouseLeave:Connect(function()
		TweenService:Create(buyBtn, TweenInfo.new(0.2), {
			Size = UDim2.new(0, 100, 0, 40)
		}):Play()
	end)
	
	-- Purchase handler
	buyBtn.MouseButton1Click:Connect(function()
		if item.type == "gamepass" then
			MarketplaceService:PromptGamePassPurchase(player, item.id)
		else
			MarketplaceService:PromptProductPurchase(player, item.id)
		end
	end)
	
	return card
end

-- Function to load section items
local function loadSection(sectionIndex)
	-- Clear container
	for _, child in ipairs(container:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	-- Create items
	local section = shopSections[sectionIndex]
	for i, item in ipairs(section.items) do
		local card = createItemCard(item, i)
		card.Parent = container
	end
	
	-- Update canvas size
	container.CanvasSize = UDim2.new(0, 0, 0, #section.items * 132)
end

-- Tab click handlers
for i, tab in ipairs(tabs) do
	tab.MouseButton1Click:Connect(function()
		if currentSection == i then return end
		
		-- Update tabs appearance
		for j, t in ipairs(tabs) do
			if j == i then
				TweenService:Create(t, TweenInfo.new(0.2), {
					BackgroundColor3 = shopSections[j].color,
					BackgroundTransparency = 0,
					TextColor3 = Color3.new(1, 1, 1)
				}):Play()
			else
				TweenService:Create(t, TweenInfo.new(0.2), {
					BackgroundColor3 = Color3.fromRGB(30, 41, 59),
					BackgroundTransparency = 0.5,
					TextColor3 = Color3.fromRGB(148, 163, 184)
				}):Play()
			end
		end
		
		currentSection = i
		loadSection(i)
	end)
end

-- Modern floating toggle button
local toggleContainer = Instance.new("Frame")
toggleContainer.Name = "ToggleContainer"
toggleContainer.Size = UDim2.new(0, 80, 0, 80)
toggleContainer.Position = UDim2.new(1, -100, 1, -100)
toggleContainer.BackgroundTransparency = 1
toggleContainer.Parent = screenGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Size = UDim2.new(1, 0, 1, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
toggleBtn.Text = ""
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = toggleContainer

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0.5, 0)
toggleCorner.Parent = toggleBtn

-- Add gradient
local toggleGradient = Instance.new("UIGradient")
toggleGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(129, 140, 248)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(99, 102, 241))
}
toggleGradient.Rotation = 45
toggleGradient.Parent = toggleBtn

-- Icon frame
local iconFrame = Instance.new("Frame")
iconFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
iconFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
iconFrame.BackgroundTransparency = 1
iconFrame.Parent = toggleBtn

-- Shop icon
local shopIcon = Instance.new("TextLabel")
shopIcon.Size = UDim2.new(1, 0, 0.5, 0)
shopIcon.Position = UDim2.new(0, 0, 0, 0)
shopIcon.BackgroundTransparency = 1
shopIcon.Text = "🛒"
shopIcon.TextScaled = true
shopIcon.Font = Enum.Font.Gotham
shopIcon.Parent = iconFrame

-- "SHOP" text
local shopText = Instance.new("TextLabel")
shopText.Size = UDim2.new(1, 0, 0.4, 0)
shopText.Position = UDim2.new(0, 0, 0.6, 0)
shopText.BackgroundTransparency = 1
shopText.Text = "SHOP"
shopText.TextColor3 = Color3.new(1, 1, 1)
shopText.Font = Enum.Font.GothamBold
shopText.TextScaled = true
shopText.Parent = iconFrame

-- Add shadow
local toggleShadow = Instance.new("ImageLabel")
toggleShadow.Name = "Shadow"
toggleShadow.Size = UDim2.new(1.4, 0, 1.4, 0)
toggleShadow.Position = UDim2.new(0.5, 0, 0.5, 4)
toggleShadow.AnchorPoint = Vector2.new(0.5, 0.5)
toggleShadow.BackgroundTransparency = 1
toggleShadow.Image = "rbxassetid://1316045217"
toggleShadow.ImageColor3 = Color3.new(0, 0, 0)
toggleShadow.ImageTransparency = 0.6
toggleShadow.ScaleType = Enum.ScaleType.Slice
toggleShadow.SliceCenter = Rect.new(10, 10, 118, 118)
toggleShadow.ZIndex = -1
toggleShadow.Parent = toggleBtn

-- Animation functions
local function showShop()
	overlay.Visible = true
	mainFrame.Visible = true
	mainFrame.Size = UDim2.new(0, 450, 0, 550)
	
	TweenService:Create(overlay, TweenInfo.new(0.3), {
		BackgroundTransparency = 0.4
	}):Play()
	
	TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 500, 0, 600)
	}):Play()
	
	-- Load first section
	loadSection(1)
end

local function hideShop()
	local overlayTween = TweenService:Create(overlay, TweenInfo.new(0.2), {
		BackgroundTransparency = 1
	})
	
	overlayTween.Completed:Connect(function()
		overlay.Visible = false
	end)
	
	overlayTween:Play()
	
	local tween = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = UDim2.new(0, 450, 0, 550)
	})
	
	tween.Completed:Connect(function()
		mainFrame.Visible = false
	end)
	
	tween:Play()
end

-- Toggle button animations
local isHovering = false

toggleBtn.MouseEnter:Connect(function()
	isHovering = true
	TweenService:Create(toggleBtn, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Size = UDim2.new(1.1, 0, 1.1, 0),
		BackgroundColor3 = Color3.fromRGB(129, 140, 248)
	}):Play()
	
	-- Rotate animation
	local rotation = TweenService:Create(toggleBtn, 
		TweenInfo.new(0.3, Enum.EasingStyle.Quad),
		{Rotation = 5}
	)
	rotation:Play()
end)

toggleBtn.MouseLeave:Connect(function()
	isHovering = false
	TweenService:Create(toggleBtn, TweenInfo.new(0.3), {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(99, 102, 241),
		Rotation = 0
	}):Play()
end)

-- Floating animation
task.spawn(function()
	while true do
		if not isHovering then
			local floatUp = TweenService:Create(toggleContainer,
				TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Position = UDim2.new(1, -100, 1, -110)}
			)
			floatUp:Play()
			floatUp.Completed:Wait()
			
			local floatDown = TweenService:Create(toggleContainer,
				TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{Position = UDim2.new(1, -100, 1, -100)}
			)
			floatDown:Play()
			floatDown.Completed:Wait()
		else
			task.wait(0.1)
		end
	end
end)

-- Button handlers
toggleBtn.MouseButton1Click:Connect(showShop)
closeBtn.MouseButton1Click:Connect(hideShop)
overlay.MouseButton1Click:Connect(hideShop)

-- Close button hover
closeBtn.MouseEnter:Connect(function()
	TweenService:Create(closeBtn, TweenInfo.new(0.2), {
		BackgroundColor3 = Color3.fromRGB(239, 68, 68),
		TextColor3 = Color3.new(1, 1, 1),
		Rotation = 90
	}):Play()
end)

closeBtn.MouseLeave:Connect(function()
	TweenService:Create(closeBtn, TweenInfo.new(0.2), {
		BackgroundColor3 = Color3.fromRGB(30, 41, 59),
		TextColor3 = Color3.fromRGB(148, 163, 184),
		Rotation = 0
	}):Play()
end)

print("Enhanced Shop UI loaded with cash and gamepass sections!")