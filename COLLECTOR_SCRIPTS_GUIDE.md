# Collector Scripts Guide

## What I Created For You:

### 1. **Collector_Debug.lua** - Debug version of your collector script
This replaces your original collector script to show detailed debug info:
- Shows exactly where the script is located
- Traces the parent hierarchy to find CurrencyToCollect
- Shows any errors clearly

**How to use:**
Replace your existing collector script (the one with `script.Parent.Text = "$"...`) with the content from `Collector_Debug.lua`

### 2. **Find_All_Collectors.lua** - Finds all collectors in your game
Run this in ServerScriptService to find all CollectorParts:
- Searches entire workspace
- Shows the path to each collector
- Checks if CurrencyToCollect exists

**How to use:**
Put this script in ServerScriptService and run it once to see all collectors

## Your Original Collector Script:
```lua
script.Parent.Text = "$"..script.Parent.Parent.Parent.Parent.Parent.Parent.CurrencyToCollect.Value

script.Parent.Parent.Parent.Parent.Parent.Parent.CurrencyToCollect.Changed:connect(function(money)
    script.Parent.Text = "$"..money
end)
```

## The Debug Version Will Show:
- Where exactly this script is running from
- If it can find CurrencyToCollect (6 parents up)
- What the current value is
- Any errors that occur

## To Apply These Scripts:
1. Open Roblox Studio
2. Find one of your collector scripts (inside CollectorParts)
3. Replace its content with the debug version
4. Run the game and check the Output window for debug info
5. Use Find_All_Collectors.lua to find all collectors in your game