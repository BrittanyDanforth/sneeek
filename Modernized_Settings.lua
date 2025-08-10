--[[
	Modernized Settings Module (2025 Standards)
	Central configuration for the tycoon kit
--]]

local Settings = {}

-- Sound Configuration
Settings.Sounds = {
	Purchase = 203785492,   -- Sound when player buys an affordable button
	Collect = 131886985,    -- Sound when player collects currency
	ErrorBuy = 138090596    -- Sound when player can't afford a button
}

-- Team Configuration
Settings.AutoAssignTeams = false  -- If false, players join "For Hire" team and pick their tycoon

-- Currency Configuration
Settings.CurrencyName = "Cash"    -- Display name for currency

-- Button Animation Settings
Settings.ButtonsFadeOut = true
Settings.FadeOutTime = 0.5
Settings.ButtonsFadeIn = true
Settings.FadeInTime = 0.5

-- Leaderboard Configuration
Settings.LeaderboardSettings = {
	KOs = true,                    -- Show KnockOuts on leaderboard
	KillsName = "Kills",          -- Display name for kills
	KillsNames = "Kills",         -- Alternative property name (for compatibility)
	WOs = true,                   -- Show Wipeouts on leaderboard
	DeathsName = "Deaths",        -- Display name for deaths
	ShowCurrency = true,          -- Show player money on leaderboard
	ShowShortCurrency = true      -- Format large numbers (100K instead of 100,000)
}

-- Stealing Configuration
Settings.StealSettings = {
	Stealing = true,              -- Enable stealing from other players' collectors
	StealPrecent = 0.25,         -- Percentage of currency that can be stolen (0.25 = 25%)
	PlayerProtection = 60         -- Cooldown in seconds before player can be stolen from again
}

-- Modern number formatting functions
function Settings:ConvertComma(num)
	num = tonumber(num) or 0
	
	-- Use string formatting for cleaner code
	local formatted = tostring(math.floor(num))
	local k
	
	-- Add commas every 3 digits from the right
	repeat
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
	until k == 0
	
	return formatted
end

function Settings:ConvertShort(num)
	num = tonumber(num) or 0
	
	-- Modern approach with proper rounding
	if num >= 1e9 then
		return string.format("%.1fB+", num / 1e9)
	elseif num >= 1e6 then
		return string.format("%.1fM+", num / 1e6)
	elseif num >= 1e3 then
		return string.format("%.1fK+", num / 1e3)
	else
		return tostring(math.floor(num))
	end
end

-- Advanced settings for future expansion
Settings.Advanced = {
	-- Performance settings
	MaxDroppedParts = 100,        -- Maximum dropped parts before cleanup
	DropCleanupTime = 60,         -- Time before dropped parts are removed
	
	-- Security settings
	AntiExploit = true,           -- Enable basic anti-exploit checks
	MaxPurchaseRate = 10,         -- Maximum purchases per second
	
	-- Visual settings
	UseParticleEffects = true,    -- Enable particle effects on purchase
	UseSoundEffects = true,       -- Enable sound effects
	
	-- Gameplay settings
	RespawnTime = 5,              -- Time to respawn tycoon items
	SaveProgress = false,         -- Save tycoon progress (requires DataStore)
}

-- Validate settings on load
local function validateSettings()
	-- Ensure steal percent is between 0 and 1
	if Settings.StealSettings.StealPrecent > 1 then
		Settings.StealSettings.StealPrecent = 1
		warn("StealPercent was greater than 1, capped at 1")
	elseif Settings.StealSettings.StealPrecent < 0 then
		Settings.StealSettings.StealPrecent = 0
		warn("StealPercent was less than 0, set to 0")
	end
	
	-- Ensure protection time is reasonable
	if Settings.StealSettings.PlayerProtection < 1 then
		Settings.StealSettings.PlayerProtection = 1
		warn("PlayerProtection was less than 1 second, set to 1")
	end
	
	-- Validate fade times
	if Settings.FadeOutTime <= 0 then
		Settings.FadeOutTime = 0.1
	end
	if Settings.FadeInTime <= 0 then
		Settings.FadeInTime = 0.1
	end
end

validateSettings()

return Settings