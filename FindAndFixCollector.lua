-- Script to find and fix the existing collector in your tycoon
-- Run this in command bar or as a script to locate and patch your collector

-- Function to search for collector scripts
local function findCollectorScripts()
    local collectors = {}
    
    -- Search through workspace for scripts that might be collectors
    local function searchIn(parent, path)
        for _, child in pairs(parent:GetDescendants()) do
            if child:IsA("Script") then
                -- Check if script source contains collector-related code
                local success, source = pcall(function() return child.Source end)
                if success and source then
                    -- Look for common collector patterns
                    if source:find("CurrencyToCollect") and source:find("Touched") then
                        table.insert(collectors, {
                            script = child,
                            path = child:GetFullName(),
                            hasDestroy = source:find(":Destroy%(%)") ~= nil,
                            hasRemove = source:find(":Remove%(%)") ~= nil,
                            hasDebounce = source:find("debounce") ~= nil or source:find("Debounce") ~= nil
                        })
                    end
                end
            end
        end
    end
    
    -- Search in common locations
    searchIn(workspace)
    searchIn(game.ServerScriptService)
    searchIn(game.ServerStorage)
    
    return collectors
end

-- Function to create a fixed collector script
local function createFixedCollector()
    return [[-- Fixed Part Collector Script
-- This version prevents orbs from being flung away

local collector = script.Parent
local debounce = {}

-- Find CurrencyToCollect
local function findCurrencyToCollect()
    local model = collector
    while model and model.Parent do
        local currency = model:FindFirstChild("CurrencyToCollect")
        if currency and currency:IsA("IntValue") then
            return currency
        end
        model = model.Parent
    end
    return nil
end

local currencyToCollect = findCurrencyToCollect()
if not currencyToCollect then
    warn("Could not find CurrencyToCollect!")
    return
end

-- Make collector non-collidable to prevent physics issues
collector.CanCollide = false

collector.Touched:Connect(function(hit)
    -- Check if it's a valid currency part
    if not hit or not hit.Parent then return end
    if hit.Name ~= "Cash" and hit.Name ~= "Money" and hit.Name ~= "Orb" then return end
    
    -- Debounce check
    if debounce[hit] then return end
    debounce[hit] = true
    
    -- Get value
    local value = 1
    local cashValue = hit:FindFirstChild("Cash") or hit:FindFirstChild("Value")
    if cashValue and cashValue:IsA("IntValue") then
        value = cashValue.Value
    end
    
    -- Add to currency
    currencyToCollect.Value = currencyToCollect.Value + value
    
    -- Immediately destroy the part to prevent flinging
    hit.Anchored = true -- Anchor first to stop movement
    hit.CanCollide = false
    hit.Transparency = 1
    game:GetService("Debris"):AddItem(hit, 0)
    
    -- Clean up debounce
    task.wait(0.1)
    debounce[hit] = nil
end)
]]
end

-- Run the search
print("=== SEARCHING FOR COLLECTOR SCRIPTS ===")
local found = findCollectorScripts()

if #found == 0 then
    print("No collector scripts found in accessible locations.")
    print("The collector might be in a model that requires the game to be running.")
    print("\nTo fix the flinging issue, add this to your collector script:")
    print("1. Set collector.CanCollide = false")
    print("2. Anchor the orb before destroying: hit.Anchored = true")
    print("3. Add proper debouncing")
else
    print("Found " .. #found .. " potential collector scripts:")
    for i, info in ipairs(found) do
        print("\n" .. i .. ". " .. info.path)
        print("   Has Destroy: " .. tostring(info.hasDestroy))
        print("   Has Debounce: " .. tostring(info.hasDebounce))
        
        if not info.hasDebounce then
            print("   ⚠️  Missing debounce - this could cause issues!")
        end
    end
end

print("\n=== COLLECTOR FIX ===")
print("The main issue with orbs being flung is usually caused by:")
print("1. The collector part having CanCollide = true")
print("2. Not anchoring orbs before destroying them")
print("3. Missing debounce causing multiple touch events")
print("\nHere's a fixed collector script you can use:")
print("----------------------------------------")
print(createFixedCollector())
print("----------------------------------------")

-- Also create a script that will patch existing collectors
print("\n=== AUTO-FIX EXISTING COLLECTORS ===")
print("Run this code to automatically fix all collector parts:")
print([[
for _, part in pairs(workspace:GetDescendants()) do
    if part.Name == "Collector" or part.Name == "PartCollector" then
        part.CanCollide = false
        print("Fixed collector: " .. part:GetFullName())
    end
end
]])