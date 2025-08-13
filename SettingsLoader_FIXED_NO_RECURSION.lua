--[[
	FIXED SETTINGS LOADER - NO RECURSIVE REQUIRES
	Place this in ServerScriptService instead of the current one
	This will NOT try to require the Settings module in ServerScriptService
]]

print("="..string.rep("=", 50))
print("🔧 FIXED SETTINGS LOADER - NO RECURSION")
print("="..string.rep("=", 50))

-- Initialize globals
_G.TycoonSettings = {}
_G.Settings = nil

-- Helper to safely require a module
local function safeRequire(module, tycoonName)
	local success, result = pcall(function()
		return require(module)
	end)
	
	if success then
		print(string.format("✅ Loaded settings for %s", tycoonName))
		return result
	else
		print(string.format("❌ Failed to load %s settings: %s", tycoonName, tostring(result)))
		return nil
	end
end

-- Find tycoons with proper structure
local function findTycoonSettings()
	local settings = {}
	
	print("\n🔍 Searching for tycoon Settings modules...")
	
	-- Look for the 4 known tycoon locations
	local tycoonPaths = {
		{name = "HelloKitty", path = workspace:FindFirstChild("SpidermanTycoon") and workspace.SpidermanTycoon:FindFirstChild("Spiderman tycoon")},
		{name = "Cinnamoroll", path = workspace:FindFirstChild("Cinnamoroll tycoon")},
		{name = "Kuromi", path = workspace:FindFirstChild("Venom Tycoon") and workspace["Venom Tycoon"]:FindFirstChild("Zednov's Tycoon Kit [OPEN!]")},
		{name = "MyMelody", path = workspace:FindFirstChild("Zednov's Tycoon Kit")}
	}
	
	for _, tycoonInfo in ipairs(tycoonPaths) do
		if tycoonInfo.path then
			local settingsModule = tycoonInfo.path:FindFirstChild("Settings")
			if settingsModule and settingsModule:IsA("ModuleScript") then
				print(string.format("  ✅ Found %s settings at: %s", tycoonInfo.name, settingsModule:GetFullName()))
				table.insert(settings, {
					name = tycoonInfo.name,
					module = settingsModule
				})
			else
				print(string.format("  ❌ No Settings module found for %s", tycoonInfo.name))
			end
		else
			print(string.format("  ❌ Tycoon container not found for %s", tycoonInfo.name))
		end
	end
	
	return settings
end

-- Main execution
local tycoonSettings = findTycoonSettings()
print(string.format("\n📊 Found %d tycoon Settings modules", #tycoonSettings))

-- Load settings for each tycoon
for _, settingInfo in ipairs(tycoonSettings) do
	local settings = safeRequire(settingInfo.module, settingInfo.name)
	if settings then
		_G.TycoonSettings[settingInfo.name] = settings
		
		-- Set first one as default
		if not _G.Settings then
			_G.Settings = settings
			print(string.format("🌟 Set %s settings as default _G.Settings", settingInfo.name))
		end
	end
end

-- Create a default/fallback Settings if none were loaded
if not _G.Settings then
	print("\n⚠️ No tycoon settings loaded, creating fallback...")
	_G.Settings = {
		Sounds = {
			Purchase = 203785492,
			Collect = 131886985,
			ErrorBuy = 138090596
		},
		CurrencyName = "Cash",
		AutoAssignTeams = false,
		ButtonsFadeOut = true,
		FadeOutTime = 0.5,
		ButtonsFadeIn = true,
		FadeInTime = 0.5,
		LeaderboardSettings = {
			KOs = true,
			KillsName = "Kills",
			WOs = true,
			DeathsName = "Deaths",
			ShowCurrency = true,
			ShowShortCurrency = true
		},
		StealSettings = {
			Stealing = true,
			StealPrecent = 0.07,
			PlayerProtection = 60
		},
		ConvertComma = function(self, num)
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
		end,
		ConvertShort = function(self, num)
			local x = tostring(num)
			if #x >= 10 then
				local important = (#x - 9)
				return x:sub(0, important) .. "." .. (x:sub(#x - 7, #x - 7)) .. "B+"
			elseif #x >= 7 then
				local important = (#x - 6)
				return x:sub(0, important) .. "." .. (x:sub(#x - 5, #x - 5)) .. "M+"
			elseif #x >= 4 then
				local important = (#x - 3)
				return x:sub(0, important) .. "." .. (x:sub(#x - 2, #x - 2)) .. "K+"
			else
				return num
			end
		end
	}
end

-- Helper function
_G.GetTycoonSettings = function(tycoonNameOrInstance)
	if type(tycoonNameOrInstance) == "string" then
		return _G.TycoonSettings[tycoonNameOrInstance] or _G.Settings
	elseif typeof(tycoonNameOrInstance) == "Instance" then
		-- Find which tycoon this belongs to
		for name, _ in pairs(_G.TycoonSettings) do
			if tycoonNameOrInstance:GetFullName():find(name) then
				return _G.TycoonSettings[name]
			end
		end
	end
	return _G.Settings
end

print("\n✅ Fixed Settings Loader Complete!")
print("📋 Loaded settings for:")
for name, _ in pairs(_G.TycoonSettings) do
	print("   - " .. name)
end
print("\n💡 NO RECURSIVE REQUIRES - This loader doesn't touch ServerScriptService.Settings!")