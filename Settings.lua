local Settings = {}

Settings.LeaderboardSettings = {
	-- Enable/Disable kill tracking
	KOs = true,
	-- Enable/Disable death tracking  
	WOs = true,
	
	-- Names for the stats on the leaderboard
	KillsName = "KOs",
	DeathsName = "WOs",
	
	-- Fix for the typo in the original script (KillsNames -> KillsName)
	KillsNames = "KOs", -- backwards compatibility
	
	-- Additional stats that can be tracked
	ExtraStats = {
		-- Example extra stats:
		-- {Name = "Points", DefaultValue = 0},
		-- {Name = "Level", DefaultValue = 1},
	}
}

return Settings