# Unified Leaderboard Setup Instructions

## Overview
This unified leaderboard system supports both regular game modes (with kills/deaths/currency) and CTF (Capture The Flag) mode. It automatically detects which mode to use based on the presence of FlagStand objects in your game.

## Installation Steps

### 1. Script Placement
1. Place `UnifiedLeaderboard.lua` in `ServerScriptService` or as a child of any object in `ServerScriptService`
2. Place `Settings.lua` as a sibling to the leaderboard script (in the same parent folder)

### 2. Currency Setup (Optional)
If you want to track player currency:
1. Create a folder named `PlayerMoney` in `ServerStorage`
2. For each player, create an IntValue or NumberValue with the player's name inside this folder
3. Update these values when players earn/spend currency

### 3. Kill System Setup
For the kill tracking to work properly:
1. When a player damages/kills another player, create an ObjectValue tag named "creator" on the victim's Humanoid
2. Set the tag's Value to the killer Player object
3. The leaderboard will automatically track kills based on these tags

Example kill tagging code:
```lua
local function tagHumanoid(humanoid, attacker)
    local tag = Instance.new("ObjectValue")
    tag.Name = "creator"
    tag.Value = attacker
    tag.Parent = humanoid
    
    -- Remove tag after 3 seconds
    game:GetService("Debris"):AddItem(tag, 3)
end
```

### 4. CTF Mode Setup
For CTF mode to activate automatically:
1. Add FlagStand objects to your workspace
2. Ensure each FlagStand has a `FlagCaptured` event
3. The script will automatically detect these and switch to CTF mode

## Configuration

Edit the `Settings.lua` file to customize your leaderboard:

```lua
Settings.LeaderboardSettings = {
    KOs = true,              -- Enable/disable kill tracking
    WOs = true,              -- Enable/disable death tracking
    ShowCurrency = true,     -- Enable/disable currency display
    ShowShortCurrency = true,-- Use short format (1K, 1M) for currency
    
    KillsName = "KOs",       -- Display name for kills
    DeathsName = "Wipeouts", -- Display name for deaths
}

Settings.CurrencyName = "Cash" -- Display name for currency
```

## Features

### Regular Mode
- **Kills (KOs)**: Tracks player kills, with -1 for suicides
- **Deaths (Wipeouts)**: Tracks player deaths
- **Currency**: Displays player money with comma formatting or short notation

### CTF Mode
- **Captures**: Tracks flag captures per player
- Automatically activates when FlagStand objects are detected

### Safety Features
- Proper error handling for missing components
- Character loading timeout (30 seconds)
- Safe player stat access
- Handles players joining before script loads
- Prevents memory leaks with proper event connections

## Troubleshooting

1. **Stats not showing**: Ensure the script is in ServerScriptService
2. **Kills not tracking**: Check that you're properly tagging humanoids with "creator" ObjectValue
3. **Currency not updating**: Verify PlayerMoney folder exists in ServerStorage with correct player values
4. **CTF mode not activating**: Ensure FlagStand objects have proper ClassName and FlagCaptured events

## Notes
- The script uses modern Roblox best practices (`:Connect` instead of `:connect`, `:FindFirstChild` instead of `:findFirstChild`)
- All deprecated methods have been updated
- Includes proper memory management to prevent leaks
- Handles edge cases like players leaving mid-game