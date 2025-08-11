-- Quick script to check button names and identify issues
-- Run this in command bar or as a script to see all button names

local function checkButtons()
    print("\n=== CHECKING ALL BUTTONS ===")
    
    -- Find all tycoons
    for _, tycoon in pairs(workspace:GetDescendants()) do
        if tycoon.Name == "Cinnamoroll" or (tycoon:FindFirstChild("Buttons") and tycoon:FindFirstChild("Owner")) then
            print("\nTycoon found: " .. tycoon.Name)
            
            local buttons = tycoon:FindFirstChild("Buttons")
            if buttons then
                local buttonList = {}
                
                for _, button in pairs(buttons:GetChildren()) do
                    table.insert(buttonList, button.Name)
                end
                
                -- Sort for easier reading
                table.sort(buttonList, function(a, b)
                    local numA = tonumber(a:match("%d+")) or 999
                    local numB = tonumber(b:match("%d+")) or 999
                    return numA < numB
                end)
                
                print("Buttons found:")
                for i, name in ipairs(buttonList) do
                    local num = name:match("%d+")
                    if num then
                        print("  " .. name .. " (Number: " .. num .. ")")
                    else
                        print("  " .. name .. " ⚠️ NO NUMBER FOUND")
                    end
                end
                
                print("\nTotal buttons: " .. #buttonList)
                
                -- Check for buttons that might be problematic
                local issues = {}
                for _, button in pairs(buttons:GetChildren()) do
                    local head = button:FindFirstChild("Head")
                    if not head then
                        table.insert(issues, button.Name .. " - Missing Head part")
                    end
                    
                    local num = button.Name:match("%d+")
                    if not num then
                        table.insert(issues, button.Name .. " - No number in name")
                    end
                end
                
                if #issues > 0 then
                    print("\n⚠️ ISSUES FOUND:")
                    for _, issue in ipairs(issues) do
                        print("  " .. issue)
                    end
                end
            end
        end
    end
    
    print("\n=========================")
end

checkButtons()