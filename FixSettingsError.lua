--[[
	SETTINGS ERROR FIX SCRIPT
	
	Put this in ServerScriptService and run it to diagnose the Settings module error
]]

local function findAllScripts(parent, scriptList)
	scriptList = scriptList or {}
	
	for _, child in ipairs(parent:GetDescendants()) do
		if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript") then
			table.insert(scriptList, child)
		end
	end
	
	return scriptList
end

-- Wait for workspace to load
wait(3)

print("\n=== SEARCHING FOR SETTINGS MODULE ISSUES ===\n")

-- Find all Settings modules
local allSettings = {}
for _, obj in ipairs(workspace:GetDescendants()) do
	if obj.Name == "Settings" and obj:IsA("ModuleScript") then
		table.insert(allSettings, obj)
		print("Found Settings module at:", obj:GetFullName())
	end
end

print("\nFound", #allSettings, "Settings modules\n")

-- Find all scripts that might require Settings
local scriptsWithRequire = {}
local allScripts = findAllScripts(workspace)

for _, script in ipairs(allScripts) do
	if script.Source and script.Source:find("require") and script.Source:find("Settings") then
		table.insert(scriptsWithRequire, script)
		print("Script requiring Settings:", script:GetFullName())
	end
end

print("\n=== QUICK FIX INSTRUCTIONS ===")
print("The error happens because scripts are trying to require Settings incorrectly.")
print("\nHere's how to fix it:")

print("\n1. Find your tycoon's Settings module")
print("2. Make sure it doesn't require ANY other modules")
print("3. In scripts that need Settings, use this safe loading code:")

print("\n--- COPY THIS CODE ---")
print([[
-- Safe Settings loader
local Settings
local success, result = pcall(function()
    -- Try to find Settings module
    local settingsModule = script.Parent.Parent:FindFirstChild("Settings") 
        or script.Parent.Parent.Parent:FindFirstChild("Settings")
        or workspace:FindFirstChild("Settings", true)
    
    if settingsModule then
        return require(settingsModule)
    else
        error("Settings module not found")
    end
end)

if success then
    Settings = result
    print("✅ Settings loaded successfully")
else
    warn("⚠️ Failed to load Settings:", result)
    -- Use default settings
    Settings = {
        Sounds = {
            Purchase = 203785492,
            Collect = 131886985,
            ErrorBuy = 138090596
        },
        CurrencyName = "Cash",
        ButtonsFadeIn = true,
        FadeInTime = 0.5,
        ButtonsFadeOut = true,
        FadeOutTime = 0.5
    }
end
]])

print("\n--- END OF CODE ---")

print("\n=== ALTERNATIVE SOLUTION ===")
print("If the error persists, put this CLEAN Settings module in your tycoon:")
print("(This one has NO requires, so it can't cause circular dependencies)")

print("\n--- CLEAN SETTINGS MODULE ---")
print([[
local module = {}

-- Sound Settings
module.Sounds = {
    Purchase = 203785492,
    Collect = 131886985,
    ErrorBuy = 138090596
}

-- Currency Settings  
module.CurrencyName = "Cash"

-- Button Animation Settings
module.ButtonsFadeOut = true
module.FadeOutTime = 0.5
module.ButtonsFadeIn = true
module.FadeInTime = 0.5

-- Leaderboard Settings
module.LeaderboardSettings = {
    KOs = true,
    KillsName = "Kills",
    WOs = true,
    DeathsName = "Deaths",
    ShowCurrency = true,
    ShowShortCurrency = true
}

-- Utility Functions
function module:ConvertComma(num)
    local x = tostring(num)
    if #x >= 10 then
        local important = (#x - 9)
        return x:sub(0, important) .. "," .. x:sub(important + 1, important + 3) .. "," .. x:sub(important + 4, important + 6) .. "," .. x:sub(important + 7)
    elseif #x >= 7 then
        local important = (#x - 6)
        return x:sub(0, important) .. "," .. x:sub(important + 1, important + 3) .. "," .. x:sub(important + 4)
    elseif #x >= 4 then
        return x:sub(0, (#x - 3)) .. "," .. x:sub((#x - 3) + 1)
    else
        return num
    end
end

function module:ConvertShort(Filter_Num)
    local x = tostring(Filter_Num)
    if #x >= 10 then
        local important = (#x - 9)
        return x:sub(0, important) .. "." .. (x:sub(#x - 7, #x - 7)) .. "B+"
    elseif #x >= 7 then
        local important = (#x - 6)
        return x:sub(0, important) .. "." .. (x:sub(#x - 5, #x - 5)) .. "M+"
    elseif #x >= 4 then
        return x:sub(0, (#x - 3)) .. "." .. (x:sub(#x - 2, #x - 2)) .. "K+"
    else
        return Filter_Num
    end
end

return module
]])

print("\n--- END OF MODULE ---")

print("\n✅ Diagnostic complete! Follow the instructions above to fix your Settings error.")