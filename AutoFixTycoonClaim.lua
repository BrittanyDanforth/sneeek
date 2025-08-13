--[[
	AUTO FIX TYCOON CLAIM
	Place in ServerScriptService to automatically fix claim functionality
]]

print("="..string.rep("=", 50))
print("🔧 AUTO-FIXING TYCOON CLAIM FUNCTIONALITY")
print("="..string.rep("=", 50))

local fixedCount = 0

-- Find all tycoons
for _, container in ipairs(workspace:GetChildren()) do
	if container.Name:lower():find("tycoon") or container.Name:lower():find("kit") then
		local tycoonsFolder = container:FindFirstChild("Tycoons")
		if tycoonsFolder then
			for _, tycoon in ipairs(tycoonsFolder:GetChildren()) do
				if tycoon:IsA("Model") then
					print(string.format("\n🏭 Checking %s tycoon...", tycoon.Name))
					
					-- Find the gate/entrance
					local gate = tycoon:FindFirstChild("Gate") or tycoon:FindFirstChild("Entrance")
					if not gate then
						print("   ❌ No Gate/Entrance found!")
						continue
					end
					
					-- Check if claim script already exists
					local existingScript = gate:FindFirstChild("GateScript") or 
					                      gate:FindFirstChild("ClaimScript") or
					                      gate:FindFirstChild("Script")
					
					if existingScript and existingScript:IsA("Script") and not existingScript.Disabled then
						print("   ✅ Claim script already exists")
						continue
					end
					
					-- Create claim functionality
					print("   🔧 Adding claim functionality...")
					
					-- Find or create claim part
					local claimPart = gate:FindFirstChild("Touch") or 
					                 gate:FindFirstChild("Head") or 
					                 gate:FindFirstChildOfClass("BasePart")
					
					if not claimPart then
						print("   ⚠️ No claim part found, creating one...")
						claimPart = Instance.new("Part")
						claimPart.Name = "Touch"
						claimPart.Size = Vector3.new(6, 10, 1)
						claimPart.Transparency = 1
						claimPart.CanCollide = false
						claimPart.Anchored = true
						claimPart.Parent = gate
						
						-- Position it at the gate
						local gatePart = gate:FindFirstChildOfClass("BasePart")
						if gatePart then
							claimPart.CFrame = gatePart.CFrame
						end
					end
					
					-- Ensure claim part properties
					claimPart.CanCollide = false
					claimPart.CanTouch = true
					claimPart.CanQuery = true
					
					-- Create the claim script
					local claimScript = Instance.new("Script")
					claimScript.Name = "AutoClaimScript"
					claimScript.Source = [[
local tycoon = script.Parent.Parent
local gate = script.Parent
local owner = tycoon:WaitForChild("Owner")
local essentials = tycoon:WaitForChild("Essentials")
local spawn = essentials:WaitForChild("Spawn")
local teamColor = tycoon:WaitForChild("TeamColor")
local claimPart = gate:WaitForChild("]] .. claimPart.Name .. [[")

print("Claim script active for " .. tycoon.Name)

local debounce = {}

claimPart.Touched:Connect(function(hit)
	local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	
	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	if not player then return end
	
	if debounce[player] then return end
	debounce[player] = true
	
	task.wait(0.5)
	debounce[player] = nil
	
	-- If already owned
	if owner.Value then
		if owner.Value == player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
		end
		return
	end
	
	-- Check if player owns another tycoon
	local alreadyOwns = false
	for _, otherTycoon in ipairs(tycoon.Parent:GetChildren()) do
		if otherTycoon ~= tycoon and otherTycoon:FindFirstChild("Owner") then
			if otherTycoon.Owner.Value == player then
				alreadyOwns = true
				break
			end
		end
	end
	
	if alreadyOwns then return end
	
	-- Claim it!
	owner.Value = player
	
	-- Set team
	player.Team = game.Teams:FindFirstChild(tycoon.Name)
	if not player.Team then
		local newTeam = Instance.new("Team")
		newTeam.Name = tycoon.Name
		newTeam.TeamColor = teamColor.Value
		newTeam.Parent = game.Teams
		player.Team = newTeam
	end
	
	-- Update storage
	local playerMoney = game.ServerStorage.PlayerMoney:FindFirstChild(player.Name)
	if playerMoney then
		local ownsTycoon = playerMoney:FindFirstChild("OwnsTycoon")
		if ownsTycoon then
			ownsTycoon.Value = tycoon
		end
	end
	
	-- Make gate transparent
	for _, part in ipairs(gate:GetDescendants()) do
		if part:IsA("BasePart") and part ~= claimPart then
			part.CanCollide = false
			part.Transparency = 0.7
		end
	end
	
	-- Teleport player
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
	end
	
	print(player.Name .. " claimed " .. tycoon.Name .. " tycoon!")
end)
]]
					
					claimScript.Parent = gate
					claimScript.Disabled = false
					
					fixedCount = fixedCount + 1
					print("   ✅ Claim functionality added!")
				end
			end
		end
	end
end

print(string.format("\n✅ AUTO-FIX COMPLETE! Fixed %d tycoons", fixedCount))
print("Try touching a tycoon door now!")