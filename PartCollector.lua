-- Modern Part Collector Script
-- Collects currency orbs/parts when they touch the collector

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

-- Configuration
local VALID_CURRENCY_NAMES = {"Cash", "Money", "Coin", "Orb", "Currency", "Part"} -- Add your currency part names here
local COLLECTION_COOLDOWN = 0.05 -- Cooldown between collections in seconds
local OWNER_ONLY = true -- Only collect for the tycoon owner

-- Get the collector part (the part this script is attached to)
local collector = script.Parent
if not collector:IsA("BasePart") then
    warn("PartCollector must be attached to a Part!")
    return
end

-- Find the tycoon owner
local function findTycoonOwner()
    local tycoon = collector:FindFirstAncestorOfClass("Model")
    if tycoon then
        -- Look for common owner value locations
        local owner = tycoon:FindFirstChild("Owner") or 
                      tycoon:FindFirstChild("OwnerValue") or
                      tycoon:FindFirstChild("TycoonOwner")
        
        if owner and owner:IsA("ObjectValue") then
            return owner.Value
        elseif owner and owner:IsA("StringValue") then
            return Players:FindFirstChild(owner.Value)
        end
    end
    return nil
end

-- Find CurrencyToCollect value
local function findCurrencyToCollect()
    local tycoon = collector:FindFirstAncestorOfClass("Model")
    if tycoon then
        local currency = tycoon:FindFirstChild("CurrencyToCollect", true)
        if currency and currency:IsA("IntValue") then
            return currency
        end
    end
    return nil
end

-- Get references
local tycoonOwner = findTycoonOwner()
local currencyToCollect = findCurrencyToCollect()

if not currencyToCollect then
    warn("PartCollector: Could not find CurrencyToCollect value!")
    return
end

-- Track collected parts to prevent double collection
local collectedParts = {}
local lastCollectionTime = 0

-- Check if a part is a valid currency part
local function isValidCurrencyPart(part)
    if not part:IsA("BasePart") then return false end
    
    -- Check if part name contains any valid currency name
    local partName = part.Name:lower()
    for _, validName in ipairs(VALID_CURRENCY_NAMES) do
        if partName:find(validName:lower()) then
            return true
        end
    end
    
    -- Also check for a "Cash" or "Value" IntValue/NumberValue inside the part
    local cashValue = part:FindFirstChild("Cash") or 
                      part:FindFirstChild("Value") or 
                      part:FindFirstChild("Worth")
    
    return cashValue and (cashValue:IsA("IntValue") or cashValue:IsA("NumberValue"))
end

-- Get the value of a currency part
local function getCurrencyValue(part)
    -- First check for value objects inside the part
    local valueObj = part:FindFirstChild("Cash") or 
                     part:FindFirstChild("Value") or 
                     part:FindFirstChild("Worth")
    
    if valueObj and (valueObj:IsA("IntValue") or valueObj:IsA("NumberValue")) then
        return valueObj.Value
    end
    
    -- Default value if no value object found
    return 1
end

-- Collect a currency part
local function collectPart(part)
    -- Check if already collected
    if collectedParts[part] then
        return
    end
    
    -- Mark as collected immediately
    collectedParts[part] = true
    
    -- Check cooldown
    local now = tick()
    if now - lastCollectionTime < COLLECTION_COOLDOWN then
        -- Still collect but with a slight delay
        task.wait(COLLECTION_COOLDOWN - (now - lastCollectionTime))
    end
    lastCollectionTime = tick()
    
    -- Get value and add to currency
    local value = getCurrencyValue(part)
    currencyToCollect.Value = currencyToCollect.Value + value
    
    -- Destroy the part immediately to prevent flinging
    part:Destroy()
    
    -- Clean up reference after a delay
    task.delay(1, function()
        collectedParts[part] = nil
    end)
end

-- Handle touched event
collector.Touched:Connect(function(hit)
    -- Quick checks
    if not hit or not hit.Parent then return end
    if not isValidCurrencyPart(hit) then return end
    
    -- Owner check if enabled
    if OWNER_ONLY and tycoonOwner then
        local humanoid = hit:FindFirstAncestorWhichIsA("Humanoid")
        if humanoid then
            -- Part belongs to a player, don't collect
            return
        end
    end
    
    -- Collect the part
    collectPart(hit)
end)

-- Alternative collection method using Region3 (more reliable for small/fast parts)
local ENABLE_REGION_COLLECTION = true
if ENABLE_REGION_COLLECTION then
    local region = Region3.new(
        collector.Position - collector.Size/2,
        collector.Position + collector.Size/2
    )
    region = region:ExpandToGrid(4)
    
    -- Check for parts in region periodically
    local lastRegionCheck = 0
    RunService.Heartbeat:Connect(function()
        local now = tick()
        if now - lastRegionCheck < 0.1 then return end -- Check every 0.1 seconds
        lastRegionCheck = now
        
        local parts = workspace:FindPartsInRegion3(region, collector, 20)
        for _, part in ipairs(parts) do
            if isValidCurrencyPart(part) and not collectedParts[part] then
                collectPart(part)
            end
        end
    end)
end

-- Make collector non-collidable for currency parts to prevent flinging
collector.CanCollide = false
collector.CanQuery = true
collector.CanTouch = true

print("PartCollector initialized on", collector:GetFullName())
print("CurrencyToCollect found at", currencyToCollect:GetFullName())
if tycoonOwner then
    print("Tycoon owner:", tycoonOwner.Name)
else
    print("No tycoon owner found - collecting for anyone")
end