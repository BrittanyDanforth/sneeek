-- START DEBUG SECTION FOR LINKEDLEADERBOARD 1
print("========================================")
print("LINKEDLEADERBOARD 1 DEBUG INFORMATION")
print("========================================")
print("Script Name:", script.Name)
print("Script ClassName:", script.ClassName)
print("Script Full Path:", script:GetFullName())

-- Print parent hierarchy
local current = script
local depth = 0
print("\nPARENT HIERARCHY:")
while current.Parent and depth < 10 do
    print(string.rep("  ", depth) .. "└─ " .. current.Name .. " (" .. current.ClassName .. ")")
    current = current.Parent
    depth = depth + 1
end

-- Print siblings in parent
print("\nSIBLINGS IN PARENT:")
if script.Parent then
    for _, child in pairs(script.Parent:GetChildren()) do
        print("  - " .. child.Name .. " (" .. child.ClassName .. ")")
    end
end

-- Try to load Settings
print("\nLOADING SETTINGS:")
print("Looking for Settings at: script.Parent.Settings")
print("Which translates to:", script.Parent and script.Parent:GetFullName() .. ".Settings" or "NO PARENT")

local settingsSuccess, settingsError = pcall(function()
    return require(script.Parent.Settings)
end)

if settingsSuccess then
    print("✓ Settings loaded successfully!")
else
    print("✗ Failed to load Settings:", settingsError)
end

print("\nBEFORE PARENT CHANGE:")
print("Current location:", script:GetFullName())
print("About to move to: game.ServerScriptService")
-- END DEBUG SECTION

local Settings = require(script.Parent.Settings)
script.Parent = game.ServerScriptService

-- MORE DEBUG AFTER MOVE
print("\nAFTER PARENT CHANGE:")
print("New location:", script:GetFullName())
print("Settings reference still valid?", Settings ~= nil)
print("========================================\n")

stands = {}
CTF_mode = false

function onHumanoidDied(humanoid, player)
	print("[DEBUG] onHumanoidDied called for", player.Name)
	local stats = player:findFirstChild("leaderstats")
	if stats ~= nil then
		local deaths = stats:findFirstChild(Settings.LeaderboardSettings.DeathsName)
		if deaths then
			deaths.Value = deaths.Value + 1
			print("[DEBUG] Incremented deaths for", player.Name, "to", deaths.Value)
		end
		-- do short dance to try and find the killer
		if Settings.LeaderboardSettings.KOs then
			local killer = getKillerOfHumanoidIfStillInGame(humanoid)
			handleKillCount(humanoid, player)
		end
	end
end

function onPlayerRespawn(property, player)
	-- need to connect to new humanoid
	
	if property == "Character" and player.Character ~= nil then
		print("[DEBUG] Character respawned for", player.Name)
		local humanoid = player.Character.Humanoid
		local p = player
		local h = humanoid
		if Settings.LeaderboardSettings.WOs then
			humanoid.Died:connect(function() onHumanoidDied(h, p) end )
		end
	end
end

function getKillerOfHumanoidIfStillInGame(humanoid)
	-- returns the player object that killed this humanoid
	-- returns nil if the killer is no longer in the game

	-- check for kill tag on humanoid - may be more than one - todo: deal with this
	local tag = humanoid:findFirstChild("creator")

	-- find player with name on tag
	if tag ~= nil then
		
		local killer = tag.Value
		if killer.Parent ~= nil then -- killer still in game
			print("[DEBUG] Found killer:", killer.Name)
			return killer
		end
	end

	return nil
end

function handleKillCount(humanoid, player)
	local killer = getKillerOfHumanoidIfStillInGame(humanoid)
	if killer ~= nil then
		local stats = killer:findFirstChild("leaderstats")
		if stats ~= nil then
			local kills = stats:findFirstChild(Settings.LeaderboardSettings.KillsNames)
			if kills then
				if killer ~= player then
					kills.Value = kills.Value + 1
					print("[DEBUG] Incremented kills for", killer.Name, "to", kills.Value)	
				else
					kills.Value = kills.Value - 1
					print("[DEBUG] Decremented kills for", killer.Name, "(suicide) to", kills.Value)
				end
			else
				print("[DEBUG] WARNING: Could not find kills stat named:", Settings.LeaderboardSettings.KillsNames)
				return
			end
		end
	end
end


-----------------------------------------------



function findAllFlagStands(root)
	local c = root:children()
	for i=1,#c do
		if (c[i].className == "Model" or c[i].className == "Part") then
			findAllFlagStands(c[i])
		end
		if (c[i].className == "FlagStand") then
			table.insert(stands, c[i])
			print("[DEBUG] Found FlagStand at:", c[i]:GetFullName())
		end
	end
end

function hookUpListeners()
	for i=1,#stands do
		stands[i].FlagCaptured:connect(onCaptureScored)
	end
	print("[DEBUG] Hooked up", #stands, "flag stand listeners")
end

function onPlayerEntered(newPlayer)
	print("[DEBUG] Player entered:", newPlayer.Name)
	print("[DEBUG] CTF Mode:", CTF_mode)

	if CTF_mode == true then

		local stats = Instance.new("IntValue")
		stats.Name = "leaderstats"

		local captures = Instance.new("IntValue")
		captures.Name = "Captures"
		captures.Value = 0


		captures.Parent = stats

		-- VERY UGLY HACK
		-- Will this leak threads?
		-- Is the problem even what I think it is (player arrived before character)?
		print("[DEBUG] Waiting for character for", newPlayer.Name)
		while true do
			if newPlayer.Character ~= nil then break end
			wait(5)
		end
		print("[DEBUG] Character loaded for", newPlayer.Name)

		stats.Parent = newPlayer

	else

		local stats = Instance.new("IntValue")
		stats.Name = "leaderstats"
		local kills = false
		if Settings.LeaderboardSettings.KOs then
			kills = Instance.new("IntValue")
			kills.Name = Settings.LeaderboardSettings.KillsName
			kills.Value = 0
			print("[DEBUG] Created kills stat:", Settings.LeaderboardSettings.KillsName)
		end
		local deaths = false
		if Settings.LeaderboardSettings.WOs then
			deaths = Instance.new("IntValue")
			deaths.Name = Settings.LeaderboardSettings.DeathsName
			deaths.Value = 0
			print("[DEBUG] Created deaths stat:", Settings.LeaderboardSettings.DeathsName)
		end
		
		local cash = false
		if Settings.LeaderboardSettings.ShowCurrency then
			cash = Instance.new("StringValue")
			cash.Name = Settings.CurrencyName
			cash.Value = 0
			print("[DEBUG] Created currency stat:", Settings.CurrencyName)
		end
		
		print("[DEBUG] Looking for PlayerMoney in ServerStorage")
		local PlayerStats = game.ServerStorage.PlayerMoney:FindFirstChild(newPlayer.Name)
		if PlayerStats ~= nil then
			print("[DEBUG] Found PlayerStats for", newPlayer.Name)
			if cash then
				local Short = Settings.LeaderboardSettings.ShowShortCurrency
				PlayerStats.Changed:connect(function()
					if (Short) then
						cash.Value = Settings:ConvertShort(PlayerStats.Value)
					else
						cash.Value = Settings:ConvertComma(PlayerStats.Value)
					end
					print("[DEBUG] Updated currency for", newPlayer.Name, "to", cash.Value)
				end)
			end
		else
			print("[DEBUG] No PlayerStats found for", newPlayer.Name)
		end
		if kills then
		kills.Parent = stats
		end
		if deaths then
		deaths.Parent = stats
		end
		if cash then
		cash.Parent = stats
		end

		-- VERY UGLY HACK
		-- Will this leak threads?
		-- Is the problem even what I think it is (player arrived before character)?
		print("[DEBUG] Waiting for character for", newPlayer.Name)
		while true do
			if newPlayer.Character ~= nil then break end
			wait(5)
		end
		print("[DEBUG] Character loaded for", newPlayer.Name)

		local humanoid = newPlayer.Character.Humanoid

		humanoid.Died:connect(function() onHumanoidDied(humanoid, newPlayer) end )

		-- start to listen for new humanoid
		newPlayer.Changed:connect(function(property) onPlayerRespawn(property, newPlayer) end )


		stats.Parent = newPlayer
		print("[DEBUG] Leaderstats created for", newPlayer.Name)

	end

end


function onCaptureScored(player)
		print("[DEBUG] Capture scored by", player.Name)
		local ls = player:findFirstChild("leaderstats")
		if ls == nil then return end
		local caps = ls:findFirstChild("Captures")
		if caps == nil then return end
		caps.Value = caps.Value + 1

end

print("[DEBUG] Searching for flag stands in workspace...")
findAllFlagStands(game.Workspace)
hookUpListeners()
if (#stands > 0) then CTF_mode = true end
print("[DEBUG] Found", #stands, "flag stands. CTF Mode:", CTF_mode)

print("[DEBUG] Connecting to Players.ChildAdded event...")
game.Players.ChildAdded:connect(onPlayerEntered)

print("[DEBUG] LINKEDLEADERBOARD 1 INITIALIZATION COMPLETE")
print("========================================\n")