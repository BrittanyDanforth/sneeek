-- Unified Leaderboard Patch
-- This script patches the existing leaderboard to ensure money values work correctly
-- Place this in ServerScriptService AFTER the UnifiedLeaderboard script

local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Wait a bit to ensure the main leaderboard script has loaded
wait(1)

print("=== UNIFIED LEADERBOARD PATCH STARTING ===")

-- Ensure PlayerMoney folder exists
local playerMoneyFolder = ServerStorage:FindFirstChild("PlayerMoney")
if not playerMoneyFolder then
	playerMoneyFolder = Instance.new("Folder")
	playerMoneyFolder.Name = "PlayerMoney"
	playerMoneyFolder.Parent = ServerStorage
	print("Created PlayerMoney folder in patch")
end

-- Override the global money functions to ensure they always work
_G.AddPlayerMoney = function(playerName, amount)
	local moneyValue = playerMoneyFolder:FindFirstChild(playerName)
	if not moneyValue then
		moneyValue = Instance.new("IntValue")
		moneyValue.Name = playerName
		moneyValue.Value = 0
		moneyValue.Parent = playerMoneyFolder
	end
	moneyValue.Value = moneyValue.Value + amount
	
	-- Update leaderboard display if player has leaderstats
	local player = Players:FindFirstChild(playerName)
	if player then
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local cashDisplay = leaderstats:FindFirstChild("Cash")
			if cashDisplay and _G.Settings then
				if _G.Settings.LeaderboardSettings.ShowShortCurrency then
					cashDisplay.Value = _G.Settings:ConvertShort(moneyValue.Value)
				else
					cashDisplay.Value = _G.Settings:ConvertComma(moneyValue.Value)
				end
			end
		end
	end
	
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
	
	-- Update leaderboard display
	local player = Players:FindFirstChild(playerName)
	if player then
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local cashDisplay = leaderstats:FindFirstChild("Cash")
			if cashDisplay and _G.Settings then
				if _G.Settings.LeaderboardSettings.ShowShortCurrency then
					cashDisplay.Value = _G.Settings:ConvertShort(moneyValue.Value)
				else
					cashDisplay.Value = _G.Settings:ConvertComma(moneyValue.Value)
				end
			end
		end
	end
	
	return true
end

_G.GetPlayerMoney = function(playerName)
	local moneyValue = playerMoneyFolder:FindFirstChild(playerName)
	if moneyValue then
		return moneyValue.Value
	end
	return 0
end

-- Function to update a player's cash display
local function updatePlayerCashDisplay(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then return end
	
	local cashDisplay = leaderstats:FindFirstChild("Cash")
	if not cashDisplay then return end
	
	local moneyValue = playerMoneyFolder:FindFirstChild(player.Name)
	if moneyValue and _G.Settings then
		if _G.Settings.LeaderboardSettings.ShowShortCurrency then
			cashDisplay.Value = _G.Settings:ConvertShort(moneyValue.Value)
		else
			cashDisplay.Value = _G.Settings:ConvertComma(moneyValue.Value)
		end
	end
end

-- Patch existing players
for _, player in pairs(Players:GetPlayers()) do
	-- Ensure they have a money value
	if not playerMoneyFolder:FindFirstChild(player.Name) then
		local moneyValue = Instance.new("IntValue")
		moneyValue.Name = player.Name
		moneyValue.Value = 0
		moneyValue.Parent = playerMoneyFolder
	end
	
	-- Update their display if they have leaderstats
	updatePlayerCashDisplay(player)
end

-- Hook into CharacterAdded to update cash when they join a team
Players.PlayerAdded:Connect(function(player)
	-- Ensure money value exists immediately
	if not playerMoneyFolder:FindFirstChild(player.Name) then
		local moneyValue = Instance.new("IntValue")
		moneyValue.Name = player.Name
		moneyValue.Value = 0
		moneyValue.Parent = playerMoneyFolder
		print("Created money value for new player:", player.Name)
	end
	
	-- Update display when leaderstats are created
	player.ChildAdded:Connect(function(child)
		if child.Name == "leaderstats" then
			wait(0.1) -- Small delay to ensure Cash StringValue is created
			updatePlayerCashDisplay(player)
		end
	end)
end)

print("=== UNIFIED LEADERBOARD PATCH COMPLETE ===")
print("Money API functions available globally")
print("Players with pre-existing money will keep their values")