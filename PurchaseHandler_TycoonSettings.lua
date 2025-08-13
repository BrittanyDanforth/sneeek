--[[
	PURCHASE HANDLER - FIXED FOR TYCOON SETTINGS
	
	This version looks for the Settings module INSIDE the tycoon model.
	Replace your PurchaseHandler with this code.
]]

-- Services
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- FIXED: Find Settings module in the tycoon model
local Settings
local success, result = pcall(function()
	-- Look for Settings in different possible locations within the tycoon
	local tycoonModel = script.Parent.Parent.Parent -- Adjust based on your structure
	
	-- Try different paths where Settings might be
	local settingsModule = 
		tycoonModel:FindFirstChild("Settings") or
		tycoonModel:FindFirstChild("TycoonKit") and tycoonModel.TycoonKit:FindFirstChild("Settings") or
		script.Parent:FindFirstChild("Settings") or
		script.Parent.Parent:FindFirstChild("Settings")
	
	if settingsModule then
		print("✅ Found Settings at:", settingsModule:GetFullName())
		return require(settingsModule)
	else
		error("Settings module not found in tycoon!")
	end
end)

if success then
	Settings = result
	print("✅ Settings loaded successfully in PurchaseHandler")
else
	warn("⚠️ Failed to load Settings in PurchaseHandler:", result)
	-- Fallback settings
	Settings = {
		Sounds = {Purchase = 203785492, Collect = 131886985, ErrorBuy = 138090596},
		CurrencyName = "Cash",
		ButtonsFadeIn = true,
		FadeInTime = 0.5,
		ButtonsFadeOut = true,
		FadeOutTime = 0.5,
		ConvertComma = function(self, num) return tostring(num) end,
		ConvertShort = function(self, num) return tostring(num) end
	}
end

-- Rest of your PurchaseHandler code...
print("✅ PurchaseHandler initialized with tycoon-specific settings!")