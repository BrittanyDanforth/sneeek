# Tycoon Purchase System Integration

Files added:
- PurchaseHandler.client.lua (place in StarterPlayerScripts)
- PurchaseServer.server.lua (place in ServerScriptService)

Setup steps in Roblox Studio:
1. Create a Folder `RemoteEvents` in `ReplicatedStorage` (script also creates it if missing).
2. Put `PurchaseServer.server.lua` under `ServerScriptService`.
3. Put `PurchaseHandler.client.lua` under `StarterPlayerScripts`.
4. In each tycoon Model (under `Workspace.Tycoons`), set one of:
   - Attribute `OwnerUserId` (number), or
   - ObjectValue `Owner` pointing to the owning Player.
5. Ensure a `Buttons` folder exists inside the tycoon containing button Models/Parts. For each button:
   - Set number `Cost` (Attribute or NumberValue/IntValue child). `Price` also supported.
   - Optional dependencies:
     - Attribute/StringValue/ObjectValue named `DependsOn` (single) or a Folder `DependsOn` with ObjectValues to prerequisite buttons.
   - Optional `Product` (ObjectValue to a model/part to enable/reveal on purchase).
   - Optional Attribute `Id` to provide a stable ID. Otherwise, path-based ID is used.
6. Currency: add `leaderstats` with one of `Cash`, `Coins`, `Money`, or `Gold` (IntValue/NumberValue).

Behavior:
- Shows a small set of next buttons, prioritizing affordable ones.
- After purchase (e.g., Mega Dropper), all dependent buttons (e.g., Super Dropper, Walls) become eligible; up to two are shown next.
- `fixButtonPosition` auto-corrects floating/underground buttons on startup.

Tuning:
- In `PurchaseHandler.client.lua`: `MAX_VISIBLE_PER_CHAIN`, `AFFORDABLE_FIRST`, `UPDATE_UI_INTERVAL`.

Troubleshooting:
- If buttons don’t appear, verify `Cost` and dependencies, and that your tycoon is detected (Owner set).
- Server always validates cost and dependencies; client only handles UI/visibility.