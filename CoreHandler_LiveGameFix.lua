--[[
	FIX FOR COREHANDLER - Replace Settings require line
]]

-- FIND THIS LINE IN YOUR COREHANDLER (around line 10):
local Settings = require(script.Parent.Settings)

-- REPLACE IT WITH THIS SAFE VERSION:
local Settings
local success = pcall(function()
	local settingsModule = script.Parent:WaitForChild("Settings", 10)
	if settingsModule then
		Settings = require(settingsModule)
	else
		error("Settings not found")
	end
end)

if not success or not Settings then
	warn("⚠️ CoreHandler: Using fallback settings!")
	Settings = {
		AutoAssignTeams = false,
		CurrencyName = "Cash",
		LeaderboardSettings = {
			KOs = true,
			KillsName = "Kills",
			WOs = true,
			DeathsName = "Deaths",
			ShowCurrency = true,
			ShowShortCurrency = true
		}
	}
end