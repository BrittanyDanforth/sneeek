-- FINAL UNIFIED LEADERBOARD
-- Place this ONE script in ServerScriptService
-- Delete all LinkedLeaderboard scripts from your tycoons

print("=== FINAL UNIFIED LEADERBOARD STARTING ===")

-- Services
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

-- Clean up old LinkedLeaderboard scripts
local function cleanupOldScripts()
    local removedCount = 0
    
    -- Search through workspace for any LinkedLeaderboard scripts
    for _, descendant in pairs(workspace:GetDescendants()) do
        if descendant:IsA("Script") and descendant.Name == "LinkedLeaderboard" then
            print("Found old LinkedLeaderboard at:", descendant:GetFullName())
            descendant:Destroy()
            removedCount = removedCount + 1
        end
    end
    
    -- Also check ServerScriptService
    for _, child in pairs(game.ServerScriptService:GetChildren()) do
        if child:IsA("Script") and child.Name == "LinkedLeaderboard" and child ~= script then
            print("Found old LinkedLeaderboard in ServerScriptService")
            child:Destroy()
            removedCount = removedCount + 1
        end
    end
    
    if removedCount > 0 then
        print("Cleaned up", removedCount, "old LinkedLeaderboard scripts")
    end
end

-- Run cleanup
cleanupOldScripts()

-- Variables
local stands = {}
local CTF_mode = false
local Settings = nil
local loadedSettings = false

-- Track if we already created stats for players (prevents duplicates)
local processedPlayers = {}

-- Look for Settings module in all tycoon kit locations
local function findAndLoadSettings()
    -- First check common locations
    local commonLocations = {
        game.ServerScriptService:FindFirstChild("Settings"),
    }
    
    for _, settingsModule in ipairs(commonLocations) do
        if settingsModule and settingsModule:IsA("ModuleScript") then
            local success, module = pcall(require, settingsModule)
            if success then
                Settings = module
                print("Loaded Settings from ServerScriptService")
                return true
            end
        end
    end
    
    -- Now search for Settings in tycoon kits
    local tycoonKits = {
        workspace:FindFirstChild("SpidermanTycoon"),
        workspace:FindFirstChild("Venom Tycoon"),
        workspace:FindFirstChild("Zednov's Tycoon Kit"),
    }
    
    for _, kit in ipairs(tycoonKits) do
        if kit then
            -- Look for Settings at the kit level
            local settingsAtRoot = kit:FindFirstChild("Settings", true)
            if settingsAtRoot and settingsAtRoot:IsA("ModuleScript") then
                local success, module = pcall(require, settingsAtRoot)
                if success then
                    Settings = module
                    print("Loaded Settings from:", kit.Name)
                    return true
                end
            end
        end
    end
    
    -- If no Settings found, create default
    warn("No Settings module found! Using defaults.")
    Settings = {
        LeaderboardSettings = {
            KOs = true,
            WOs = true,
            ShowCurrency = true,
            ShowShortCurrency = true,
            KillsName = "KOs",
            KillsNames = "KOs", -- Support both versions
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

-- Load settings
loadedSettings = findAndLoadSettings()

-- Ensure PlayerMoney folder exists
local playerMoneyFolder = ServerStorage:FindFirstChild("PlayerMoney")
if not playerMoneyFolder then
    playerMoneyFolder = Instance.new("Folder")
    playerMoneyFolder.Name = "PlayerMoney"
    playerMoneyFolder.Parent = ServerStorage
    print("Created PlayerMoney folder in ServerStorage")
end

-- Get or create player money value
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

function onHumanoidDied(humanoid, player)
    local stats = player:FindFirstChild("leaderstats")
    if stats ~= nil then
        local deaths = stats:FindFirstChild(Settings.LeaderboardSettings.DeathsName)
        if deaths then
            deaths.Value = deaths.Value + 1
        end
        -- do short dance to try and find the killer
        if Settings.LeaderboardSettings.KOs then
            local killer = getKillerOfHumanoidIfStillInGame(humanoid)
            handleKillCount(humanoid, player)
        end
    end
end

function onPlayerRespawn(property, player)
    -- need to connect to new humanoid
    if property == "Character" and player.Character ~= nil then
        local humanoid = player.Character:WaitForChild("Humanoid", 10)
        if humanoid and Settings.LeaderboardSettings.WOs then
            humanoid.Died:Connect(function() onHumanoidDied(humanoid, player) end)
        end
    end
end

function getKillerOfHumanoidIfStillInGame(humanoid)
    -- returns the player object that killed this humanoid
    -- returns nil if the killer is no longer in the game

    -- check for kill tag on humanoid - may be more than one - todo: deal with this
    local tag = humanoid:FindFirstChild("creator")

    -- find player with name on tag
    if tag ~= nil then
        local killer = tag.Value
        if killer and killer.Parent ~= nil then -- killer still in game
            return killer
        end
    end

    return nil
end

function handleKillCount(humanoid, player)
    local killer = getKillerOfHumanoidIfStillInGame(humanoid)
    if killer ~= nil then
        local stats = killer:FindFirstChild("leaderstats")
        if stats ~= nil then
            -- Try both KillsName and KillsNames (to handle the typo in different versions)
            local kills = stats:FindFirstChild(Settings.LeaderboardSettings.KillsName) or 
                         stats:FindFirstChild(Settings.LeaderboardSettings.KillsNames)
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

-----------------------------------------------

function findAllFlagStands(root)
    for _, descendant in pairs(root:GetDescendants()) do
        if descendant.ClassName == "FlagStand" then
            table.insert(stands, descendant)
        end
    end
end

function hookUpListeners()
    for i=1,#stands do
        if stands[i].FlagCaptured then
            stands[i].FlagCaptured:Connect(onCaptureScored)
        end
    end
end

function onPlayerEntered(newPlayer)
    -- Check if we already processed this player (prevents duplicate stats)
    if processedPlayers[newPlayer.Name] then
        print("Player already has stats:", newPlayer.Name)
        return
    end
    processedPlayers[newPlayer.Name] = true
    
    print("Creating stats for player:", newPlayer.Name)

    if CTF_mode == true then
        local stats = Instance.new("Folder")
        stats.Name = "leaderstats"

        local captures = Instance.new("IntValue")
        captures.Name = "Captures"
        captures.Value = 0
        captures.Parent = stats

        -- Wait for character
        local character = newPlayer.Character or newPlayer.CharacterAdded:Wait()
        stats.Parent = newPlayer

    else
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
            
            -- Set up money tracking
            local playerMoney = getOrCreatePlayerMoney(newPlayer.Name)
            local Short = Settings.LeaderboardSettings.ShowShortCurrency
            
            local function updateCash()
                if Short then
                    cash.Value = Settings:ConvertShort(playerMoney.Value)
                else
                    cash.Value = Settings:ConvertComma(playerMoney.Value)
                end
            end
            
            -- Initial update
            updateCash()
            
            -- Listen for changes
            playerMoney.Changed:Connect(updateCash)
        end

        -- Wait for character
        local character = newPlayer.Character or newPlayer.CharacterAdded:Wait()
        
        if character then
            local humanoid = character:WaitForChild("Humanoid", 10)
            if humanoid then
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
end

function onCaptureScored(player)
    local ls = player:FindFirstChild("leaderstats")
    if ls == nil then return end
    local caps = ls:FindFirstChild("Captures")
    if caps == nil then return end
    caps.Value = caps.Value + 1
end

-- Clean up when player leaves
local function onPlayerRemoving(player)
    processedPlayers[player.Name] = nil
end

-- Initialize
findAllFlagStands(workspace)
hookUpListeners()
if (#stands > 0) then CTF_mode = true end

-- Connect events
Players.PlayerAdded:Connect(onPlayerEntered)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Handle players already in game
for _, player in pairs(Players:GetPlayers()) do
    spawn(function()
        onPlayerEntered(player)
    end)
end

print("=== FINAL UNIFIED LEADERBOARD READY ===")
print("Mode:", CTF_mode and "CTF" or "Regular")
print("Settings loaded:", loadedSettings)
print("KOs enabled:", Settings.LeaderboardSettings.KOs)
print("WOs enabled:", Settings.LeaderboardSettings.WOs)
print("Currency enabled:", Settings.LeaderboardSettings.ShowCurrency)

-- Money API for shops
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
    if moneyValue then
        return moneyValue.Value
    end
    return 0
end