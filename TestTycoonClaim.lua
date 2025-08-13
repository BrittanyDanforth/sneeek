--[[
	🧪 TEST TYCOON CLAIM 🧪
	Manually tests claiming a tycoon
	Put this in ServerScriptService and run it
]]

local Players = game:GetService("Players")

-- Wait for a player
Players.PlayerAdded:Connect(function(player)
	print("🧪 Testing tycoon claim for", player.Name)
	
	-- Wait a bit for character to load
	task.wait(2)
	
	-- Find an unclaimed tycoon
	for _, tycoon in ipairs(workspace:GetDescendants()) do
		if (tycoon.Name:find("tycoon") or tycoon.Name:find("Tycoon")) and tycoon:IsA("Model") then
			local owner = tycoon:FindFirstChild("Owner")
			if owner and owner:IsA("ObjectValue") and owner.Value == nil then
				print("📍 Found unclaimed tycoon:", tycoon:GetFullName())
				
				-- Try to claim it
				owner.Value = player
				print("✅ Manually set owner to", player.Name)
				
				-- Check if player joined the team
				task.wait(0.5)
				if player.Team then
					print("🏆 Player is on team:", player.Team.Name)
				else
					print("❌ Player has no team!")
				end
				
				-- Look for the claim part
				local essentials = tycoon:FindFirstChild("Essentials")
				if essentials then
					print("📦 Checking Essentials...")
					for _, part in ipairs(essentials:GetChildren()) do
						if part:IsA("BasePart") and (part.Name:lower():find("claim") or 
						   part.Name:lower():find("gate") or part.Name:lower():find("door") or
						   part.Name:lower():find("entrance")) then
							print("   🚪 Found part:", part.Name)
							print("   CanCollide:", part.CanCollide)
							print("   Transparency:", part.Transparency)
							
							-- Check for scripts
							for _, script in ipairs(part:GetDescendants()) do
								if script:IsA("Script") then
									print("      📜 Script:", script.Name, "Disabled:", script.Disabled)
								end
							end
						end
					end
				end
				
				break -- Only test with first tycoon
			end
		end
	end
end)