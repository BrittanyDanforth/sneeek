--[[
	Quick Fix Patch for Tycoon Errors
	This script fixes common reference errors in tycoon scripts
	Place in ServerScriptService and it will run first
--]]

-- Wait a tiny bit for other scripts to start loading
wait(0.1)

print("[QUICK FIX] Patching tycoon reference errors...")

-- Find Settings module
local function findSettingsModule()
	-- Check common locations
	local locations = {
		game.ServerScriptService:FindFirstChild("Settings"),
		game.ServerStorage:FindFirstChild("Settings"),
		workspace:FindFirstChild("Settings", true),
	}
	
	for _, module in ipairs(locations) do
		if module and module:IsA("ModuleScript") then
			return module
		end
	end
	
	-- Deep search in tycoons
	local tycoons = workspace:FindFirstChild("Tycoons")
	if tycoons then
		local found = tycoons:FindFirstChild("Settings", true)
		if found and found:IsA("ModuleScript") then
			return found
		end
	end
	
	return nil
end

-- Load or create Settings
local Settings
local settingsModule = findSettingsModule()

if settingsModule then
	local success, result = pcall(require, settingsModule)
	if success then
		Settings = result
		print("[QUICK FIX] Loaded existing Settings from:", settingsModule:GetFullName())
	end
end

if not Settings then
	print("[QUICK FIX] Creating default Settings")
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
			KillsNames = "Kills", -- Handle both versions
			WOs = true,
			DeathsName = "Deaths",
			ShowCurrency = true,
			ShowShortCurrency = true
		},
		StealSettings = {
			Stealing = true,
			StealPercent = 0.25,
			StealPrecent = 0.25, -- Handle typo version
			PlayerProtection = 60
		},
		ConvertComma = function(self, num)
			local x = tostring(num)
			if #x >= 7 then
				local important = (#x - 6)
				return x:sub(0, important) .. "," .. x:sub(important + 1, important + 3) .. "," .. x:sub(important + 4)
			elseif #x >= 4 then
				return x:sub(0, (#x - 3)) .. "," .. x:sub((#x - 3) + 1)
			else
				return tostring(num)
			end
		end,
		ConvertShort = function(self, num)
			num = tonumber(num) or 0
			if num >= 1000000000 then
				return string.format("%.1fB", num / 1000000000)
			elseif num >= 1000000 then
				return string.format("%.1fM", num / 1000000)
			elseif num >= 1000 then
				return string.format("%.1fK", num / 1000)
			else
				return tostring(num)
			end
		end
	}
end

-- Make Settings globally available
_G.Settings = Settings

-- Also create a fake "game.Settings" for scripts that use that
local fakeSettings = Instance.new("ModuleScript")
fakeSettings.Name = "Settings"
fakeSettings.Source = "return _G.Settings"

-- Try to parent it safely
pcall(function()
	-- Create a GetSettings function that returns the module
	game.GetSettings = function()
		return Settings
	end
end)

-- Fix PurchaseHandler looking for TeamColor
local function fixPurchaseHandler()
	local tycoons = workspace:FindFirstChild("Tycoons")
	if not tycoons then return end
	
	local purchaseHandler = tycoons:FindFirstChild("PurchaseHandler")
	if purchaseHandler and purchaseHandler:IsA("Script") then
		-- Create a fake TeamColor value if it doesn't exist
		if not purchaseHandler:FindFirstChild("TeamColor") then
			local teamColor = Instance.new("BrickColorValue")
			teamColor.Name = "TeamColor"
			teamColor.Value = BrickColor.new("Medium stone grey")
			teamColor.Parent = purchaseHandler
			print("[QUICK FIX] Added TeamColor to PurchaseHandler")
		end
	end
end

-- Fix Core_Handler reference
local function fixCoreHandler()
	local coreHandler = workspace:FindFirstChild("Core_Handler")
	if coreHandler and coreHandler:IsA("Script") then
		-- Core_Handler might be looking for TeamColor in wrong place
		-- This is harder to fix without seeing the script
		print("[QUICK FIX] Found Core_Handler - may need manual fixing")
	end
end

-- Apply fixes
fixPurchaseHandler()
fixCoreHandler()

-- Create a helper function for scripts to get Settings
_G.GetSettings = function()
	return _G.Settings or Settings
end

print("[QUICK FIX] Patches applied. Settings available via:")
print("  - _G.Settings")
print("  - _G.GetSettings()")

-- Monitor for new tycoons being added
workspace.ChildAdded:Connect(function(child)
	if child.Name == "Tycoons" then
		wait(0.5) -- Let it load
		fixPurchaseHandler()
	end
end)