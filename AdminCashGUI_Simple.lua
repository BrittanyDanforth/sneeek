--[[
	SIMPLE Admin Cash GUI
	
	HOW TO USE:
	1. Put this script in ServerScriptService
	2. Put your username in the ADMINS list below
	3. Say "!givecash username amount" in chat
	   Example: !givecash kinjys 5000
]]

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- ADMIN USERNAMES - Put your EXACT username here!
local ADMINS = {
	"kinjys", -- Your username here
	-- Add more admins if needed
}

-- Check if player is admin
local function isAdmin(player)
	for _, adminName in ipairs(ADMINS) do
		if player.Name == adminName then
			return true
		end
	end
	return false
end

-- Create beautiful notification
local function notify(player, message, isSuccess, amount)
	local gui = Instance.new("ScreenGui")
	gui.Name = "CashNotification"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 1000
	gui.Parent = player:WaitForChild("PlayerGui")
	
	-- Main container
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, 500, 0, 140)
	container.Position = UDim2.new(0.5, 0, 0, -150) -- Start off-screen
	container.AnchorPoint = Vector2.new(0.5, 0)
	container.BackgroundTransparency = 1
	container.Parent = gui
	
	-- Shadow/glow effect
	local glow = Instance.new("ImageLabel")
	glow.Name = "Glow"
	glow.Size = UDim2.new(1, 80, 1, 80)
	glow.Position = UDim2.new(0.5, 0, 0.5, 0)
	glow.AnchorPoint = Vector2.new(0.5, 0.5)
	glow.BackgroundTransparency = 1
	glow.Image = "rbxassetid://6015897843"
	glow.ImageColor3 = isSuccess and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 120, 120)
	glow.ImageTransparency = 0.5
	glow.ScaleType = Enum.ScaleType.Slice
	glow.SliceCenter = Rect.new(49, 49, 450, 450)
	glow.ZIndex = 1
	glow.Parent = container
	
	-- Main frame
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.new(1, 1, 1)
	frame.BorderSizePixel = 0
	frame.ZIndex = 2
	frame.Parent = container
	
	-- Rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 20)
	corner.Parent = frame
	
	-- Gradient background
	local gradient = Instance.new("UIGradient")
	if isSuccess then
		gradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 253, 250)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(250, 255, 250)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(245, 255, 245))
		}
	else
		gradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 250, 250)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 245, 245)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 240, 240))
		}
	end
	gradient.Rotation = 90
	gradient.Parent = frame
	
	-- Border stroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = isSuccess and Color3.fromRGB(100, 220, 100) or Color3.fromRGB(220, 100, 100)
	stroke.Thickness = 2
	stroke.Transparency = 0.5
	stroke.Parent = frame
	
	-- Icon background circle
	local iconBg = Instance.new("Frame")
	iconBg.Size = UDim2.new(0, 80, 0, 80)
	iconBg.Position = UDim2.new(0, 30, 0.5, 0)
	iconBg.AnchorPoint = Vector2.new(0, 0.5)
	iconBg.BackgroundColor3 = isSuccess and Color3.fromRGB(100, 220, 100) or Color3.fromRGB(220, 100, 100)
	iconBg.BorderSizePixel = 0
	iconBg.ZIndex = 3
	iconBg.Parent = frame
	
	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(1, 0)
	iconCorner.Parent = iconBg
	
	-- Icon
	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.new(1, 0, 1, 0)
	icon.BackgroundTransparency = 1
	icon.Text = isSuccess and "💰" or "❌"
	icon.TextScaled = true
	icon.TextColor3 = Color3.new(1, 1, 1)
	icon.Font = Enum.Font.SourceSansBold
	icon.ZIndex = 4
	icon.Parent = iconBg
	
	-- Message container
	local textContainer = Instance.new("Frame")
	textContainer.Size = UDim2.new(1, -150, 1, -20)
	textContainer.Position = UDim2.new(0, 130, 0, 10)
	textContainer.BackgroundTransparency = 1
	textContainer.ZIndex = 3
	textContainer.Parent = frame
	
	-- Main text
	local mainText = Instance.new("TextLabel")
	mainText.Size = UDim2.new(1, 0, 0.5, 0)
	mainText.Position = UDim2.new(0, 0, 0, 5)
	mainText.BackgroundTransparency = 1
	mainText.Text = isSuccess and "Cash Received!" or "Action Failed"
	mainText.TextScaled = true
	mainText.TextColor3 = Color3.fromRGB(50, 50, 50)
	mainText.Font = Enum.Font.SourceSansBold
	mainText.ZIndex = 4
	mainText.Parent = textContainer
	
	-- Detail text
	local detailText = Instance.new("TextLabel")
	detailText.Size = UDim2.new(1, 0, 0.4, 0)
	detailText.Position = UDim2.new(0, 0, 0.5, 0)
	detailText.BackgroundTransparency = 1
	detailText.Text = message
	detailText.TextScaled = true
	detailText.TextColor3 = Color3.fromRGB(100, 100, 100)
	detailText.Font = Enum.Font.SourceSans
	detailText.ZIndex = 4
	detailText.Parent = textContainer
	
	-- Amount display (if provided)
	if amount and isSuccess then
		-- Cash amount in big text
		local amountLabel = Instance.new("TextLabel")
		amountLabel.Size = UDim2.new(0.5, 0, 0.4, 0)
		amountLabel.Position = UDim2.new(1, -10, 0.5, 0)
		amountLabel.AnchorPoint = Vector2.new(1, 0.5)
		amountLabel.BackgroundTransparency = 1
		amountLabel.Text = "+$" .. tostring(amount)
		amountLabel.TextScaled = true
		amountLabel.TextColor3 = Color3.fromRGB(50, 200, 50)
		amountLabel.Font = Enum.Font.SourceSansBold
		amountLabel.ZIndex = 4
		amountLabel.Parent = frame
		
		-- Add shimmer effect
		local shimmer = Instance.new("Frame")
		shimmer.Size = UDim2.new(0, 100, 2, 0)
		shimmer.Position = UDim2.new(-0.5, 0, 0, 0)
		shimmer.BackgroundColor3 = Color3.new(1, 1, 1)
		shimmer.BackgroundTransparency = 0.8
		shimmer.BorderSizePixel = 0
		shimmer.ZIndex = 5
		shimmer.Parent = frame
		
		local shimmerGradient = Instance.new("UIGradient")
		shimmerGradient.Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(1, 1)
		}
		shimmerGradient.Rotation = 45
		shimmerGradient.Parent = shimmer
		
		-- Animate shimmer
		local shimmerTween = TweenService:Create(shimmer, 
			TweenInfo.new(1, Enum.EasingStyle.Linear), 
			{Position = UDim2.new(1.5, 0, 0, 0)}
		)
		shimmerTween:Play()
	end
	
	-- Sparkle particles (for success)
	if isSuccess then
		for i = 1, 5 do
			local sparkle = Instance.new("Frame")
			sparkle.Size = UDim2.new(0, 6, 0, 6)
			sparkle.Position = UDim2.new(math.random(), 0, math.random(), 0)
			sparkle.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
			sparkle.BorderSizePixel = 0
			sparkle.ZIndex = 6
			sparkle.Parent = container
			
			local sparkleCorner = Instance.new("UICorner")
			sparkleCorner.CornerRadius = UDim.new(1, 0)
			sparkleCorner.Parent = sparkle
			
			-- Animate sparkles
			local startPos = sparkle.Position
			local endPos = UDim2.new(startPos.X.Scale, 0, startPos.Y.Scale - 0.3, 0)
			
			local sparkleTween = TweenService:Create(sparkle,
				TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Position = endPos, BackgroundTransparency = 1}
			)
			sparkleTween:Play()
		end
	end
	
	-- Animate entrance
	local slideIn = TweenService:Create(container,
		TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Position = UDim2.new(0.5, 0, 0, 50)}
	)
	
	local fadeIn = TweenService:Create(glow,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad),
		{ImageTransparency = 0.3}
	)
	
	-- Icon bounce animation
	local iconBounce = TweenService:Create(iconBg,
		TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{Size = UDim2.new(0, 90, 0, 90)}
	)
	
	local iconBounceBack = TweenService:Create(iconBg,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = UDim2.new(0, 80, 0, 80)}
	)
	
	slideIn:Play()
	fadeIn:Play()
	wait(0.2)
	iconBounce:Play()
	iconBounce.Completed:Connect(function()
		iconBounceBack:Play()
	end)
	
	-- Auto dismiss
	wait(3.5)
	
	-- Animate exit
	local slideOut = TweenService:Create(container,
		TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In),
		{Position = UDim2.new(0.5, 0, 0, -150)}
	)
	
	local fadeOut = TweenService:Create(frame,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad),
		{BackgroundTransparency = 1}
	)
	
	local glowFadeOut = TweenService:Create(glow,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad),
		{ImageTransparency = 1}
	)
	
	slideOut:Play()
	fadeOut:Play()
	glowFadeOut:Play()
	
	slideOut.Completed:Connect(function()
		gui:Destroy()
	end)
end

-- Handle chat commands
Players.PlayerAdded:Connect(function(player)
	print(player.Name .. " joined")
	
	-- Create money value if it doesn't exist
	local playerMoney = ServerStorage:WaitForChild("PlayerMoney", 5)
	if playerMoney and not playerMoney:FindFirstChild(player.Name) then
		local money = Instance.new("NumberValue")
		money.Name = player.Name
		money.Value = 0
		money.Parent = playerMoney
	end
	
	-- Listen to chat
	player.Chatted:Connect(function(message)
		-- Check if admin
		if not isAdmin(player) then return end
		
		-- Check for givecash command
		local args = message:split(" ")
		if args[1]:lower() == "!givecash" then
			-- Parse command
			local targetName = args[2]
			local amount = tonumber(args[3])
			
			print("GIVECASH COMMAND:")
			print("From:", player.Name)
			print("Target:", targetName)
			print("Amount:", amount)
			
			-- Validate
			if not targetName then
				notify(player, "Usage: !givecash username amount", false)
				return
			end
			
			if not amount or amount <= 0 then
				notify(player, "Invalid amount! Use a positive number.", false)
				return
			end
			
			-- Find target player
			local targetPlayer = nil
			for _, p in ipairs(Players:GetPlayers()) do
				if p.Name:lower() == targetName:lower() then
					targetPlayer = p
					break
				end
			end
			
			if not targetPlayer then
				notify(player, "Player '" .. targetName .. "' not found!", false)
				return
			end
			
			-- Give cash
			local playerMoney = ServerStorage:FindFirstChild("PlayerMoney")
			if not playerMoney then
				notify(player, "ERROR: PlayerMoney folder not found!", false)
				return
			end
			
			local targetMoney = playerMoney:FindFirstChild(targetPlayer.Name)
			if not targetMoney then
				-- Create it
				targetMoney = Instance.new("NumberValue")
				targetMoney.Name = targetPlayer.Name
				targetMoney.Value = 0
				targetMoney.Parent = playerMoney
			end
			
			-- Add cash
			targetMoney.Value = targetMoney.Value + amount
			
			-- Notify both players with beautiful notifications
			notify(player, "Successfully sent to " .. targetPlayer.Name, true)
			notify(targetPlayer, "From " .. player.Name, true, amount)
			
			print("SUCCESS: Gave $" .. amount .. " to " .. targetPlayer.Name)
		end
		
		-- Help command
		if message:lower() == "!help" and isAdmin(player) then
			notify(player, "Commands: !givecash username amount", true)
		end
	end)
	
	-- Welcome admins with style
	if isAdmin(player) then
		wait(3)
		notify(player, "Type !help for commands", true)
	end
end)

print("✅ Beautiful Admin Cash System Loaded!")
print("📋 Admins:", table.concat(ADMINS, ", "))
print("💬 Use chat command: !givecash username amount")