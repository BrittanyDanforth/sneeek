--[[
	🚪 GATE SCRIPT FIXER 🚪
	Finds and fixes gate/claim scripts in all tycoons
	Updates their Settings loading to be live-safe
	
	Run this ONCE in ServerScriptService, then delete it
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- The live-safe settings loading code
local FIXED_SETTINGS_CODE = [[
-- LIVE-SAFE SETTINGS LOADING
local Settings
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local deadline = os.clock() + 20

repeat
	-- Prefer the loader's BindableFunction
	local bf = ReplicatedStorage:FindFirstChild("GetTycoonSettingsBF")
	if bf then
		local ok, res = pcall(function() return bf:Invoke(script.Parent.Parent) end)
		if ok and res then 
			Settings = res 
			break 
		end
	end

	-- Try _G as second option
	if _G.GetTycoonSettings then
		local ok, res = pcall(function() return _G.GetTycoonSettings(script.Parent.Parent) end)
		if ok and res then
			Settings = res
			break
		end
	end

	-- Direct local Settings module
	local mod = script.Parent.Parent:FindFirstChild("Settings")
	if mod and mod:IsA("ModuleScript") then
		local ok, res = pcall(require, mod)
		if ok and res then 
			Settings = res 
			break 
		end
	end

	task.wait(0.1)
until Settings or os.clock() > deadline

if not Settings then
	Settings = {
		AutoAssignTeams = false,
		CurrencyName = "Cash"
	}
end
]]

print("🔍 Starting gate script search...")

local fixedCount = 0

-- Search all tycoons
for _, tycoon in ipairs(workspace:GetDescendants()) do
	if (tycoon.Name:find("tycoon") or tycoon.Name:find("Tycoon")) and tycoon:IsA("Model") then
		-- Look for Gate/Entrance
		local gate = tycoon:FindFirstChild("Gate") or tycoon:FindFirstChild("Entrance") or tycoon:FindFirstChild("Touch to claim door!")
		
		if gate then
			-- Find scripts in the gate
			for _, child in ipairs(gate:GetDescendants()) do
				if child:IsA("Script") and not child.Disabled then
					local source = child.Source
					
					-- Check if it has Settings require
					if source:find("require") and source:find("Settings") then
						print("📝 Found gate script in", tycoon.Name, "-", child:GetFullName())
						
						-- Find the line with Settings require
						local lines = source:split("\n")
						local newLines = {}
						local foundSettings = false
						
						for i, line in ipairs(lines) do
							if line:find("local Settings") and line:find("require") and not foundSettings then
								-- Replace this line with our fixed code
								table.insert(newLines, FIXED_SETTINGS_CODE)
								foundSettings = true
								print("   ✅ Replaced Settings loading")
							elseif not (line:find("local Settings") and foundSettings) then
								-- Keep other lines
								table.insert(newLines, line)
							end
						end
						
						if foundSettings then
							child.Source = table.concat(newLines, "\n")
							fixedCount = fixedCount + 1
						end
					end
				end
			end
		end
		
		-- Also check Essentials for claim parts
		local essentials = tycoon:FindFirstChild("Essentials")
		if essentials then
			local claimPart = essentials:FindFirstChild("Touch to claim tycoon") or 
			                  essentials:FindFirstChild("Touch to claim door!") or
			                  essentials:FindFirstChild("Gate")
			
			if claimPart then
				-- Check for scripts in essentials
				for _, script in ipairs(essentials:GetDescendants()) do
					if script:IsA("Script") and script.Source:find("Owner") and script.Source:find("Settings") then
						print("📝 Found claim script in", tycoon.Name, "Essentials -", script:GetFullName())
						
						-- Apply same fix
						local source = script.Source
						local lines = source:split("\n")
						local newLines = {}
						local foundSettings = false
						
						for i, line in ipairs(lines) do
							if line:find("local Settings") and line:find("require") and not foundSettings then
								table.insert(newLines, FIXED_SETTINGS_CODE)
								foundSettings = true
								print("   ✅ Replaced Settings loading")
							elseif not (line:find("local Settings") and foundSettings) then
								table.insert(newLines, line)
							end
						end
						
						if foundSettings then
							script.Source = table.concat(newLines, "\n")
							fixedCount = fixedCount + 1
						end
					end
				end
			end
		end
	end
end

print("\n✨ Gate Script Fix Complete!")
print("📊 Fixed " .. fixedCount .. " scripts")
print("🎯 Your touch-to-claim doors should now work in live games!")
print("\n⚠️ IMPORTANT: Delete this FixGateScripts script now - it only needs to run once!")