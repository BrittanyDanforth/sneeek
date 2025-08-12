-- ⭐ UNIFIED LEADERBOARD SYSTEM ⭐
-- Handles leaderboard display and money management for all players
-- Place in ServerScriptService

print("⭐ UNIFIED LEADERBOARD STARTING...")

-- Services
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

-- Variables
local processedPlayers = {}
local Settings = nil
local CTF_mode = false

-- Clean up old scripts
local function cleanupOldScripts()
	local removedCount = 0
	
	-- Check workspace for old leaderboard scripts
	for _, model in pairs(workspace:GetDescendants()) do
		if model:IsA("Script") and model.Name == "LinkedLeaderboard" then
			model:Destroy()
			removedCount = removedCount + 1
		end
	end
	
	-- Check ServerScriptService
	for _, script in pairs(game.ServerScriptService:GetChildren()) do
		if script:IsA("Script") and script.Name == "LinkedLeaderboard" and script ~= script then
			script:Destroy()
			removedCount = removedCount + 1
		end
	end
	
	if removedCount > 0 then
		print("🧹 Cleaned up", removedCount, "old leaderboard scripts")
	end
end

-- Load settings
local function loadSettings()
	-- Try ServerScriptService first
	local settingsModule = game.ServerScriptService:FindFirstChild("Settings")
	if settingsModule and settingsModule:IsA("ModuleScript") then
		local success, module = pcall(require, settingsModule)
		if success then
			Settings = module
			print("✅ Loaded Settings from ServerScriptService")
			return true
		end
	end
	
	-- Try workspace tycoon kits
	local tycoonLocations = {
		workspace:FindFirstChild("SpidermanTycoon"),
		workspace:FindFirstChild("Venom Tycoon"),
		workspace:FindFirstChild("Zednov's Tycoon Kit"),
		workspace:FindFirstChild("Cinnamoroll tycoon")
	}
	
	for _, location in pairs(tycoonLocations) do
		if location then
			local settings = location:FindFirstChild("Settings", true)
			if settings and settings:IsA("ModuleScript") then
				local success, module = pcall(require, settings)
				if success then
					Settings = module
					print("✅ Loaded Settings from", location.Name)
					return true
				end
			end
		end
	end
	
	-- Use defaults if no settings found
	warn("⚠️ No Settings module found - using defaults")
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
			if value >= 1e9 then
				return string.format("%.1fB", value / 1e9)
			elseif value >= 1e6 then
				return string.format("%.1fM", value / 1e6)
			elseif value >= 1e3 then
				return string.format("%.1fK", value / 1e3)
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
	return false
end

-- Initialize
task.wait(0.1)
cleanupOldScripts()
loadSettings()

-- Setup PlayerMoney folder
local playerMoneyFolder = ServerStorage:FindFirstChild("PlayerMoney")
if not playerMoneyFolder then
	playerMoneyFolder = Instance.new("Folder")
	playerMoneyFolder.Name = "PlayerMoney"
	playerMoneyFolder.Parent = ServerStorage
	print("📁 Created PlayerMoney folder")
end

-- Helper function to get/create money value
local function getOrCreatePlayerMoney(playerName)
	local moneyValue = playerMoneyFolder:FindFirstChild(playerName)
	if not moneyValue then
		moneyValue = Instance.new("IntValue")
		moneyValue.Name = playerName
		moneyValue.Value = 0
		moneyValue.Parent = playerMoneyFolder
	end
	return moneyValue
end

-- Handle player death
local function onHumanoidDied(humanoid, player)
	local stats = player:FindFirstChild("leaderstats")
	if not stats then return end
	
	-- Increment deaths
	local deaths = stats:FindFirstChild(Settings.LeaderboardSettings.DeathsName)
	if deaths then
		deaths.Value = deaths.Value + 1
	end
	
	-- Handle kills
	if Settings.LeaderboardSettings.KOs then
		local tag = humanoid:FindFirstChild("creator")
		if tag and tag.Value and tag.Value.Parent then
			local killer = tag.Value
			local killerStats = killer:FindFirstChild("leaderstats")
			if killerStats then
				local kills = killerStats:FindFirstChild(Settings.LeaderboardSettings.KillsName)
				if kills then
					if killer ~= player then
						kills.Value = kills.Value + 1
					else
						kills.Value = kills.Value - 1  -- Suicide penalty
					end
				end
			end
		end
	end
end

-- Create player stats
local function createPlayerStats(player)
	-- Prevent duplicate stats
	if processedPlayers[player.Name] then
		return
	end
	processedPlayers[player.Name] = true
	
	print("👤 Creating stats for", player.Name)
	
	-- Create leaderstats immediately
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player
	
	-- Create KOs stat
	if Settings.LeaderboardSettings.KOs then
		local kills = Instance.new("IntValue")
		kills.Name = Settings.LeaderboardSettings.KillsName
		kills.Value = 0
		kills.Parent = stats
	end
	
	-- Create Deaths stat
	if Settings.LeaderboardSettings.WOs then
		local deaths = Instance.new("IntValue")
		deaths.Name = Settings.LeaderboardSettings.DeathsName
		deaths.Value = 0
		deaths.Parent = stats
	end
	
	-- Create Cash display
	if Settings.LeaderboardSettings.ShowCurrency then
		local cash = Instance.new("StringValue")
		cash.Name = Settings.CurrencyName
		cash.Value = "0"
		cash.Parent = stats
		
		-- Setup money tracking
		task.spawn(function()
			local playerMoney = getOrCreatePlayerMoney(player.Name)
			local useShort = Settings.LeaderboardSettings.ShowShortCurrency
			
			local function updateCashDisplay()
				if useShort then
					cash.Value = Settings:ConvertShort(playerMoney.Value)
				else
					cash.Value = Settings:ConvertComma(playerMoney.Value)
				end
			end
			
			updateCashDisplay()
			playerMoney.Changed:Connect(updateCashDisplay)
		end)
	end
	
	-- Connect death handler
	local function onCharacterAdded(character)
		local humanoid = character:WaitForChild("Humanoid", 10)
		if humanoid and Settings.LeaderboardSettings.WOs then
			humanoid.Died:Connect(function()
				onHumanoidDied(humanoid, player)
			end)
		end
	end
	
	player.CharacterAdded:Connect(onCharacterAdded)
	if player.Character then
		onCharacterAdded(player.Character)
	end
end

-- Player events
Players.PlayerAdded:Connect(createPlayerStats)
Players.PlayerRemoving:Connect(function(player)
	processedPlayers[player.Name] = nil
end)

-- Handle existing players
for _, player in pairs(Players:GetPlayers()) do
	task.spawn(createPlayerStats, player)
end

-- Global Money API
_G.AddPlayerMoney = function(playerName, amount)
	local moneyValue = getOrCreatePlayerMoney(playerName)
	moneyValue.Value = moneyValue.Value + amount
	return true
end

_G.SetPlayerMoney = function(playerName, amount)
	local moneyValue = getOrCreatePlayerMoney(playerName)
	moneyValue.Value = amount
	return true
end

_G.GetPlayerMoney = function(playerName)
	local moneyValue = playerMoneyFolder:FindFirstChild(playerName)
	return moneyValue and moneyValue.Value or 0
end

-- Ready message
print("⭐ UNIFIED LEADERBOARD READY!")
print("📊 Features enabled:")
print("   - KOs:", Settings.LeaderboardSettings.KOs and "✅" or "❌")
print("   - Deaths:", Settings.LeaderboardSettings.WOs and "✅" or "❌")
print("   - Currency:", Settings.LeaderboardSettings.ShowCurrency and "✅" or "❌")
print("   - Format:", Settings.LeaderboardSettings.ShowShortCurrency and "Short (1.5K)" or "Comma (1,500)")