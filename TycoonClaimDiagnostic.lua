--[[
	TYCOON CLAIM DIAGNOSTIC
	Put this in ServerScriptService to diagnose claim issues
]]

print("="..string.rep("=", 50))
print("🔍 TYCOON CLAIM DIAGNOSTIC STARTING")
print("="..string.rep("=", 50))

-- Check all tycoons
local tycoonCount = 0
local claimParts = {}

-- Search for tycoons
for _, obj in ipairs(workspace:GetDescendants()) do
	-- Look for claim parts/doors
	if obj:IsA("BasePart") and (obj.Name:lower():find("claim") or obj.Name:lower():find("owner") or obj.Name == "Head") then
		local parent = obj.Parent
		
		-- Check if this is part of a tycoon
		local tycoon = obj:FindFirstAncestor("Tycoons") or obj:FindFirstAncestor("tycoon") or obj:FindFirstAncestor("Tycoon")
		if tycoon then
			print(string.format("\n📍 Found potential claim part: %s", obj:GetFullName()))
			print(string.format("   Name: %s", obj.Name))
			print(string.format("   CanCollide: %s", tostring(obj.CanCollide)))
			print(string.format("   CanTouch: %s", tostring(obj.CanTouch)))
			print(string.format("   CanQuery: %s", tostring(obj.CanQuery)))
			print(string.format("   Transparency: %s", tostring(obj.Transparency)))
			
			-- Check for touch connections
			local connections = obj:GetPropertyChangedSignal("Parent"):GetConnections()
			print(string.format("   Has connections: %s", #connections > 0 and "Yes" or "No"))
			
			-- Check for scripts
			local scripts = {}
			for _, child in ipairs(obj:GetDescendants()) do
				if child:IsA("Script") then
					table.insert(scripts, child)
				end
			end
			
			-- Check parent for scripts
			for _, child in ipairs(obj.Parent:GetChildren()) do
				if child:IsA("Script") then
					table.insert(scripts, child)
				end
			end
			
			print(string.format("   Related scripts: %d", #scripts))
			for _, script in ipairs(scripts) do
				print(string.format("     - %s (Enabled: %s)", script.Name, tostring(not script.Disabled)))
			end
			
			-- Check for Owner value
			local ownerValue = nil
			local searchParent = obj.Parent
			while searchParent and not ownerValue do
				ownerValue = searchParent:FindFirstChild("Owner") or searchParent:FindFirstChild("OwnerValue")
				if not ownerValue then
					searchParent = searchParent.Parent
				end
			end
			
			if ownerValue then
				print(string.format("   Owner value found at: %s", ownerValue:GetFullName()))
				print(string.format("   Current owner: %s", tostring(ownerValue.Value)))
			else
				print("   ⚠️ No Owner value found!")
			end
			
			table.insert(claimParts, {
				part = obj,
				tycoon = tycoon,
				ownerValue = ownerValue
			})
		end
	end
end

print(string.format("\n📊 Found %d potential claim parts", #claimParts))

-- Check tycoon structure
print("\n🏭 Checking tycoon structures:")
for _, container in ipairs(workspace:GetChildren()) do
	if container.Name:lower():find("tycoon") or container.Name:lower():find("kit") then
		local tycoons = container:FindFirstChild("Tycoons")
		if tycoons then
			for _, tycoon in ipairs(tycoons:GetChildren()) do
				tycoonCount = tycoonCount + 1
				print(string.format("\n🏭 Tycoon: %s", tycoon.Name))
				
				-- Check for essential components
				local components = {
					"Owner", "OwnerValue", "PurchaseHandler", "Essentials", 
					"Gate", "ClaimDoor", "Entrance", "Touch", "Claim"
				}
				
				for _, comp in ipairs(components) do
					local found = tycoon:FindFirstChild(comp, true)
					if found then
						print(string.format("   ✅ Has %s at: %s", comp, found:GetFullName()))
					end
				end
				
				-- Check Essentials
				local essentials = tycoon:FindFirstChild("Essentials")
				if essentials then
					print("   📦 Essentials contents:")
					for _, child in ipairs(essentials:GetChildren()) do
						print(string.format("      - %s (%s)", child.Name, child.ClassName))
					end
				end
				
				-- Check entrance/gate
				local entrance = tycoon:FindFirstChild("Entrance") or tycoon:FindFirstChild("Gate")
				if entrance then
					print(string.format("   🚪 Entrance/Gate found: %s", entrance.Name))
					for _, child in ipairs(entrance:GetChildren()) do
						if child:IsA("BasePart") then
							print(string.format("      Part: %s (CanCollide: %s, Transparency: %s)", 
								child.Name, tostring(child.CanCollide), tostring(child.Transparency)))
						elseif child:IsA("Script") then
							print(string.format("      Script: %s (Disabled: %s)", child.Name, tostring(child.Disabled)))
						end
					end
				end
			end
		end
	end
end

print(string.format("\n📊 Total tycoons found: %d", tycoonCount))

-- Monitor touch events
print("\n👆 Setting up touch monitoring...")

for _, claimData in ipairs(claimParts) do
	local part = claimData.part
	local ownerValue = claimData.ownerValue
	
	part.Touched:Connect(function(hit)
		local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		if humanoid then
			local player = game.Players:GetPlayerFromCharacter(hit.Parent)
			if player then
				print(string.format("\n🚶 TOUCH DETECTED on %s by %s", part.Name, player.Name))
				print(string.format("   Part: %s", part:GetFullName()))
				if ownerValue then
					print(string.format("   Current owner: %s", tostring(ownerValue.Value)))
				end
				print("   ⚠️ If nothing happens after this, the claim script might be broken!")
			end
		end
	end)
end

print("\n✅ Diagnostic complete! Try touching a tycoon door/claim part now.")