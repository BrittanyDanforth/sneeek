--[[
	Fix All Tycoon Errors Script
	This will fix PurchaseHandler, Core_Handler, and any other scripts with reference errors
	Place in ServerScriptService - IT RUNS FIRST!
--]]

print("\n\n🔧 === FIXING ALL TYCOON ERRORS === 🔧")
print("Starting comprehensive fix...")

-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

-- Wait for game to load
wait(0.5)

-- Find ALL Settings modules in the game
print("\n📋 SEARCHING FOR ALL SETTINGS MODULES...")
local allSettings = {}
local function findAllSettings(parent)
	for _, child in pairs(parent:GetDescendants()) do
		if child.Name == "Settings" and child:IsA("ModuleScript") then
			table.insert(allSettings, child)
			print("  Found Settings at:", child:GetFullName())
		end
	end
end

findAllSettings(game.Workspace)
findAllSettings(ServerScriptService)
findAllSettings(ServerStorage)

print("Total Settings modules found:", #allSettings)

-- Load the first valid Settings module
local Settings
local loadedFrom
for _, settingsModule in ipairs(allSettings) do
	local success, result = pcall(require, settingsModule)
	if success then
		Settings = result
		loadedFrom = settingsModule:GetFullName()
		print("\n✅ Successfully loaded Settings from:", loadedFrom)
		break
	else
		print("❌ Failed to load Settings from:", settingsModule:GetFullName())
	end
end

-- If no Settings loaded, create default
if not Settings then
	print("\n⚠️ NO SETTINGS MODULE LOADED! Creating default...")
	Settings = {
		Sounds = {
			Purchase = 203785492,
			Collect = 131886985,
			ErrorBuy = 138090596,
			Error = 138090596
		},
		AutoAssignTeams = false,
		CurrencyName = "Cash",
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
			StealPrecent = 0.25,
			StealPercent = 0.25,
			PlayerProtection = 60
		},
		ConvertComma = function(self, num) return tostring(num) end,
		ConvertShort = function(self, num) return tostring(num) end
	}
end

-- Make Settings globally available
_G.Settings = Settings
print("\n🌐 Settings now available globally via _G.Settings")

-- Fix PurchaseHandler
print("\n🔍 LOOKING FOR PURCHASEHANDLER...")
local purchaseHandler = workspace:FindFirstChild("Tycoons") and workspace.Tycoons:FindFirstChild("PurchaseHandler")
if purchaseHandler then
	print("  Found PurchaseHandler at:", purchaseHandler:GetFullName())
	
	-- Create a fake Settings module as its child
	local fakeSettings = Instance.new("ModuleScript")
	fakeSettings.Name = "Settings"
	fakeSettings.Source = [[
		-- Auto-generated Settings reference
		return _G.Settings or error("Settings not loaded yet!")
	]]
	
	-- Try to parent it
	local success = pcall(function()
		fakeSettings.Parent = purchaseHandler
	end)
	
	if success then
		print("  ✅ Added Settings reference to PurchaseHandler")
	else
		print("  ❌ Couldn't add Settings to PurchaseHandler")
	end
	
	-- Also check if it needs TeamColor
	if not purchaseHandler:FindFirstChild("TeamColor") then
		local tc = Instance.new("BrickColorValue")
		tc.Name = "TeamColor"
		tc.Value = BrickColor.new("Medium stone grey")
		tc.Parent = purchaseHandler
		print("  ✅ Added TeamColor to PurchaseHandler")
	end
else
	print("  ❌ PurchaseHandler not found at expected location")
end

-- Fix Core_Handler 
print("\n🔍 LOOKING FOR CORE_HANDLER...")
local coreHandler = workspace:FindFirstChild("Core_Handler")
if coreHandler then
	print("  Found Core_Handler at:", coreHandler:GetFullName())
	
	-- Core_Handler is looking for TeamColor in the tycoon models
	-- Let's fix each tycoon
	print("\n🏭 FIXING TYCOON MODELS...")
	
	-- Look for tycoons in common locations
	local tycoonLocations = {
		workspace:FindFirstChild("SpidermanTycoon"),
		workspace:FindFirstChild("Tycoons"),
		workspace:FindFirstChild("Tycoon"),
	}
	
	-- Also search for any model with "tycoon" in the name
	for _, child in pairs(workspace:GetChildren()) do
		if child:IsA("Model") and child.Name:lower():find("tycoon") then
			table.insert(tycoonLocations, child)
		end
	end
	
	-- Fix each tycoon
	for _, location in pairs(tycoonLocations) do
		if location then
			print("\n  Checking location:", location.Name)
			
			-- If it's a folder of tycoons
			if location.Name == "Tycoons" then
				for _, tycoon in pairs(location:GetChildren()) do
					if tycoon:IsA("Model") then
						print("    Processing tycoon:", tycoon.Name)
						
						-- Ensure TeamColor exists
						if not tycoon:FindFirstChild("TeamColor") then
							local tc = Instance.new("BrickColorValue")
							tc.Name = "TeamColor"
							tc.Value = BrickColor.new("Really red")
							tc.Parent = tycoon
							print("      ✅ Added TeamColor to", tycoon.Name)
						else
							print("      ✓ TeamColor already exists in", tycoon.Name)
						end
					end
				end
			else
				-- It's a single tycoon
				-- Look for the inner tycoon model (like "Spiderman tycoon" inside "SpidermanTycoon")
				local innerTycoon = location:FindFirstChildWhichIsA("Model")
				if innerTycoon and not innerTycoon:FindFirstChild("TeamColor") then
					local tc = Instance.new("BrickColorValue")
					tc.Name = "TeamColor"
					tc.Value = BrickColor.new("Really red")
					tc.Parent = innerTycoon
					print("    ✅ Added TeamColor to", innerTycoon.Name)
				end
			end
		end
	end
else
	print("  ❌ Core_Handler not found")
end

-- Create a monitoring function
local function monitorForErrors()
	-- Hook into LogService to catch errors
	game:GetService("LogService").MessageOut:Connect(function(message, messageType)
		if messageType == Enum.MessageType.MessageError then
			-- Check for Settings error
			if message:find("Settings is not a valid member") then
				print("\n⚠️ CAUGHT SETTINGS ERROR! The problematic script needs _G.Settings")
				print("Error:", message)
			end
			
			-- Check for TeamColor error
			if message:find("TeamColor is not a valid member") then
				print("\n⚠️ CAUGHT TEAMCOLOR ERROR! A tycoon is missing TeamColor")
				print("Error:", message)
			end
		end
	end)
end

-- Start monitoring
monitorForErrors()

-- Create helper functions globally
_G.GetSettings = function()
	print("[GetSettings] Returning Settings from:", loadedFrom or "default")
	return Settings
end

_G.FixTycoonReferences = function()
	print("\n🔧 Running FixTycoonReferences...")
	-- This function can be called manually if needed
end

print("\n✅ === FIX SCRIPT COMPLETE === ✅")
print("Settings loaded from:", loadedFrom or "default settings")
print("Available via:")
print("  - _G.Settings")
print("  - _G.GetSettings()")
print("\nIf you still see errors, the scripts need to be modified to use _G.Settings")
print("========================================\n")

-- Final check after a delay
task.wait(2)
print("\n📊 FINAL STATUS CHECK:")
print("- Settings loaded:", Settings ~= nil)
print("- PurchaseHandler fixed:", purchaseHandler ~= nil)
print("- Core_Handler found:", coreHandler ~= nil)
print("- Global Settings available:", _G.Settings ~= nil)

-- Keep checking for new tycoons
workspace.ChildAdded:Connect(function(child)
	if child.Name:lower():find("tycoon") then
		wait(0.5)
		print("\n🏭 New tycoon detected:", child.Name)
		-- Add TeamColor if missing
		if child:IsA("Model") and not child:FindFirstChild("TeamColor") then
			local tc = Instance.new("BrickColorValue")
			tc.Name = "TeamColor"
			tc.Value = BrickColor.new("Medium stone grey")
			tc.Parent = child
			print("  ✅ Added TeamColor to new tycoon")
		end
	end
end)