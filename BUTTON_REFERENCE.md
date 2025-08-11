# Button Number Reference Guide

## How It Works
Your tycoon kit uses numbered buttons (1, 2, 3, etc.) in the Buttons folder. The progression system uses these numbers to track what's been purchased and what should be shown next.

## Button Number → Item Name Mapping

```
Button 1  = Buy Dropper - [$10,000] (Starting dropper)
Button 2  = Buy Dropper - [$20,000]
Button 3  = Buy Dropper - [$12,000]
Button 4  = Buy Dropper - [$70]
Button 5  = Buy Extra - [$35,000]
Button 7  = Buy Floor - [$1,500]
Button 8  = Buy Conveyer - [$8,000]
Button 9  = Buy CORE Dropper - [$5,000]
Button 10 = Buy POWER CORE Dropper - [$2,000]
Button 11 = Buy MEGA Dropper - [$300] ⭐ KEY UNLOCK POINT
Button 12 = Buy Super Dropper - [$1,000]
Button 13 = Buy a Mega Dropper - [$7,000]
Button 14 = Buy a Omega Dropper - [$15,000]
Button 15 = Buy a Omega Dropper - [$9,000]
Button 16 = Buy Path - [$10,000]
Button 17 = Buy Path - [$10,000] (second one)
Button 18 = Buy Path - [$250]
Button 19 = Buy Walls - [$100]
Button 20 = Buy Stair - [$2500]
Button 21 = Upgrade Walls - [$1,000]
Button 25 = Upgrade Walls - [$12,000]
Button 26 = Upgrade Walls - [$20,000]
Button 27 = Upgrade Walls - [$28,000]
Button 30 = Upgrade Wall - [$35,000]
Button 31 = Upgrade Walls - [$350]
Button 32 = Upgrade Wall - [$45,000]
Button 35 = Upgrade Walls - [$7,000]
Button 38 = Upgrade Walls - [$700]
Button 39 = Upgrade Roof - [$40,000]
Button 40 = Buy an OwnerDoor - [$1,500]
```

## Key Progression Points

### Starting Point
- Only Button 1 is visible at start

### After MEGA Dropper (Button 11)
When you buy MEGA Dropper, these become available:
- Button 12 (Super Dropper)
- Button 19 (Walls - if you also have Button 18)
- Button 13 (Mega Dropper $7k)

### Important Requirements
- Walls (Button 19) requires BOTH:
  - Button 18 (Path $250)
  - Button 11 (MEGA Dropper $300)

## Setup Instructions

1. Make sure your buttons in the Buttons folder are named with just numbers (1, 2, 3, etc.)
2. Replace your PurchaseHandler script with the new one
3. The system will automatically hide/show buttons based on progression

## Testing Path
1. Start game → Only Button 1 visible
2. Buy Button 1 → Buttons 2 and 8 appear
3. Buy Button 2 → Buttons 3 and 4 appear
4. Buy Button 3 → Buttons 5 and 16 appear
5. Buy Button 5 → Button 11 (MEGA) appears
6. Buy Button 11 → Buttons 12, 13 appear (and 19 if you have 18)

The key fix is that MEGA Dropper now properly unlocks the next tier of items!