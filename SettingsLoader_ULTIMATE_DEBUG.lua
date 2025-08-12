--[[
	ULTIMATE SETTINGS LOADER WITH EXTREME DEBUGGING
	Place in ServerScriptService
	
	This will find your Settings module NO MATTER WHAT and give you
	TONS of debug info to see what's happening in live games!
--]]

print("\n" .. string.rep("=", 80))
print("🔧 ULTIMATE SETTINGS LOADER STARTING...")
print("⏰ Time:", os.date("%Y-%m-%d %H:%M:%S"))
print("🎮 PlaceId:", game.PlaceId)
print("🌐 JobId:", game.JobId)
print(string.rep("=", 80) .. "\n")

-- Debug tracking
local debugInfo = {
	searchedLocations = {},
	foundModules = {},
	errors = {},
	startTime = tick()
}

-- Enhanced search function with detailed logging
local function searchLocation(location, depth)
	depth = depth or 0
	local indent = string.rep("  ", depth)
	
	print(indent .. "🔍 Searching in:", location:GetFullName())
	table.insert(debugInfo.searchedLocations, location:GetFullName())
	
	-- Direct child search
	for _, child in ipairs(location:GetChildren()) do
		if child.Name == "Settings" and child:IsA("ModuleScript") then
			print(indent .. "  ✅ FOUND Settings module!")
			table.insert(debugInfo.foundModules, {
				path = child:GetFullName(),
				parent = child.Parent.Name,
				className = child.Parent.ClassName
			})
			return child
		end
	end
	
	-- Recursive search (limited depth to prevent lag)
	if depth < 3 then
		for _, child in ipairs(location:GetChildren()) do
			if child:IsA("Folder") or child:IsA("Model") then
				local found = searchLocation(child, depth + 1)
				if found then return found end
			end
		end
	end
	
	return nil
end

-- Main search function with multiple strategies
local function findSettingsModule()
	print("📋 PHASE 1: Quick Search in Common Locations")
	print(string.rep("-", 60))
	
	-- Strategy 1: Direct common locations
	local quickLocations = {
		{game.ServerScriptService, "ServerScriptService"},
		{game.ServerStorage, "ServerStorage"},
		{game.ReplicatedStorage, "ReplicatedStorage"},
		{workspace, "Workspace (root only)"}
	}
	
	for i, locationData in ipairs(quickLocations) do
		local location, name = locationData[1], locationData[2]
		print(string.format("[%d/%d] Checking %s...", i, #quickLocations, name))
		
		local settings = location:FindFirstChild("Settings")
		if settings and settings:IsA("ModuleScript") then
			print("  ✅ FOUND in " .. name .. "!")
			return settings
		else
			print("  ❌ Not found in " .. name)
		end
	end
	
	print("\n📋 PHASE 2: Deep Search in Workspace")
	print(string.rep("-", 60))
	
	-- Strategy 2: Search for tycoon-related folders
	local tycoonKeywords = {"Tycoon", "Kit", "TycoonKit", "Zednov", "Cinnamoroll"}
	local searchCount = 0
	
	for _, descendant in ipairs(workspace:GetDescendants()) do
		searchCount = searchCount + 1
		
		-- Progress update every 100 items
		if searchCount % 100 == 0 then
			print("  ⏳ Searched", searchCount, "items...")
		end
		
		if descendant.Name == "Settings" and descendant:IsA("ModuleScript") then
			local parent = descendant.Parent
			local grandParent = parent and parent.Parent
			
			print("\n  🎯 Found potential Settings module:")
			print("    Path:", descendant:GetFullName())
			print("    Parent:", parent and parent.Name or "nil")
			print("    GrandParent:", grandParent and grandParent.Name or "nil")
			
			-- Check if it's in a tycoon-related location
			local isTycoonSettings = false
			for _, keyword in ipairs(tycoonKeywords) do
				if (parent and parent.Name:lower():find(keyword:lower())) or
				   (grandParent and grandParent.Name:lower():find(keyword:lower())) then
					isTycoonSettings = true
					print("    ✅ Matched keyword:", keyword)
					break
				end
			end
			
			if isTycoonSettings then
				print("    ✅ CONFIRMED: This is a tycoon Settings module!")
				return descendant
			else
				print("    ⚠️ Found but not in tycoon context, continuing search...")
			end
		end
	end
	
	print("  🔍 Total items searched:", searchCount)
	
	print("\n📋 PHASE 3: Pattern-Based Search")
	print(string.rep("-", 60))
	
	-- Strategy 3: Look for specific folder patterns
	local patterns = {
		"TycoonKit",
		"Tycoons",
		"StarterTycoon",
		"MainTycoon"
	}
	
	for _, pattern in ipairs(patterns) do
		print("  🔍 Looking for folders named:", pattern)
		for _, folder in ipairs(workspace:GetDescendants()) do
			if folder.Name == pattern and (folder:IsA("Folder") or folder:IsA("Model")) then
				print("    📁 Found folder:", folder:GetFullName())
				local settings = searchLocation(folder, 1)
				if settings then
					return settings
				end
			end
		end
	end
	
	return nil
end

-- Attempt to load the module with detailed error handling
local function loadSettingsModule(moduleScript)
	print("\n📋 LOADING SETTINGS MODULE")
	print(string.rep("-", 60))
	print("Module path:", moduleScript:GetFullName())
	print("Module parent:", moduleScript.Parent.Name)
	
	-- Multiple loading attempts with different strategies
	local loadStrategies = {
		-- Strategy 1: Direct require
		function()
			print("\n  🔧 Strategy 1: Direct require")
			return require(moduleScript)
		end,
		
		-- Strategy 2: Clone and require
		function()
			print("\n  🔧 Strategy 2: Clone and require")
			local clone = moduleScript:Clone()
			clone.Parent = game.ServerStorage
			wait(0.1) -- Small delay for replication
			return require(clone)
		end,
		
		-- Strategy 3: Deferred require
		function()
			print("\n  🔧 Strategy 3: Deferred require")
			local result = nil
			task.defer(function()
				result = require(moduleScript)
			end)
			wait(0.5)
			return result
		end
	}
	
	for i, strategy in ipairs(loadStrategies) do
		print(string.format("\n  [%d/%d] Trying loading strategy...", i, #loadStrategies))
		
		local success, result = pcall(strategy)
		
		if success and result then
			print("    ✅ SUCCESS! Settings loaded with strategy", i)
			return result
		else
			local errorMsg = tostring(result)
			print("    ❌ Failed:", errorMsg)
			table.insert(debugInfo.errors, {
				strategy = i,
				error = errorMsg,
				time = tick()
			})
			
			-- Special handling for recursive require error
			if errorMsg:find("recursive") then
				print("    ⚠️ RECURSIVE REQUIRE DETECTED!")
				print("    💡 This means the Settings module is trying to require other modules.")
				print("    💡 Check if Settings has any 'require' statements!")
			end
		end
	end
	
	return nil
end

-- MAIN EXECUTION
print("\n" .. string.rep("=", 80))
print("🚀 STARTING MAIN SEARCH PROCESS")
print(string.rep("=", 80) .. "\n")

local settingsModule = findSettingsModule()
local Settings = nil

if settingsModule then
	print("\n✅ Settings module located! Attempting to load...")
	Settings = loadSettingsModule(settingsModule)
else
	print("\n❌ No Settings module found after exhaustive search!")
end

-- Final result handling
print("\n" .. string.rep("=", 80))
print("📊 FINAL RESULTS")
print(string.rep("=", 80))

if Settings then
	print("\n✅ SUCCESS! Settings loaded successfully!")
	
	-- Make globally available
	_G.Settings = Settings
	
	-- Store in ServerStorage for easy access
	if not game.ServerStorage:FindFirstChild("Settings") and settingsModule then
		local copy = settingsModule:Clone()
		copy.Parent = game.ServerStorage
		print("📦 Copied Settings to ServerStorage for easy access")
	end
	
	-- Display loaded settings info
	print("\n📋 Loaded Settings Info:")
	print(string.rep("-", 40))
	
	local function printTable(tbl, indent)
		indent = indent or "  "
		for key, value in pairs(tbl) do
			local valueType = type(value)
			if valueType == "table" then
				print(indent .. key .. ": (table)")
				printTable(value, indent .. "  ")
			elseif valueType == "function" then
				print(indent .. key .. ": (function)")
			else
				print(indent .. key .. ":", tostring(value))
			end
		end
	end
	
	-- Safely print settings
	local success, err = pcall(function()
		printTable(Settings)
	end)
	
	if not success then
		print("  ⚠️ Could not print settings table:", err)
	end
	
else
	print("\n❌ FAILED TO LOAD SETTINGS!")
	print("Creating fallback settings...")
	
	-- Create comprehensive fallback
	_G.Settings = {
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
			StealPrecent = 0.07, -- Note: Check spelling in your code
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
	
	print("✅ Fallback settings created!")
end

-- Debug summary
print("\n" .. string.rep("=", 80))
print("🐛 DEBUG SUMMARY")
print(string.rep("=", 80))
print("⏱️ Total search time:", string.format("%.2f", tick() - debugInfo.startTime), "seconds")
print("📍 Locations searched:", #debugInfo.searchedLocations)
print("📦 Modules found:", #debugInfo.foundModules)
print("❌ Errors encountered:", #debugInfo.errors)

if #debugInfo.foundModules > 0 then
	print("\n📦 Found modules:")
	for i, moduleInfo in ipairs(debugInfo.foundModules) do
		print(string.format("  [%d] %s", i, moduleInfo.path))
	end
end

if #debugInfo.errors > 0 then
	print("\n❌ Error details:")
	for i, errorInfo in ipairs(debugInfo.errors) do
		print(string.format("  [%d] Strategy %d: %s", i, errorInfo.strategy, errorInfo.error))
	end
end

print("\n✅ Settings Loader complete! Access via _G.Settings")
print(string.rep("=", 80) .. "\n")

-- Create a debug remote for live game testing
local debugRemote = Instance.new("RemoteFunction")
debugRemote.Name = "SettingsDebugInfo"
debugRemote.Parent = game.ReplicatedStorage

debugRemote.OnServerInvoke = function(player)
	return {
		loaded = _G.Settings ~= nil,
		debugInfo = debugInfo,
		settingsPath = settingsModule and settingsModule:GetFullName() or "Not found"
	}
end

print("🔧 Debug RemoteFunction created: game.ReplicatedStorage.SettingsDebugInfo")