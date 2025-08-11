-- Simple TeamColor Fix
-- This just adds TeamColor where it's missing

wait(0.5)

-- Fix 1: Add TeamColor to "Spiderman tycoon" model (for error at line 6)
local spidermanTycoon = workspace:FindFirstChild("SpidermanTycoon")
if spidermanTycoon then
	local innerModel = spidermanTycoon:FindFirstChild("Spiderman tycoon")
	if innerModel and not innerModel:FindFirstChild("TeamColor") then
		-- Get TeamColor from one of the actual tycoons
		local tycoons = innerModel:FindFirstChild("Tycoons")
		if tycoons then
			local firstTycoon = tycoons:FindFirstChildOfClass("Model")
			if firstTycoon and firstTycoon:FindFirstChild("TeamColor") then
				-- Copy the TeamColor structure
				local tc = Instance.new("BrickColorValue")
				tc.Name = "TeamColor"
				tc.Value = BrickColor.new("Medium stone grey")
				tc.Parent = innerModel
				print("Fixed: Added TeamColor to Spiderman tycoon model")
			end
		end
	end
end

-- Fix 2: Add TeamColor to PurchaseHandler (for error at line 33)
local purchaseHandler = workspace:FindFirstChild("Tycoons") and workspace.Tycoons:FindFirstChild("PurchaseHandler")
if purchaseHandler and not purchaseHandler:FindFirstChild("TeamColor") then
	local tc = Instance.new("BrickColorValue")
	tc.Name = "TeamColor"
	tc.Value = BrickColor.new("Medium stone grey")
	tc.Parent = purchaseHandler
	print("Fixed: Added TeamColor to PurchaseHandler")
end

-- Fix 3: There's also a Core_Handler in workspace looking for TeamColor
local coreHandler = workspace:FindFirstChild("Core_Handler")
if coreHandler then
	-- Core_Handler at line 33 is looking for TeamColor in script (PurchaseHandler)
	-- This is the script that's throwing the error
	print("Note: Core_Handler found in workspace - may need to be moved or edited")
end

print("TeamColor fixes applied!")