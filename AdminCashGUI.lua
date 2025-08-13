--[[
	Admin Cash GUI - Simple Money Giver
	Only specific usernames can access this GUI
	Place this in ServerScriptService
]]

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ADMIN USERNAMES - Add your admin usernames here
local ADMINS = {
	"kinjys", -- Replace with your username
	"AdminUsername2", -- Add more admins here
	"AdminUsername3",
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

-- Create RemoteEvent for secure communication
local remoteEvent = ReplicatedStorage:FindFirstChild("AdminGiveCash")
if not remoteEvent then
	remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = "AdminGiveCash"
	remoteEvent.Parent = ReplicatedStorage
end

-- Create GUI for admin
local function createAdminGUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AdminCashGUI"
	screenGui.ResetOnSpawn = false
	
	-- Main Frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 350, 0, 250)
	mainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
	mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui
	
	-- Round corners
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 12)
	uiCorner.Parent = mainFrame
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 40)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	title.BorderSizePixel = 0
	title.Text = "💰 ADMIN CASH GIVER"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextScaled = true
	title.Font = Enum.Font.SourceSansBold
	title.Parent = mainFrame
	
	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 12)
	titleCorner.Parent = title
	
	-- Username Input
	local usernameLabel = Instance.new("TextLabel")
	usernameLabel.Name = "UsernameLabel"
	usernameLabel.Size = UDim2.new(0, 100, 0, 30)
	usernameLabel.Position = UDim2.new(0, 20, 0, 60)
	usernameLabel.BackgroundTransparency = 1
	usernameLabel.Text = "Username:"
	usernameLabel.TextColor3 = Color3.new(1, 1, 1)
	usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
	usernameLabel.Font = Enum.Font.SourceSans
	usernameLabel.TextSize = 18
	usernameLabel.Parent = mainFrame
	
	local usernameInput = Instance.new("TextBox")
	usernameInput.Name = "UsernameInput"
	usernameInput.Size = UDim2.new(0, 200, 0, 35)
	usernameInput.Position = UDim2.new(0, 120, 0, 55)
	usernameInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	usernameInput.BorderSizePixel = 0
	usernameInput.Text = ""
	usernameInput.PlaceholderText = "Enter player name..."
	usernameInput.TextColor3 = Color3.new(1, 1, 1)
	usernameInput.Font = Enum.Font.SourceSans
	usernameInput.TextSize = 16
	usernameInput.Parent = mainFrame
	
	local usernameCorner = Instance.new("UICorner")
	usernameCorner.CornerRadius = UDim.new(0, 8)
	usernameCorner.Parent = usernameInput
	
	-- Amount Input
	local amountLabel = Instance.new("TextLabel")
	amountLabel.Name = "AmountLabel"
	amountLabel.Size = UDim2.new(0, 100, 0, 30)
	amountLabel.Position = UDim2.new(0, 20, 0, 110)
	amountLabel.BackgroundTransparency = 1
	amountLabel.Text = "Amount:"
	amountLabel.TextColor3 = Color3.new(1, 1, 1)
	amountLabel.TextXAlignment = Enum.TextXAlignment.Left
	amountLabel.Font = Enum.Font.SourceSans
	amountLabel.TextSize = 18
	amountLabel.Parent = mainFrame
	
	local amountInput = Instance.new("TextBox")
	amountInput.Name = "AmountInput"
	amountInput.Size = UDim2.new(0, 200, 0, 35)
	amountInput.Position = UDim2.new(0, 120, 0, 105)
	amountInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	amountInput.BorderSizePixel = 0
	amountInput.Text = ""
	amountInput.PlaceholderText = "Enter amount..."
	amountInput.TextColor3 = Color3.new(1, 1, 1)
	amountInput.Font = Enum.Font.SourceSans
	amountInput.TextSize = 16
	amountInput.Parent = mainFrame
	
	local amountCorner = Instance.new("UICorner")
	amountCorner.CornerRadius = UDim.new(0, 8)
	amountCorner.Parent = amountInput
	
	-- Give Button
	local giveButton = Instance.new("TextButton")
	giveButton.Name = "GiveButton"
	giveButton.Size = UDim2.new(0, 150, 0, 40)
	giveButton.Position = UDim2.new(0.5, -75, 0, 160)
	giveButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	giveButton.BorderSizePixel = 0
	giveButton.Text = "GIVE CASH"
	giveButton.TextColor3 = Color3.new(1, 1, 1)
	giveButton.Font = Enum.Font.SourceSansBold
	giveButton.TextSize = 20
	giveButton.Parent = mainFrame
	
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 8)
	buttonCorner.Parent = giveButton
	
	-- Status Label
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Size = UDim2.new(1, -40, 0, 20)
	statusLabel.Position = UDim2.new(0, 20, 0, 210)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = ""
	statusLabel.TextColor3 = Color3.new(1, 1, 1)
	statusLabel.Font = Enum.Font.SourceSans
	statusLabel.TextSize = 14
	statusLabel.Parent = mainFrame
	
	-- Toggle Button (minimize/maximize)
	local toggleButton = Instance.new("TextButton")
	toggleButton.Name = "ToggleButton"
	toggleButton.Size = UDim2.new(0, 100, 0, 30)
	toggleButton.Position = UDim2.new(0, 10, 1, -40)
	toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	toggleButton.BorderSizePixel = 0
	toggleButton.Text = "💰 Admin"
	toggleButton.TextColor3 = Color3.new(1, 1, 1)
	toggleButton.Font = Enum.Font.SourceSansBold
	toggleButton.TextSize = 16
	toggleButton.Parent = screenGui
	
	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 8)
	toggleCorner.Parent = toggleButton
	
	-- Toggle functionality
	local isOpen = true
	toggleButton.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		mainFrame.Visible = isOpen
	end)
	
	-- Give button functionality
	giveButton.MouseButton1Click:Connect(function()
		local username = usernameInput.Text
		local amount = tonumber(amountInput.Text)
		
		if username == "" then
			statusLabel.Text = "❌ Please enter a username"
			statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
			return
		end
		
		if not amount or amount <= 0 then
			statusLabel.Text = "❌ Please enter a valid amount"
			statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
			return
		end
		
		-- Fire remote event
		remoteEvent:FireServer(username, amount)
	end)
	
	return screenGui
end

-- Handle remote event on server
remoteEvent.OnServerEvent:Connect(function(player, targetUsername, amount)
	-- Security check - is player an admin?
	if not isAdmin(player) then
		warn(player.Name .. " tried to use admin commands without permission!")
		return
	end
	
	-- Validate inputs
	if type(targetUsername) ~= "string" or type(amount) ~= "number" then
		return
	end
	
	-- Find target player
	local targetPlayer = nil
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Name:lower() == targetUsername:lower() then
			targetPlayer = p
			break
		end
	end
	
	if not targetPlayer then
		-- Send error message back
		local gui = player.PlayerGui:FindFirstChild("AdminCashGUI")
		if gui then
			local statusLabel = gui.MainFrame.StatusLabel
			statusLabel.Text = "❌ Player '" .. targetUsername .. "' not found"
			statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		end
		return
	end
	
	-- Give cash (using your tycoon's money system)
	local playerMoney = ServerStorage:WaitForChild("PlayerMoney"):FindFirstChild(targetPlayer.Name)
	if playerMoney then
		playerMoney.Value = playerMoney.Value + amount
		
		-- Send success message
		local gui = player.PlayerGui:FindFirstChild("AdminCashGUI")
		if gui then
			local statusLabel = gui.MainFrame.StatusLabel
			statusLabel.Text = "✅ Gave $" .. tostring(amount) .. " to " .. targetPlayer.Name
			statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
			
			-- Clear inputs
			gui.MainFrame.UsernameInput.Text = ""
			gui.MainFrame.AmountInput.Text = ""
		end
		
		print("Admin " .. player.Name .. " gave $" .. amount .. " to " .. targetPlayer.Name)
	else
		-- Send error message
		local gui = player.PlayerGui:FindFirstChild("AdminCashGUI")
		if gui then
			local statusLabel = gui.MainFrame.StatusLabel
			statusLabel.Text = "❌ Could not find player's money data"
			statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		end
	end
end)

-- Give GUI to admins when they join
Players.PlayerAdded:Connect(function(player)
	if isAdmin(player) then
		player.CharacterAdded:Connect(function()
			wait(1) -- Wait for character to load
			
			-- Check if GUI already exists
			if not player.PlayerGui:FindFirstChild("AdminCashGUI") then
				local gui = createAdminGUI()
				gui.Parent = player.PlayerGui
				print("✅ Admin GUI given to " .. player.Name)
			end
		end)
	end
end)

print("💰 Admin Cash GUI loaded! Admins:", table.concat(ADMINS, ", "))