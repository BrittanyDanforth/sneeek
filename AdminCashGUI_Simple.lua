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

-- Create simple notification function
local function notify(player, message, isSuccess)
	local gui = Instance.new("ScreenGui")
	gui.Name = "Notification"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")
	
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 400, 0, 100)
	frame.Position = UDim2.new(0.5, -200, 0, 20)
	frame.BackgroundColor3 = isSuccess and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
	frame.BorderSizePixel = 0
	frame.Parent = gui
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame
	
	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1, 0, 1, 0)
	text.BackgroundTransparency = 1
	text.Text = message
	text.TextScaled = true
	text.TextColor3 = Color3.new(1, 1, 1)
	text.Font = Enum.Font.SourceSansBold
	text.Parent = frame
	
	wait(3)
	gui:Destroy()
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
			
			-- Notify both players
			notify(player, "Gave $" .. amount .. " to " .. targetPlayer.Name .. "!", true)
			notify(targetPlayer, "You received $" .. amount .. " from " .. player.Name .. "!", true)
			
			print("SUCCESS: Gave $" .. amount .. " to " .. targetPlayer.Name)
		end
		
		-- Help command
		if message:lower() == "!help" and isAdmin(player) then
			notify(player, "Commands: !givecash username amount", true)
		end
	end)
	
	-- Welcome admins
	if isAdmin(player) then
		wait(3)
		notify(player, "Welcome Admin! Say !help for commands", true)
	end
end)

print("✅ Simple Admin Cash System Loaded!")
print("📋 Admins:", table.concat(ADMINS, ", "))
print("💬 Use chat command: !givecash username amount")