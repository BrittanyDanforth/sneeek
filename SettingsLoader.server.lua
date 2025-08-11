--[[
	Settings Loader
	This script finds and loads the Settings module, making it globally available
	Place in ServerScriptService
--]]

local function findSettings()
	-- Common locations for Settings module
	local locations = {
		game.ServerScriptService,
		game.ServerStorage,
		game.ReplicatedStorage,
		workspace
	}
	
	-- Search in common locations first
	for _, location in ipairs(locations) do
		local settings = location:FindFirstChild("Settings")
		if settings and settings:IsA("ModuleScript") then
			return settings
		end
	end
	
	-- Deep search in workspace for tycoon kits
	for _, descendant in pairs(workspace:GetDescendants()) do
		if descendant.Name == "Settings" and descendant:IsA("ModuleScript") then
			-- Make sure it's a tycoon settings module
			local parent = descendant.Parent
			if parent and (parent.Name:find("Tycoon") or parent.Name:find("Kit")) then
				return descendant
			end
		end
	end
	
	return nil
end

-- Find and load Settings
local settingsModule = findSettings()

if settingsModule then
	print("[SETTINGS LOADER] Found Settings module at:", settingsModule:GetFullName())
	
	-- Load the module
	local success, Settings = pcall(require, settingsModule)
	
	if success then
		-- Make it globally available
		_G.Settings = Settings
		
		-- Also put a copy in ServerStorage for easy access
		if not game.ServerStorage:FindFirstChild("Settings") then
			local copy = settingsModule:Clone()
			copy.Parent = game.ServerStorage
		end
		
		print("[SETTINGS LOADER] Settings loaded successfully")
		
		-- Print some settings info
		if Settings.CurrencyName then
			print("  Currency:", Settings.CurrencyName)
		end
		if Settings.StealSettings then
			print("  Stealing:", Settings.StealSettings.Stealing and "Enabled" or "Disabled")
		end
	else
		warn("[SETTINGS LOADER] Failed to load Settings module:", Settings)
	end
else
	warn("[SETTINGS LOADER] Settings module not found! Using default settings.")
	
	-- Create default settings
	_G.Settings = {
		Sounds = {
			Purchase = 203785492,
			Collect = 131886985,
			ErrorBuy = 138090596
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
			StealPercent = 0.25,
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
	
	print("[SETTINGS LOADER] Created default settings")
end

print("[SETTINGS LOADER] Settings available via _G.Settings")