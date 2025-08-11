-- TycoonScript.lua
-- Place this script directly inside each Tycoon model in the workspace
-- This script manages the tycoon for multiplayer gameplay

local TycoonModel = script.Parent
local PurchaseHandler = require(game.ServerScriptService.PurchaseHandler) -- Adjust path if needed

-- Tycoon Configuration
local TYCOON_CONFIG = {
    SpawnCooldown = 3, -- Seconds between money drops
    BaseDropValue = 10, -- Base money per drop
    ClaimPadName = "ClaimPad",
    SpawnName = "Spawn",
    CollectorName = "Collector",
    PurchasedObjectsName = "PurchasedObjects"
}

-- Tycoon state
local tycoonOwner = nil
local purchaseHandler = nil
local isRunning = false
local dropperConnections = {}

-- Create necessary components if they don't exist
local function ensureTycoonComponents()
    -- Ensure Owner ObjectValue exists
    local ownerValue = TycoonModel:FindFirstChild("Owner")
    if not ownerValue then
        ownerValue = Instance.new("ObjectValue")
        ownerValue.Name = "Owner"
        ownerValue.Parent = TycoonModel
    end
    
    -- Ensure PurchasedObjects folder exists
    local purchasedObjects = TycoonModel:FindFirstChild(TYCOON_CONFIG.PurchasedObjectsName)
    if not purchasedObjects then
        purchasedObjects = Instance.new("Folder")
        purchasedObjects.Name = TYCOON_CONFIG.PurchasedObjectsName
        purchasedObjects.Parent = TycoonModel
    end
    
    -- Ensure TeamColor value exists
    local teamColor = TycoonModel:FindFirstChild("TeamColor")
    if not teamColor then
        teamColor = Instance.new("BrickColorValue")
        teamColor.Name = "TeamColor"
        teamColor.Value = BrickColor.random()
        teamColor.Parent = TycoonModel
    end
end

-- Set up the claim pad
local function setupClaimPad()
    local claimPad = TycoonModel:FindFirstChild(TYCOON_CONFIG.ClaimPadName)
    if not claimPad then
        warn("No claim pad found in tycoon: " .. TycoonModel.Name)
        return
    end
    
    -- Make sure it has a touch detector
    local connection
    connection = claimPad.Touched:Connect(function(hit)
        -- Check if already owned
        if tycoonOwner then return end
        
        local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        
        local character = hit.Parent
        local player = game.Players:GetPlayerFromCharacter(character)
        if not player then return end
        
        -- Check if player already owns a tycoon
        local alreadyOwns = false
        for _, tycoon in pairs(workspace:GetDescendants()) do
            if tycoon.Name == "Tycoon" or tycoon:FindFirstChild("Owner") then
                local owner = tycoon:FindFirstChild("Owner")
                if owner and owner.Value == player then
                    alreadyOwns = true
                    break
                end
            end
        end
        
        if alreadyOwns then
            -- Optional: Show message to player
            return
        end
        
        -- Claim the tycoon
        claimTycoon(player)
        
        -- Disconnect the touch event
        connection:Disconnect()
    end)
end

-- Claim the tycoon for a player
function claimTycoon(player)
    -- Set owner
    tycoonOwner = player
    local ownerValue = TycoonModel:FindFirstChild("Owner")
    if ownerValue then
        ownerValue.Value = player
    end
    
    -- Change claim pad appearance
    local claimPad = TycoonModel:FindFirstChild(TYCOON_CONFIG.ClaimPadName)
    if claimPad then
        claimPad.BrickColor = BrickColor.new("Lime green")
        claimPad.Material = Enum.Material.Neon
        claimPad.CanCollide = false
        
        -- Add owner billboard
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Parent = claimPad
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = player.Name .. "'s Tycoon"
        label.TextScaled = true
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextStrokeTransparency = 0
        label.Parent = billboard
    end
    
    -- Set spawn location
    local spawn = TycoonModel:FindFirstChild(TYCOON_CONFIG.SpawnName)
    if spawn and spawn:IsA("SpawnLocation") then
        spawn.Enabled = true
        spawn.TeamColor = TycoonModel.TeamColor.Value
        
        -- Create team if needed
        local team = game.Teams:FindFirstChild(player.Name .. "'s Team")
        if not team then
            team = Instance.new("Team")
            team.Name = player.Name .. "'s Team"
            team.TeamColor = TycoonModel.TeamColor.Value
            team.Parent = game.Teams
        end
        
        player.Team = team
        player.TeamColor = TycoonModel.TeamColor.Value
    end
    
    -- Initialize purchase handler
    purchaseHandler = PurchaseHandler.new(TycoonModel)
    purchaseHandler:Initialize()
    
    -- Connect money tracking
    setupMoneyTracking(player)
    
    -- Start tycoon operations
    isRunning = true
    startTycoonLoop()
    
    -- Handle player leaving
    player.AncestryChanged:Connect(function()
        if not player.Parent then
            resetTycoon()
        end
    end)
end

-- Set up money tracking for the purchase handler
function setupMoneyTracking(player)
    local leaderstats = player:WaitForChild("leaderstats", 5)
    if not leaderstats then
        -- Create leaderstats if it doesn't exist
        leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = player
    end
    
    local money = leaderstats:FindFirstChild("Money") or leaderstats:FindFirstChild("Cash")
    if not money then
        money = Instance.new("IntValue")
        money.Name = "Money"
        money.Value = 50000 -- Starting money
        money.Parent = leaderstats
    end
    
    -- Update purchase handler when money changes
    local moneyConnection = money.Changed:Connect(function()
        if purchaseHandler then
            purchaseHandler:UpdateMoney(money.Value)
        end
    end)
    
    -- Initial money update
    if purchaseHandler then
        purchaseHandler:UpdateMoney(money.Value)
    end
    
    -- Store connection for cleanup
    table.insert(dropperConnections, moneyConnection)
end

-- Start the tycoon's main loop
function startTycoonLoop()
    -- Set up collector
    local collector = TycoonModel:FindFirstChild(TYCOON_CONFIG.CollectorName)
    if collector then
        setupCollector(collector)
    end
    
    -- Fix button positions after a short delay
    task.wait(1)
    if purchaseHandler then
        purchaseHandler:FixButtonPositions()
    end
end

-- Set up the money collector
function setupCollector(collector)
    local connection = collector.Touched:Connect(function(hit)
        if not tycoonOwner then return end
        
        -- Check if it's a money part
        local cashValue = hit:FindFirstChild("CashValue")
        if cashValue and cashValue:IsA("NumberValue") then
            -- Give money to owner
            local leaderstats = tycoonOwner:FindFirstChild("leaderstats")
            if leaderstats then
                local money = leaderstats:FindFirstChild("Money") or leaderstats:FindFirstChild("Cash")
                if money then
                    money.Value = money.Value + cashValue.Value
                end
            end
            
            -- Destroy the money part
            hit:Destroy()
        end
    end)
    
    table.insert(dropperConnections, connection)
end

-- Reset the tycoon when owner leaves
function resetTycoon()
    isRunning = false
    
    -- Clean up purchase handler
    if purchaseHandler then
        purchaseHandler:Cleanup()
        purchaseHandler = nil
    end
    
    -- Disconnect all connections
    for _, connection in ipairs(dropperConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    dropperConnections = {}
    
    -- Reset owner
    tycoonOwner = nil
    local ownerValue = TycoonModel:FindFirstChild("Owner")
    if ownerValue then
        ownerValue.Value = nil
    end
    
    -- Reset claim pad
    local claimPad = TycoonModel:FindFirstChild(TYCOON_CONFIG.ClaimPadName)
    if claimPad then
        claimPad.BrickColor = BrickColor.new("Bright green")
        claimPad.Material = Enum.Material.Plastic
        claimPad.CanCollide = true
        
        -- Remove billboard
        local billboard = claimPad:FindFirstChildOfClass("BillboardGui")
        if billboard then
            billboard:Destroy()
        end
    end
    
    -- Reset spawn
    local spawn = TycoonModel:FindFirstChild(TYCOON_CONFIG.SpawnName)
    if spawn and spawn:IsA("SpawnLocation") then
        spawn.Enabled = false
    end
    
    -- Move purchased items back to storage
    local purchasedObjects = TycoonModel:FindFirstChild(TYCOON_CONFIG.PurchasedObjectsName)
    if purchasedObjects then
        for _, child in pairs(TycoonModel:GetChildren()) do
            -- Check if this is a purchased item (has a matching button)
            if child:FindFirstChild("Head") and (child.Name:match("^Buy") or child.Name:match("^Upgrade")) then
                -- This is a purchased object, move it back
                child.Parent = purchasedObjects
            end
        end
    end
    
    -- Set up claim pad again
    setupClaimPad()
end

-- Initialize the tycoon
ensureTycoonComponents()
setupClaimPad()

-- Handle dropper spawning (called by individual droppers)
_G.RegisterDropper = _G.RegisterDropper or function(tycoonModel, dropper, dropModel, spawnRate, cashValue)
    if tycoonModel ~= TycoonModel then return end
    
    task.spawn(function()
        while isRunning and dropper.Parent do
            if dropper.Parent == TycoonModel then -- Only spawn if dropper is active
                local drop = dropModel:Clone()
                drop.Position = dropper.Position - Vector3.new(0, 2, 0)
                
                local cash = Instance.new("NumberValue")
                cash.Name = "CashValue"
                cash.Value = cashValue
                cash.Parent = drop
                
                drop.Parent = workspace
                
                -- Clean up old drops
                game.Debris:AddItem(drop, 20)
            end
            
            task.wait(spawnRate)
        end
    end)
end