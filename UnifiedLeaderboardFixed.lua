-- COMPLETE UNIFIED LEADERBOARD FIXED (Improved Tycoon Cleanup)
-- Place this ONE script in ServerScriptService
-- This version includes:
-- 1. Creates PlayerMoney folder and values WITH OwnsTycoon for gate scripts
-- 2. Provides money API for MoneyShop
-- 3. Updates leaderboard display when money changes
-- 4. PROPERLY RESETS TYCOON WHEN PLAYER LEAVES (FIXED!)

print("⭐ COMPLETE UNIFIED LEADERBOARD FIXED STARTING...")

-- Services
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

-- Variables
local processedPlayers = {}
local Settings = nil
local CTF_mode = false

-- Create Global Money API IMMEDIATELY (before anything else)
_G.AddPlayerMoney = function(playerName, amount)
	-- Will be properly implemented below
	return false
end

_G.SetPlayerMoney = function(playerName, amount)
	return false
end

_G.GetPlayerMoney = function(playerName)
	return 0
end

print("💰 Global Money API created (placeholder)")

-- GATE FIX: Create PlayerMoney folder immediately
local playerMoneyFolder = ServerStorage:FindFirstChild("PlayerMoney")
if not playerMoneyFolder then
	playerMoneyFolder = Instance.new("Folder")
	playerMoneyFolder.Name = "PlayerMoney"
	playerMoneyFolder.Parent = ServerStorage
	print("Created PlayerMoney folder")
end

-- Clean up old LinkedLeaderboard scripts
local function cleanupOldScripts()
	local removedCount = 0
	local foundLocations = {}

	-- Look for tycoon kits in workspace
	for _, child in pairs(workspace:GetChildren()) do
		if child:IsA("Model") then
			local innerModel = child:FindFirstChild(child.Name:gsub("Tycoon", " tycoon")) or 
				child:FindFirstChild("Zednov's Tycoon Kit [OPEN!]") or
				child:FindFirstChild("Spiderman tycoon")

			if innerModel then
				local linkedScript = innerModel:FindFirstChild("LinkedLeaderboard")
				if linkedScript and linkedScript:IsA("Script") then
					table.insert(foundLocations, linkedScript:GetFullName())
					linkedScript:Destroy()
					removedCount = removedCount + 1
				end
			end
		end
	end

	-- Also check ServerScriptService
	for _, child in pairs(game.ServerScriptService:GetChildren()) do
		if child:IsA("Script") and child.Name == "LinkedLeaderboard" and child ~= script then
			table.insert(foundLocations, "ServerScriptService.LinkedLeaderboard")
			child:Destroy()
			removedCount = removedCount + 1
		end
	end

	if removedCount > 0 then
		print("Removed", removedCount, "old LinkedLeaderboard scripts")
	else
		print("No old LinkedLeaderboard scripts found to clean up")
	end
end

task.wait(0.1)
cleanupOldScripts()

-- Look for Settings module
local function loadSettings()
	-- Try common locations first
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

	-- Default settings
	warn("No Settings module found! Using defaults.")
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
	return false
end

loadSettings()

-- Helper function to get or create player money
local function getOrCreatePlayerMoney(playerName)
	local moneyValue = playerMoneyFolder:FindFirstChild(playerName)
	if not moneyValue then
		moneyValue = Instance.new("IntValue")
		moneyValue.Name = playerName
		moneyValue.Value = 0

		-- GATE FIX: Add OwnsTycoon value that gate scripts check for
		local ownsTycoon = Instance.new("ObjectValue")
		ownsTycoon.Name = "OwnsTycoon"
		ownsTycoon.Parent = moneyValue

		moneyValue.Parent = playerMoneyFolder
		print("Created PlayerMoney data for", playerName)
	end
	return moneyValue
end

-- Update Global Money API with real implementation
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

print("💰 Global Money API updated with real implementation")

-- Death handling
function onHumanoidDied(humanoid, player)
	local stats = player:FindFirstChild("leaderstats")
	if stats then
		local deaths = stats:FindFirstChild(Settings.LeaderboardSettings.DeathsName)
		if deaths then
			deaths.Value = deaths.Value + 1
		end

		if Settings.LeaderboardSettings.KOs then
			local killer = getKillerOfHumanoidIfStillInGame(humanoid)
			handleKillCount(humanoid, player)
		end
	end
end

function getKillerOfHumanoidIfStillInGame(humanoid)
	local tag = humanoid:FindFirstChild("creator")
	if tag then
		local killer = tag.Value
		if killer and killer.Parent then
			return killer
		end
	end
	return nil
end

function handleKillCount(humanoid, player)
	local killer = getKillerOfHumanoidIfStillInGame(humanoid)
	if killer then
		local stats = killer:FindFirstChild("leaderstats")
		if stats then
			local kills = stats:FindFirstChild(Settings.LeaderboardSettings.KillsName)
			if kills then
				if killer ~= player then
					kills.Value = kills.Value + 1
				else
					kills.Value = kills.Value - 1
				end
			end
		end
	end
end

-- CTF support
local stands = {}
local function findAllFlagStands(root)
	for _, descendant in pairs(root:GetDescendants()) do
		if descendant.ClassName == "FlagStand" then
			table.insert(stands, descendant)
		end
	end
end

local function onCaptureScored(player)
	local ls = player:FindFirstChild("leaderstats")
	if ls then
		local caps = ls:FindFirstChild("Captures")
		if caps then
			caps.Value = caps.Value + 1
		end
	end
end

findAllFlagStands(workspace)
if #stands > 0 then 
	CTF_mode = true
	for _, stand in ipairs(stands) do
		if stand.FlagCaptured then
			stand.FlagCaptured:Connect(onCaptureScored)
		end
	end
end

-- Main player setup
function onPlayerEntered(newPlayer)
	-- Prevent duplicate stats
	if processedPlayers[newPlayer.Name] then
		print("Player already has stats:", newPlayer.Name)
		return
	end
	processedPlayers[newPlayer.Name] = true

	print("Creating stats for player:", newPlayer.Name)

	-- GATE FIX: Create player money value IMMEDIATELY
	local playerMoney = getOrCreatePlayerMoney(newPlayer.Name)

	-- Create leaderstats
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"

	if CTF_mode then
		local captures = Instance.new("IntValue")
		captures.Name = "Captures"
		captures.Value = 0
		captures.Parent = stats
	else
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

			-- Update cash display
			local Short = Settings.LeaderboardSettings.ShowShortCurrency
			local function updateCash()
				if Short then
					cash.Value = Settings:ConvertShort(playerMoney.Value)
				else
					cash.Value = Settings:ConvertComma(playerMoney.Value)
				end
				print("Updated", newPlayer.Name, "cash display to", cash.Value, "(raw:", playerMoney.Value, ")")
			end

			-- Initial update
			updateCash()

			-- Listen for changes
			playerMoney.Changed:Connect(updateCash)
		end
	end

	-- Wait for character and connect death
	local character = newPlayer.Character or newPlayer.CharacterAdded:Wait()
	if character then
		local humanoid = character:WaitForChild("Humanoid", 10)
		if humanoid and Settings.LeaderboardSettings.WOs then
			humanoid.Died:Connect(function() onHumanoidDied(humanoid, newPlayer) end)
		end
	end

	-- Listen for respawns
	newPlayer.CharacterAdded:Connect(function(newCharacter)
		local humanoid = newCharacter:WaitForChild("Humanoid", 10)
		if humanoid and Settings.LeaderboardSettings.WOs then
			humanoid.Died:Connect(function() onHumanoidDied(humanoid, newPlayer) end)
		end
	end)

	stats.Parent = newPlayer
end

-- IMPROVED TYCOON CLEANUP FUNCTION
local function resetTycoon(tycoon, playerName)
	print("🔧 Resetting tycoon:", tycoon.Name, "for player:", playerName)
	
	-- Reset the currency collector
	local currencyToCollect = tycoon:FindFirstChild("CurrencyToCollect")
	if currencyToCollect then
		currencyToCollect.Value = 0
		print("  ✓ Reset currency to 0")
	end
	
	-- Clear the owner value
	local owner = tycoon:FindFirstChild("Owner")
	if owner then
		owner.Value = nil
		print("  ✓ Cleared owner")
	end
	
	-- Remove all purchased objects
	local purchasedObjects = tycoon:FindFirstChild("PurchasedObjects")
	if purchasedObjects then
		for _, obj in pairs(purchasedObjects:GetChildren()) do
			obj:Destroy()
		end
		print("  ✓ Cleared", #purchasedObjects:GetChildren(), "purchased objects")
	end
	
	-- Reset all buttons
	local buttons = tycoon:FindFirstChild("Buttons")
	if buttons then
		for _, button in pairs(buttons:GetChildren()) do
			local head = button:FindFirstChild("Head")
			if head then
				-- Check for dependency
				local dependency = button:FindFirstChild("Dependency")
				if dependency and dependency.Value and dependency.Value ~= "" then
					-- Hide dependent buttons
					head.CanCollide = false
					head.Transparency = 1
				else
					-- Show base buttons
					head.CanCollide = true
					head.Transparency = 0
				end
				
				-- Reset color
				head.BrickColor = BrickColor.new("Really red")
			end
		end
		print("  ✓ Reset all buttons")
	end
	
	-- Reset essentials to default state
	local essentials = tycoon:FindFirstChild("Essentials")
	if essentials then
		-- Reset money collector color
		local giver = essentials:FindFirstChild("Giver")
		if giver then
			giver.BrickColor = BrickColor.new("Bright green")
		end
	end
	
	print("  ✅ Tycoon reset complete!")
end

-- Clean up when player leaves
local function onPlayerRemoving(player)
	print("🚪 Player leaving:", player.Name)
	processedPlayers[player.Name] = nil

	-- COMPREHENSIVE TYCOON SEARCH AND RESET
	local foundTycoon = false
	
	-- Method 1: Direct search in common locations
	local searchLocations = {
		workspace,
		workspace:FindFirstChild("Tycoons"),
		workspace:FindFirstChild("SpidermanTycoon"),
		workspace:FindFirstChild("Venom Tycoon"),
		workspace:FindFirstChild("Cinnamoroll tycoon"),
		workspace:FindFirstChild("Zednov's Tycoon Kit"),
	}
	
	for _, location in pairs(searchLocations) do
		if location then
			-- Search recursively for tycoons
			for _, descendant in pairs(location:GetDescendants()) do
				if descendant.Name == "Owner" and descendant:IsA("ObjectValue") and descendant.Value == player then
					local tycoon = descendant.Parent
					if tycoon:FindFirstChild("Essentials") and tycoon:FindFirstChild("Buttons") then
						foundTycoon = true
						resetTycoon(tycoon, player.Name)
						break
					end
				end
			end
			if foundTycoon then break end
		end
	end
	
	-- Method 2: If not found, search ALL models in workspace
	if not foundTycoon then
		print("  ⚠️ Tycoon not found in common locations, searching entire workspace...")
		for _, model in pairs(workspace:GetDescendants()) do
			if model:IsA("ObjectValue") and model.Name == "Owner" and model.Value == player then
				local potentialTycoon = model.Parent
				if potentialTycoon:FindFirstChild("Essentials") and potentialTycoon:FindFirstChild("Buttons") then
					foundTycoon = true
					resetTycoon(potentialTycoon, player.Name)
					break
				end
			end
		end
	end
	
	-- Clear PlayerMoney references
	local playerMoney = playerMoneyFolder:FindFirstChild(player.Name)
	if playerMoney then
		local ownsTycoon = playerMoney:FindFirstChild("OwnsTycoon")
		if ownsTycoon then
			ownsTycoon.Value = nil
		end
		-- Optional: Clear money on leave (uncomment if desired)
		-- playerMoney.Value = 0
	end
	
	if not foundTycoon then
		warn("  ❌ Could not find tycoon for player:", player.Name)
	end
end

-- Connect events
Players.PlayerAdded:Connect(onPlayerEntered)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Handle players already in game
for _, player in pairs(Players:GetPlayers()) do
	task.spawn(onPlayerEntered, player)
end

print("⭐ COMPLETE UNIFIED LEADERBOARD FIXED READY")
print("Mode:", CTF_mode and "CTF" or "Regular")
print("KOs enabled:", Settings.LeaderboardSettings.KOs)
print("WOs enabled:", Settings.LeaderboardSettings.WOs)
print("Currency enabled:", Settings.LeaderboardSettings.ShowCurrency)
print("💰 Money API: Ready")
print("🚪 Gate Fix: PlayerMoney includes OwnsTycoon")
print("🔄 Tycoon Reset: IMPROVED - Clears everything when owner leaves")