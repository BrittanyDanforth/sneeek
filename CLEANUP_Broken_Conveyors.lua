-- CLEANUP SCRIPT - Fix broken conveyors
-- Run this in ServerScriptService to fix the conveyors

local function findAndFixConveyors()
	print("=== SEARCHING FOR BROKEN CONVEYORS ===")
	
	local conveyorsFixed = 0
	local scriptsRemoved = 0
	
	-- Search through workspace
	for _, obj in pairs(workspace:GetDescendants()) do
		-- Look for conveyor parts
		if obj:IsA("BasePart") and (obj.Name == "Conv" or obj.Name:lower():find("conveyor") or obj.Name:lower():find("conveyer")) then
			-- Re-anchor any unanchored conveyors
			if not obj.Anchored then
				obj.Anchored = true
				conveyorsFixed = conveyorsFixed + 1
				print("✓ Re-anchored conveyor:", obj:GetFullName())
				
				-- Remove any velocity
				if obj.AssemblyLinearVelocity then
					obj.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				end
				if obj.Velocity then
					obj.Velocity = Vector3.new(0, 0, 0)
				end
				
				-- Remove BodyVelocity if it exists
				local bodyVel = obj:FindFirstChild("BodyVelocity")
				if bodyVel then
					bodyVel:Destroy()
				end
			end
			
			-- Find and remove the broken debug scripts
			local scriptsToRemove = {}
			for _, child in pairs(obj:GetChildren()) do
				if child:IsA("Script") and child.Name == "ConveyorScript" then
					-- Check if it's one of the broken debug scripts
					local source = child.Source or ""
					if source:find("CONVEYOR_1") or source:find("CONVEYOR_2") or source:find("CONVEYOR_3") then
						table.insert(scriptsToRemove, child)
					end
				end
			end
			
			-- Remove the scripts
			for _, script in pairs(scriptsToRemove) do
				script:Destroy()
				scriptsRemoved = scriptsRemoved + 1
				print("✗ Removed broken debug script from:", obj:GetFullName())
			end
		end
	end
	
	print("=== CLEANUP COMPLETE ===")
	print("Conveyors re-anchored:", conveyorsFixed)
	print("Broken scripts removed:", scriptsRemoved)
	print("")
	print("Now you can add the FIXED conveyor scripts to your conveyor parts!")
end

-- Run the cleanup
findAndFixConveyors()

-- This script will self-destruct after running
script:Destroy()