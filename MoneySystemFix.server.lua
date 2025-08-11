-- Money System Fix
-- This ensures the UnifiedLeaderboard money system works with purchases
-- Place in ServerScriptService

local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

-- Wait for everything to load
wait(2)

print("=== MONEY SYSTEM FIX STARTING ===")

-- Find or create PlayerMoney folder
local playerMoneyFolder = ServerStorage:FindFirstChild("PlayerMoney")
if not playerMoneyFolder then
	playerMoneyFolder = Instance.new("Folder")
	playerMoneyFolder.Name = "PlayerMoney"
	playerMoneyFolder.Parent = ServerStorage
	print("Created PlayerMoney folder")
end

-- Get Settings for formatting
local Settings = _G.Settings

if not Settings then
	-- Try to load it
	pcall(function()
		local settingsModule = game.ServerScriptService:FindFirstChild("Settings") 
			or game.ServerStorage:FindFirstChild("Settings")
			or workspace:FindFirstChild("Settings", true)
		if settingsModule then
			Settings = require(settingsModule)
			_G.Settings = Settings
		end
	end)
end

if not Settings then
	-- Default settings if not found
	Settings = {
		LeaderboardSettings = {
			ShowShortCurrency = true,
			ShowCurrency = true,
		},
		CurrencyName = "Cash",
		ConvertShort = function(self, value)
			value = tonumber(value) or 0
			if value >= 1000000000 then
				return string.format("%.1fB", value / 1000000000)
			elseif value >= 1000000 then
				return string.format("%.1fM", value / 1000000)
			elseif value >= 1000 then
				return string.format("%.1fK", value / 1000)
			else
				return tostring(value)
			end
		end,
		ConvertComma = function(self, value)
			local formatted = tostring(value)
			while true do
				local newFormatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
				if k == 0 then break end
				formatted = newFormatted
			end
			return formatted
		end
	}
end

-- Function to ensure player has money value and update display
local function ensurePlayerMoney(player)
	local playerName = player.Name
	
	-- Get or create money value
	local moneyValue = playerMoneyFolder:FindFirstChild(playerName)
	if not moneyValue then
		moneyValue = Instance.new("IntValue")
		moneyValue.Name = playerName
		moneyValue.Value = 0
		moneyValue.Parent = playerMoneyFolder
		print("Created money value for", playerName)
	end
	
	-- Function to update display
	local function updateDisplay()
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local cashDisplay = leaderstats:FindFirstChild(Settings.CurrencyName or "Cash")
			if cashDisplay and cashDisplay:IsA("StringValue") then
				local value = moneyValue.Value
				if Settings.LeaderboardSettings.ShowShortCurrency then
					cashDisplay.Value = Settings:ConvertShort(value)
				else
					cashDisplay.Value = Settings:ConvertComma(value)
				end
				print("Updated", playerName, "cash display to", cashDisplay.Value, "(raw:", value, ")")
			end
		end
	end
	
	-- Set up value changed connection
	local connection = moneyValue.Changed:Connect(updateDisplay)
	
	-- Watch for leaderstats creation
	local leaderConnection
	leaderConnection = player.ChildAdded:Connect(function(child)
		if child.Name == "leaderstats" then
			wait(0.1) -- Let Cash StringValue be created
			updateDisplay() -- Update immediately
			
			-- Watch for Cash StringValue creation
			local cashWatch
			cashWatch = child.ChildAdded:Connect(function(cashChild)
				if cashChild.Name == (Settings.CurrencyName or "Cash") then
					updateDisplay()
					cashWatch:Disconnect()
				end
			end)
		end
	end)
	
	-- Initial update if leaderstats already exists
	updateDisplay()
	
	-- Clean up on player leaving
	player.AncestryChanged:Connect(function()
		if not player.Parent then
			connection:Disconnect()
			if leaderConnection then
				leaderConnection:Disconnect()
			end
		end
	end)
end

-- Process all current players
for _, player in pairs(Players:GetPlayers()) do
	ensurePlayerMoney(player)
end

-- Process new players
Players.PlayerAdded:Connect(ensurePlayerMoney)

-- Override global money functions with better versions
_G.AddPlayerMoney = function(playerName, amount)
	local moneyValue = playerMoneyFolder:FindFirstChild(playerName)
	if not moneyValue then
		moneyValue = Instance.new("IntValue")
		moneyValue.Name = playerName
		moneyValue.Value = 0
		moneyValue.Parent = playerMoneyFolder
	end
	
	moneyValue.Value = moneyValue.Value + amount
	print("Added", amount, "cash to", playerName, "new total:", moneyValue.Value)
	return true
end

_G.SetPlayerMoney = function(playerName, amount)
	local moneyValue = playerMoneyFolder:FindFirstChild(playerName)
	if not moneyValue then
		moneyValue = Instance.new("IntValue")
		moneyValue.Name = playerName
		moneyValue.Parent = playerMoneyFolder
	end
	
	moneyValue.Value = amount
	print("Set", playerName, "cash to", amount)
	return true
end

_G.GetPlayerMoney = function(playerName)
	local moneyValue = playerMoneyFolder:FindFirstChild(playerName)
	if moneyValue then
		return moneyValue.Value
	end
	return 0
end

print("=== MONEY SYSTEM FIX COMPLETE ===")
print("Global money functions ready")
print("Monitoring", #Players:GetPlayers(), "players")