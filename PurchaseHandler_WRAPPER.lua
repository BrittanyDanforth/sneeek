--[[
	PURCHASE HANDLER WRAPPER
	This wraps your existing PurchaseHandler to fix the Settings require issue
	
	INSTRUCTIONS:
	1. Rename your current PurchaseHandler to "PurchaseHandler_Original" (keep it disabled)
	2. Use this script as the new PurchaseHandler
	3. This will load Settings properly then run your original code
]]

-- Wait for settings to be available
local settingsReady = false
local Settings

-- Try multiple methods to get Settings
task.spawn(function()
	-- Method 1: Wait for global settings
	local attempts = 0
	while not _G.GetTycoonSettings and attempts < 50 do
		task.wait(0.1)
		attempts = attempts + 1
	end
	
	if _G.GetTycoonSettings then
		Settings = _G.GetTycoonSettings(script.Parent)
		settingsReady = true
		print("✅ PurchaseHandler got Settings from global loader")
		return
	end
	
	-- Method 2: Try to find Settings module directly
	local settingsModule = script.Parent:FindFirstChild("Settings") or 
	                      script.Parent.Parent:FindFirstChild("Settings") or
	                      script.Parent.Parent.Parent:FindFirstChild("Settings")
	
	if settingsModule then
		local success, result = pcall(require, settingsModule)
		if success then
			Settings = result
			settingsReady = true
			print("✅ PurchaseHandler loaded Settings directly")
			return
		end
	end
	
	-- Method 3: Use fallback
	warn("⚠️ PurchaseHandler using fallback Settings")
	Settings = {
		Sounds = {
			Purchase = 203785492,
			Collect = 131886985,
			ErrorBuy = 138090596
		},
		StealSettings = {
			Stealing = true,
			StealPrecent = 0.07,
			PlayerProtection = 60
		},
		ButtonsFadeOut = true,
		FadeOutTime = 0.5,
		ButtonsFadeIn = true,
		FadeInTime = 0.5
	}
	settingsReady = true
end)

-- Wait for settings to be ready
while not settingsReady do
	task.wait()
end

-- Now inject Settings into the environment and run the original script
local originalScript = script.Parent:FindFirstChild("PurchaseHandler_Original")
if not originalScript then
	error("Could not find PurchaseHandler_Original! Please rename your original PurchaseHandler script.")
end

-- Load the original script's source
local originalSource = originalScript.Source

-- Create a new environment with Settings injected
local env = getfenv()
env.Settings = Settings
env.script = script -- Make sure script reference is correct

-- Execute the original code with the fixed Settings
local func = loadstring(originalSource)
setfenv(func, env)
func()