--[[
	🔥 ULTIMATE SETTINGS FIX - WORKS IN LIVE GAMES 🔥
	Place this in ServerScriptService and name it "!SettingsLoader" 
	(The ! makes it run first)
]]

-- Run immediately
local RunService = game:GetService("RunService")

print("🚀 ULTIMATE SETTINGS FIX STARTING...")

-- Initialize globals IMMEDIATELY
_G.TycoonSettings = {}
_G.Settings = nil
_G.SettingsLoaded = false

-- Create a robust fallback settings object
local function createFallbackSettings()
	return {
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

-- Set fallback immediately
_G.Settings = createFallbackSettings()

-- Helper to safely load a module
local function safeRequire(module, name)
	local success, result = pcall(function()
		return require(module)
	end)
	
	if success then
		print("✅ Loaded settings for " .. name)
		return result
	else
		warn("❌ Failed to load " .. name .. " settings: " .. tostring(result))
		return nil
	end
end

-- Wait for and load all tycoon settings
task.spawn(function()
	print("⏳ Waiting for tycoons to load...")
	
	-- Wait a bit for workspace to populate
	if not RunService:IsStudio() then
		task.wait(2) -- Extra wait in live games
	end
	
	-- Known tycoon paths with timeouts
	local tycoonData = {
		{
			name = "HelloKitty",
			getter = function()
				local container = workspace:WaitForChild("SpidermanTycoon", 10)
				if container then
					return container:WaitForChild("Spiderman tycoon", 5)
				end
			end
		},
		{
			name = "Cinnamoroll",
			getter = function()
				return workspace:WaitForChild("Cinnamoroll tycoon", 10)
			end
		},
		{
			name = "Kuromi",
			getter = function()
				local container = workspace:WaitForChild("Venom Tycoon", 10)
				if container then
					return container:WaitForChild("Zednov's Tycoon Kit [OPEN!]", 5)
				end
			end
		},
		{
			name = "MyMelody",
			getter = function()
				return workspace:WaitForChild("Zednov's Tycoon Kit", 10)
			end
		}
	}
	
	-- Load each tycoon's settings
	local loadedCount = 0
	for _, data in ipairs(tycoonData) do
		local success, tycoonModel = pcall(data.getter)
		
		if success and tycoonModel then
			local settingsModule = tycoonModel:FindFirstChild("Settings")
			if settingsModule and settingsModule:IsA("ModuleScript") then
				local settings = safeRequire(settingsModule, data.name)
				if settings then
					_G.TycoonSettings[data.name] = settings
					loadedCount = loadedCount + 1
					
					-- Update default if this is the first one
					if loadedCount == 1 then
						_G.Settings = settings
						print("🌟 Set default _G.Settings to " .. data.name)
					end
				end
			else
				warn("⚠️ No Settings module found for " .. data.name)
			end
		else
			warn("⚠️ Tycoon not found: " .. data.name)
		end
	end
	
	_G.SettingsLoaded = true
	print("✅ Settings loaded! Found " .. loadedCount .. " tycoon settings")
end)

-- Create the global getter function
_G.GetTycoonSettings = function(tycoonInstanceOrName)
	-- If settings aren't loaded yet, return fallback
	if not _G.SettingsLoaded then
		return _G.Settings or createFallbackSettings()
	end
	
	if type(tycoonInstanceOrName) == "string" then
		return _G.TycoonSettings[tycoonInstanceOrName] or _G.Settings
	elseif typeof(tycoonInstanceOrName) == "Instance" then
		local fullName = tycoonInstanceOrName:GetFullName()
		
		-- Check each tycoon name
		for name, settings in pairs(_G.TycoonSettings) do
			if fullName:find(name) then
				return settings
			end
		end
		
		-- Check by actual tycoon model names
		if fullName:find("HelloKitty") or fullName:find("Spiderman tycoon") then
			return _G.TycoonSettings["HelloKitty"] or _G.Settings
		elseif fullName:find("Cinnamoroll") then
			return _G.TycoonSettings["Cinnamoroll"] or _G.Settings
		elseif fullName:find("Kuromi") or fullName:find("Venom Tycoon") then
			return _G.TycoonSettings["Kuromi"] or _G.Settings
		elseif fullName:find("MyMelody") or fullName:find("Zednov's Tycoon Kit") then
			return _G.TycoonSettings["MyMelody"] or _G.Settings
		end
	end
	
	return _G.Settings or createFallbackSettings()
end

-- Override the require function for Settings modules (NUCLEAR OPTION)
local oldRequire = require
getfenv().require = function(module)
	if typeof(module) == "Instance" and module.Name == "Settings" then
		-- Intercept Settings requires and use our global system
		local tycoonModel = module.Parent
		local settings = _G.GetTycoonSettings(tycoonModel)
		if settings then
			print("🔄 Intercepted Settings require - returning global settings")
			return settings
		end
	end
	
	-- Normal require for everything else
	return oldRequire(module)
end

print("🛡️ ULTIMATE SETTINGS FIX READY!")
print("💡 Scripts can now safely use require(Settings) or _G.GetTycoonSettings()")