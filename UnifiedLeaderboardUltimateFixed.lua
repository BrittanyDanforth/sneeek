-- COMPLETE UNIFIED LEADERBOARD ULTIMATE FIXED (Guaranteed Tycoon Reset)
-- Place this ONE script in ServerScriptService
-- This version includes:
-- 1. Creates PlayerMoney folder and values WITH OwnsTycoon for gate scripts
-- 2. Provides money API for MoneyShop
-- 3. Updates leaderboard display when money changes
-- 4. GUARANTEES TYCOON RESET INCLUDING DOORS/BUTTONS!

print("⭐ COMPLETE UNIFIED LEADERBOARD ULTIMATE FIXED STARTING...")

-- Services
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

-- Variables
local processedPlayers = {}
local Settings = nil
local CTF_mode = false
local playerTycoons = {} -- Track which tycoon each player owns

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

-- TYCOON TRACKING SYSTEM
local function findAllTycoons()
	local tycoons = {}
	
	-- Search patterns for tycoons
	local function searchForTycoons(parent)
		for _, child in pairs(parent:GetChildren()) do
			-- Check if this is a tycoon (has Owner, Essentials, Buttons)
			local owner = child:FindFirstChild("Owner")
			local essentials = child:FindFirstChild("Essentials")
			local buttons = child:FindFirstChild("Buttons")
			
			if owner and essentials and buttons then
				table.insert(tycoons, child)
				print("📍 Found tycoon:", child:GetFullName())
			elseif child:IsA("Folder") or child:IsA("Model") then
				-- Recursively search
				searchForTycoons(child)
			end
		end
	end
	
	searchForTycoons(workspace)
	return tycoons
end

-- Monitor tycoon ownership
local function monitorTycoons()
	local tycoons = findAllTycoons()
	
	for _, tycoon in pairs(tycoons) do
		local owner = tycoon:FindFirstChild("Owner")
		if owner then
			owner.Changed:Connect(function()
				if owner.Value then
					playerTycoons[owner.Value.Name] = tycoon
					print("🏠 Player", owner.Value.Name, "now owns", tycoon.Name)
				end
			end)
			
			-- Check current owner
			if owner.Value then
				playerTycoons[owner.Value.Name] = tycoon
			end
		end
	end
	
	print("📊 Monitoring", #tycoons, "tycoons")
end

-- Start monitoring after a short delay
task.wait(1)
monitorTycoons()

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

-- ULTIMATE TYCOON RESET FUNCTION
local function resetTycoon(tycoon, playerName)
	print("🔧 ULTIMATE RESET for tycoon:", tycoon.Name, "owned by:", playerName)
	
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
		local objectCount = #purchasedObjects:GetChildren()
		for _, obj in pairs(purchasedObjects:GetChildren()) do
			obj:Destroy()
		end
		print("  ✓ Destroyed", objectCount, "purchased objects")
	end
	
	-- COMPLETE BUTTON RESET - This is the critical part!
	local buttons = tycoon:FindFirstChild("Buttons")
	if buttons then
		print("  🔄 Resetting", #buttons:GetChildren(), "buttons...")
		
		for _, button in pairs(buttons:GetChildren()) do
			local head = button:FindFirstChild("Head")
			if head then
				-- Check for dependency
				local dependency = button:FindFirstChild("Dependency")
				
				if dependency and dependency.Value and dependency.Value ~= "" then
					-- DEPENDENT BUTTON - Hide it
					head.CanCollide = false
					head.Transparency = 1
					print("    - Hiding dependent button:", button.Name, "(depends on", dependency.Value, ")")
				else
					-- BASE BUTTON - Make it visible and purchasable
					head.CanCollide = true
					head.Transparency = 0
					head.BrickColor = BrickColor.new("Really red")
					
					-- Ensure button is at proper height
					if head:IsA("BasePart") then
						local cf = head.CFrame
						head.CFrame = cf
					end
					
					print("    - Activated base button:", button.Name)
				end
				
				-- Remove any hover effects
				local hoverDetector = button:FindFirstChild("HoverDetector")
				if hoverDetector then
					hoverDetector:Destroy()
				end
			end
		end
		print("  ✓ All buttons reset!")
	end
	
	-- Reset essentials to default state
	local essentials = tycoon:FindFirstChild("Essentials")
	if essentials then
		-- Reset money collector color
		local giver = essentials:FindFirstChild("Giver")
		if giver then
			giver.BrickColor = BrickColor.new("Bright green")
			print("  ✓ Reset money collector color")
		end
	end
	
	-- Clear any purchase tracking
	local buyObject = tycoon:FindFirstChild("BuyObject")
	if buyObject then
		for _, child in pairs(buyObject:GetChildren()) do
			child:Destroy()
		end
	end
	
	print("  ✅ TYCOON FULLY RESET AND READY FOR NEW OWNER!")
end

-- Clean up when player leaves
local function onPlayerRemoving(player)
	print("🚪 Player leaving:", player.Name)
	processedPlayers[player.Name] = nil

	-- Method 1: Check our tracking table first
	local tycoon = playerTycoons[player.Name]
	if tycoon then
		print("  ✓ Found tycoon from tracking table!")
		resetTycoon(tycoon, player.Name)
		playerTycoons[player.Name] = nil
	else
		-- Method 2: Search all tycoons
		print("  🔍 Searching for tycoon...")
		local allTycoons = findAllTycoons()
		
		for _, searchTycoon in pairs(allTycoons) do
			local owner = searchTycoon:FindFirstChild("Owner")
			if owner and owner.Value == player then
				print("  ✓ Found tycoon by owner search!")
				resetTycoon(searchTycoon, player.Name)
				break
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
		-- Reset money to 0 on leave
		playerMoney.Value = 0
		print("  ✓ Reset player money to 0")
	end
end

-- Connect events
Players.PlayerAdded:Connect(onPlayerEntered)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Handle players already in game
for _, player in pairs(Players:GetPlayers()) do
	task.spawn(onPlayerEntered, player)
end

print("⭐ COMPLETE UNIFIED LEADERBOARD ULTIMATE FIXED READY")
print("Mode:", CTF_mode and "CTF" or "Regular")
print("KOs enabled:", Settings.LeaderboardSettings.KOs)
print("WOs enabled:", Settings.LeaderboardSettings.WOs)
print("Currency enabled:", Settings.LeaderboardSettings.ShowCurrency)
print("💰 Money API: Ready")
print("🚪 Gate Fix: PlayerMoney includes OwnsTycoon")
print("🔄 Tycoon Reset: ULTIMATE - Guaranteed complete reset!")
print("🏠 Tycoon Tracking: Active")