# FINAL Unified Leaderboard Setup

## Quick Setup (2 minutes)

### Step 1: Delete Old Scripts (OR Let the Script Do It!)
The new script will **automatically clean up** old LinkedLeaderboard scripts!

But if you want to manually check, they're located deep inside tycoon models:
- `Workspace > SpidermanTycoon > Spiderman tycoon > Tycoons > Cinnamoroll > LinkedLeaderboard`
- `Workspace > SpidermanTycoon > Spiderman tycoon > Tycoons > HelloKitty > LinkedLeaderboard`
- `Workspace > Venom Tycoon > [tycoon name] > Tycoons > [plot name] > LinkedLeaderboard`
- And any other LinkedLeaderboard scripts buried in tycoon plots

### Step 2: Install New Script
1. Copy all code from `FINAL_UnifiedLeaderboard.lua`
2. In Roblox Studio, right-click on **ServerScriptService**
3. Insert Object → Script
4. Name it "UnifiedLeaderboard" 
5. Paste the code
6. Done!

## What This Fixes

✅ **No more duplicate stats** - Only one script handling all players
✅ **No more errors** - Fixed the setupCurrencyTracking bug
✅ **Easier to manage** - ONE script instead of multiple buried in each tycoon plot
✅ **Auto-cleanup** - Automatically removes old LinkedLeaderboard scripts
✅ **Works with tycoon kits** - Handles scripts deep inside Tycoons > Plot folders
✅ **Better performance** - No duplicate processing
✅ **Works for ALL tycoons** - Cinnamoroll, HelloKitty, and any future tycoons

## How It Works

1. **Auto-cleanup** - Removes all old LinkedLeaderboard scripts on startup
2. **Smart Settings search** - Looks for Settings modules in tycoon kits
3. **Single source of truth** - One script manages ALL tycoon leaderboards
4. **No more buried scripts** - Everything runs from ServerScriptService
5. **Prevents duplicate stats** - Tracks which players already have stats
6. **Handles typos** - Works with both KillsName and KillsNames

## For Shops

Use these anywhere in your game:
```lua
-- Give player money
_G.AddPlayerMoney("PlayerName", 100)

-- Set player money
_G.SetPlayerMoney("PlayerName", 500)

-- Check player money
local money = _G.GetPlayerMoney("PlayerName")
```

## Troubleshooting

**Stats not showing?**
- Make sure you deleted ALL old LinkedLeaderboard scripts
- Check Output for any errors

**Money not working?**
- PlayerMoney folder is auto-created in ServerStorage
- Check if player name matches exactly

That's it! Much simpler than managing 4 separate scripts hidden deep in models!