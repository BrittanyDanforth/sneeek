--[[
	🔍 FIND CLAIM LOGIC 🔍
	Searches for where the tycoon claiming is handled
]]

print("🔍 Searching for claim logic...")

local foundScripts = {}

-- Search all tycoons
for _, obj in ipairs(workspace:GetDescendants()) do
	if obj:IsA("Script") then
		local source = obj.Source
		
		-- Look for claim-related keywords
		if source:find("Owner") and source:find("Value") and 
		   (source:find("Touched") or source:find("Touch") or source:find("claim") or source:find("Claim")) then
			print("📝 Found potential claim script:", obj:GetFullName())
			table.insert(foundScripts, obj)
		end
		
		-- Also check for gate/door scripts
		if (obj.Name:lower():find("gate") or obj.Name:lower():find("door") or 
		    obj.Name:lower():find("entrance") or obj.Name:lower():find("claim")) then
			print("📝 Found by name:", obj:GetFullName())
			if not table.find(foundScripts, obj) then
				table.insert(foundScripts, obj)
			end
		end
	end
	
	-- Check for ClickDetectors or proximity prompts
	if obj:IsA("ClickDetector") or obj:IsA("ProximityPrompt") then
		local parent = obj.Parent
		if parent and parent.Name:lower():find("claim") or parent.Name:lower():find("door") or 
		   parent.Name:lower():find("gate") then
			print("🖱️ Found interaction object:", obj:GetFullName())
		end
	end
end

-- Check Essentials for claim parts
print("\n🔍 Checking Essentials folders...")
for _, tycoon in ipairs(workspace:GetDescendants()) do
	if (tycoon.Name:find("tycoon") or tycoon.Name:find("Tycoon")) and tycoon:IsA("Model") then
		local essentials = tycoon:FindFirstChild("Essentials")
		if essentials then
			-- Look for claim-related parts
			for _, child in ipairs(essentials:GetChildren()) do
				if child.Name:lower():find("claim") or child.Name:lower():find("door") or 
				   child.Name:lower():find("gate") or child.Name:lower():find("entrance") then
					print("🚪 Found claim part in", tycoon.Name, ":", child.Name)
					
					-- Check for scripts inside
					for _, script in ipairs(child:GetDescendants()) do
						if script:IsA("Script") then
							print("   📜 Script inside:", script.Name)
						end
					end
				end
			end
		end
	end
end

print("\n📊 Found", #foundScripts, "potential claim scripts")
print("🔍 Search complete!")