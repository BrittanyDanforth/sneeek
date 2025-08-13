--[[
	REPLACE THE TOP OF YOUR COREHANDLER WITH THIS
	This fixes the Settings require issue for live games
]]

local Tycoons = {}
local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

-- FIXED SETTINGS LOADING - Works in live games
local Settings
local attempts = 0

-- Method 1: Try global settings first
while not Settings and attempts < 30 do
	if _G.GetTycoonSettings then
		Settings = _G.GetTycoonSettings(script.Parent)
		if Settings then
			print("✅ CoreHandler: Got settings from global system")
			break
		end
	end
	
	-- Method 2: Try direct path with pcall
	if not Settings then
		local success, result = pcall(function()
			-- CoreHandler is usually at: Tycoon.CoreHandler
			-- Settings is usually at: Tycoon.Settings
			local settingsModule = script.Parent:FindFirstChild("Settings")
			if settingsModule and settingsModule:IsA("ModuleScript") then
				return require(settingsModule)
			end
		end)
		
		if success and result then
			Settings = result
			print("✅ CoreHandler: Found Settings module directly")
			break
		end
	end
	
	attempts = attempts + 1
	task.wait(0.1)
end

-- Fallback if still no settings
if not Settings then
	warn("⚠️ CoreHandler: Using fallback settings")
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
		},
		ConvertComma = function(self, num)
			return tostring(num)
		end,
		ConvertShort = function(self, num)
			return tostring(num)
		end
	}
end

-- REST OF YOUR COREHANDLER CODE GOES HERE
-- (Starting from: local Storage = ServerStorage:FindFirstChild("PlayerMoney") )