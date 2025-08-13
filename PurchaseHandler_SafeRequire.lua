--[[
	SAFE SETTINGS LOADER FOR PURCHASEHANDLER
	
	Replace the Settings require line in your PurchaseHandler with this code.
	This will work in BOTH Studio and Live games!
]]

-- REPLACE THIS LINE:
-- local Settings = require(script.Parent.Parent.Parent.Settings)

-- WITH THIS SAFE LOADER:
local Settings
local success, result = pcall(function()
	-- Try multiple paths where Settings might be
	local paths = {
		script.Parent.Parent.Parent:FindFirstChild("Settings"),
		script.Parent.Parent:FindFirstChild("Settings"),
		script.Parent:FindFirstChild("Settings"),
		-- Also check in workspace
		workspace:FindFirstDescendant("Settings")
	}
	
	for _, path in ipairs(paths) do
		if path and path:IsA("ModuleScript") then
			print("Found Settings at:", path:GetFullName())
			return require(path)
		end
	end
	
	error("Settings module not found in any location")
end)

if success then
	Settings = result
	print("✅ Settings loaded successfully!")
else
	warn("⚠️ Failed to load Settings module:", result)
	warn("Using fallback settings instead")
	
	-- FALLBACK SETTINGS - This ensures your tycoon works even if Settings fails
	Settings = {
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
			StealPrecent = 0.07,
			PlayerProtection = 60
		},
		-- Include the utility functions
		ConvertComma = function(self, num)
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
		end,
		ConvertShort = function(self, Filter_Num)
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
	}
end

-- Now continue with the rest of your PurchaseHandler code...