--[[
	FIND AND FIX GATE SCRIPTS
	This finds all gate scripts and shows what's wrong
]]

print("🔍 SEARCHING FOR GATE SCRIPTS...")

local gateScripts = {}

-- Find all gate-related scripts
for _, desc in ipairs(workspace:GetDescendants()) do
	if desc:IsA("Script") then
		local parent = desc.Parent
		if parent and (parent.Name == "Gate" or parent.Name == "Entrance" or 
		   desc.Name == "GateScript" or desc.Name:lower():find("gate") or 
		   desc.Name:lower():find("claim") or desc.Name:lower():find("touch")) then
			
			-- Check if it's part of a tycoon
			local tycoon = desc:FindFirstAncestor("Tycoons")
			if tycoon then
				print(string.format("\n📜 Found gate script: %s", desc:GetFullName()))
				print(string.format("   Disabled: %s", tostring(desc.Disabled)))
				
				-- Check if it has Settings require
				if desc.Source:find("Settings") then
					print("   ⚠️ This script requires Settings!")
				end
				
				table.insert(gateScripts, desc)
			end
		end
	end
end

print(string.format("\n📊 Found %d gate scripts", #gateScripts))

-- Check if scripts are disabled
local disabledCount = 0
for _, script in ipairs(gateScripts) do
	if script.Disabled then
		disabledCount = disabledCount + 1
		print(string.format("\n❌ DISABLED: %s", script:GetFullName()))
		print("   Enabling it...")
		script.Disabled = false
	end
end

if disabledCount > 0 then
	print(string.format("\n✅ Enabled %d disabled gate scripts!", disabledCount))
end

-- The REAL issue might be that your tycoons have AutoAssignTeams = false
-- Let's check the teams
print("\n🏁 Checking team setup...")
local teams = game:GetService("Teams")
local forHire = teams:FindFirstChild("For Hire")
if forHire then
	print("✅ 'For Hire' team exists")
	print("   AutoAssignable: " .. tostring(forHire.AutoAssignable))
else
	print("❌ No 'For Hire' team found!")
end

-- Check tycoon teams
for _, team in ipairs(teams:GetChildren()) do
	if team:IsA("Team") and team.Name ~= "For Hire" then
		print(string.format("   Tycoon team: %s (AutoAssignable: %s)", team.Name, tostring(team.AutoAssignable)))
	end
end

print("\n💡 If AutoAssignTeams is false, players MUST touch the gate to claim!")
print("The gate scripts handle this - if they're broken, claiming won't work.")