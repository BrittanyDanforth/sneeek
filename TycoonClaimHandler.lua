--[[
	TYCOON CLAIM HANDLER
	Place in each tycoon's Gate/Entrance model
	This handles claiming the tycoon when a player touches the door
]]

local tycoon = script.Parent.Parent
local gate = script.Parent
local owner = tycoon:WaitForChild("Owner")
local essentials = tycoon:WaitForChild("Essentials")
local spawn = essentials:WaitForChild("Spawn")
local teamColor = tycoon:WaitForChild("TeamColor")

-- Find the claim part (usually called "Touch" or "Head")
local claimPart = gate:FindFirstChild("Touch") or gate:FindFirstChild("Head") or gate:FindFirstChildOfClass("BasePart")

if not claimPart then
	warn("No claim part found in gate!")
	return
end

print(string.format("✅ Claim handler ready for %s tycoon", tycoon.Name))
print(string.format("   Claim part: %s", claimPart.Name))

-- Debounce table
local debounce = {}

-- Handle claiming
claimPart.Touched:Connect(function(hit)
	local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	
	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	if not player then return end
	
	-- Check debounce
	if debounce[player] then return end
	debounce[player] = true
	
	-- Delay to prevent spam
	task.wait(0.5)
	debounce[player] = nil
	
	-- Check if tycoon is already owned
	if owner.Value then
		-- Teleport owner to spawn
		if owner.Value == player then
			if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				player.Character.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
			end
		end
		return
	end
	
	-- Check if player already owns a tycoon
	local alreadyOwns = false
	for _, otherTycoon in ipairs(tycoon.Parent:GetChildren()) do
		if otherTycoon ~= tycoon and otherTycoon:FindFirstChild("Owner") then
			if otherTycoon.Owner.Value == player then
				alreadyOwns = true
				break
			end
		end
	end
	
	if alreadyOwns then
		-- Could add a message here
		return
	end
	
	-- Claim the tycoon!
	owner.Value = player
	
	-- Set player's team
	player.Team = game.Teams:FindFirstChild(tycoon.Name)
	if not player.Team then
		-- Create team if it doesn't exist
		local newTeam = Instance.new("Team")
		newTeam.Name = tycoon.Name
		newTeam.TeamColor = teamColor.Value
		newTeam.Parent = game.Teams
		player.Team = newTeam
	end
	
	-- Update player money storage
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
	
	-- Teleport player to spawn
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
	end
	
	print(string.format("🎉 %s claimed %s tycoon!", player.Name, tycoon.Name))
end)