--[[
	Admin Cash GUI - WORKING VERSION
	Place this in ServerScriptService
]]

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ADMIN USERNAMES - Add your EXACT Roblox username here
local ADMINS = {
	"kinjys", -- Replace with your EXACT username (case sensitive!)
	-- Add more admin usernames here if needed
}

-- Create RemoteEvent
local remoteEvent = ReplicatedStorage:FindFirstChild("AdminGiveCash")
if not remoteEvent then
	remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = "AdminGiveCash"
	remoteEvent.Parent = ReplicatedStorage
end

-- Server Script
local function isAdmin(player)
	for _, adminName in ipairs(ADMINS) do
		if player.Name == adminName then
			return true
		end
	end
	return false
end

-- Handle cash giving
remoteEvent.OnServerEvent:Connect(function(player, targetUsername, amount)
	print("=== ADMIN CASH REQUEST ===")
	print("From:", player.Name)
	print("Target:", targetUsername)
	print("Amount:", amount)
	
	-- Check if admin
	if not isAdmin(player) then
		warn(player.Name .. " is not an admin!")
		return
	end
	
	-- Validate amount
	if type(amount) ~= "number" or amount <= 0 then
		print("Invalid amount:", amount)
		return
	end
	
	-- Find target player (try multiple methods)
	local targetPlayer = nil
	
	-- Method 1: Exact name match
	targetPlayer = Players:FindFirstChild(targetUsername)
	
	-- Method 2: Case insensitive search
	if not targetPlayer then
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Name:lower() == targetUsername:lower() then
				targetPlayer = p
				break
			end
		end
	end
	
	-- Method 3: Partial match
	if not targetPlayer then
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Name:lower():find(targetUsername:lower(), 1, true) then
				targetPlayer = p
				break
			end
		end
	end
	
	if not targetPlayer then
		print("ERROR: Could not find player:", targetUsername)
		print("Players online:")
		for _, p in ipairs(Players:GetPlayers()) do
			print(" -", p.Name)
		end
		return
	end
	
	print("Found player:", targetPlayer.Name)
	
	-- Give cash
	local playerMoney = ServerStorage:WaitForChild("PlayerMoney", 5)
	if not playerMoney then
		print("ERROR: PlayerMoney folder not found in ServerStorage!")
		return
	end
	
	local targetMoney = playerMoney:FindFirstChild(targetPlayer.Name)
	if not targetMoney then
		print("ERROR: No money data for", targetPlayer.Name)
		-- Try to create it
		targetMoney = Instance.new("NumberValue")
		targetMoney.Name = targetPlayer.Name
		targetMoney.Value = 0
		targetMoney.Parent = playerMoney
		print("Created money data for", targetPlayer.Name)
	end
	
	-- Add the cash
	local oldValue = targetMoney.Value
	targetMoney.Value = targetMoney.Value + amount
	
	print("SUCCESS! Gave", amount, "cash to", targetPlayer.Name)
	print("Old value:", oldValue, "New value:", targetMoney.Value)
end)

-- LocalScript Code (as a string)
local clientCode = [[
-- Admin Cash GUI Client
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

print("Admin GUI loading for:", player.Name)

-- Wait for remote
local remoteEvent = ReplicatedStorage:WaitForChild("AdminGiveCash", 10)
if not remoteEvent then
	warn("AdminGiveCash remote not found!")
	return
end

-- Create GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AdminCashGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
title.BorderSizePixel = 0
title.Text = "ADMIN CASH GIVER"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

-- Username box
local userLabel = Instance.new("TextLabel")
userLabel.Size = UDim2.new(0.3, 0, 0, 30)
userLabel.Position = UDim2.new(0.05, 0, 0.25, 0)
userLabel.BackgroundTransparency = 1
userLabel.Text = "Player:"
userLabel.TextColor3 = Color3.new(1, 1, 1)
userLabel.TextScaled = true
userLabel.Font = Enum.Font.SourceSans
userLabel.Parent = frame

local userBox = Instance.new("TextBox")
userBox.Size = UDim2.new(0.6, 0, 0, 30)
userBox.Position = UDim2.new(0.35, 0, 0.25, 0)
userBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
userBox.BorderSizePixel = 0
userBox.Text = ""
userBox.PlaceholderText = "Username"
userBox.TextColor3 = Color3.new(1, 1, 1)
userBox.TextScaled = true
userBox.Font = Enum.Font.SourceSans
userBox.ClearTextOnFocus = false
userBox.Parent = frame

local userCorner = Instance.new("UICorner")
userCorner.CornerRadius = UDim.new(0, 5)
userCorner.Parent = userBox

-- Amount box
local amountLabel = Instance.new("TextLabel")
amountLabel.Size = UDim2.new(0.3, 0, 0, 30)
amountLabel.Position = UDim2.new(0.05, 0, 0.5, 0)
amountLabel.BackgroundTransparency = 1
amountLabel.Text = "Amount:"
amountLabel.TextColor3 = Color3.new(1, 1, 1)
amountLabel.TextScaled = true
amountLabel.Font = Enum.Font.SourceSans
amountLabel.Parent = frame

local amountBox = Instance.new("TextBox")
amountBox.Size = UDim2.new(0.6, 0, 0, 30)
amountBox.Position = UDim2.new(0.35, 0, 0.5, 0)
amountBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
amountBox.BorderSizePixel = 0
amountBox.Text = ""
amountBox.PlaceholderText = "Amount"
amountBox.TextColor3 = Color3.new(1, 1, 1)
amountBox.TextScaled = true
amountBox.Font = Enum.Font.SourceSans
amountBox.ClearTextOnFocus = false
amountBox.Parent = frame

local amountCorner = Instance.new("UICorner")
amountCorner.CornerRadius = UDim.new(0, 5)
amountCorner.Parent = amountBox

-- Give button
local giveBtn = Instance.new("TextButton")
giveBtn.Size = UDim2.new(0.9, 0, 0, 35)
giveBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
giveBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
giveBtn.BorderSizePixel = 0
giveBtn.Text = "GIVE CASH"
giveBtn.TextColor3 = Color3.new(1, 1, 1)
giveBtn.TextScaled = true
giveBtn.Font = Enum.Font.SourceSansBold
giveBtn.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 5)
btnCorner.Parent = giveBtn

-- Toggle button
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 80, 0, 30)
toggle.Position = UDim2.new(0, 10, 1, -40)
toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggle.BorderSizePixel = 0
toggle.Text = "Admin"
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.TextScaled = true
toggle.Font = Enum.Font.SourceSansBold
toggle.Parent = gui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 5)
toggleCorner.Parent = toggle

-- Toggle visibility
local visible = true
toggle.MouseButton1Click:Connect(function()
	visible = not visible
	frame.Visible = visible
end)

-- Give cash function
giveBtn.MouseButton1Click:Connect(function()
	local username = userBox.Text
	local amount = tonumber(amountBox.Text)
	
	print("=== GIVE CASH CLICKED ===")
	print("Username:", username)
	print("Amount:", amount)
	
	-- Validation
	if username == "" then
		giveBtn.Text = "ENTER USERNAME!"
		giveBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		wait(1)
		giveBtn.Text = "GIVE CASH"
		giveBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
		return
	end
	
	if not amount or amount <= 0 then
		giveBtn.Text = "INVALID AMOUNT!"
		giveBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		wait(1)
		giveBtn.Text = "GIVE CASH"
		giveBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
		return
	end
	
	-- Send to server
	print("Sending to server...")
	remoteEvent:FireServer(username, amount)
	
	-- Visual feedback
	giveBtn.Text = "SENT!"
	giveBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
	
	-- Clear boxes
	userBox.Text = ""
	amountBox.Text = ""
	
	wait(1)
	giveBtn.Text = "GIVE CASH"
	giveBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
end)

print("Admin GUI loaded successfully!")
]]

-- Give GUI to admins
Players.PlayerAdded:Connect(function(player)
	print(player.Name .. " joined the game")
	
	if isAdmin(player) then
		print(player.Name .. " is an admin! Giving GUI...")
		
		-- Wait for character
		player.CharacterAdded:Connect(function()
			wait(1)
			
			-- Create LocalScript
			local localScript = Instance.new("LocalScript")
			localScript.Name = "AdminCashGUIClient"
			localScript.Source = clientCode
			localScript.Parent = player:WaitForChild("PlayerGui")
			
			print("Admin GUI given to " .. player.Name)
		end)
		
		-- Also give if character already exists
		if player.Character then
			wait(1)
			local localScript = Instance.new("LocalScript")
			localScript.Name = "AdminCashGUIClient"
			localScript.Source = clientCode
			localScript.Parent = player:WaitForChild("PlayerGui")
			print("Admin GUI given to " .. player.Name .. " (character already loaded)")
		end
	else
		print(player.Name .. " is not an admin")
	end
end)

-- Debug: Print all players periodically
task.spawn(function()
	while true do
		wait(10)
		print("\n=== PLAYERS ONLINE ===")
		for _, p in ipairs(Players:GetPlayers()) do
			local money = ServerStorage:FindFirstChild("PlayerMoney")
			if money then
				local playerMoney = money:FindFirstChild(p.Name)
				if playerMoney then
					print(p.Name .. " - $" .. playerMoney.Value)
				else
					print(p.Name .. " - No money data")
				end
			end
		end
		print("====================\n")
	end
end)

print("✅ Admin Cash GUI Script Loaded!")
print("📋 Admins:", table.concat(ADMINS, ", "))