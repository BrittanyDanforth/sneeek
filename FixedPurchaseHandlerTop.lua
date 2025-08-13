--[[
	REPLACE THE TOP OF YOUR PURCHASEHANDLER WITH THIS
	This fixes the Settings require issue for live games
]]

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

-- FIXED SETTINGS LOADING - Works in live games
local Settings
local attempts = 0

-- Method 1: Try global settings first
while not Settings and attempts < 30 do
	if _G.GetTycoonSettings then
		Settings = _G.GetTycoonSettings(script.Parent)
		if Settings then
			print("✅ PurchaseHandler: Got settings from global system")
			break
		end
	end
	
	-- Method 2: Try direct path with pcall
	if not Settings then
		local success, result = pcall(function()
			-- Try different paths
			local paths = {
				script.Parent.Parent.Parent:FindFirstChild("Settings"),
				script.Parent.Parent:FindFirstChild("Settings"),
				script.Parent:FindFirstChild("Settings")
			}
			
			for _, settingsModule in ipairs(paths) do
				if settingsModule and settingsModule:IsA("ModuleScript") then
					return require(settingsModule)
				end
			end
		end)
		
		if success and result then
			Settings = result
			print("✅ PurchaseHandler: Found Settings module directly")
			break
		end
	end
	
	attempts = attempts + 1
	task.wait(0.1)
end

-- Fallback if still no settings
if not Settings then
	warn("⚠️ PurchaseHandler: Using fallback settings")
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
		}
	}
end

-- REST OF YOUR PURCHASEHANDLER CODE GOES HERE
-- (Starting from: local Objects = {} )