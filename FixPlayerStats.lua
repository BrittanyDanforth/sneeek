--[[
	🔧 FIX PLAYER STATS FOR TYCOON CLAIMING 🔧
	This ensures players have all required stats to claim tycoons
	Place in ServerScriptService
]]

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

-- Function to create all required stats for a player
local function ensurePlayerStats(player)
	print("🔍 Checking stats for", player.Name)
	
	-- 1. Ensure leaderstats exists
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
		print("✅ Created leaderstats for", player.Name)
	end
	
	-- 2. Ensure PlayerMoney value exists in ServerStorage
	local playerMoneyFolder = ServerStorage:FindFirstChild("PlayerMoney")
	if not playerMoneyFolder then
		playerMoneyFolder = Instance.new("Folder")
		playerMoneyFolder.Name = "PlayerMoney"
		playerMoneyFolder.Parent = ServerStorage
		print("✅ Created PlayerMoney folder")
	end
	
	local playerMoney = playerMoneyFolder:FindFirstChild(player.Name)
	if not playerMoney then
		playerMoney = Instance.new("IntValue")
		playerMoney.Name = player.Name
		playerMoney.Value = 0
		playerMoney.Parent = playerMoneyFolder
		print("✅ Created money value for", player.Name)
	end
	
	-- 3. Check if player has OwnsTycoon value (might be required by gate)
	local ownsTycoon = playerMoney:FindFirstChild("OwnsTycoon")
	if not ownsTycoon then
		ownsTycoon = Instance.new("ObjectValue")
		ownsTycoon.Name = "OwnsTycoon"
		ownsTycoon.Parent = playerMoney
		print("✅ Created OwnsTycoon value for", player.Name)
	end
	
	-- 4. Force create Cash display in leaderstats if missing
	local cashDisplay = leaderstats:FindFirstChild("Cash")
	if not cashDisplay then
		cashDisplay = Instance.new("StringValue")
		cashDisplay.Name = "Cash"
		cashDisplay.Value = "0"
		cashDisplay.Parent = leaderstats
		print("✅ Created Cash display for", player.Name)
	end
	
	-- 5. Create any other stats that might be required
	local kills = leaderstats:FindFirstChild("KOs")
	if not kills then
		kills = Instance.new("IntValue")
		kills.Name = "KOs"
		kills.Value = 0
		kills.Parent = leaderstats
		print("✅ Created KOs stat for", player.Name)
	end
	
	local deaths = leaderstats:FindFirstChild("Wipeouts")
	if not deaths then
		deaths = Instance.new("IntValue")
		deaths.Name = "Wipeouts"
		deaths.Value = 0
		deaths.Parent = leaderstats
		print("✅ Created Wipeouts stat for", player.Name)
	end
	
	print("✅ All stats verified for", player.Name)
end

-- Check all current players
for _, player in pairs(Players:GetPlayers()) do
	ensurePlayerStats(player)
end

-- Check new players
Players.PlayerAdded:Connect(function(player)
	-- Wait a bit for other scripts to set up
	task.wait(0.5)
	ensurePlayerStats(player)
end)

-- Also check when character spawns (in case stats get removed)
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		task.wait(0.5)
		ensurePlayerStats(player)
	end)
end)

print("🔧 Player Stats Fixer loaded!")
print("📊 This ensures all players have required stats for tycoon claiming")