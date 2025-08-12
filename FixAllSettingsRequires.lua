--[[
	FIX ALL SETTINGS REQUIRES
	This fixes ALL scripts in tycoons that try to require Settings
	Place in ServerScriptService and run ONCE
]]

print("🔧 FIXING ALL SETTINGS REQUIRES IN TYCOONS...")

local fixedCount = 0

-- Function to patch a script's source
local function patchScriptSource(script)
	local source = script.Source
	
	-- Check if it has a Settings require
	if not source:find("require") or not source:find("Settings") then
		return false
	end
	
	print(string.format("   📝 Patching %s", script:GetFullName()))
	
	-- Find the Settings require line
	local patterns = {
		"local Settings = require%(script%.Parent%.Settings%)",
		"local Settings = require%(script%.Parent%.Parent%.Settings%)",  
		"local Settings = require%(script%.Parent%.Parent%.Parent%.Settings%)",
		"local Settings = require%(script%.Parent%.Parent%.Parent%.Parent%.Settings%)",
		"Settings = require%(script%.Parent%.Settings%)",
		"Settings = require%(script%.Parent%.Parent%.Settings%)",
		"local settings = require%(script%.Parent%.Settings%)",
		"local settings = require%(script%.Parent%.Parent%.Settings%)"
	}
	
	local newRequireCode = [[
-- FIXED SETTINGS LOADING
local Settings
local attempts = 0
while not Settings and attempts < 30 do
	if _G.GetTycoonSettings then
		Settings = _G.GetTycoonSettings(script.Parent)
		if Settings then break end
	end
	
	-- Try to find Settings module
	local current = script.Parent
	for i = 1, 5 do
		local settingsModule = current:FindFirstChild("Settings")
		if settingsModule and settingsModule:IsA("ModuleScript") then
			local success, result = pcall(require, settingsModule)
			if success then
				Settings = result
				break
			end
		end
		current = current.Parent
		if not current then break end
	end
	
	attempts = attempts + 1
	task.wait(0.1)
end

if not Settings then
	warn(script.Name .. ": Using fallback settings")
	Settings = {
		Sounds = {Purchase = 203785492, Collect = 131886985, ErrorBuy = 138090596},
		CurrencyName = "Cash",
		AutoAssignTeams = false,
		ButtonsFadeOut = true,
		FadeOutTime = 0.5,
		ButtonsFadeIn = true,
		FadeInTime = 0.5,
		LeaderboardSettings = {ShowCurrency = true},
		StealSettings = {Stealing = true, StealPrecent = 0.07, PlayerProtection = 60},
		ConvertComma = function(self, num) return tostring(num) end,
		ConvertShort = function(self, num) return tostring(num) end
	}
end]]
	
	-- Replace the require line
	local patched = false
	for _, pattern in ipairs(patterns) do
		if source:find(pattern) then
			source = source:gsub(pattern, newRequireCode)
			patched = true
			break
		end
	end
	
	if patched then
		script.Source = source
		return true
	end
	
	return false
end

-- Search all tycoons
for _, container in ipairs(workspace:GetChildren()) do
	if container.Name:lower():find("tycoon") or container.Name:lower():find("kit") then
		print(string.format("\n📦 Checking container: %s", container.Name))
		
		-- Find all scripts in this container
		local scripts = {}
		for _, desc in ipairs(container:GetDescendants()) do
			if desc:IsA("Script") and not desc.Disabled then
				table.insert(scripts, desc)
			end
		end
		
		print(string.format("   Found %d active scripts", #scripts))
		
		-- Patch each script
		for _, script in ipairs(scripts) do
			if patchScriptSource(script) then
				fixedCount = fixedCount + 1
			end
		end
	end
end

print(string.format("\n✅ FIXED %d SCRIPTS!", fixedCount))
print("All scripts that require Settings should now work properly!")
print("Try touching the tycoon door again!")