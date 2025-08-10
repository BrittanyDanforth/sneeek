-- Simple Leaderstats for Custom Tycoon System
-- Place in: ServerScriptService (name it "Leaderstats")
-- This replaces ALL other leaderstats scripts

local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
    -- Create leaderstats folder
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    -- Cash value (IntValue for tycoon compatibility)
    local cash = Instance.new("IntValue")
    cash.Name = "Cash"
    cash.Value = 0
    cash.Parent = leaderstats
    
    print(player.Name .. " joined with leaderstats")
end)