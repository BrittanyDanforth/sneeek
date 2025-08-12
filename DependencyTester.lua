--[[
	Dependency System Tester
	Place this in ServerScriptService to debug dependency issues
--]]

local function checkTycoonDependencies()
	print("\n🔍 CHECKING TYCOON DEPENDENCIES...")
	
	-- Find all tycoons
	local tycoons = workspace:FindFirstChild("Cinnamoroll tycoon")
	if not tycoons then
		tycoons = workspace:FindFirstChild("Zednov's Tycoon Kit")
	end
	if not tycoons then
		warn("No tycoon kit found!")
		return
	end
	
	tycoons = tycoons:FindFirstChild("Tycoons")
	if not tycoons then
		warn("No Tycoons folder found!")
		return
	end
	
	-- Check each tycoon
	for _, tycoon in ipairs(tycoons:GetChildren()) do
		if tycoon:IsA("Model") then
			print("\n📦 Tycoon: " .. tycoon.Name)
			
			local buttons = tycoon:FindFirstChild("Buttons")
			local purchases = tycoon:FindFirstChild("Purchases")
			
			if buttons and purchases then
				print("  Checking button dependencies...")
				
				-- Map of button names to their object names
				local buttonToObject = {}
				
				for _, button in ipairs(buttons:GetChildren()) do
					local obj = button:FindFirstChild("Object")
					local dep = button:FindFirstChild("Dependency")
					
					if obj and obj.Value then
						buttonToObject[button.Name] = obj.Value
					end
					
					-- Check dependency
					if dep and dep.Value and dep.Value ~= "" then
						print("  ⚠️  " .. button.Name .. " depends on: " .. dep.Value)
						
						-- Check if dependency exists
						local depExists = false
						
						-- Check if it's a button name
						if buttons:FindFirstChild(dep.Value) then
							depExists = true
							print("      ✅ Found as button: " .. dep.Value)
						end
						
						-- Check if it's an object name
						if purchases:FindFirstChild(dep.Value) then
							depExists = true
							print("      ✅ Found as purchase object: " .. dep.Value)
						end
						
						-- Check if any button spawns this object
						for btnName, objName in pairs(buttonToObject) do
							if objName == dep.Value then
								depExists = true
								print("      ✅ Button '" .. btnName .. "' spawns: " .. dep.Value)
							end
						end
						
						if not depExists then
							warn("      ❌ DEPENDENCY NOT FOUND: " .. dep.Value)
							print("      This will cause infinite yield!")
						end
					end
				end
			end
		end
	end
	
	print("\n✅ Dependency check complete!")
end

-- Run the check
task.wait(5) -- Wait for game to load
checkTycoonDependencies()