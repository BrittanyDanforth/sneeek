--[[
	DELETE BAD SETTINGS SCRIPT
	Run this ONCE in ServerScriptService to remove the problematic Settings module
	Then delete this script
]]

local badSettings = game.ServerScriptService:FindFirstChild("Settings")
if badSettings then
	print("🗑️ Found problematic Settings module in ServerScriptService")
	print("   Path: " .. badSettings:GetFullName())
	badSettings:Destroy()
	print("✅ Deleted the problematic Settings module!")
	print("💡 Your tycoons still have their own Settings modules - those are fine!")
else
	print("✅ No Settings module found in ServerScriptService - all good!")
end

print("\n📋 Your tycoon Settings are at:")
print("   - Workspace.SpidermanTycoon.Spiderman tycoon.Settings")
print("   - Workspace.Cinnamoroll tycoon.Settings") 
print("   - Workspace.Venom Tycoon.Zednov's Tycoon Kit [OPEN!].Settings")
print("   - Workspace.Zednov's Tycoon Kit.Settings")
print("\n⚠️ You can now delete this DeleteBadSettings script!")