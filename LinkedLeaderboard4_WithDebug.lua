-- START DEBUG SECTION FOR LINKEDLEADERBOARD 4 (UNIFIED VERSION)
print("========================================")
print("LINKEDLEADERBOARD 4 (UNIFIED) DEBUG INFORMATION")
print("========================================")
print("Script Name:", script.Name)
print("Script ClassName:", script.ClassName)
print("Script Full Path:", script:GetFullName())

-- Print parent hierarchy
local current = script
local depth = 0
print("\nPARENT HIERARCHY:")
while current.Parent and depth < 10 do
    print(string.rep("  ", depth) .. "└─ " .. current.Name .. " (" .. current.ClassName .. ")")
    current = current.Parent
    depth = depth + 1
end

-- Print siblings in parent
print("\nSIBLINGS IN PARENT:")
if script.Parent then
    for _, child in pairs(script.Parent:GetChildren()) do
        print("  - " .. child.Name .. " (" .. child.ClassName .. ")")
    end
end

-- Try to load Settings
print("\nLOADING SETTINGS:")
print("Looking for Settings at: game.ServerScriptService.Settings")
print("Which translates to:", game.ServerScriptService:GetFullName() .. ".Settings")

local settingsSuccess, settingsError = pcall(function()
    return require(game.ServerScriptService.Settings)
end)

if settingsSuccess then
    print("✓ Settings loaded successfully!")
else
    print("✗ Failed to load Settings:", settingsError)
end

print("\nBEFORE PARENT CHANGE:")
print("Current location:", script:GetFullName())
print("About to move to: game.ServerScriptService")
-- END DEBUG SECTION

-- Unified Leaderboard Script for Roblox
-- This script handles both CTF (Capture The Flag) and regular game modes
-- with kills, deaths, and currency tracking

local Settings = require(game.ServerScriptService.Settings)
-- Script will auto-parent to ServerScriptService (remove line below if already there)
script.Parent = game.ServerScriptService

-- MORE DEBUG AFTER MOVE
print("\nAFTER PARENT CHANGE:")
print("New location:", script:GetFullName())
print("Settings reference still valid?", Settings ~= nil)
print("========================================\n")

-- Global variables
local stands = {}
local CTF_mode = false

-- Services
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

-- Helper function to safely get player stats
local function getPlayerStats(player)
	return player:FindFirstChild("leaderstats")
end

-- Helper function to wait for character with timeout
local function waitForCharacter(player, timeout)
	timeout = timeout or 30
	local startTime = tick()

	print("[DEBUG] Waiting for character for", player.Name, "with timeout", timeout)
	while not player.Character and tick() - startTime < timeout do
		wait(0.1)
	end
	
	if player.Character then
		print("[DEBUG] Character found for", player.Name)
	else
		print("[DEBUG] Timeout waiting for character for", player.Name)
	end

	return player.Character
end

-- Function to handle humanoid death
local function onHumanoidDied(humanoid, player)
	print("[DEBUG] onHumanoidDied called for", player.Name)
	local stats = getPlayerStats(player)
	if not stats then return end

	-- Update deaths
	if Settings.LeaderboardSettings.WOs then
		local deaths = stats:FindFirstChild(Settings.LeaderboardSettings.DeathsName)
		if deaths then
			deaths.Value = deaths.Value + 1
			print("[DEBUG] Incremented deaths for", player.Name, "to", deaths.Value)
		end
	end

	-- Handle kill count
	if Settings.LeaderboardSettings.KOs then
		local killer = getKillerOfHumanoidIfStillInGame(humanoid)
		if killer then
			handleKillCount(humanoid, player, killer)
		end
	end
end

-- Function to get killer of humanoid
function getKillerOfHumanoidIfStillInGame(humanoid)
	local tag = humanoid:FindFirstChild("creator")

	if tag and tag.Value and tag.Value:IsA("Player") and tag.Value.Parent then
		print("[DEBUG] Found killer:", tag.Value.Name)
		return tag.Value
	end

	return nil
end

-- Function to handle kill count
function handleKillCount(humanoid, victim, killer)
	if not killer or killer == victim then
		-- Suicide case - decrease kill count
		local stats = getPlayerStats(killer)
		if stats and Settings.LeaderboardSettings.KOs then
			local kills = stats:FindFirstChild(Settings.LeaderboardSettings.KillsName)
			if kills then
				kills.Value = kills.Value - 1
				print("[DEBUG] Decremented kills for", killer.Name, "(suicide) to", kills.Value)
			end
		end
		return
	end

	-- Normal kill case
	local stats = getPlayerStats(killer)
	if stats and Settings.LeaderboardSettings.KOs then
		local kills = stats:FindFirstChild(Settings.LeaderboardSettings.KillsName)
		if kills then
			kills.Value = kills.Value + 1
			print("[DEBUG] Incremented kills for", killer.Name, "to", kills.Value)
		end
	end
end

-- Function to handle player respawn
local function onPlayerRespawn(property, player)
	if property == "Character" and player.Character then
		print("[DEBUG] Character respawned for", player.Name)
		local humanoid = player.Character:FindFirstChild("Humanoid")
		if humanoid and Settings.LeaderboardSettings.WOs then
			humanoid.Died:Connect(function()
				onHumanoidDied(humanoid, player)
			end)
		end
	end
end

-- Function to find all flag stands (for CTF mode)
local function findAllFlagStands(root)
	print("[DEBUG] Searching for flag stands in", root:GetFullName())
	for _, child in pairs(root:GetDescendants()) do
		if child.ClassName == "FlagStand" then
			table.insert(stands, child)
			print("[DEBUG] Found FlagStand at:", child:GetFullName())
		end
	end
end

-- Function to hook up CTF listeners
local function hookUpListeners()
	for _, stand in pairs(stands) do
		if stand.FlagCaptured then
			stand.FlagCaptured:Connect(onCaptureScored)
		end
	end
	print("[DEBUG] Hooked up", #stands, "flag stand listeners")
end

-- Function to handle capture scoring (CTF mode)
function onCaptureScored(player)
	print("[DEBUG] Capture scored by", player.Name)
	local stats = getPlayerStats(player)
	if not stats then return end

	local captures = stats:FindFirstChild("Captures")
	if captures then
		captures.Value = captures.Value + 1
	end
end

-- Function to create CTF mode stats
local function createCTFStats(player)
	print("[DEBUG] Creating CTF stats for", player.Name)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"

	local captures = Instance.new("IntValue")
	captures.Name = "Captures"
	captures.Value = 0
	captures.Parent = stats

	return stats
end

-- Function to create regular mode stats
local function createRegularStats(player)
	print("[DEBUG] Creating regular stats for", player.Name)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"

	-- Create kills stat
	if Settings.LeaderboardSettings.KOs then
		local kills = Instance.new("IntValue")
		kills.Name = Settings.LeaderboardSettings.KillsName
		kills.Value = 0
		kills.Parent = stats
		print("[DEBUG] Created kills stat:", Settings.LeaderboardSettings.KillsName)
	end

	-- Create deaths stat
	if Settings.LeaderboardSettings.WOs then
		local deaths = Instance.new("IntValue")
		deaths.Name = Settings.LeaderboardSettings.DeathsName
		deaths.Value = 0
		deaths.Parent = stats
		print("[DEBUG] Created deaths stat:", Settings.LeaderboardSettings.DeathsName)
	end

	-- Create currency stat
	if Settings.LeaderboardSettings.ShowCurrency then
		local cash = Instance.new("StringValue")
		cash.Name = Settings.CurrencyName
		cash.Value = "0"
		cash.Parent = stats
		print("[DEBUG] Created currency stat:", Settings.CurrencyName)

		-- Set up currency tracking
		setupCurrencyTracking(player, cash)
	end

	return stats
end

-- Function to setup currency tracking
local function setupCurrencyTracking(player, cashStat)
	print("[DEBUG] Setting up currency tracking for", player.Name)
	local playerMoneyFolder = ServerStorage:FindFirstChild("PlayerMoney")
	if not playerMoneyFolder then 
		print("[DEBUG] PlayerMoney folder not found in ServerStorage")
		return 
	end

	local playerStats = playerMoneyFolder:FindFirstChild(player.Name)
	if not playerStats then 
		print("[DEBUG] No PlayerStats found for", player.Name)
		return 
	end

	local function updateCurrency()
		local value = playerStats.Value or 0
		if Settings.LeaderboardSettings.ShowShortCurrency then
			cashStat.Value = Settings:ConvertShort(value)
		else
			cashStat.Value = Settings:ConvertComma(value)
		end
		print("[DEBUG] Updated currency for", player.Name, "to", cashStat.Value)
	end

	-- Initial update
	updateCurrency()

	-- Connect to changes
	playerStats.Changed:Connect(updateCurrency)
end

-- Main function when player joins
local function onPlayerEntered(newPlayer)
	print("[DEBUG] Player entered:", newPlayer.Name)
	print("[DEBUG] CTF Mode:", CTF_mode)
	
	local stats

	if CTF_mode then
		stats = createCTFStats(newPlayer)
	else
		stats = createRegularStats(newPlayer)
	end

	-- Wait for character to load
	local character = waitForCharacter(newPlayer)

	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			-- Connect death event
			if Settings.LeaderboardSettings.WOs then
				humanoid.Died:Connect(function()
					onHumanoidDied(humanoid, newPlayer)
				end)
			end
		end
	end

	-- Connect to character respawn
	newPlayer.CharacterAdded:Connect(function(char)
		wait(0.1) -- Small delay to ensure humanoid is loaded
		local humanoid = char:FindFirstChild("Humanoid") or char:WaitForChild("Humanoid", 5)
		if humanoid and Settings.LeaderboardSettings.WOs then
			humanoid.Died:Connect(function()
				onHumanoidDied(humanoid, newPlayer)
			end)
		end
	end)

	-- Parent stats to player
	stats.Parent = newPlayer
	print("[DEBUG] Leaderstats created for", newPlayer.Name)
end

-- Initialize the script
local function initialize()
	print("[DEBUG] Initializing LinkedLeaderboard 4 (Unified)")
	
	-- Find all flag stands in workspace
	findAllFlagStands(workspace)

	-- Set CTF mode if flag stands exist
	if #stands > 0 then
		CTF_mode = true
		hookUpListeners()
	end
	print("[DEBUG] Found", #stands, "flag stands. CTF Mode:", CTF_mode)

	-- Connect player events
	print("[DEBUG] Connecting to Players.PlayerAdded event...")
	Players.PlayerAdded:Connect(onPlayerEntered)

	-- Handle players who joined before script ran
	for _, player in pairs(Players:GetPlayers()) do
		spawn(function()
			onPlayerEntered(player)
		end)
	end
end

-- Start the script
initialize()

print("Unified Leaderboard Script loaded successfully!")
print("Mode:", CTF_mode and "CTF" or "Regular")
print("KOs enabled:", Settings.LeaderboardSettings.KOs or false)
print("WOs enabled:", Settings.LeaderboardSettings.WOs or false)
print("Currency enabled:", Settings.LeaderboardSettings.ShowCurrency or false)

print("[DEBUG] LINKEDLEADERBOARD 4 (UNIFIED) INITIALIZATION COMPLETE")
print("========================================\n")