# TRUE Unified Leaderboard Setup Guide

## Overview
Instead of managing 4 separate LinkedLeaderboard scripts across different tycoons, you now have ONE unified script that handles everything!

## Setup Instructions

### Step 1: Remove Old Scripts
1. Delete or disable ALL LinkedLeaderboard scripts from your tycoons:
   - `Workspace.SpidermanTycoon.Spiderman tycoon.LinkedLeaderboard`
   - `Workspace.VenomTycoon.Venom tycoon.LinkedLeaderboard`
   - (and any others)

### Step 2: Install New Script
1. Place `TRUE_UnifiedLeaderboard.lua` in **ServerScriptService**
2. Name it `UnifiedLeaderboard` (or keep the name)
3. That's it! The script will automatically find all Settings modules from your tycoons

### Step 3: Keep Your Settings
- You DON'T need to move the Settings modules
- Leave them in each tycoon folder where they are
- The script will find them automatically

## Features

### 1. Automatic Settings Detection
The script searches for all Settings modules in tycoons and uses the first one it finds

### 2. Centralized Money Management
- Creates `PlayerMoney` folder in ServerStorage automatically
- Each player gets an IntValue with their name
- Money updates show on leaderboard in real-time

### 3. Global Money API
Use these functions from ANY script to manage money:

```lua
-- Add money to a player
_G.AddPlayerMoney("PlayerName", 100)

-- Set player's money to specific amount
_G.SetPlayerMoney("PlayerName", 5000)

-- Get player's current money
local money = _G.GetPlayerMoney("PlayerName")
```

### 4. Shop Integration Example
Here's how to use it in a shop:

```lua
-- Shop purchase script example
local price = 100
local playerName = player.Name

-- Check if player has enough money
if _G.GetPlayerMoney(playerName) >= price then
    -- Take the money
    _G.AddPlayerMoney(playerName, -price)
    -- Give the item
    print("Purchase successful!")
else
    print("Not enough money!")
end
```

## Benefits Over Old System

1. **ONE script instead of FOUR** - Much easier to maintain
2. **Centralized money** - All players' money in one place
3. **Global API** - Easy to add/remove money from anywhere
4. **No duplicate stats** - Prevents multiple leaderboards
5. **Better performance** - Only one script running
6. **Easier debugging** - Check one place for issues

## Troubleshooting

### Stats not showing?
- Check Output for error messages
- Ensure at least one Settings module exists in a tycoon

### Money not updating?
- Check if PlayerMoney folder exists in ServerStorage
- Verify player name matches exactly

### Old scripts still running?
- Make sure ALL LinkedLeaderboard scripts are removed/disabled
- Check Output for duplicate script messages

## What Happens to Tycoons?
- Tycoons work exactly the same
- Just remove the LinkedLeaderboard scripts
- Keep everything else including Settings modules

## Advanced: Custom Settings
If you want different settings, edit the default settings in the script (lines 47-75) or ensure at least one Settings module exists in your tycoons.