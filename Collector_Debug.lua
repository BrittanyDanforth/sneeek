-- COLLECTOR DEBUG SCRIPT
print("=====================================")
print("💰 COLLECTOR SCRIPT INITIALIZING 💰")
print("=====================================")

-- Print current location
print("Script Name:", script.Name)
print("Script Path:", script:GetFullName())
print("")

-- Trace the parent hierarchy
print("PARENT HIERARCHY:")
local current = script
local depth = 0
while current and depth < 10 do
    print(string.rep("  ", depth) .. "└─ " .. current.Name .. " (" .. current.ClassName .. ")")
    current = current.Parent
    depth = depth + 1
end
print("")

-- Now let's trace to find CurrencyToCollect
print("SEARCHING FOR CurrencyToCollect...")
local targetParent = script.Parent.Parent.Parent.Parent.Parent.Parent

if targetParent then
    print("Target parent found:", targetParent.Name, "at", targetParent:GetFullName())
    
    -- Look for CurrencyToCollect
    local currencyValue = targetParent:FindFirstChild("CurrencyToCollect")
    if currencyValue then
        print("✓ Found CurrencyToCollect! Current value:", currencyValue.Value)
        print("  Location:", currencyValue:GetFullName())
    else
        print("✗ CurrencyToCollect NOT FOUND in", targetParent.Name)
        print("  Children of", targetParent.Name, ":")
        for _, child in pairs(targetParent:GetChildren()) do
            print("    -", child.Name, "(" .. child.ClassName .. ")")
        end
    end
else
    print("✗ Could not find target parent (6 levels up)")
end
print("")

-- Check if script.Parent is a TextLabel/TextButton
print("CHECKING TEXT ELEMENT:")
if script.Parent:IsA("TextLabel") or script.Parent:IsA("TextButton") or script.Parent:IsA("TextBox") then
    print("✓ Parent is a text element:", script.Parent.ClassName)
    print("  Current text:", script.Parent.Text)
else
    print("✗ Parent is NOT a text element! It's a:", script.Parent.ClassName)
end
print("")

-- Try to set up the collector with error handling
print("SETTING UP COLLECTOR...")
local success, err = pcall(function()
    -- Set initial value
    script.Parent.Text = "$"..script.Parent.Parent.Parent.Parent.Parent.Parent.CurrencyToCollect.Value
    print("✓ Initial text set successfully")
    
    -- Connect to changes
    local connection = script.Parent.Parent.Parent.Parent.Parent.Parent.CurrencyToCollect.Changed:Connect(function(money)
        print("💰 Currency changed to:", money)
        script.Parent.Text = "$"..money
    end)
    print("✓ Change listener connected")
end)

if not success then
    print("✗ ERROR setting up collector:", err)
    print("")
    print("DEBUGGING TIPS:")
    print("1. Check if CurrencyToCollect exists")
    print("2. Verify the parent chain is correct")
    print("3. Make sure script.Parent is a TextLabel/TextButton")
end

print("=====================================")
print("💰 COLLECTOR DEBUG COMPLETE 💰")
print("=====================================")