-- Simple Modern Collector Display Script
-- Direct replacement for the original script

-- Get the CurrencyToCollect value by going up the hierarchy
local currencyToCollect = script.Parent.Parent.Parent.Parent.Parent.Parent:FindFirstChild("CurrencyToCollect")

if not currencyToCollect then
    warn("Could not find CurrencyToCollect!")
    return
end

-- Simple number formatting (adds commas)
local function formatNumber(amount)
    local formatted = tostring(amount)
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- Update the display
local function updateDisplay(value)
    script.Parent.Text = "$" .. formatNumber(value)
end

-- Show initial value
updateDisplay(currencyToCollect.Value)

-- Update when value changes (using modern Connect syntax)
currencyToCollect.Changed:Connect(function(newValue)
    updateDisplay(newValue)
end)