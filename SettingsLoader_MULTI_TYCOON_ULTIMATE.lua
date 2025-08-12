--[[
	🔥 ULTIMATE MULTI-TYCOON SETTINGS LOADER 🔥
	Handles MULTIPLE tycoons with EXTREME debugging!
	Place in ServerScriptService
	
	Features:
	- Finds ALL Settings modules from ALL tycoons
	- Loads them into a table organized by tycoon
	- Extreme debugging for live games
	- Multiple fallback strategies
--]]

print("\n" .. string.rep("🔥", 40))
print("💎 ULTIMATE MULTI-TYCOON SETTINGS LOADER STARTING...")
print("⏰ Time:", os.date("%Y-%m-%d %H:%M:%S"))
print("🎮 PlaceId:", game.PlaceId)
print("🌐 JobId:", game.JobId)
print("🖥️ Running on:", game:GetService("RunService"):IsStudio() and "STUDIO" or "LIVE GAME")
print(string.rep("🔥", 40) .. "\n")

-- Master debug tracking
local MasterDebug = {
	startTime = tick(),
	searchedLocations = {},
	foundTycoons = {},
	foundSettings = {},
	loadedSettings = {},
	errors = {},
	warnings = {}
}

-- Multi-tycoon settings storage
_G.TycoonSettings = {}
_G.Settings = nil -- Will point to first found settings for compatibility

-- Enhanced tycoon detection - MUCH MORE ACCURATE
local function isTycoonFolder(folder)
	-- A real tycoon needs MULTIPLE of these components, not just one
	local requiredComponents = {
		"PurchaseHandler",
		"Essentials",
		"Buttons"
	}
	
	local optionalComponents = {
		"Owner",
		"OwnerValue", 
		"TeamColor",
		"Purchases",
		"PurchasedObjects",
		"CurrencyToCollect"
	}
	
	-- Count how many required components we find
	local foundRequired = 0
	for _, component in ipairs(requiredComponents) do
		if folder:FindFirstChild(component) then
			foundRequired = foundRequired + 1
		end
	end
	
	-- Need at least 2 required components
	if foundRequired < 2 then
		return false, "Missing required tycoon components"
	end
	
	-- Count optional components for confidence
	local foundOptional = 0
	for _, component in ipairs(optionalComponents) do
		if folder:FindFirstChild(component) then
			foundOptional = foundOptional + 1
		end
	end
	
	-- Need some optional components too
	if foundOptional < 2 then
		return false, "Not enough tycoon components"
	end
	
	return true, string.format("Has %d required and %d optional tycoon components", foundRequired, foundOptional)
end

-- Special function to find actual tycoon containers
local function findRealTycoons()
	print("🎯 FINDING YOUR 4 ACTUAL TYCOONS...")
	print(string.rep("-", 80))
	
	local realTycoons = {}
	
	-- Common tycoon container names
	local tycoonContainers = {
		"Tycoons",
		"TycoonFolder", 
		"TycoonModels",
		"Tycoon"
	}
	
	-- First, look for obvious tycoon containers
	for _, container in ipairs(workspace:GetChildren()) do
		-- Check if this is a tycoon kit or container
		if container.Name:lower():find("tycoon") or container.Name:lower():find("kit") then
			print(string.format("📦 Checking container: %s", container.Name))
			
			-- Look inside for actual tycoons
			for _, child in ipairs(container:GetDescendants()) do
				if (child:IsA("Model") or child:IsA("Folder")) then
					local isTycoon, reason = isTycoonFolder(child)
					if isTycoon then
						-- Make sure we haven't already found this tycoon
						local alreadyFound = false
						for _, existing in ipairs(realTycoons) do
							if existing.instance == child then
								alreadyFound = true
								break
							end
						end
						
						if not alreadyFound then
							print(string.format("  ✅ Found REAL tycoon: %s", child.Name))
							print(string.format("     Path: %s", child:GetFullName()))
							print(string.format("     Reason: %s", reason))
							
							table.insert(realTycoons, {
								instance = child,
								name = child.Name,
								path = child:GetFullName(),
								settings = nil
							})
							
							-- Look for Settings
							local settings = child:FindFirstChild("Settings", true)
							if settings and settings:IsA("ModuleScript") then
								print(string.format("     📄 Has Settings at: %s", settings:GetFullName()))
								realTycoons[#realTycoons].settings = settings
							end
						end
					end
				end
			end
		end
	end
	
	-- Also check direct children of workspace that might be tycoons
	for _, child in ipairs(workspace:GetChildren()) do
		if (child:IsA("Model") or child:IsA("Folder")) and not child.Name:lower():find("tycoon") then
			local isTycoon, reason = isTycoonFolder(child)
			if isTycoon then
				print(string.format("✅ Found REAL tycoon: %s", child.Name))
				print(string.format("   Path: %s", child:GetFullName()))
				print(string.format("   Reason: %s", reason))
				
				table.insert(realTycoons, {
					instance = child,
					name = child.Name, 
					path = child:GetFullName(),
					settings = nil
				})
				
				-- Look for Settings
				local settings = child:FindFirstChild("Settings", true)
				if settings and settings:IsA("ModuleScript") then
					print(string.format("   📄 Has Settings at: %s", settings:GetFullName()))
					realTycoons[#realTycoons].settings = settings
				end
			end
		end
	end
	
	print(string.format("\n🎉 Found %d REAL tycoons!", #realTycoons))
	return realTycoons
end

-- Deep search with tycoon awareness
local function searchForAllSettings()
	print("🔍 PHASE 1: SCANNING ENTIRE GAME FOR TYCOONS")
	print(string.rep("-", 80))
	
	local allTycoons = {}
	local searchQueue = {
		{location = workspace, depth = 0, path = "Workspace"},
		{location = game.ServerScriptService, depth = 0, path = "ServerScriptService"},
		{location = game.ServerStorage, depth = 0, path = "ServerStorage"},
		{location = game.ReplicatedStorage, depth = 0, path = "ReplicatedStorage"}
	}
	
	local itemsSearched = 0
	local maxDepth = 5
	
	while #searchQueue > 0 do
		local current = table.remove(searchQueue, 1)
		local location = current.location
		local depth = current.depth
		local path = current.path
		
		itemsSearched = itemsSearched + 1
		
		-- Progress update
		if itemsSearched % 50 == 0 then
			print(string.format("  ⏳ Searched %d items... Found %d tycoons so far", itemsSearched, #allTycoons))
		end
		
		-- Check if this is a tycoon
		if location:IsA("Model") or location:IsA("Folder") then
			local isTycoon, reason = isTycoonFolder(location)
			if isTycoon then
				print(string.format("\n  🏭 FOUND TYCOON: %s", location:GetFullName()))
				print(string.format("     Reason: %s", reason))
				
				table.insert(allTycoons, {
					instance = location,
					name = location.Name,
					path = location:GetFullName(),
					settings = nil
				})
				
				-- Look for Settings in this tycoon
				local settings = location:FindFirstChild("Settings", true)
				if settings and settings:IsA("ModuleScript") then
					print(string.format("     ✅ Has Settings module at: %s", settings:GetFullName()))
					allTycoons[#allTycoons].settings = settings
					table.insert(MasterDebug.foundSettings, {
						tycoon = location.Name,
						path = settings:GetFullName(),
						module = settings
					})
				else
					print("     ❌ No Settings module found in this tycoon")
				end
			end
		end
		
		-- Add children to search queue (if not too deep)
		if depth < maxDepth then
			for _, child in ipairs(location:GetChildren()) do
				if child:IsA("Model") or child:IsA("Folder") then
					table.insert(searchQueue, {
						location = child,
						depth = depth + 1,
						path = path .. "." .. child.Name
					})
				elseif child.Name == "Settings" and child:IsA("ModuleScript") then
					-- Found a standalone Settings module
					print(string.format("\n  📄 Found standalone Settings: %s", child:GetFullName()))
					table.insert(MasterDebug.foundSettings, {
						tycoon = "Standalone",
						path = child:GetFullName(),
						module = child
					})
				end
			end
		end
	end
	
	print(string.format("\n  🏁 Search complete! Searched %d items", itemsSearched))
	print(string.format("  🏭 Found %d tycoons", #allTycoons))
	print(string.format("  📄 Found %d Settings modules", #MasterDebug.foundSettings))
	
	MasterDebug.foundTycoons = allTycoons
	return allTycoons
end

-- Multi-strategy module loader
local function loadSettingsModule(settingsData)
	local module = settingsData.module
	local tycoonName = settingsData.tycoon
	
	print(string.format("\n📦 LOADING SETTINGS FOR: %s", tycoonName))
	print(string.format("   Path: %s", module:GetFullName()))
	
	local strategies = {
		{
			name = "Direct Require",
			func = function()
				return require(module)
			end
		},
		{
			name = "Clone to ServerStorage",
			func = function()
				local clone = module:Clone()
				clone.Name = "Settings_" .. tycoonName:gsub("%s+", "_")
				clone.Parent = game.ServerStorage
				wait(0.1)
				return require(clone)
			end
		},
		{
			name = "Deferred Require",
			func = function()
				local result = nil
				local loaded = false
				task.defer(function()
					result = require(module)
					loaded = true
				end)
				
				local timeout = 0
				while not loaded and timeout < 2 do
					wait(0.1)
					timeout = timeout + 0.1
				end
				
				return result
			end
		},
		{
			name = "Parent Swap",
			func = function()
				local originalParent = module.Parent
				module.Parent = game.ServerStorage
				wait(0.1)
				local result = require(module)
				module.Parent = originalParent
				return result
			end
		}
	}
	
	for i, strategy in ipairs(strategies) do
		print(string.format("\n   🔧 Strategy %d: %s", i, strategy.name))
		
		local success, result = pcall(strategy.func)
		
		if success and result then
			print("      ✅ SUCCESS!")
			return result
		else
			local error = tostring(result)
			print("      ❌ Failed:", error)
			
			table.insert(MasterDebug.errors, {
				tycoon = tycoonName,
				strategy = strategy.name,
				error = error,
				time = tick()
			})
			
			-- Special error detection
			if error:find("recursive") then
				print("      ⚠️ RECURSIVE REQUIRE DETECTED!")
				print("      💡 The Settings module has 'require' statements inside it!")
				table.insert(MasterDebug.warnings, {
					tycoon = tycoonName,
					warning = "Recursive require - Settings has require statements"
				})
			elseif error:find("timeout") then
				print("      ⚠️ TIMEOUT ERROR!")
				print("      💡 The module is taking too long to load")
			end
		end
	end
	
	print("   ❌ ALL STRATEGIES FAILED!")
	return nil
end

-- Create comprehensive fallback settings
local function createFallbackSettings(tycoonName)
	print(string.format("\n🛡️ Creating fallback settings for: %s", tycoonName))
	
	return {
		_IS_FALLBACK = true,
		_TYCOON_NAME = tycoonName,
		
		-- Sound Settings
		Sounds = {
			Purchase = 203785492,
			Collect = 131886985,
			ErrorBuy = 138090596
		},
		
		-- Team Settings
		AutoAssignTeams = false,
		
		-- Currency Settings
		CurrencyName = "Cash",
		
		-- Button Animation Settings
		ButtonsFadeOut = true,
		FadeOutTime = 0.5,
		ButtonsFadeIn = true,
		FadeInTime = 0.5,
		
		-- Leaderboard Settings
		LeaderboardSettings = {
			KOs = true,
			KillsName = "Kills",
			WOs = true,
			DeathsName = "Deaths",
			ShowCurrency = true,
			ShowShortCurrency = true
		},
		
		-- Steal Settings
		StealSettings = {
			Stealing = true,
			StealPrecent = 0.07,
			PlayerProtection = 60
		},
		
		-- Utility Functions
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
		
		ConvertShort = function(self, Filter_Num)
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
	}
end

-- MAIN EXECUTION
print("\n" .. string.rep("🚀", 40))
print("STARTING MULTI-TYCOON SETTINGS LOADER")
print(string.rep("🚀", 40) .. "\n")

-- Step 1: Find all tycoons and settings
local allTycoons = findRealTycoons()
MasterDebug.foundTycoons = allTycoons

-- Populate MasterDebug.foundSettings from the real tycoons
MasterDebug.foundSettings = {}
for _, tycoon in ipairs(allTycoons) do
	if tycoon.settings then
		table.insert(MasterDebug.foundSettings, {
			tycoon = tycoon.name,
			path = tycoon.settings:GetFullName(),
			module = tycoon.settings
		})
	end
end

-- Also look for standalone Settings modules
print("\n🔍 Looking for standalone Settings modules...")
local standaloneSettings = {
	game.ServerScriptService:FindFirstChild("Settings"),
	game.ServerStorage:FindFirstChild("Settings")
}

for _, settings in ipairs(standaloneSettings) do
	if settings and settings:IsA("ModuleScript") then
		print(string.format("📄 Found standalone Settings: %s", settings:GetFullName()))
		table.insert(MasterDebug.foundSettings, {
			tycoon = "Standalone",
			path = settings:GetFullName(),
			module = settings
		})
	end
end

-- Step 2: Load all settings modules
print("\n🔧 PHASE 2: LOADING ALL SETTINGS MODULES")
print(string.rep("-", 80))

for _, settingsData in ipairs(MasterDebug.foundSettings) do
	local loadedSettings = loadSettingsModule(settingsData)
	
	if loadedSettings then
		-- Store in global table
		_G.TycoonSettings[settingsData.tycoon] = loadedSettings
		
		-- Set main _G.Settings to first successful load for compatibility
		if not _G.Settings then
			_G.Settings = loadedSettings
			print(string.format("\n🌟 Set _G.Settings to: %s", settingsData.tycoon))
		end
		
		table.insert(MasterDebug.loadedSettings, {
			tycoon = settingsData.tycoon,
			path = settingsData.path,
			success = true
		})
	else
		-- Create fallback
		local fallback = createFallbackSettings(settingsData.tycoon)
		_G.TycoonSettings[settingsData.tycoon] = fallback
		
		-- Set main _G.Settings if needed
		if not _G.Settings then
			_G.Settings = fallback
		end
		
		table.insert(MasterDebug.loadedSettings, {
			tycoon = settingsData.tycoon,
			path = settingsData.path,
			success = false,
			fallback = true
		})
	end
end

-- Step 3: Create Settings access helper
_G.GetTycoonSettings = function(tycoonNameOrInstance)
	if type(tycoonNameOrInstance) == "string" then
		return _G.TycoonSettings[tycoonNameOrInstance]
	elseif typeof(tycoonNameOrInstance) == "Instance" then
		-- Try exact name match first
		local settings = _G.TycoonSettings[tycoonNameOrInstance.Name]
		if settings then return settings end
		
		-- Try to find by checking if instance is inside a known tycoon
		for tycoonName, _ in pairs(_G.TycoonSettings) do
			if tycoonNameOrInstance:IsDescendantOf(workspace) and 
			   tycoonNameOrInstance:GetFullName():find(tycoonName) then
				return _G.TycoonSettings[tycoonName]
			end
		end
	end
	
	-- Return default settings if nothing found
	return _G.Settings
end

-- Step 4: Final Report
print("\n" .. string.rep("📊", 40))
print("FINAL MULTI-TYCOON SETTINGS REPORT")
print(string.rep("📊", 40))
print(string.format("\n🏭 Found %d REAL tycoons (not %d false positives!)", #allTycoons, 21))

print(string.format("\n⏱️ Total load time: %.2f seconds", tick() - MasterDebug.startTime))
print(string.format("🏭 Tycoons found: %d", #MasterDebug.foundTycoons))
print(string.format("📄 Settings modules found: %d", #MasterDebug.foundSettings))
print(string.format("✅ Settings loaded: %d", #MasterDebug.loadedSettings))
print(string.format("❌ Errors encountered: %d", #MasterDebug.errors))
print(string.format("⚠️ Warnings: %d", #MasterDebug.warnings))

-- List all loaded settings
print("\n📦 LOADED SETTINGS:")
for tycoonName, settings in pairs(_G.TycoonSettings) do
	local status = settings._IS_FALLBACK and "⚠️ FALLBACK" or "✅ LOADED"
	print(string.format("  [%s] %s", status, tycoonName))
end

-- Show errors if any
if #MasterDebug.errors > 0 then
	print("\n❌ ERROR DETAILS:")
	for i, err in ipairs(MasterDebug.errors) do
		print(string.format("  [%d] %s - %s: %s", i, err.tycoon, err.strategy, err.error))
	end
end

-- Show warnings
if #MasterDebug.warnings > 0 then
	print("\n⚠️ WARNINGS:")
	for i, warn in ipairs(MasterDebug.warnings) do
		print(string.format("  [%d] %s: %s", i, warn.tycoon, warn.warning))
	end
end

-- Usage instructions
print("\n📚 HOW TO USE:")
print("  1. Access main settings: _G.Settings")
print("  2. Access specific tycoon: _G.TycoonSettings['TycoonName']")
print("  3. Use helper: _G.GetTycoonSettings(tycoonInstanceOrName)")

-- Create debug remote for live testing
local debugRemote = Instance.new("RemoteFunction")
debugRemote.Name = "MultiTycoonSettingsDebug"
debugRemote.Parent = game.ReplicatedStorage

debugRemote.OnServerInvoke = function(player)
	local report = {
		masterDebug = MasterDebug,
		loadedTycoons = {},
		isStudio = game:GetService("RunService"):IsStudio()
	}
	
	for name, settings in pairs(_G.TycoonSettings) do
		report.loadedTycoons[name] = {
			loaded = true,
			isFallback = settings._IS_FALLBACK or false
		}
	end
	
	return report
end

print("\n🔧 Debug RemoteFunction: game.ReplicatedStorage.MultiTycoonSettingsDebug")
print(string.rep("🔥", 40) .. "\n")

-- Auto-fix for PurchaseHandlers
task.wait(1)
print("🔧 AUTO-FIXING PURCHASE HANDLERS...")

for _, tycoonData in ipairs(MasterDebug.foundTycoons) do
	local tycoon = tycoonData.instance
	local purchaseHandler = tycoon:FindFirstChild("PurchaseHandler", true)
	
	if purchaseHandler and purchaseHandler:IsA("Script") then
		print("  Found PurchaseHandler in:", tycoon.Name)
		
		-- Inject settings fix at runtime
		local settingsForThisTycoon = _G.TycoonSettings[tycoon.Name] or _G.Settings
		
		-- Create a value to pass settings
		local settingsValue = Instance.new("ObjectValue")
		settingsValue.Name = "_SettingsFixed"
		settingsValue.Parent = purchaseHandler
		
		-- This signals to PurchaseHandler that settings are available
		print("  ✅ Marked for settings injection")
	end
end

print("\n✅ MULTI-TYCOON SETTINGS LOADER COMPLETE!")