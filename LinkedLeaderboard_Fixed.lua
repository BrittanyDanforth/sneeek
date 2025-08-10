-- This version keeps the exact structure you have
local Settings = require(script.Parent.Settings)
-- DON'T move the script - let it stay where it is
-- script.Parent = game.ServerScriptService  -- COMMENTED OUT

stands = {}
CTF_mode = false

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
        local humanoid = player.Character.Humanoid
        local p = player
        local h = humanoid
        if Settings.LeaderboardSettings.WOs then
            humanoid.Died:Connect(function() onHumanoidDied(h, p) end )
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
        if killer.Parent ~= nil then -- killer still in game
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
            -- FIXED: Changed KillsNames to KillsName
            local kills = stats:FindFirstChild(Settings.LeaderboardSettings.KillsName)
            if kills then
                if killer ~= player then
                    kills.Value = kills.Value + 1    
                else
                    kills.Value = kills.Value - 1
                end
            else
                return
            end
        end
    end
end


-----------------------------------------------



function findAllFlagStands(root)
    local c = root:GetChildren()
    for i=1,#c do
        if (c[i].ClassName == "Model" or c[i].ClassName == "Part") then
            findAllFlagStands(c[i])
        end
        if (c[i].ClassName == "FlagStand") then
            table.insert(stands, c[i])
        end
    end
end

function hookUpListeners()
    for i=1,#stands do
        stands[i].FlagCaptured:Connect(onCaptureScored)
    end
end

function onPlayerEntered(newPlayer)

    if CTF_mode == true then

        local stats = Instance.new("Folder")
        stats.Name = "leaderstats"

        local captures = Instance.new("IntValue")
        captures.Name = "Captures"
        captures.Value = 0


        captures.Parent = stats

        -- VERY UGLY HACK
        -- Will this leak threads?
        -- Is the problem even what I think it is (player arrived before character)?
        while true do
            if newPlayer.Character ~= nil then break end
            wait(5)
        end

        stats.Parent = newPlayer

    else

        local stats = Instance.new("Folder")
        stats.Name = "leaderstats"
        local kills = false
        if Settings.LeaderboardSettings.KOs then
            kills = Instance.new("IntValue")
            kills.Name = Settings.LeaderboardSettings.KillsName
            kills.Value = 0
        end
        local deaths = false
        if Settings.LeaderboardSettings.WOs then
            deaths = Instance.new("IntValue")
            deaths.Name = Settings.LeaderboardSettings.DeathsName
            deaths.Value = 0
        end
        
        local cash = false
        if Settings.LeaderboardSettings.ShowCurrency then
            cash = Instance.new("StringValue")
            cash.Name = Settings.CurrencyName
            cash.Value = "0"
        end
        
        -- Safely check for PlayerMoney
        local serverStorage = game:GetService("ServerStorage")
        local playerMoneyFolder = serverStorage:FindFirstChild("PlayerMoney")
        if playerMoneyFolder then
            local PlayerStats = playerMoneyFolder:FindFirstChild(newPlayer.Name)
            if PlayerStats ~= nil then
                if cash then
                    local Short = Settings.LeaderboardSettings.ShowShortCurrency
                    
                    local function updateCashDisplay()
                        local value = PlayerStats.Value
                        if (Short) then
                            cash.Value = Settings:ConvertShort(value)
                        else
                            cash.Value = Settings:ConvertComma(value)
                        end
                    end
                    
                    -- Set initial value
                    updateCashDisplay()
                    
                    -- Connect to changes
                    PlayerStats.Changed:Connect(updateCashDisplay)
                end
            end
        end
        
        if kills then
            kills.Parent = stats
        end
        if deaths then
            deaths.Parent = stats
        end
        if cash then
            cash.Parent = stats
        end

        -- VERY UGLY HACK
        -- Will this leak threads?
        -- Is the problem even what I think it is (player arrived before character)?
        while true do
            if newPlayer.Character ~= nil then break end
            wait(5)
        end

        local humanoid = newPlayer.Character:WaitForChild("Humanoid", 10)
        if humanoid then
            humanoid.Died:Connect(function() onHumanoidDied(humanoid, newPlayer) end )
        end

        -- start to listen for new humanoid
        newPlayer.Changed:Connect(function(property) onPlayerRespawn(property, newPlayer) end )


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


findAllFlagStands(game.Workspace)
hookUpListeners()
if (#stands > 0) then CTF_mode = true end
game.Players.PlayerAdded:Connect(onPlayerEntered)