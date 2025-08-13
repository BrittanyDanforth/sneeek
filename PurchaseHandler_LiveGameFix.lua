--[[
	FIX FOR LIVE GAME - Replace Settings require line
]]

-- FIND THIS LINE IN YOUR PURCHASEHANDLER (around line 20):
local Settings = require(script.Parent.Parent.Parent.Settings)

-- REPLACE IT WITH THIS SAFE VERSION:
local Settings
local success = false
local attempts = 0

-- Try to load Settings with retries
while not success and attempts < 5 do
	attempts = attempts + 1
	
	success = pcall(function()
		-- Try different paths
		local settingsModule = script.Parent.Parent.Parent:WaitForChild("Settings", 5) or
		                      script.Parent.Parent:WaitForChild("Settings", 5) or
		                      script.Parent:FindFirstChild("Settings")
		
		if settingsModule then
			Settings = require(settingsModule)
		else
			error("Settings module not found")
		end
	end)
	
	if not success then
		warn("Attempt", attempts, "failed to load Settings, retrying...")
		task.wait(1)
	end
end

-- If still failed, use embedded fallback
if not Settings then
	warn("⚠️ USING FALLBACK SETTINGS - Module not found!")
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
		StealSettings = {
			Stealing = true,
			StealPrecent = 0.07,
			PlayerProtection = 60
		},
		-- Utility functions
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
	print("✅ Fallback settings loaded - tycoon will work!")
end