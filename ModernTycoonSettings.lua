--[[
	Modern Tycoon Settings Module
	Cleaner organization with validation and type checking
--]]

local Settings = {}

-- Sound Configuration
Settings.Sounds = {
	Purchase = 203785492,     -- Sound when buying affordable items
	Collect = 131886985,      -- Sound when collecting currency
	ErrorBuy = 138090596,     -- Sound when trying to buy unaffordable items
	-- Additional sounds you can add:
	-- Dependency = 123456789, -- Sound when dependency is met
	-- Steal = 987654321,     -- Sound when stealing
}

-- Tycoon Behavior
Settings.AutoAssignTeams = false  -- False = players pick their own tycoon
Settings.CurrencyName = "Cash"    -- Name shown everywhere
Settings.StartingCash = 0         -- How much money players start with

-- Visual Effects
Settings.ButtonsFadeOut = true
Settings.FadeOutTime = 0.5
Settings.ButtonsFadeIn = true
Settings.FadeInTime = 0.5

-- Button Visual Settings
Settings.ButtonVisuals = {
	PurchasedTransparency = 0.8,  -- How transparent buttons become after purchase
	DependencyTransparency = 0.9, -- How transparent locked buttons are
	GlowEffect = true,           -- Add glow to affordable buttons
	ColorShift = true,           -- Change button color based on affordability
}

-- Leaderboard Configuration
Settings.LeaderboardSettings = {
	KOs = true,               -- Show kills on leaderboard
	KillsName = "Kills",      -- Display name for kills
	WOs = true,               -- Show deaths on leaderboard  
	DeathsName = "Deaths",    -- Display name for deaths
	ShowCurrency = true,      -- Show player money
	ShowShortCurrency = true, -- Format as 100K instead of 100,000
	-- Additional stats you can add:
	-- ShowLevel = false,
	-- ShowPlayTime = false,
}

-- Stealing Configuration
Settings.StealSettings = {
	Stealing = true,          -- Enable/disable stealing
	StealPercent = 0.25,      -- Percentage of money that can be stolen (0-1)
	PlayerProtection = 60,    -- Cooldown in seconds before player can be stolen from again
	NotifyVictim = true,      -- Notify the victim when stolen from
	StealCap = 10000,         -- Maximum amount that can be stolen in one go
}

-- Performance Settings
Settings.Performance = {
	PartCleanupTime = 30,     -- How long dropped parts exist before cleanup
	MaxPartsPerCollector = 50, -- Maximum parts a collector processes at once
	DebounceTime = 0.1,       -- Minimum time between purchases
}

-- Developer Settings
Settings.Developer = {
	DebugMode = true,         -- Enable debug prints
	ShowPurchaseLogs = true,  -- Log all purchases
	ShowErrorTracing = true,  -- Detailed error messages
}

-- Currency Formatting Functions
function Settings:ConvertComma(num)
	local formatted = tostring(math.floor(num))
	local k = nil
	
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then break end
	end
	
	return formatted
end

function Settings:ConvertShort(num)
	num = tonumber(num) or 0
	
	if num >= 1000000000000 then
		return string.format("%.1fT", num / 1000000000000)
	elseif num >= 1000000000 then
		return string.format("%.1fB", num / 1000000000)
	elseif num >= 1000000 then
		return string.format("%.1fM", num / 1000000)
	elseif num >= 1000 then
		return string.format("%.1fK", num / 1000)
	else
		return tostring(math.floor(num))
	end
end

-- Advanced formatting with suffixes
function Settings:ConvertAdvanced(num)
	local suffixes = {"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"}
	local index = 1
	
	while num >= 1000 and index < #suffixes do
		num = num / 1000
		index = index + 1
	end
	
	if index == 1 then
		return tostring(math.floor(num))
	else
		return string.format("%.2f%s", num, suffixes[index])
	end
end

-- Validate settings on load
local function ValidateSettings()
	-- Ensure steal percent is valid
	if Settings.StealSettings.StealPercent < 0 then
		Settings.StealSettings.StealPercent = 0
	elseif Settings.StealSettings.StealPercent > 1 then
		Settings.StealSettings.StealPercent = 1
	end
	
	-- Ensure positive values
	Settings.StealSettings.PlayerProtection = math.max(0, Settings.StealSettings.PlayerProtection)
	Settings.StealSettings.StealCap = math.max(0, Settings.StealSettings.StealCap)
	Settings.Performance.PartCleanupTime = math.max(1, Settings.Performance.PartCleanupTime)
	Settings.Performance.MaxPartsPerCollector = math.max(1, Settings.Performance.MaxPartsPerCollector)
	
	-- Validate fade times
	Settings.FadeInTime = math.max(0.1, Settings.FadeInTime)
	Settings.FadeOutTime = math.max(0.1, Settings.FadeOutTime)
end

-- Run validation
ValidateSettings()

-- Freeze the table to prevent accidental modifications
table.freeze(Settings.Sounds)
table.freeze(Settings.LeaderboardSettings)
table.freeze(Settings.StealSettings)
table.freeze(Settings.Performance)
table.freeze(Settings.Developer)
table.freeze(Settings.ButtonVisuals)

return Settings