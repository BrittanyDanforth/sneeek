# Script Placement Guide for Roblox Money Shop

## 📁 Explorer Structure

```
game
├── ServerScriptService
│   ├── Leaderstats.server.lua      ← Unified leaderstats (Cash, KOs, WOs)
│   ├── MoneyShop.server.lua        ← Handles Developer Product purchases
│   └── [Your other server scripts]
│
├── StarterPlayer
│   └── StarterPlayerScripts
│       └── CreateMoneyShop.client.lua  ← Creates the money shop GUI
│
├── Workspace
│   ├── [Your Dropper Model]
│   │   ├── Drop (Part)             ← Where money spawns from
│   │   └── Script                  ← Dropper.server.lua goes here
│   └── PartStorage (Folder)        ← Auto-created by dropper
│
└── ReplicatedStorage
    └── [Tools, modules, etc.]
```

## 🔧 Setup Instructions

### 1. **Leaderstats** (REQUIRED - Use only ONE)
- Delete all duplicate leaderstats scripts
- Place `Leaderstats.server.lua` in `ServerScriptService`
- This handles Cash, and optionally KOs/WOs

### 2. **Money Shop**
- Place `MoneyShop.server.lua` in `ServerScriptService`
- Place `CreateMoneyShop.client.lua` in `StarterPlayer/StarterPlayerScripts`
- **IMPORTANT**: Replace product IDs with your real ones from Creator Dashboard

### 3. **Dropper**
- Create a Model in Workspace for your dropper
- Add a Part named "Drop" inside the model (this is the spawn point)
- Place `Dropper.server.lua` as a Script child of the dropper model

## ⚠️ Important Notes

1. **Remove Duplicate Scripts**: You had 4 copies of the same leaderstats script. Use only the unified one provided.

2. **Product IDs**: The placeholder IDs (12345678, etc.) MUST be replaced with real Developer Product IDs:
   - Go to Creator Dashboard → Your Game → Monetization → Developer Products
   - Create products for each cash amount
   - Copy the product IDs and replace them in both server and client scripts

3. **Existing Tycoon Compatibility**: The provided leaderstats script works with your tycoon system since it creates the standard `leaderstats.Cash` IntValue.

## 🎮 How It Works

1. **Player Joins** → Leaderstats creates Cash value
2. **Dropper** → Spawns collectible money parts
3. **Player Touches Money** → Cash value increases
4. **Money Shop Button** → Opens purchase GUI
5. **Player Purchases** → Roblox handles payment → Server grants cash

## 🐛 Troubleshooting

- **"Unknown productId" warning**: You need to replace placeholder IDs
- **GUI not showing**: Check that client script is in StarterPlayerScripts
- **Dropper not working**: Ensure "Drop" part exists in dropper model
- **Cash not saving**: You'll need to add DataStore saving (not included)