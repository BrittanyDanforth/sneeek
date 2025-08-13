--[[
	QUICK FIX - EMBEDDED SETTINGS
	
	Replace the Settings require line with this embedded version
]]

-- REPLACE THIS LINE:
-- local Settings = require(script.Parent.Parent.Parent.Settings)

-- WITH THIS EMBEDDED SETTINGS:
local Settings = {
	Sounds = {
		Purchase = 203785492,
		Collect = 131886985,
		ErrorBuy = 138090596
	},
	CurrencyName = "Cash",
	ButtonsFadeOut = true,
	FadeOutTime = 0.5,
	ButtonsFadeIn = true,
	FadeInTime = 0.5,
	StealSettings = {
		Stealing = true,
		StealPrecent = 0.07,
		PlayerProtection = 60
	}
}

-- Add the utility functions
function Settings:ConvertComma(num)
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

function Settings:ConvertShort(Filter_Num)
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

-- Now continue with the rest of your PurchaseHandler code...