# Complete Fix Guide for Tycoon and Leaderstats Issues

## Step 1: Disable Old Tycoon Kits
Run this in the Command Bar in Roblox Studio:
```lua
local oldKits = {"SpidermanTycoon", "Venom Tycoon", "Zednov's Tycoon Kit"}
for _, kitName in ipairs(oldKits) do
    local kit = workspace:FindFirstChild(kitName)
    if kit then
        for _, descendant in ipairs(kit:GetDescendants()) do
            if descendant:IsA("Script") or descendant:IsA("LocalScript") then
                descendant.Disabled = true
            end
        end
        kit.Parent = game.ServerStorage
        print("Disabled:", kitName)
    end
end
```

## Step 2: Fix Your Custom Tycoon Setup

### Required Workspace Structure:
```
ReplicatedStorage
├── TycoonTemplates (Folder)
│   └── Cinnamoroll (Your tycoon template model)
├── Modules (Folder)
│   ├── Tycoon (ModuleScript)
│   └── Button (ModuleScript)
└── JS GY Kitty 001 (Model for Hello Kitty statue)

Workspace
└── Plots (Folder with plot Models inside)
```

### Update TycoonService.lua:
Change line 9 from:
```lua
local TycoonTemplate = Workspace.Tycoons:WaitForChild("Cinnamoroll")
```
To:
```lua
local TycoonTemplate = ReplicatedStorage:WaitForChild("TycoonTemplates"):WaitForChild("Cinnamoroll")
```

### Update ThemeManager.lua:
Change lines 8-9 from:
```lua
local cinnamorollTemplate = Workspace.Tycoons:WaitForChild("Cinnamoroll")
local kittyModel = Workspace:WaitForChild("JS GY Kitty 001")
```
To:
```lua
local tycoonTemplates = ReplicatedStorage:WaitForChild("TycoonTemplates")
local cinnamorollTemplate = tycoonTemplates:WaitForChild("Cinnamoroll")
local kittyModel = ReplicatedStorage:WaitForChild("JS GY Kitty 001")
```

## Step 3: Use ONE Leaderstats Script

Delete/disable ALL other leaderstats scripts and use this simple one in ServerScriptService:

```lua
-- Leaderstats.lua
local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local cash = Instance.new("IntValue")
    cash.Name = "Cash"
    cash.Value = 0
    cash.Parent = leaderstats
end)
```

## Step 4: Money Shop Placement

- `MoneyShop.server.lua` → ServerScriptService
- `CreateMoneyShop.client.lua` → StarterPlayer/StarterPlayerScripts
- Remember to replace the product IDs!

## Summary of Issues Fixed:
1. ✅ Old tycoon kits disabled (stops the spam errors)
2. ✅ Fixed path to tycoon template (ReplicatedStorage instead of Workspace)
3. ✅ Single leaderstats script (instead of 4 conflicting ones)
4. ✅ Proper structure for custom tycoon system