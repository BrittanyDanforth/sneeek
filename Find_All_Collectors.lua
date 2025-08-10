-- FIND ALL COLLECTOR PARTS SCRIPT
print("=====================================")
print("🔍 SEARCHING FOR ALL COLLECTORS 🔍")
print("=====================================")

local collectorsFound = 0

-- Search function
local function searchForCollectors(parent, path)
    for _, obj in pairs(parent:GetChildren()) do
        -- Check if this is a collector part
        if obj.Name == "CollectorParts" or obj.Name:lower():find("collector") then
            collectorsFound = collectorsFound + 1
            print("")
            print("FOUND COLLECTOR #" .. collectorsFound .. ":")
            print("  Name:", obj.Name)
            print("  Type:", obj.ClassName)
            print("  Path:", obj:GetFullName())
            
            -- Check for CurrencyToCollect nearby
            local tycoon = obj.Parent
            while tycoon and not tycoon:FindFirstChild("CurrencyToCollect") do
                tycoon = tycoon.Parent
                if tycoon == game then
                    tycoon = nil
                    break
                end
            end
            
            if tycoon and tycoon:FindFirstChild("CurrencyToCollect") then
                print("  ✓ Found CurrencyToCollect at:", tycoon.Name)
                print("    Current value:", tycoon.CurrencyToCollect.Value)
            else
                print("  ✗ No CurrencyToCollect found in parent hierarchy")
            end
            
            -- Check for scripts inside
            local scripts = {}
            for _, child in pairs(obj:GetDescendants()) do
                if child:IsA("Script") then
                    table.insert(scripts, child:GetFullName())
                end
            end
            
            if #scripts > 0 then
                print("  Scripts found inside:")
                for _, scriptPath in pairs(scripts) do
                    print("    -", scriptPath)
                end
            end
        end
        
        -- Continue searching in children
        searchForCollectors(obj, path .. "." .. obj.Name)
    end
end

-- Start the search
print("Starting search in Workspace...")
searchForCollectors(workspace, "Workspace")

print("")
print("=====================================")
print("SEARCH COMPLETE!")
print("Total collectors found:", collectorsFound)
print("=====================================")