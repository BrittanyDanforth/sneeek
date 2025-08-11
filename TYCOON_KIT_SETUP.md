# Tycoon Kit - PurchaseHandler Setup

## Quick Setup Instructions

Your tycoon kit already has Core_Handler and Settings modules working. You just need to replace/update the PurchaseHandler script in each tycoon.

### File Structure
```
GameEssentials/
├── Core_Handler (Script) ✓ Already working
├── Settings (ModuleScript) ✓ Already working
└── Tycoons/
    └── Cinnamoroll/ (or your tycoon name)
        ├── Owner (ObjectValue)
        ├── TeamColor (BrickColorValue)
        ├── PurchaseHandler (Script) ← REPLACE THIS
        ├── Buttons/ (Folder)
        │   ├── Buy Dropper - [$10,000] (Model with Head part)
        │   ├── Buy MEGA Dropper - [$300] (Model with Head part)
        │   └── ... (all buttons)
        └── Purchases/ (Folder)
            ├── Buy Dropper - [$10,000] (Model)
            ├── Buy MEGA Dropper - [$300] (Model)
            └── ... (all purchasable objects)
```

### Installation Steps

1. **Replace the PurchaseHandler Script**:
   - Delete or disable the existing PurchaseHandler script
   - Create a new Script named "PurchaseHandler" 
   - Paste the code from `PurchaseHandler_TycoonKit.lua`
   - Make sure it's NOT disabled

2. **Verify Structure**:
   - Each button must be in the "Buttons" folder
   - Each purchasable object must be in the "Purchases" folder
   - Button names must match object names exactly

3. **That's it!** The new PurchaseHandler will:
   - Work with your existing Core_Handler
   - Use your Settings module for sounds and currency
   - Handle the proper dropper progression
   - Show/hide buttons based on prerequisites
   - Color buttons green (affordable) or red (too expensive)

### How It Works

1. When MEGA Dropper ($300) is purchased:
   - Super Dropper ($1,000) becomes available
   - Walls ($100) becomes available (if Path $250 is also owned)
   - Mega Dropper ($7,000) becomes available

2. Button visibility is automatic:
   - Hidden = Prerequisites not met
   - Red = Can't afford
   - Green = Can afford

3. Fully multiplayer compatible:
   - Each tycoon instance works independently
   - Resets properly when players leave
   - No interference between tycoons

### Testing

1. Start the game
2. Claim a tycoon
3. Buy: Dropper $10k → Dropper $20k → Dropper $12k → Extra $35k → MEGA $300
4. Verify Super Dropper and other buttons appear after MEGA purchase

The system now properly follows the progression tree!