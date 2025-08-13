--[[
	MAIN SETTINGS MODULE
	Place this in ServerScriptService
	
	This is the ONLY Settings module you need!
	Delete any other Settings modules in your tycoons.
]]

local module = {}

-- Sound Settings
module.Sounds = {
	Purchase = 203785492,  -- Sound when player successfully purchases
	Collect = 131886985,   -- Sound when collecting currency
	ErrorBuy = 138090596   -- Sound when purchase fails
}

-- Team Settings
module.AutoAssignTeams = false  -- If false, players join 'For Hire' team first

-- Currency Settings
module.CurrencyName = "Cash"

-- Button Animation Settings
module.ButtonsFadeOut = true
module.FadeOutTime = 0.5
module.ButtonsFadeIn = true
module.FadeInTime = 0.5

-- Leaderboard Settings
module.LeaderboardSettings = {
	KOs = true,
	KillsName = "Kills",
	WOs = true,
	DeathsName = "Deaths",
	ShowCurrency = true,
	ShowShortCurrency = true
}

-- Steal Settings
module.StealSettings = {
	Stealing = true,
	StealPrecent = 0.07,
	PlayerProtection = 60
}

-- Utility Functions (defined directly, no external requires)
function module:ConvertComma(num)
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
end

function module:ConvertShort(Filter_Num)
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

print("✅ Main Settings Module Loaded!")

return module