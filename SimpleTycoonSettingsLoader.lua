--[[
	SIMPLE TYCOON SETTINGS LOADER
	For when you know you have exactly 4 tycoons
	Place in ServerScriptService
]]

print(string.rep("=", 50))
print("🎯 SIMPLE TYCOON SETTINGS LOADER")
print(string.rep("=", 50))

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
		-- Return a basic fallback
		return {
			Sounds = {
				Purchase = 203785492,
				Collect = 131886985,
				ErrorBuy = 138090596
			},
			CurrencyName = "Cash",
			LeaderboardSettings = {
				ShowCurrency = true
			},
			ConvertComma = function(self, num)
				return tostring(num)
			end,
			ConvertShort = function(self, num)
				return tostring(num)
			end
		}
	end
end

-- Find tycoons with proper structure
local function findTycoons()
	local tycoons = {}
	
	print("\n🔍 Searching for tycoons...")
	
	-- Search in workspace
	for _, child in ipairs(workspace:GetDescendants()) do
		if (child:IsA("Model") or child:IsA("Folder")) then
			-- Check if it has key tycoon components
			local hasEssentials = child:FindFirstChild("Essentials")
			local hasPurchaseHandler = child:FindFirstChild("PurchaseHandler")
			local hasButtons = child:FindFirstChild("Buttons")
			
			if hasEssentials and hasPurchaseHandler and hasButtons then
				-- This is a tycoon!
				local settings = child:FindFirstChild("Settings", true)
				if settings and settings:IsA("ModuleScript") then
					print(string.format("  ✅ Found tycoon: %s", child.Name))
					print(string.format("     Path: %s", child:GetFullName()))
					
					table.insert(tycoons, {
						name = child.Name,
						instance = child,
						settingsModule = settings
					})
				end
			end
		end
	end
	
	return tycoons
end

-- Main execution
local tycoons = findTycoons()
print(string.format("\n📊 Found %d tycoons total", #tycoons))

-- Load settings for each tycoon
for _, tycoon in ipairs(tycoons) do
	local settings = safeRequire(tycoon.settingsModule, tycoon.name)
	_G.TycoonSettings[tycoon.name] = settings
	
	-- Set first one as default
	if not _G.Settings then
		_G.Settings = settings
		print(string.format("🌟 Set %s settings as default _G.Settings", tycoon.name))
	end
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

print("\n✅ Simple Tycoon Settings Loader Complete!")
print("📋 Loaded settings for:")
for name, _ in pairs(_G.TycoonSettings) do
	print("   - " .. name)
end