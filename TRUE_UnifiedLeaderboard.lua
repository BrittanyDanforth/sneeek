-- TRUE UNIFIED LEADERBOARD SCRIPT
-- This single script replaces all 4 LinkedLeaderboard scripts
-- Place this in ServerScriptService with a Settings ModuleScript

print("=== TRUE UNIFIED LEADERBOARD STARTING ===")

-- First, let's find ALL Settings modules from all tycoons
local function findAllSettingsModules()
    local settingsModules = {}
    local workspace = game:GetService("Workspace")
    
    -- Search through workspace for tycoon models with Settings
    for _, child in pairs(workspace:GetDescendants()) do
        if child.Name == "Settings" and child:IsA("ModuleScript") then
            -- Check if there's a LinkedLeaderboard script nearby (indicating a tycoon)
            local hasLeaderboard = false
            if child.Parent then
                for _, sibling in pairs(child.Parent:GetChildren()) do
                    if sibling.Name:match("LinkedLeaderboard") or sibling.Name == "LinkedLeaderboard" then
                        hasLeaderboard = true
                        break
                    end
                end
            end
            
            if hasLeaderboard then
                print("Found Settings module at:", child:GetFullName())
                table.insert(settingsModules, child)
            end
        end
    end
    
    return settingsModules
end

-- Load the first Settings module we find (they should all be the same)
local settingsModules = findAllSettingsModules()
local Settings

if #settingsModules > 0 then
    Settings = require(settingsModules[1])
    print("Loaded Settings from:", settingsModules[1]:GetFullName())
else
    -- Fallback: Create default settings
    warn("No Settings modules found! Using default settings.")
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
                formatted = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
                if formatted == tostring(value) then break end
            end
            return formatted
        end
    }
end

-- Services
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

-- Variables
local stands = {}
local CTF_mode = false
local playerConnections = {} -- Track connections to clean up

-- Ensure PlayerMoney folder exists
local function ensurePlayerMoneyFolder()
    local folder = ServerStorage:FindFirstChild("PlayerMoney")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "PlayerMoney"
        folder.Parent = ServerStorage
        print("Created PlayerMoney folder in ServerStorage")
    end
    return folder
end

local playerMoneyFolder = ensurePlayerMoneyFolder()

-- Create or get player money value
local function getOrCreatePlayerMoney(playerName)
    local moneyValue = playerMoneyFolder:FindFirstChild(playerName)
    if not moneyValue then
        moneyValue = Instance.new("IntValue")
        moneyValue.Name = playerName
        moneyValue.Value = 0
        moneyValue.Parent = playerMoneyFolder
        print("Created money value for", playerName)
    end
    return moneyValue
end

-- Helper function to safely get leaderstats
local function getLeaderstats(player)
    return player:FindFirstChild("leaderstats")
end

function onHumanoidDied(humanoid, player)
    local stats = getLeaderstats(player)
    if stats then
        -- Update deaths
        local deaths = stats:FindFirstChild(Settings.LeaderboardSettings.DeathsName)
        if deaths then
            deaths.Value = deaths.Value + 1
        end
        
        -- Handle kills
        if Settings.LeaderboardSettings.KOs then
            local killer = getKillerOfHumanoidIfStillInGame(humanoid)
            if killer then
                handleKillCount(humanoid, player, killer)
            end
        end
    end
end

function getKillerOfHumanoidIfStillInGame(humanoid)
    local tag = humanoid:FindFirstChild("creator")
    if tag and tag.Value and tag.Value:IsA("Player") and tag.Value.Parent then
        return tag.Value
    end
    return nil
end

function handleKillCount(humanoid, victim, killer)
    if not killer then return end
    
    local stats = getLeaderstats(killer)
    if stats then
        -- Fix: Use KillsName not KillsNames
        local kills = stats:FindFirstChild(Settings.LeaderboardSettings.KillsName)
        if kills then
            if killer ~= victim then
                kills.Value = kills.Value + 1
            else
                kills.Value = kills.Value - 1 -- Suicide penalty
            end
        end
    end
end

function onPlayerRespawn(property, player)
    if property == "Character" and player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid and Settings.LeaderboardSettings.WOs then
            -- Clean up old connection if exists
            local oldConnection = playerConnections[player.Name .. "_died"]
            if oldConnection then
                oldConnection:Disconnect()
            end
            
            -- Create new connection
            playerConnections[player.Name .. "_died"] = humanoid.Died:Connect(function()
                onHumanoidDied(humanoid, player)
            end)
        end
    end
end

-- CTF Functions
function findAllFlagStands(root)
    for _, descendant in pairs(root:GetDescendants()) do
        if descendant.ClassName == "FlagStand" then
            table.insert(stands, descendant)
            print("Found FlagStand at:", descendant:GetFullName())
        end
    end
end

function hookUpListeners()
    for _, stand in pairs(stands) do
        if stand.FlagCaptured then
            stand.FlagCaptured:Connect(onCaptureScored)
        end
    end
    print("Hooked up", #stands, "flag stand listeners")
end

function onCaptureScored(player)
    local ls = getLeaderstats(player)
    if ls then
        local caps = ls:FindFirstChild("Captures")
        if caps then
            caps.Value = caps.Value + 1
        end
    end
end

-- Main player entered function
function onPlayerEntered(newPlayer)
    print("Player entered:", newPlayer.Name)
    
    -- Create leaderstats
    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    
    if CTF_mode then
        -- CTF Mode
        local captures = Instance.new("IntValue")
        captures.Name = "Captures"
        captures.Value = 0
        captures.Parent = stats
    else
        -- Regular Mode
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
            
            local function updateCashDisplay()
                local value = playerMoney.Value
                if Settings.LeaderboardSettings.ShowShortCurrency then
                    cash.Value = Settings:ConvertShort(value)
                else
                    cash.Value = Settings:ConvertComma(value)
                end
            end
            
            -- Initial update
            updateCashDisplay()
            
            -- Connect to changes
            playerConnections[newPlayer.Name .. "_money"] = playerMoney.Changed:Connect(updateCashDisplay)
        end
    end
    
    -- Parent stats to player
    stats.Parent = newPlayer
    
    -- Set up character connections
    local function onCharacterAdded(character)
        local humanoid = character:WaitForChild("Humanoid", 10)
        if humanoid and Settings.LeaderboardSettings.WOs then
            playerConnections[newPlayer.Name .. "_died"] = humanoid.Died:Connect(function()
                onHumanoidDied(humanoid, newPlayer)
            end)
        end
    end
    
    -- Connect to current character if exists
    if newPlayer.Character then
        onCharacterAdded(newPlayer.Character)
    end
    
    -- Connect to future characters
    playerConnections[newPlayer.Name .. "_char"] = newPlayer.CharacterAdded:Connect(onCharacterAdded)
    
    -- Also use the old method for compatibility
    playerConnections[newPlayer.Name .. "_prop"] = newPlayer.Changed:Connect(function(property)
        onPlayerRespawn(property, newPlayer)
    end)
end

-- Clean up when player leaves
function onPlayerRemoving(player)
    -- Clean up all connections for this player
    local connectionKeys = {
        player.Name .. "_died",
        player.Name .. "_money",
        player.Name .. "_char",
        player.Name .. "_prop"
    }
    
    for _, key in pairs(connectionKeys) do
        local connection = playerConnections[key]
        if connection then
            connection:Disconnect()
            playerConnections[key] = nil
        end
    end
    
    print("Cleaned up connections for", player.Name)
end

-- Initialize
print("Searching for flag stands...")
findAllFlagStands(workspace)
if #stands > 0 then
    CTF_mode = true
    hookUpListeners()
end

print("Game mode:", CTF_mode and "CTF" or "Regular")
print("Settings loaded:")
print("  KOs enabled:", Settings.LeaderboardSettings.KOs)
print("  WOs enabled:", Settings.LeaderboardSettings.WOs) 
print("  Currency enabled:", Settings.LeaderboardSettings.ShowCurrency)
print("  Currency name:", Settings.CurrencyName)

-- Connect player events
Players.PlayerAdded:Connect(onPlayerEntered)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Handle players who joined before script ran
for _, player in pairs(Players:GetPlayers()) do
    spawn(function()
        onPlayerEntered(player)
    end)
end

print("=== TRUE UNIFIED LEADERBOARD READY ===")

-- API for other scripts to add/remove money
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

print("Money API available:")
print("  _G.AddPlayerMoney(playerName, amount)")
print("  _G.SetPlayerMoney(playerName, amount)")
print("  _G.GetPlayerMoney(playerName)")