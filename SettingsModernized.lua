-- Modernized Tycoon Settings Module
-- Drop-in replacement with backward compatibility

local module = {
	-- Sound Configuration
	['Sounds'] = {
		['Purchase'] = 203785492,  -- Sound when buying an affordable button
		['Collect'] = 131886985,   -- Sound when collecting currency
		['ErrorBuy'] = 138090596   -- Sound when trying to buy unaffordable button
	},
	
	-- Team & Tycoon Settings
	['AutoAssignTeams'] = true,    -- Auto-assign to tycoons (false = manual selection)
	['CurrencyName'] = "Cash",     -- Your currency name
	
	-- Visual Effects
	['ButtonsFadeOut'] = true,
	['FadeOutTime'] = 0.5,
	['ButtonsFadeIn'] = true,
	['FadeInTime'] = 0.5,
	
	-- Leaderboard Configuration
	['LeaderboardSettings'] = {
		['KOs'] = true,              -- Show kills on leaderboard
		['KillsName'] = "Kills",     -- Display name for kills
		['WOs'] = true,              -- Show deaths on leaderboard
		['DeathsName'] = "Deaths",   -- Display name for deaths
		['ShowCurrency'] = true,     -- Show player money
		['ShowShortCurrency'] = true -- Use short format (100K instead of 100,000)
	},
	
	-- Stealing/PvP Settings
	['StealSettings'] = {
		['Stealing'] = true,         -- Enable stealing from other players
		['StealPrecent'] = 0.25,     -- Percent stolen (0.25 = 25%) - reduced from 0.37
		['PlayerProtection'] = 30    -- Protection time after spawn (seconds) - increased from 20
	}
}

-- Modern number formatting with commas
function module:ConvertComma(num)
	-- Ensure we have a number
	num = tonumber(num) or 0
	
	-- Handle negative numbers
	if num < 0 then
		return "-" .. self:ConvertComma(-num)
	end
	
	-- Convert to string and split integer/decimal parts
	local str = tostring(num)
	local intPart, decPart = str:match("^(%d+)(%.%d+)$")
	intPart = intPart or str
	
	-- Add commas to integer part
	local result = ""
	local digitCount = 0
	
	for i = #intPart, 1, -1 do
		if digitCount == 3 then
			result = "," .. result
			digitCount = 0
		end
		result = intPart:sub(i, i) .. result
		digitCount = digitCount + 1
	end
	
	-- Add decimal part if it exists
	return result .. (decPart or "")
end

-- Modern short number formatting
function module:ConvertShort(num)
	-- Ensure we have a number
	num = tonumber(num) or 0
	
	-- Handle negative numbers
	local negative = num < 0
	num = math.abs(num)
	
	-- Format based on size
	local formatted
	if num >= 1e12 then
		formatted = string.format("%.1fT", num / 1e12)
	elseif num >= 1e9 then
		formatted = string.format("%.1fB", num / 1e9)
	elseif num >= 1e6 then
		formatted = string.format("%.1fM", num / 1e6)
	elseif num >= 1e3 then
		formatted = string.format("%.1fK", num / 1e3)
	else
		formatted = tostring(math.floor(num))
	end
	
	-- Remove unnecessary decimals (e.g., 1.0K -> 1K)
	formatted = formatted:gsub("%.0", "")
	
	return (negative and "-" or "") .. formatted
end

-- Additional utility functions for modern features

-- Format currency with symbol
function module:FormatMoney(amount, useShort)
	if useShort == nil then
		useShort = self.LeaderboardSettings.ShowShortCurrency
	end
	
	local formatted = useShort and self:ConvertShort(amount) or self:ConvertComma(amount)
	return "$" .. formatted
end

-- Get steal amount based on victim's money
function module:CalculateStealAmount(victimMoney)
	local amount = victimMoney * self.StealSettings.StealPrecent
	return math.floor(amount) -- Round down to nearest integer
end

-- Check if player can be stolen from
function module:CanStealFrom(player, lastStealTime)
	if not self.StealSettings.Stealing then
		return false, "Stealing is disabled"
	end
	
	local timeSinceSpawn = tick() - (player.Character and player.Character:GetAttribute("SpawnTime") or 0)
	if timeSinceSpawn < self.StealSettings.PlayerProtection then
		local timeLeft = self.StealSettings.PlayerProtection - timeSinceSpawn
		return false, "Player is protected for " .. math.ceil(timeLeft) .. " seconds"
	end
	
	return true, "Can steal"
end

-- Validate settings on load
local function validateSettings()
	-- Fix common typos
	if module.StealSettings.StealPrecent then
		module.StealSettings.StealPercent = module.StealSettings.StealPrecent
	end
	
	-- Clamp steal percent between 0 and 1
	module.StealSettings.StealPercent = math.clamp(module.StealSettings.StealPercent or 0.25, 0, 1)
	
	-- Ensure positive protection time
	module.StealSettings.PlayerProtection = math.max(0, module.StealSettings.PlayerProtection)
end

validateSettings()

return module