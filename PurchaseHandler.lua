-- PurchaseHandler for Cinnamoroll Tycoon
-- Handles purchase progression and button visibility

local PurchaseHandler = {}
PurchaseHandler.__index = PurchaseHandler

-- Define the purchase progression tree
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

function PurchaseHandler.new(tycoon)
    local self = setmetatable({}, PurchaseHandler)
    self.tycoon = tycoon
    self.purchasedItems = {}
    self.buttons = {}
    self.playerMoney = 0
    self.connections = {} -- Store button connections for cleanup
    self.isInitialized = false
    
    return self
end

function PurchaseHandler:Initialize()
    -- Prevent double initialization
    if self.isInitialized then
        warn("PurchaseHandler already initialized for this tycoon")
        return
    end
    
    -- Find all purchase buttons in the tycoon
    self:FindAllButtons()
    
    -- Hide all buttons initially
    self:HideAllButtons()
    
    -- Show initial available buttons
    self:UpdateButtonVisibility()
    
    -- Set up button connections
    self:SetupButtonConnections()
    
    self.isInitialized = true
end

function PurchaseHandler:Cleanup()
    -- Disconnect all button connections
    for _, connection in pairs(self.connections) do
        if connection then
            connection:Disconnect()
        end
    end
    self.connections = {}
    
    -- Reset state
    self.isInitialized = false
    self.purchasedItems = {}
    self.playerMoney = 0
    
    -- Hide all buttons
    self:HideAllButtons()
end

function PurchaseHandler:FindAllButtons()
    local function findButtonsRecursive(parent)
        for _, child in pairs(parent:GetChildren()) do
            if child.Name:match("^Buy") or child.Name:match("^Upgrade") then
                -- Check if this is a button model with a Head part
                local head = child:FindFirstChild("Head")
                if head then
                    self.buttons[child.Name] = child
                end
            end
            findButtonsRecursive(child)
        end
    end
    
    findButtonsRecursive(self.tycoon)
end

function PurchaseHandler:HideAllButtons()
    for name, button in pairs(self.buttons) do
        self:SetButtonVisible(button, false)
    end
end

function PurchaseHandler:SetButtonVisible(button, visible)
    if button then
        -- Set transparency for all parts in the button
        for _, part in pairs(button:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = visible and 0 or 1
                part.CanCollide = visible
            elseif part:IsA("SurfaceGui") or part:IsA("BillboardGui") then
                part.Enabled = visible
            elseif part:IsA("Decal") or part:IsA("Texture") then
                part.Transparency = visible and 0 or 1
            end
        end
    end
end

function PurchaseHandler:CanAfford(itemName)
    local data = PURCHASE_DATA[itemName]
    if not data then return false end
    
    return self.playerMoney >= data.price
end

function PurchaseHandler:HasRequirements(itemName)
    local data = PURCHASE_DATA[itemName]
    if not data then return false end
    
    -- If no requirements, it's available
    if not data.requires then
        return true
    end
    
    -- Check all requirements
    for _, requirement in pairs(data.requires) do
        if not self.purchasedItems[requirement] then
            return false
        end
    end
    
    return true
end

function PurchaseHandler:UpdateButtonVisibility()
    -- First, hide all buttons
    self:HideAllButtons()
    
    -- Show buttons that meet requirements and haven't been purchased
    for itemName, button in pairs(self.buttons) do
        if not self.purchasedItems[itemName] then
            if self:HasRequirements(itemName) then
                self:SetButtonVisible(button, true)
                
                -- Update button color based on affordability
                local head = button:FindFirstChild("Head")
                if head then
                    if self:CanAfford(itemName) then
                        head.BrickColor = BrickColor.new("Lime green")
                    else
                        head.BrickColor = BrickColor.new("Really red")
                    end
                end
            end
        end
    end
    
    -- Special case: Show initial buttons if nothing has been purchased
    if next(self.purchasedItems) == nil then
        -- Show the starting dropper
        local startButton = self.buttons["Buy Dropper - [$10,000]"]
        if startButton then
            self:SetButtonVisible(startButton, true)
        end
    end
end

function PurchaseHandler:Purchase(itemName)
    local data = PURCHASE_DATA[itemName]
    if not data then
        warn("No purchase data for: " .. itemName)
        return false
    end
    
    -- Check if already purchased
    if self.purchasedItems[itemName] then
        return false
    end
    
    -- Check requirements
    if not self:HasRequirements(itemName) then
        warn("Missing requirements for: " .. itemName)
        return false
    end
    
    -- Check money
    if not self:CanAfford(itemName) then
        warn("Not enough money for: " .. itemName)
        return false
    end
    
    -- Deduct money and mark as purchased
    self.playerMoney = self.playerMoney - data.price
    self.purchasedItems[itemName] = true
    
    -- Hide the purchased button
    local button = self.buttons[itemName]
    if button then
        self:SetButtonVisible(button, false)
    end
    
    -- Update visibility for newly unlocked items
    self:UpdateButtonVisibility()
    
    -- Spawn the purchased item
    self:SpawnPurchasedItem(itemName)
    
    return true
end

function PurchaseHandler:SpawnPurchasedItem(itemName)
    -- Spawn the actual dropper/item in the tycoon
    local purchasedObjects = self.tycoon:FindFirstChild("PurchasedObjects")
    if not purchasedObjects then
        warn("No PurchasedObjects folder found in tycoon")
        return
    end
    
    -- Look for the item to spawn
    local item = purchasedObjects:FindFirstChild(itemName)
    if not item then
        -- Try without brackets price (in case names don't match exactly)
        for _, child in pairs(purchasedObjects:GetChildren()) do
            if child.Name:match(itemName:match("^[^%[]+")) then
                item = child
                break
            end
        end
    end
    
    if item then
        -- Move item to tycoon
        item.Parent = self.tycoon
        
        -- Make all parts visible
        for _, part in pairs(item:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
                part.CanCollide = true
            elseif part:IsA("Decal") or part:IsA("Texture") then
                part.Transparency = 0
            end
        end
        
        -- Special handling for droppers
        if itemName:match("Dropper") then
            self:SetupDropper(item)
        end
        
        print("Spawned: " .. itemName)
    else
        warn("Could not find item to spawn: " .. itemName)
    end
end

function PurchaseHandler:SetupDropper(dropper)
    -- Set up dropper functionality
    if dropper:FindFirstChild("DropperScript") then
        dropper.DropperScript.Enabled = true
    else
        -- Create a basic dropper script if none exists
        local dropperScript = Instance.new("Script")
        dropperScript.Name = "DropperScript"
        dropperScript.Source = [[
local dropper = script.Parent
local dropPart = dropper:FindFirstChild("Drop") or dropper:FindFirstChild("DropPart")
if not dropPart then return end

local tycoon = dropper.Parent
local baseValue = 10
local dropRate = 3

-- Determine drop value based on dropper type
if dropper.Name:match("MEGA") then
    baseValue = 100
    dropRate = 2
elseif dropper.Name:match("Super") then
    baseValue = 250
    dropRate = 2.5
elseif dropper.Name:match("Omega") then
    baseValue = 500
    dropRate = 2
elseif dropper.Name:match("POWER") then
    baseValue = 150
    dropRate = 2.5
elseif dropper.Name:match("CORE") then
    baseValue = 75
    dropRate = 3
end

-- Register with tycoon system
if _G.RegisterDropper then
    _G.RegisterDropper(tycoon, dropper, dropPart, dropRate, baseValue)
end
]]
        dropperScript.Parent = dropper
        dropperScript.Enabled = true
    end
end

function PurchaseHandler:SetupButtonConnections()
    for itemName, button in pairs(self.buttons) do
        local head = button:FindFirstChild("Head")
        if head then
            local clickDetector = head:FindFirstChild("ClickDetector")
            if not clickDetector then
                clickDetector = Instance.new("ClickDetector")
                clickDetector.MaxActivationDistance = 20
                clickDetector.Parent = head
            end
            
            -- Disconnect any existing connections to prevent duplicates
            if self.connections[itemName] then
                self.connections[itemName]:Disconnect()
            end
            
            -- Store connection for cleanup
            self.connections[itemName] = clickDetector.MouseClick:Connect(function(player)
                -- Verify this is the tycoon owner
                local owner = self.tycoon:FindFirstChild("Owner")
                if owner and owner.Value == player then
                    self:Purchase(itemName)
                end
            end)
        end
    end
end

function PurchaseHandler:UpdateMoney(newAmount)
    self.playerMoney = newAmount
    self:UpdateButtonVisibility()
end

function PurchaseHandler:FixButtonPositions()
    -- Fix floating or underground buttons
    for name, button in pairs(self.buttons) do
        local head = button:FindFirstChild("Head")
        if head and head:IsA("BasePart") then
            -- Ensure button is properly positioned
            local ray = workspace:Raycast(
                head.Position + Vector3.new(0, 10, 0),
                Vector3.new(0, -50, 0)
            )
            
            if ray then
                -- Position button slightly above ground
                head.CFrame = CFrame.new(
                    ray.Position + Vector3.new(0, head.Size.Y/2 + 0.1, 0)
                ) * CFrame.Angles(0, head.CFrame:ToEulerAnglesYXZ(), 0)
            end
        end
    end
end

-- Debug function to show purchase tree
function PurchaseHandler:DebugShowTree()
    print("=== Purchase Tree ===")
    for itemName, data in pairs(PURCHASE_DATA) do
        print(itemName .. " ($" .. data.price .. ")")
        if data.requires then
            print("  Requires: " .. table.concat(data.requires, ", "))
        end
        if data.unlocks and #data.unlocks > 0 then
            print("  Unlocks: " .. table.concat(data.unlocks, ", "))
        end
    end
end

return PurchaseHandler