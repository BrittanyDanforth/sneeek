--[[
	Modern Tycoon Settings Module
	Updated with better practices and more features
--]]

local Settings = {
	-- Sound Configuration
	Sounds = {
		Purchase = 203785492,    -- Sound when player successfully purchases an item
		Collect = 131886985,     -- Sound when player collects currency
		ErrorBuy = 138090596,    -- Sound when player cannot afford purchase
		LevelUp = 0,            -- Add your sound ID for level up
		Unlock = 0,             -- Add your sound ID for unlocking new areas
	},
	
	-- Team Settings
	AutoAssignTeams = true,  -- Auto-assign players to tycoons (false = manual selection)
	MaxPlayersPerTycoon = 1, -- Maximum players that can own a single tycoon
	
	-- Currency Configuration
	CurrencyName = "Cash",
	StartingCash = 0,        -- How much money players start with
	
	-- Visual Effects
	ButtonsFadeOut = true,
	FadeOutTime = 0.5,
	ButtonsFadeIn = true,
	FadeInTime = 0.5,
	
	-- UI Effects
	ShowCurrencyEffects = true,  -- Show +$100 floating text when collecting
	UseRainbowEffects = false,   -- Rainbow effects for high-value items
	
	-- Leaderboard Configuration
	LeaderboardSettings = {
		KOs = true,
		KillsName = "Kills",
		WOs = true,
		DeathsName = "Deaths",
		ShowCurrency = true,
		ShowShortCurrency = true,
		ShowLevel = false,           -- Show player level on leaderboard
		ShowRebirth = false,         -- Show rebirth count
		RefreshRate = 1,             -- How often to update leaderboard (seconds)
	},
	
	-- Stealing/PvP Settings
	StealSettings = {
		Stealing = true,
		StealPercent = 0.25,         -- Changed from 0.37 to be less harsh
		PlayerProtection = 30,       -- Increased from 20 seconds
		MinimumSteal = 100,          -- Minimum amount that can be stolen
		MaximumSteal = 50000,        -- Maximum amount that can be stolen
		StealCooldown = 60,          -- Cooldown between steals from same player
		NotifyOnSteal = true,        -- Notify player when they're stolen from
	},
	
	-- Collection Settings
	CollectionSettings = {
		CollectCooldown = 0.1,       -- Cooldown between collections
		AutoCollectRadius = 10,      -- Radius for auto-collection (0 = disabled)
		MagnetEnabled = false,       -- Enable magnet effect for currency
		MagnetRange = 20,           -- Range of magnet effect
		CollectMultiplier = 1,       -- Global collection multiplier
	},
	
	-- Save Settings
	DataStoreSettings = {
		AutoSave = true,
		SaveInterval = 60,           -- Save every 60 seconds
		SaveOnLeave = true,
		DataStoreKey = "TycoonData_v2",
		BackupEnabled = true,
	},
	
	-- Performance Settings
	PerformanceMode = {
		Enabled = false,             -- Enable performance optimizations
		MaxOrbs = 50,               -- Maximum currency orbs at once
		OrbLifetime = 30,           -- How long orbs exist before cleanup
		ReduceEffects = true,       -- Reduce particle effects in performance mode
	},
}

-- Modern number formatting with better precision
function Settings:ConvertComma(num)
	num = tonumber(num) or 0
	
	-- Handle negative numbers
	local negative = num < 0
	num = math.abs(num)
	
	local formatted = tostring(num)
	local decimal = ""
	
	-- Handle decimals
	if formatted:find("%.") then
		local parts = formatted:split(".")
		formatted = parts[1]
		decimal = "." .. parts[2]:sub(1, 2) -- Keep 2 decimal places
	end
	
	-- Add commas
	formatted = formatted:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	
	-- Remove leading comma if present
	if formatted:sub(1, 1) == "," then
		formatted = formatted:sub(2)
	end
	
	return (negative and "-" or "") .. formatted .. decimal
end

-- Modern short number formatting
function Settings:ConvertShort(num)
	num = tonumber(num) or 0
	
	-- Handle negative numbers
	local negative = num < 0
	num = math.abs(num)
	
	-- More precise formatting with proper rounding
	local suffixes = {
		{1e12, "T"}, -- Trillion
		{1e9, "B"},  -- Billion
		{1e6, "M"},  -- Million
		{1e3, "K"},  -- Thousand
	}
	
	for _, data in ipairs(suffixes) do
		local threshold, suffix = data[1], data[2]
		if num >= threshold then
			local formatted = num / threshold
			
			-- Determine decimal places based on size
			local decimals = 1
			if formatted >= 100 then
				decimals = 0
			elseif formatted >= 10 then
				decimals = 1
			else
				decimals = 2
			end
			
			return (negative and "-" or "") .. 
				   string.format("%." .. decimals .. "f", formatted) .. suffix
		end
	end
	
	-- For numbers less than 1000, show the exact number
	return (negative and "-" or "") .. tostring(math.floor(num))
end

-- Convert time to readable format
function Settings:ConvertTime(seconds)
	seconds = tonumber(seconds) or 0
	
	if seconds < 60 then
		return seconds .. "s"
	elseif seconds < 3600 then
		local minutes = math.floor(seconds / 60)
		local secs = seconds % 60
		return string.format("%dm %ds", minutes, secs)
	elseif seconds < 86400 then
		local hours = math.floor(seconds / 3600)
		local minutes = math.floor((seconds % 3600) / 60)
		return string.format("%dh %dm", hours, minutes)
	else
		local days = math.floor(seconds / 86400)
		local hours = math.floor((seconds % 86400) / 3600)
		return string.format("%dd %dh", days, hours)
	end
end

-- Get formatted currency string
function Settings:FormatCurrency(amount, useShort)
	if useShort == nil then
		useShort = self.LeaderboardSettings.ShowShortCurrency
	end
	
	local formatted = useShort and self:ConvertShort(amount) or self:ConvertComma(amount)
	return self.CurrencyName .. ": " .. formatted
end

-- Validate settings on module load
function Settings:ValidateSettings()
	-- Ensure steal percent is between 0 and 1
	self.StealSettings.StealPercent = math.clamp(self.StealSettings.StealPercent, 0, 1)
	
	-- Ensure positive values
	self.StealSettings.PlayerProtection = math.max(0, self.StealSettings.PlayerProtection)
	self.CollectionSettings.CollectCooldown = math.max(0.01, self.CollectionSettings.CollectCooldown)
	
	-- Validate sound IDs
	for soundName, soundId in pairs(self.Sounds) do
		if type(soundId) ~= "number" or soundId < 0 then
			warn("Invalid sound ID for", soundName)
			self.Sounds[soundName] = 0
		end
	end
end

-- Initialize settings
Settings:ValidateSettings()

return Settings