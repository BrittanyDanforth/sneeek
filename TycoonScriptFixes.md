# Tycoon Script Fixes Guide

## Error 1: "Settings is not a valid member of DataModel 'Game'"

This happens in `PurchaseHandler` at line 7. The script is trying to access Settings incorrectly.

### Find this line in PurchaseHandler:
```lua
local Settings = require(game.Settings) -- WRONG!
```

### Replace with:
```lua
-- Option 1: Use global Settings
local Settings = _G.Settings or require(script.Parent.Parent:FindFirstChild("Settings") or script.Parent:FindFirstChild("Settings"))

-- Option 2: Search for Settings module
local Settings
local settingsModule = script.Parent.Parent:FindFirstChild("Settings", true)
if settingsModule and settingsModule:IsA("ModuleScript") then
    Settings = require(settingsModule)
else
    -- Use default settings
    Settings = {
        Sounds = {
            Purchase = 203785492,
            Collect = 131886985,
            ErrorBuy = 138090596
        },
        -- Add other default settings as needed
    }
end
```

## Error 2: "TeamColor is not a valid member of Script"

This happens in `Core_Handler` at line 33. The script is looking for TeamColor in the wrong place.

### Find this line in Core_Handler:
```lua
local TeamColor = script.TeamColor.Value -- WRONG!
```

### Replace with:
```lua
-- Option 1: Look in parent
local TeamColor = script.Parent:FindFirstChild("TeamColor")
if TeamColor then
    TeamColor = TeamColor.Value
else
    -- Default team color
    TeamColor = BrickColor.new("Medium stone grey")
end

-- Option 2: Look in tycoon model
local tycoon = script.Parent.Parent -- Adjust based on hierarchy
local TeamColor = tycoon:FindFirstChild("TeamColor")
if TeamColor then
    TeamColor = TeamColor.Value
else
    TeamColor = BrickColor.new("Medium stone grey")
end
```

## Quick Solution:

1. Add `QuickFixPatch.server.lua` to ServerScriptService
2. This will automatically:
   - Create global Settings
   - Fix missing TeamColor values
   - Provide fallbacks for common errors

## Permanent Solution:

Edit the actual scripts (`PurchaseHandler` and `Core_Handler`) with the fixes above.

## Common Script Locations:

- **PurchaseHandler**: Usually in `Workspace.Tycoons.PurchaseHandler`
- **Core_Handler**: Usually in `Workspace.Core_Handler`
- **Settings Module**: Should be in tycoon kit folder or ServerScriptService

## Testing:

After applying fixes, check for:
1. No more red errors in output
2. Tycoon buttons work properly
3. Money collection works
4. Settings are loaded correctly