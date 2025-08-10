-- UNIFIED LEADERSTATS SCRIPT - Combines all 4 tycoon kit leaderstats
-- Place in ServerScriptService and DELETE/DISABLE all other leaderstats scripts

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

-- Try to find Settings module (some kits have it, some don't)
local Settings = nil
local settingsLocations = {
    script.Parent:FindFirstChild("Settings"),
    ServerStorage:FindFirstChild("Settings"),
    game.ReplicatedStorage:FindFirstChild("Settings")
}

for _, location in ipairs(settingsLocations) do
    if location then
        Settings = require(location)
        break
    end
end

-- Default settings if no Settings module found
local DEFAULT_SETTINGS = {
    LeaderboardSettings = {
        KOs = true,
        WOs = true,
        ShowCurrency = true,
        KillsName = "KOs",
        DeathsName = "WOs",
        ShowShortCurrency = false
    },
    CurrencyName = "Money"
}

-- Use found settings or defaults
local config = Settings or {
    LeaderboardSettings = DEFAULT_SETTINGS.LeaderboardSettings,
    CurrencyName = DEFAULT_SETTINGS.CurrencyName,
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
            formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
            if k == 0 then break end
        end
        return formatted
    end
}

-- CTF Mode support
local stands = {}
local CTF_mode = false

-- Functions for kill/death tracking
local function getKillerOfHumanoidIfStillInGame(humanoid)
    local tag = humanoid:FindFirstChild("creator")
    if tag and tag.Value and tag.Value:IsA("Player") and tag.Value.Parent then
        return tag.Value
    end
    return nil
end

local function onHumanoidDied(humanoid, player)
    local stats = player:FindFirstChild("leaderstats")
    if not stats then return end
    
    -- Update deaths
    local deaths = stats:FindFirstChild(config.LeaderboardSettings.DeathsName or "WOs")
    if deaths then
        deaths.Value = deaths.Value + 1
    end
    
    -- Handle kill credit
    if config.LeaderboardSettings.KOs then
        local killer = getKillerOfHumanoidIfStillInGame(humanoid)
        if killer and killer ~= player then
            local killerStats = killer:FindFirstChild("leaderstats")
            if killerStats then
                local kills = killerStats:FindFirstChild(config.LeaderboardSettings.KillsName or "KOs")
                if kills then
                    kills.Value = kills.Value + 1
                end
            end
        end
    end
end

-- CTF Functions
local function findAllFlagStands(root)
    for _, child in ipairs(root:GetChildren()) do
        if child:IsA("Model") or child:IsA("Part") then
            findAllFlagStands(child)
        elseif child.ClassName == "FlagStand" then
            table.insert(stands, child)
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

-- Initialize CTF mode
findAllFlagStands(workspace)
if #stands > 0 then 
    CTF_mode = true
    for _, stand in ipairs(stands) do
        stand.FlagCaptured:Connect(onCaptureScored)
    end
end

-- Main player setup
Players.PlayerAdded:Connect(function(player)
    -- Always create leaderstats
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    
    if CTF_mode then
        -- CTF Mode - only show captures
        local captures = Instance.new("IntValue")
        captures.Name = "Captures"
        captures.Value = 0
        captures.Parent = leaderstats
    else
        -- Regular Mode - Cash always shows
        local cash = Instance.new("IntValue")
        cash.Name = "Cash"
        cash.Value = 0
        cash.Parent = leaderstats
        
        -- Optional: KOs
        if config.LeaderboardSettings.KOs then
            local kills = Instance.new("IntValue")
            kills.Name = config.LeaderboardSettings.KillsName or "KOs"
            kills.Value = 0
            kills.Parent = leaderstats
        end
        
        -- Optional: WOs (Deaths)
        if config.LeaderboardSettings.WOs then
            local deaths = Instance.new("IntValue")
            deaths.Name = config.LeaderboardSettings.DeathsName or "WOs"
            deaths.Value = 0
            deaths.Parent = leaderstats
        end
        
        -- Optional: Currency display (for old tycoon kits)
        if config.LeaderboardSettings.ShowCurrency then
            local currency = Instance.new("StringValue")
            currency.Name = config.CurrencyName or "Money"
            currency.Value = "0"
            currency.Parent = leaderstats
            
            -- Try to connect to PlayerMoney if it exists
            local playerMoneyFolder = ServerStorage:FindFirstChild("PlayerMoney")
            if playerMoneyFolder then
                -- Wait a bit for the value to be created
                task.wait(1)
                local playerMoney = playerMoneyFolder:FindFirstChild(player.Name)
                if playerMoney and playerMoney:IsA("IntValue") then
                    local updateCurrency = function()
                        if config.LeaderboardSettings.ShowShortCurrency then
                            currency.Value = config:ConvertShort(playerMoney.Value)
                        else
                            currency.Value = config:ConvertComma(playerMoney.Value)
                        end
                    end
                    playerMoney.Changed:Connect(updateCurrency)
                    updateCurrency() -- Initial update
                end
            end
        end
    end
    
    -- Parent leaderstats to player
    leaderstats.Parent = player
    
    -- Connect death tracking
    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid", 10)
        if humanoid and config.LeaderboardSettings.WOs then
            humanoid.Died:Connect(function()
                onHumanoidDied(humanoid, player)
            end)
        end
    end)
end)