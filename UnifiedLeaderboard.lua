-- Unified Leaderboard Script for Roblox
-- This script handles both CTF (Capture The Flag) and regular game modes
-- with kills, deaths, and currency tracking

local Settings = require(game.ServerScriptService.Settings)
-- Script will auto-parent to ServerScriptService (remove line below if already there)
script.Parent = game.ServerScriptService

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
    
    while not player.Character and tick() - startTime < timeout do
        wait(0.1)
    end
    
    return player.Character
end

-- Function to handle humanoid death
local function onHumanoidDied(humanoid, player)
    local stats = getPlayerStats(player)
    if not stats then return end
    
    -- Update deaths
    if Settings.LeaderboardSettings.WOs then
        local deaths = stats:FindFirstChild(Settings.LeaderboardSettings.DeathsName)
        if deaths then
            deaths.Value = deaths.Value + 1
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
        end
    end
end

-- Function to handle player respawn
local function onPlayerRespawn(property, player)
    if property == "Character" and player.Character then
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
    for _, child in pairs(root:GetDescendants()) do
        if child.ClassName == "FlagStand" then
            table.insert(stands, child)
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
end

-- Function to handle capture scoring (CTF mode)
function onCaptureScored(player)
    local stats = getPlayerStats(player)
    if not stats then return end
    
    local captures = stats:FindFirstChild("Captures")
    if captures then
        captures.Value = captures.Value + 1
    end
end

-- Function to create CTF mode stats
local function createCTFStats(player)
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
    local stats = Instance.new("Folder")
    stats.Name = "leaderstats"
    
    -- Create kills stat
    if Settings.LeaderboardSettings.KOs then
        local kills = Instance.new("IntValue")
        kills.Name = Settings.LeaderboardSettings.KillsName
        kills.Value = 0
        kills.Parent = stats
    end
    
    -- Create deaths stat
    if Settings.LeaderboardSettings.WOs then
        local deaths = Instance.new("IntValue")
        deaths.Name = Settings.LeaderboardSettings.DeathsName
        deaths.Value = 0
        deaths.Parent = stats
    end
    
    -- Create currency stat
    if Settings.LeaderboardSettings.ShowCurrency then
        local cash = Instance.new("StringValue")
        cash.Name = Settings.CurrencyName
        cash.Value = "0"
        cash.Parent = stats
        
        -- Set up currency tracking
        setupCurrencyTracking(player, cash)
    end
    
    return stats
end

-- Function to setup currency tracking
local function setupCurrencyTracking(player, cashStat)
    local playerMoneyFolder = ServerStorage:FindFirstChild("PlayerMoney")
    if not playerMoneyFolder then return end
    
    local playerStats = playerMoneyFolder:FindFirstChild(player.Name)
    if not playerStats then return end
    
    local function updateCurrency()
        local value = playerStats.Value or 0
        if Settings.LeaderboardSettings.ShowShortCurrency then
            cashStat.Value = Settings:ConvertShort(value)
        else
            cashStat.Value = Settings:ConvertComma(value)
        end
    end
    
    -- Initial update
    updateCurrency()
    
    -- Connect to changes
    playerStats.Changed:Connect(updateCurrency)
end

-- Main function when player joins
local function onPlayerEntered(newPlayer)
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
end

-- Initialize the script
local function initialize()
    -- Find all flag stands in workspace
    findAllFlagStands(workspace)
    
    -- Set CTF mode if flag stands exist
    if #stands > 0 then
        CTF_mode = true
        hookUpListeners()
    end
    
    -- Connect player events
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