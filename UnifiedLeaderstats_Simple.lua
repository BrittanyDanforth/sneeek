-- UNIFIED LEADERSTATS - Works for ALL tycoon kits
-- Place in ServerScriptService as "Leaderstats"
-- DELETE all other leaderstats scripts

local Players = game:GetService("Players")

-- CONFIGURATION - Change these to control what shows
local SHOW_CASH = true      -- Always show Cash (for tycoons)
local SHOW_KOS = false      -- Show Kills
local SHOW_WOS = false      -- Show Deaths (Wipeouts)
local SHOW_MONEY = false    -- Show formatted Money (for old kits)
local CHECK_CTF = true      -- Check for Capture The Flag mode

-- CTF Mode detection
local stands = {}
local CTF_mode = false

if CHECK_CTF then
    local function findAllFlagStands(root)
        for _, child in ipairs(root:GetChildren()) do
            if child:IsA("Model") or child:IsA("Part") then
                findAllFlagStands(child)
            elseif child.ClassName == "FlagStand" then
                table.insert(stands, child)
            end
        end
    end
    
    findAllFlagStands(workspace)
    CTF_mode = #stands > 0
end

-- Helper functions
local function formatNumber(value)
    if value >= 1000000000 then
        return string.format("%.1fB", value / 1000000000)
    elseif value >= 1000000 then
        return string.format("%.1fM", value / 1000000)
    elseif value >= 1000 then
        return string.format("%.1fK", value / 1000)
    else
        return tostring(value)
    end
end

local function getKiller(humanoid)
    local tag = humanoid:FindFirstChild("creator")
    if tag and tag.Value and tag.Value:IsA("Player") and tag.Value.Parent then
        return tag.Value
    end
    return nil
end

-- Main player handler
Players.PlayerAdded:Connect(function(player)
    -- Create leaderstats
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player
    
    if CTF_mode then
        -- CTF Mode - only Captures
        local captures = Instance.new("IntValue")
        captures.Name = "Captures"
        captures.Value = 0
        captures.Parent = leaderstats
        
        -- Connect capture scoring
        for _, stand in ipairs(stands) do
            stand.FlagCaptured:Connect(function(scoringPlayer)
                if scoringPlayer == player then
                    captures.Value = captures.Value + 1
                end
            end)
        end
    else
        -- Regular Mode
        
        -- Cash (for tycoons)
        if SHOW_CASH then
            local cash = Instance.new("IntValue")
            cash.Name = "Cash"
            cash.Value = 0
            cash.Parent = leaderstats
        end
        
        -- KOs (Kills)
        if SHOW_KOS then
            local kills = Instance.new("IntValue")
            kills.Name = "KOs"
            kills.Value = 0
            kills.Parent = leaderstats
        end
        
        -- WOs (Deaths)
        if SHOW_WOS then
            local deaths = Instance.new("IntValue")
            deaths.Name = "WOs"
            deaths.Value = 0
            deaths.Parent = leaderstats
        end
        
        -- Money (formatted display for old kits)
        if SHOW_MONEY then
            local money = Instance.new("StringValue")
            money.Name = "Money"
            money.Value = "0"
            money.Parent = leaderstats
            
            -- Try to sync with ServerStorage.PlayerMoney
            task.spawn(function()
                task.wait(1)
                local playerMoneyFolder = game.ServerStorage:FindFirstChild("PlayerMoney")
                if playerMoneyFolder then
                    local playerMoney = playerMoneyFolder:FindFirstChild(player.Name)
                    if playerMoney and playerMoney:IsA("IntValue") then
                        playerMoney.Changed:Connect(function()
                            money.Value = formatNumber(playerMoney.Value)
                        end)
                        money.Value = formatNumber(playerMoney.Value)
                    end
                end
            end)
        end
    end
    
    -- Death tracking (for KOs and WOs)
    if SHOW_KOS or SHOW_WOS then
        player.CharacterAdded:Connect(function(character)
            local humanoid = character:WaitForChild("Humanoid", 10)
            if humanoid then
                humanoid.Died:Connect(function()
                    -- Update deaths
                    if SHOW_WOS then
                        local deaths = leaderstats:FindFirstChild("WOs")
                        if deaths then
                            deaths.Value = deaths.Value + 1
                        end
                    end
                    
                    -- Update killer's KOs
                    if SHOW_KOS then
                        local killer = getKiller(humanoid)
                        if killer and killer ~= player then
                            local killerStats = killer:FindFirstChild("leaderstats")
                            if killerStats then
                                local kills = killerStats:FindFirstChild("KOs")
                                if kills then
                                    kills.Value = kills.Value + 1
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end
end)