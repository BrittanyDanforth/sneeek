-- Debug version to understand your setup
print("=== LEADERBOARD DEBUG INFO ===")
print("Script location:", script:GetFullName())
print("Script parent:", script.Parent and script.Parent:GetFullName() or "nil")
print("Looking for Settings at:", script.Parent and "script.Parent.Settings" or "nowhere")

-- Try to find Settings module
local Settings
local success, error = pcall(function()
    Settings = require(script.Parent.Settings)
    print("✓ Settings module found!")
end)

if not success then
    print("✗ Failed to load Settings:", error)
    print("Attempting to find Settings in other locations...")
    
    -- Try common locations
    local locations = {
        game.ServerScriptService:FindFirstChild("Settings"),
        script.Parent.Parent:FindFirstChild("Settings"),
        game.ReplicatedStorage:FindFirstChild("Settings")
    }
    
    for i, location in ipairs(locations) do
        if location then
            print("Found Settings at:", location:GetFullName())
            Settings = require(location)
            break
        end
    end
    
    if not Settings then
        error("Could not find Settings module anywhere!")
    end
end

-- Print current hierarchy
print("\n=== CURRENT HIERARCHY ===")
if script.Parent then
    print("Children of", script.Parent:GetFullName(), ":")
    for _, child in pairs(script.Parent:GetChildren()) do
        print(" -", child.Name, "(" .. child.ClassName .. ")")
    end
end

-- Original script starts here with fixes
script.Parent = game.ServerScriptService
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
                print("Warning: Could not find kills stat named:", Settings.LeaderboardSettings.KillsName)
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
    print("Player entered:", newPlayer.Name)

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
            print("Created kills stat:", Settings.LeaderboardSettings.KillsName)
        end
        local deaths = false
        if Settings.LeaderboardSettings.WOs then
            deaths = Instance.new("IntValue")
            deaths.Name = Settings.LeaderboardSettings.DeathsName
            deaths.Value = 0
            print("Created deaths stat:", Settings.LeaderboardSettings.DeathsName)
        end
        
        local cash = false
        if Settings.LeaderboardSettings.ShowCurrency then
            cash = Instance.new("StringValue")
            cash.Name = Settings.CurrencyName
            cash.Value = "0"
            print("Created currency stat:", Settings.CurrencyName)
        end
        
        -- Check for PlayerMoney folder
        local playerMoneyFolder = game.ServerStorage:FindFirstChild("PlayerMoney")
        if not playerMoneyFolder then
            print("Warning: PlayerMoney folder not found in ServerStorage")
        else
            local PlayerStats = playerMoneyFolder:FindFirstChild(newPlayer.Name)
            if PlayerStats ~= nil then
                if cash then
                    local Short = Settings.LeaderboardSettings.ShowShortCurrency
                    PlayerStats.Changed:Connect(function()
                        if (Short) then
                            cash.Value = Settings:ConvertShort(PlayerStats.Value)
                        else
                            cash.Value = Settings:ConvertComma(PlayerStats.Value)
                        end
                    end)
                    -- Initial value
                    if (Short) then
                        cash.Value = Settings:ConvertShort(PlayerStats.Value)
                    else
                        cash.Value = Settings:ConvertComma(PlayerStats.Value)
                    end
                end
            else
                print("No PlayerStats found for", newPlayer.Name)
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

        local humanoid = newPlayer.Character:WaitForChild("Humanoid")

        humanoid.Died:Connect(function() onHumanoidDied(humanoid, newPlayer) end )

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
print("CTF Mode:", CTF_mode, "- Found", #stands, "flag stands")

game.Players.PlayerAdded:Connect(onPlayerEntered)

print("=== LEADERBOARD LOADED SUCCESSFULLY ===")
print("KOs enabled:", Settings.LeaderboardSettings.KOs or false)
print("WOs enabled:", Settings.LeaderboardSettings.WOs or false)
print("Currency enabled:", Settings.LeaderboardSettings.ShowCurrency or false)