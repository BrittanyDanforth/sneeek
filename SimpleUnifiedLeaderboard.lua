-- SIMPLE UNIFIED LEADERBOARD
-- Just handles stats and clears ownership when player leaves
-- Place in ServerScriptService

print("⭐ SIMPLE UNIFIED LEADERBOARD STARTING...")

-- Services
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

-- Variables
local processedPlayers = {}
local Settings = nil

-- Create Money API
_G.AddPlayerMoney = function(playerName, amount)
	local moneyValue = playerMoneyFolder:FindFirstChild(playerName)
	if moneyValue then
		moneyValue.Value = moneyValue.Value + amount
		return true
	end
	return false
end

_G.SetPlayerMoney = function(playerName, amount)
	local moneyValue = playerMoneyFolder:FindFirstChild(playerName)
	if moneyValue then
		moneyValue.Value = amount
		return true
	end
	return false
end

_G.GetPlayerMoney = function(playerName)
	local moneyValue = playerMoneyFolder:FindFirstChild(playerName)
	return moneyValue and moneyValue.Value or 0
end

-- Create PlayerMoney folder
local playerMoneyFolder = ServerStorage:FindFirstChild("PlayerMoney")
if not playerMoneyFolder then
	playerMoneyFolder = Instance.new("Folder")
	playerMoneyFolder.Name = "PlayerMoney"
	playerMoneyFolder.Parent = ServerStorage
	print("Created PlayerMoney folder")
end

-- Load Settings
local function loadSettings()
	local locations = {
		game.ServerScriptService:FindFirstChild("Settings"),
		workspace:FindFirstChild("SpidermanTycoon"),
		workspace:FindFirstChild("Venom Tycoon"),
		workspace:FindFirstChild("Zednov's Tycoon Kit"),
		workspace:FindFirstChild("Cinnamoroll tycoon"),
	}

	for _, location in ipairs(locations) do
		if location then
			local settingsModule = location:FindFirstChild("Settings", true)
			if settingsModule and settingsModule:IsA("ModuleScript") then
				local success, module = pcall(require, settingsModule)
				if success then
					Settings = module
					print("Loaded Settings from:", location.Name)
					return true
				end
			end
		end
	end

	-- Default settings if not found
	Settings = {
		LeaderboardSettings = {
			KOs = true,
			WOs = true,
			ShowCurrency = true,
			ShowShortCurrency = true,
			KillsName = "KOs",
			DeathsName = "Wipeouts"
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

loadSettings()

-- Create player money value
local function getOrCreatePlayerMoney(playerName)
	local moneyValue = playerMoneyFolder:FindFirstChild(playerName)
	if not moneyValue then
		moneyValue = Instance.new("IntValue")
		moneyValue.Name = playerName
		moneyValue.Value = 0

		local ownsTycoon = Instance.new("ObjectValue")
		ownsTycoon.Name = "OwnsTycoon"
		ownsTycoon.Parent = moneyValue

		moneyValue.Parent = playerMoneyFolder
	end
	return moneyValue
end

-- Player joins
local function onPlayerEntered(player)
	if processedPlayers[player.Name] then return end
	processedPlayers[player.Name] = true

	print("Creating stats for:", player.Name)

	local playerMoney = getOrCreatePlayerMoney(player.Name)

	-- Create leaderstats
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"

	if Settings.LeaderboardSettings.KOs then
		local kills = Instance.new("IntValue")
		kills.Name = Settings.LeaderboardSettings.KillsName
		kills.Value = 0
		kills.Parent = stats
	end

	if Settings.LeaderboardSettings.WOs then
		local deaths = Instance.new("IntValue")
		deaths.Name = Settings.LeaderboardSettings.DeathsName
		deaths.Value = 0
		deaths.Parent = stats
	end

	if Settings.LeaderboardSettings.ShowCurrency then
		local cash = Instance.new("StringValue")
		cash.Name = Settings.CurrencyName
		cash.Value = "0"
		cash.Parent = stats

		-- Update display when money changes
		local function updateCash()
			if Settings.LeaderboardSettings.ShowShortCurrency then
				cash.Value = Settings:ConvertShort(playerMoney.Value)
			else
				cash.Value = Settings:ConvertComma(playerMoney.Value)
			end
		end

		updateCash()
		playerMoney.Changed:Connect(updateCash)
	end

	stats.Parent = player
end

-- Player leaves - JUST clear their tycoon ownership
local function onPlayerRemoving(player)
	print("🚪 Player leaving:", player.Name)
	processedPlayers[player.Name] = nil
	
	-- Get player's money data
	local playerMoney = playerMoneyFolder:FindFirstChild(player.Name)
	if playerMoney then
		local ownsTycoon = playerMoney:FindFirstChild("OwnsTycoon")
		if ownsTycoon and ownsTycoon.Value then
			-- Clear the tycoon's owner
			local tycoon = ownsTycoon.Value
			local owner = tycoon:FindFirstChild("Owner")
			if owner then
				owner.Value = nil
				print("  ✓ Cleared tycoon owner")
			end
			
			-- Clear the reference
			ownsTycoon.Value = nil
		end
		
		-- Reset money to 0
		playerMoney.Value = 0
		print("  ✓ Reset money to 0")
	end
end

-- Connect events
Players.PlayerAdded:Connect(onPlayerEntered)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Handle existing players
for _, player in pairs(Players:GetPlayers()) do
	task.spawn(onPlayerEntered, player)
end

print("✅ SIMPLE UNIFIED LEADERBOARD READY")
print("💰 Money API: Active")
print("🚪 Will clear tycoon owner on player leave")