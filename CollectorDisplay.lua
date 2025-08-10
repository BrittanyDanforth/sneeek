-- Modern Collector Display Script
-- This script updates the text display to show the current currency to collect

-- Services
local RunService = game:GetService("RunService")

-- Wait for all necessary components
local textLabel = script.Parent
if not textLabel:IsA("TextLabel") and not textLabel:IsA("TextButton") then
    warn("CollectorDisplay: Script parent must be a TextLabel or TextButton")
    return
end

-- Navigate up the hierarchy more safely
local function findCurrencyToCollect()
    local current = script.Parent
    local maxLevels = 10 -- Prevent infinite loops
    local level = 0
    
    -- Go up the hierarchy looking for CurrencyToCollect
    while current and level < maxLevels do
        local currencyValue = current:FindFirstChild("CurrencyToCollect")
        if currencyValue and currencyValue:IsA("IntValue") then
            return currencyValue
        end
        current = current.Parent
        level = level + 1
    end
    
    -- If not found by traversing up, search in common tycoon locations
    local tycoonModel = script:FindFirstAncestorOfClass("Model")
    if tycoonModel then
        local currencyValue = tycoonModel:FindFirstChild("CurrencyToCollect", true)
        if currencyValue and currencyValue:IsA("IntValue") then
            return currencyValue
        end
    end
    
    return nil
end

-- Currency formatting functions (matching the leaderboard system)
local function convertShort(value)
    value = tonumber(value) or 0
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

local function convertComma(value)
    local formatted = tostring(value)
    while true do
        local newFormatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
        formatted = newFormatted
    end
    return formatted
end

-- Configuration
local USE_SHORT_FORMAT = true -- Set to false for comma format (1,000,000)
local CURRENCY_SYMBOL = "$"
local UPDATE_THROTTLE = 0.1 -- Minimum time between updates (in seconds)

-- Find the CurrencyToCollect value
local currencyToCollect = findCurrencyToCollect()

if not currencyToCollect then
    warn("CollectorDisplay: Could not find CurrencyToCollect IntValue!")
    textLabel.Text = CURRENCY_SYMBOL .. "0"
    return
end

print("CollectorDisplay: Found CurrencyToCollect at", currencyToCollect:GetFullName())

-- Update function
local lastUpdate = 0
local function updateDisplay(value)
    local now = tick()
    if now - lastUpdate < UPDATE_THROTTLE then
        return -- Throttle updates
    end
    lastUpdate = now
    
    local formattedValue
    if USE_SHORT_FORMAT then
        formattedValue = convertShort(value)
    else
        formattedValue = convertComma(value)
    end
    
    textLabel.Text = CURRENCY_SYMBOL .. formattedValue
end

-- Set initial value
updateDisplay(currencyToCollect.Value)

-- Connect to changes using modern syntax
local connection = currencyToCollect.Changed:Connect(function(newValue)
    updateDisplay(newValue)
end)

-- Clean up connection if script is destroyed
script.AncestryChanged:Connect(function()
    if not script.Parent then
        connection:Disconnect()
    end
end)

-- Optional: Smooth counting animation
local ENABLE_SMOOTH_COUNT = false -- Set to true for smooth counting
if ENABLE_SMOOTH_COUNT then
    local displayValue = currencyToCollect.Value
    local targetValue = currencyToCollect.Value
    
    currencyToCollect.Changed:Connect(function(newValue)
        targetValue = newValue
    end)
    
    RunService.Heartbeat:Connect(function(deltaTime)
        if displayValue ~= targetValue then
            local diff = targetValue - displayValue
            local step = diff * math.min(deltaTime * 5, 1) -- Smooth interpolation
            
            if math.abs(step) < 1 then
                displayValue = targetValue
            else
                displayValue = displayValue + step
            end
            
            updateDisplay(math.floor(displayValue))
        end
    end)
end