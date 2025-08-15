--[[
	Cinnamoroll Tycoon Diagnostic
	Run this to see what's wrong with the Cinnamoroll tycoon
--]]

local function diagnoseCinnamoroll()
	print("\n🔍 CINNAMOROLL TYCOON DIAGNOSTIC")
	print("================================")
	
	-- Find Cinnamoroll tycoon
	local cinnamorollTycoon = nil
	local searchPaths = {
		"Workspace.Cinnamoroll tycoon.Tycoons.Cinnamoroll",
		"Workspace.CinnamorollTycoon.Tycoons.Cinnamoroll",
		"Workspace.Cinnamoroll tycoon.Cinnamoroll"
	}
	
	-- Try direct paths first
	for _, path in ipairs(searchPaths) do
		local success, result = pcall(function()
			local parts = string.split(path, ".")
			local current = game
			for _, part in ipairs(parts) do
				current = current:FindFirstChild(part)
				if not current then return nil end
			end
			return current
		end)
		
		if success and result then
			cinnamorollTycoon = result
			print("✅ Found at:", path)
			break
		end
	end
	
	-- If not found, search deeply
	if not cinnamorollTycoon then
		for _, descendant in ipairs(workspace:GetDescendants()) do
			if descendant.Name:lower():find("cinnamoroll") and 
			   descendant:FindFirstChild("Owner") and 
			   descendant:FindFirstChild("PurchasedObjects") then
				cinnamorollTycoon = descendant
				print("✅ Found at:", descendant:GetFullName())
				break
			end
		end
	end
	
	if not cinnamorollTycoon then
		print("❌ Could not find Cinnamoroll tycoon!")
		return
	end
	
	-- Check components
	print("\n📦 TYCOON COMPONENTS:")
	
	local components = {
		"Owner",
		"Buttons", 
		"PurchasedObjects",
		"Purchases",
		"CurrencyToCollect",
		"Essentials",
		"TeamColor",
		"PurchaseHandler",
		"TycoonReady"
	}
	
	for _, component in ipairs(components) do
		local found = cinnamorollTycoon:FindFirstChild(component, true)
		if found then
			print("  ✅", component, "->", found:GetFullName())
			
			-- Special checks
			if component == "Owner" and found:IsA("ObjectValue") then
				print("     Owner:", found.Value and found.Value.Name or "nil")
			elseif component == "PurchasedObjects" then
				print("     Objects:", #found:GetChildren())
				if #found:GetChildren() > 0 then
					print("     ⚠️ PRE-BUILT OBJECTS DETECTED:")
					for i, obj in ipairs(found:GetChildren()) do
						print("       -", obj.Name)
						if i >= 5 then
							print("       ... and", #found:GetChildren() - 5, "more")
							break
						end
					end
				end
			elseif component == "Purchases" then
				print("     Available objects:", #found:GetChildren())
			elseif component == "Buttons" then
				print("     Total buttons:", #found:GetChildren())
				
				-- Count visible vs hidden
				local visible = 0
				local hidden = 0
				for _, button in ipairs(found:GetChildren()) do
					local head = button:FindFirstChild("Head")
					if head and head.Transparency < 1 then
						visible = visible + 1
					else
						hidden = hidden + 1
					end
				end
				print("     Visible:", visible, "Hidden:", hidden)
			elseif component == "CurrencyToCollect" and found:IsA("NumberValue") then
				print("     Money:", found.Value)
			elseif component == "PurchaseHandler" and found:IsA("Script") then
				print("     Enabled:", not found.Disabled)
			end
		else
			print("  ❌", component, "- NOT FOUND")
		end
	end
	
	-- Check for duplicate purchase handlers
	print("\n🔍 CHECKING FOR DUPLICATE HANDLERS:")
	local handlers = {}
	for _, desc in ipairs(cinnamorollTycoon:GetDescendants()) do
		if desc:IsA("Script") and desc.Name:lower():find("purchase") then
			table.insert(handlers, desc)
		end
	end
	
	if #handlers > 1 then
		print("  ⚠️ MULTIPLE PURCHASE HANDLERS FOUND:")
		for _, handler in ipairs(handlers) do
			print("    -", handler:GetFullName(), "(Enabled:", not handler.Disabled, ")")
		end
	elseif #handlers == 1 then
		print("  ✅ Single handler:", handlers[1]:GetFullName())
	else
		print("  ❌ No purchase handlers found!")
	end
	
	print("\n================================")
	print("DIAGNOSTIC COMPLETE")
	
	-- Recommendations
	if cinnamorollTycoon:FindFirstChild("PurchasedObjects") and 
	   #cinnamorollTycoon.PurchasedObjects:GetChildren() > 0 then
		print("\n⚠️ RECOMMENDATION: Run CinnamorollTycoonFix to reset the pre-built objects!")
	end
end

-- Run diagnostic
diagnoseCinnamoroll()