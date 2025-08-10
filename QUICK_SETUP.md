# Quick Setup - Unified Leaderboard

## Step 1: Place Both Scripts in ServerScriptService

1. Open Roblox Studio
2. In the Explorer window, find **ServerScriptService**
3. Right-click on ServerScriptService → Insert Object → Script
4. Name this script **"UnifiedLeaderboard"**
5. Copy all the code from `UnifiedLeaderboard.lua` and paste it into this script

6. Right-click on ServerScriptService again → Insert Object → ModuleScript  
7. Name this ModuleScript **"Settings"**
8. Copy all the code from `Settings.lua` and paste it into this ModuleScript

Your Explorer should now look like this:
```
ServerScriptService
├── UnifiedLeaderboard (Script)
└── Settings (ModuleScript)
```

## Step 2: Update Line 5 in UnifiedLeaderboard

Since both scripts are now in ServerScriptService, update line 5 in UnifiedLeaderboard from:
```lua
local Settings = require(script.Parent.Settings)
```
to:
```lua
local Settings = require(game.ServerScriptService.Settings)
```

## Step 3: Test It!

1. Hit Play to test
2. Check the Output window - you should see:
   - "Unified Leaderboard Script loaded successfully!"
   - Mode: Regular (or CTF if you have FlagStands)
   - Status of enabled features

That's it! The leaderboard should now be working in your game.