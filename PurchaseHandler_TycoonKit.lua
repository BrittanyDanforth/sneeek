--[[
	Purchase Handler for Tycoon Kit
	Place this as a Script inside Tycoons > [TycoonName] > PurchaseHandler
	Handles dropper progression and button visibility
--]]

wait(2) -- Wait for tycoon to fully load

local Settings = require(script.Parent.Parent:WaitForChild("Settings"))
local Objects = {}
local TeamColor = script.Parent:WaitForChild("TeamColor")
local Tycoon = script.Parent
local Owner = Tycoon:WaitForChild("Owner")

-- Services
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

-- Define the purchase progression tree (same as before)
local PURCHASE_DATA = {
    -- Basic Droppers (Starting items)
    ["Buy Dropper - [$10,000]"] = {
        price = 10000,
        category = "dropper",
        unlocks = {"Buy Dropper - [$20,000]", "Buy Conveyer - [$8,000]"}
    },
    ["Buy Dropper - [$20,000]"] = {
        price = 20000,
        category = "dropper",
        requires = {"Buy Dropper - [$10,000]"},
        unlocks = {"Buy Dropper - [$12,000]", "Buy Dropper - [$70]"}
    },
    ["Buy Dropper - [$12,000]"] = {
        price = 12000,
        category = "dropper",
        requires = {"Buy Dropper - [$20,000]"},
        unlocks = {"Buy Extra - [$35,000]", "Buy Path - [$10,000]"}
    },
    ["Buy Dropper - [$70]"] = {
        price = 70,
        category = "dropper",
        requires = {"Buy Dropper - [$20,000]"},
        unlocks = {"Buy Floor - [$1,500]"}
    },
    
    -- Conveyers and Extras
    ["Buy Conveyer - [$8,000]"] = {
        price = 8000,
        category = "conveyer",
        requires = {"Buy Dropper - [$10,000]"},
        unlocks = {"Buy CORE Dropper - [$5,000]"}
    },
    ["Buy Extra - [$35,000]"] = {
        price = 35000,
        category = "extra",
        requires = {"Buy Dropper - [$12,000]"},
        unlocks = {"Buy MEGA Dropper - [$300]"}
    },
    ["Buy Floor - [$1,500]"] = {
        price = 1500,
        category = "floor",
        requires = {"Buy Dropper - [$70]"},
        unlocks = {"Buy Path - [$250]"}
    },
    
    -- CORE Droppers
    ["Buy CORE Dropper - [$5,000]"] = {
        price = 5000,
        category = "core_dropper",
        requires = {"Buy Conveyer - [$8,000]"},
        unlocks = {"Buy POWER CORE Dropper - [$2,000]"}
    },
    ["Buy POWER CORE Dropper - [$2,000]"] = {
        price = 2000,
        category = "power_core_dropper",
        requires = {"Buy CORE Dropper - [$5,000]"},
        unlocks = {"Buy a Omega Dropper - [$15,000]"}
    },
    
    -- MEGA and Advanced Droppers
    ["Buy MEGA Dropper - [$300]"] = {
        price = 300,
        category = "mega_dropper",
        requires = {"Buy Extra - [$35,000]"},
        unlocks = {
            "Buy Super Dropper - [$1,000]",
            "Buy Walls - [$100]",
            "Buy a Mega Dropper - [$7,000]"
        }
    },
    ["Buy Super Dropper - [$1,000]"] = {
        price = 1000,
        category = "super_dropper",
        requires = {"Buy MEGA Dropper - [$300]"},
        unlocks = {"Buy a Omega Dropper - [$9,000]"}
    },
    ["Buy a Mega Dropper - [$7,000]"] = {
        price = 7000,
        category = "mega_dropper_advanced",
        requires = {"Buy MEGA Dropper - [$300]"},
        unlocks = {"Buy an OwnerDoor - [$1,500]"}
    },
    
    -- Omega Droppers
    ["Buy a Omega Dropper - [$15,000]"] = {
        price = 15000,
        category = "omega_dropper",
        requires = {"Buy POWER CORE Dropper - [$2,000]"},
        unlocks = {"Upgrade Roof - [$40,000]"}
    },
    ["Buy a Omega Dropper - [$9,000]"] = {
        price = 9000,
        category = "omega_dropper",
        requires = {"Buy Super Dropper - [$1,000]"},
        unlocks = {"Upgrade Wall - [$35,000]"}
    },
    
    -- Paths
    ["Buy Path - [$10,000]"] = {
        price = 10000,
        category = "path",
        requires = {"Buy Dropper - [$12,000]"},
        unlocks = {"Buy Path - [$10,000]_2"}
    },
    ["Buy Path - [$10,000]_2"] = {
        price = 10000,
        category = "path",
        requires = {"Buy Path - [$10,000]"},
        unlocks = {"Buy Stair - [$2500]"}
    },
    ["Buy Path - [$250]"] = {
        price = 250,
        category = "path",
        requires = {"Buy Floor - [$1,500]"},
        unlocks = {"Buy Walls - [$100]"}
    },
    ["Buy Stair - [$2500]"] = {
        price = 2500,
        category = "stair",
        requires = {"Buy Path - [$10,000]_2"},
        unlocks = {"Upgrade Walls - [$1,000]"}
    },
    
    -- Walls and Upgrades
    ["Buy Walls - [$100]"] = {
        price = 100,
        category = "walls",
        requires = {"Buy Path - [$250]", "Buy MEGA Dropper - [$300]"},
        unlocks = {"Upgrade Walls - [$1,000]"}
    },
    ["Upgrade Walls - [$1,000]"] = {
        price = 1000,
        category = "upgrade",
        requires = {"Buy Walls - [$100]"},
        unlocks = {"Upgrade Walls - [$12,000]"}
    },
    ["Upgrade Walls - [$12,000]"] = {
        price = 12000,
        category = "upgrade",
        requires = {"Upgrade Walls - [$1,000]"},
        unlocks = {"Upgrade Walls - [$20,000]"}
    },
    ["Upgrade Walls - [$20,000]"] = {
        price = 20000,
        category = "upgrade",
        requires = {"Upgrade Walls - [$12,000]"},
        unlocks = {"Upgrade Walls - [$28,000]"}
    },
    ["Upgrade Walls - [$28,000]"] = {
        price = 28000,
        category = "upgrade",
        requires = {"Upgrade Walls - [$20,000]"},
        unlocks = {"Upgrade Walls - [$350]"}
    },
    ["Upgrade Walls - [$350]"] = {
        price = 350,
        category = "upgrade",
        requires = {"Upgrade Walls - [$28,000]"},
        unlocks = {"Upgrade Walls - [$7,000]"}
    },
    ["Upgrade Walls - [$7,000]"] = {
        price = 7000,
        category = "upgrade",
        requires = {"Upgrade Walls - [$350]"},
        unlocks = {"Upgrade Walls - [$700]"}
    },
    ["Upgrade Walls - [$700]"] = {
        price = 700,
        category = "upgrade",
        requires = {"Upgrade Walls - [$7,000]"},
        unlocks = {"Upgrade Wall - [$35,000]"}
    },
    ["Upgrade Wall - [$35,000]"] = {
        price = 35000,
        category = "upgrade",
        requires = {"Buy a Omega Dropper - [$9,000]", "Upgrade Walls - [$700]"},
        unlocks = {"Upgrade Wall - [$45,000]"}
    },
    ["Upgrade Wall - [$45,000]"] = {
        price = 45000,
        category = "upgrade",
        requires = {"Upgrade Wall - [$35,000]"},
        unlocks = {"Upgrade Roof - [$40,000]"}
    },
    ["Upgrade Roof - [$40,000]"] = {
        price = 40000,
        category = "upgrade",
        requires = {"Buy a Omega Dropper - [$15,000]", "Upgrade Wall - [$45,000]"},
        unlocks = {}
    },
    
    -- Special Items
    ["Buy an OwnerDoor - [$1,500]"] = {
        price = 1500,
        category = "special",
        requires = {"Buy a Mega Dropper - [$7,000]"},
        unlocks = {}
    }
}

-- Track purchased items
local purchasedItems = {}
local buttonConnections = {}

-- Sound IDs from settings
local Sounds = {
    Purchase = Settings.Sounds.Purchase,
    Collect = Settings.Sounds.Collect,
    ErrorBuy = Settings.Sounds.ErrorBuy
}

-- Function to play sound
local function playSound(soundId)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. soundId
    sound.Volume = 0.5
    sound.Parent = workspace
    sound:Play()
    Debris:AddItem(sound, 2)
end

-- Check if player has requirements
local function hasRequirements(itemName)
    local data = PURCHASE_DATA[itemName]
    if not data then return false end
    
    if not data.requires then
        return true
    end
    
    for _, requirement in pairs(data.requires) do
        if not purchasedItems[requirement] then
            return false
        end
    end
    
    return true
end

-- Update button visibility
local function updateButtonVisibility()
    local buttons = Tycoon:WaitForChild("Buttons")
    
    for _, button in pairs(buttons:GetChildren()) do
        local itemName = button.Name
        local head = button:FindFirstChild("Head")
        
        if head then
            -- Check if already purchased
            if purchasedItems[itemName] then
                -- Hide purchased buttons
                head.Transparency = 1
                head.CanCollide = false
                local gui = head:FindFirstChildOfClass("SurfaceGui") or head:FindFirstChildOfClass("BillboardGui")
                if gui then gui.Enabled = false end
            elseif hasRequirements(itemName) then
                -- Show available buttons
                head.Transparency = 0
                head.CanCollide = true
                local gui = head:FindFirstChildOfClass("SurfaceGui") or head:FindFirstChildOfClass("BillboardGui")
                if gui then gui.Enabled = true end
                
                -- Update color based on affordability
                if Owner.Value then
                    local player = Owner.Value
                    local leaderstats = player:FindFirstChild("leaderstats")
                    if leaderstats then
                        local money = leaderstats:FindFirstChild(Settings.CurrencyName)
                        if money then
                            local data = PURCHASE_DATA[itemName]
                            if data and money.Value >= data.price then
                                head.BrickColor = BrickColor.new("Lime green")
                            else
                                head.BrickColor = BrickColor.new("Really red")
                            end
                        end
                    end
                end
            else
                -- Hide buttons without requirements
                head.Transparency = 1
                head.CanCollide = false
                local gui = head:FindFirstChildOfClass("SurfaceGui") or head:FindFirstChildOfClass("BillboardGui")
                if gui then gui.Enabled = false end
            end
        end
    end
end

-- Handle purchase
local function handlePurchase(player, itemName)
    if player ~= Owner.Value then return end
    
    local data = PURCHASE_DATA[itemName]
    if not data then return end
    
    -- Check if already purchased
    if purchasedItems[itemName] then return end
    
    -- Check requirements
    if not hasRequirements(itemName) then
        playSound(Sounds.ErrorBuy)
        return
    end
    
    -- Check money
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then return end
    
    local money = leaderstats:FindFirstChild(Settings.CurrencyName)
    if not money or money.Value < data.price then
        playSound(Sounds.ErrorBuy)
        return
    end
    
    -- Make purchase
    money.Value = money.Value - data.price
    purchasedItems[itemName] = true
    playSound(Sounds.Purchase)
    
    -- Spawn the object
    local purchases = Tycoon:WaitForChild("Purchases")
    local object = purchases:FindFirstChild(itemName)
    if object then
        object.Parent = Tycoon
        Objects[itemName] = object
    end
    
    -- Update visibility
    updateButtonVisibility()
end

-- Set up button connections
local function setupButtons()
    local buttons = Tycoon:WaitForChild("Buttons")
    
    for _, button in pairs(buttons:GetChildren()) do
        local head = button:FindFirstChild("Head")
        if head then
            local clickDetector = head:FindFirstChildOfClass("ClickDetector")
            if clickDetector then
                buttonConnections[button.Name] = clickDetector.MouseClick:Connect(function(player)
                    handlePurchase(player, button.Name)
                end)
            end
        end
    end
    
    -- Initial visibility update
    updateButtonVisibility()
end

-- Handle owner changes
Owner.Changed:Connect(function()
    if Owner.Value then
        -- New owner claimed tycoon
        setupButtons()
        
        -- Track money changes
        local player = Owner.Value
        local leaderstats = player:WaitForChild("leaderstats")
        local money = leaderstats:WaitForChild(Settings.CurrencyName)
        
        money.Changed:Connect(function()
            updateButtonVisibility()
        end)
    else
        -- Owner left, reset
        purchasedItems = {}
        
        -- Disconnect all connections
        for _, connection in pairs(buttonConnections) do
            connection:Disconnect()
        end
        buttonConnections = {}
        
        -- Move objects back to purchases
        local purchases = Tycoon:WaitForChild("Purchases")
        for name, object in pairs(Objects) do
            if object and object.Parent then
                object.Parent = purchases
            end
        end
        Objects = {}
        
        -- Reset button visibility
        updateButtonVisibility()
    end
end)

-- Initialize if owner already exists
if Owner.Value then
    setupButtons()
end