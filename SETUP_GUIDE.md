# Cinnamoroll Tycoon - Multiplayer Setup Guide

## Overview
This system creates a fully functional multiplayer tycoon with proper dropper progression. Each player can claim their own tycoon, and the purchase system works independently for each tycoon.

## File Structure
```
ServerScriptService/
├── PurchaseHandler.lua (ModuleScript)

Workspace/
├── Tycoons/ (Folder)
│   ├── Tycoon1/ (Model)
│   │   ├── TycoonScript.lua (Script)
│   │   ├── ClaimPad (Part)
│   │   ├── Spawn (SpawnLocation)
│   │   ├── Collector (Part)
│   │   ├── PurchasedObjects/ (Folder)
│   │   │   ├── Buy Dropper - [$10,000] (Model)
│   │   │   ├── Buy Dropper - [$20,000] (Model)
│   │   │   ├── Buy MEGA Dropper - [$300] (Model)
│   │   │   └── ... (all other purchasable items)
│   │   └── Buttons/ (Folder)
│   │       ├── Buy Dropper - [$10,000] (Button Model with Head part)
│   │       ├── Buy Dropper - [$20,000] (Button Model with Head part)
│   │       └── ... (all purchase buttons)
│   ├── Tycoon2/ (Copy of Tycoon1)
│   ├── Tycoon3/ (Copy of Tycoon1)
│   └── Tycoon4/ (Copy of Tycoon1)
```

## Setup Instructions

### 1. Install the PurchaseHandler
1. Create a ModuleScript in ServerScriptService
2. Name it "PurchaseHandler"
3. Paste the PurchaseHandler.lua code into it

### 2. Set Up Each Tycoon
1. Create your tycoon model structure with:
   - ClaimPad (Part) - Where players step to claim
   - Spawn (SpawnLocation) - Where players respawn
   - Collector (Part) - Collects money drops
   - PurchasedObjects (Folder) - Stores unpurchased items
   - All purchase buttons as models with "Head" parts

2. Add the TycoonScript:
   - Create a Script inside each tycoon model
   - Paste the TycoonScript.lua code
   - Update the PurchaseHandler require path if needed

### 3. Button Setup
Each button must:
- Be a Model with a part named "Head"
- Have a name matching the pattern in PURCHASE_DATA
- Be positioned where you want it in the tycoon

### 4. Purchased Objects Setup
In the PurchasedObjects folder:
- Add models for each purchasable item
- Name them exactly as they appear in PURCHASE_DATA
- For droppers, include a part named "Drop" or "DropPart"

## How It Works

### Claiming a Tycoon
1. Player touches the ClaimPad
2. System checks if they already own a tycoon
3. If not, assigns them as owner and initializes PurchaseHandler
4. Creates team and sets spawn location

### Purchase Flow
1. Player's money is tracked via leaderstats
2. Buttons show/hide based on prerequisites and money
3. Green = affordable, Red = too expensive
4. Clicking a button purchases and spawns the item
5. New buttons appear based on progression tree

### Multiplayer Safety
- Each tycoon has its own PurchaseHandler instance
- Owner verification on all purchases
- Proper cleanup when players leave
- No cross-tycoon interference

## Testing
1. Start with 2+ players
2. Have each claim a different tycoon
3. Verify buttons work independently
4. Test progression from basic → MEGA → Super droppers
5. Verify money collection and spending

## Customization

### Adding New Items
1. Add entry to PURCHASE_DATA in PurchaseHandler
2. Create the button model
3. Create the purchasable object model
4. Set requires/unlocks in progression tree

### Changing Starting Money
In TycoonScript.lua, find:
```lua
money.Value = 50000 -- Starting money
```

### Modifying Drop Values
In PurchaseHandler.lua, SetupDropper function:
```lua
if dropper.Name:match("MEGA") then
    baseValue = 100  -- Change this
    dropRate = 2     -- Change this
```

## Troubleshooting

### Buttons Not Showing
- Check button has "Head" part
- Verify name matches PURCHASE_DATA exactly
- Check prerequisites in progression tree

### Items Not Spawning
- Ensure item exists in PurchasedObjects folder
- Check name matching between button and object
- Look for warnings in output

### Money Not Working
- Verify leaderstats folder exists
- Check Money or Cash IntValue
- Ensure collector is touching money drops