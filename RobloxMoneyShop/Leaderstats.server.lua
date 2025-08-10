-- Unified Leaderstats Script
-- Place in: ServerScriptService/Leaderstats.server.lua

local Players = game:GetService("Players")

-- Configuration
local SHOW_KOS = false  -- Set to true to show Kills
local SHOW_WOS = false  -- Set to true to show Deaths (Wipeouts)
local STARTING_CASH = 0

Players.PlayerAdded:Connect(function(player)
    -- Create leaderstats folder
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    -- Cash (always shown)
    local cash = Instance.new("IntValue")
    cash.Name = "Cash"
    cash.Value = STARTING_CASH
    cash.Parent = leaderstats

    -- Optional: Kills
    if SHOW_KOS then
        local kills = Instance.new("IntValue")
        kills.Name = "KOs"
        kills.Value = 0
        kills.Parent = leaderstats
    end

    -- Optional: Deaths
    if SHOW_WOS then
        local deaths = Instance.new("IntValue")
        deaths.Name = "WOs"
        deaths.Value = 0
        deaths.Parent = leaderstats
        
        -- Connect death tracking
        player.CharacterAdded:Connect(function(character)
            local humanoid = character:WaitForChild("Humanoid")
            humanoid.Died:Connect(function()
                deaths.Value = deaths.Value + 1
                
                -- Handle kill credit if KOs are enabled
                if SHOW_KOS then
                    local tag = humanoid:FindFirstChild("creator")
                    if tag and tag.Value and tag.Value:IsA("Player") and tag.Value ~= player then
                        local killerStats = tag.Value:FindFirstChild("leaderstats")
                        if killerStats then
                            local killerKOs = killerStats:FindFirstChild("KOs")
                            if killerKOs then
                                killerKOs.Value = killerKOs.Value + 1
                            end
                        end
                    end
                end
            end)
        end)
    end
end)