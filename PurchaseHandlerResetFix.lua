-- Add this improved resetTycoonPurchases function to your purchase handler
-- Replace the existing resetTycoonPurchases function with this:

local function resetTycoonPurchases()
	print("🔄 RESETTING PURCHASE HANDLER...")

	-- Clear purchased items tracking
	purchasedItems = {}

	-- FIRST: Destroy all existing cash parts that might be falling or waiting to be collected
	local destroyedParts = 0
	for _, descendant in pairs(workspace:GetDescendants()) do
		-- Check if it's a cash part from this tycoon
		if descendant:FindFirstChild("Cash") then
			-- Make sure it belongs to this tycoon (check if it's a descendant or near the tycoon)
			local isFromThisTycoon = false
			
			-- Method 1: Check if it's a descendant of the tycoon
			if descendant:IsDescendantOf(script.Parent) then
				isFromThisTycoon = true
			else
				-- Method 2: Check if it's near the tycoon (for parts that have fallen)
				if descendant:IsA("BasePart") then
					local distance = (descendant.Position - script.Parent:GetPivot().Position).Magnitude
					if distance < 100 then -- Within 100 studs of tycoon
						isFromThisTycoon = true
					end
				end
			end
			
			if isFromThisTycoon then
				descendant:Destroy()
				destroyedParts = destroyedParts + 1
			end
		end
	end
	print("  ✓ Destroyed", destroyedParts, "cash parts")

	-- Reset money to 0 AFTER destroying parts
	Money.Value = 0
	print("  ✓ Reset money to 0")

	-- Destroy all purchased objects
	local objectCount = #purchasedObjects:GetChildren()
	for _, obj in pairs(purchasedObjects:GetChildren()) do
		obj:Destroy()
	end
	print("  ✓ Destroyed", objectCount, "purchased objects")

	-- Reset all buttons to original state
	for _, button in pairs(buttons:GetChildren()) do
		local head = button:FindFirstChild("Head")
		if head and originalButtonStates[button.Name] then
			local originalState = originalButtonStates[button.Name]

			-- Remove hover detector if exists
			local hoverDetector = button:FindFirstChild("HoverDetector")
			if hoverDetector then
				hoverDetector:Destroy()
			end

			-- Check for dependency
			local dependency = button:FindFirstChild("Dependency")
			if dependency and dependency.Value and dependency.Value ~= "" then
				-- Dependent button - hide it
				head.CanCollide = false
				head.Transparency = 1
			else
				-- Base button - restore to original
				head.CanCollide = originalState.CanCollide
				head.Transparency = originalState.Transparency
				head.BrickColor = BrickColor.new("Really red")
				head.CFrame = originalState.CFrame
			end
		end
	end

	-- Reset money collector color
	local giver = essentials:FindFirstChild("Giver")
	if giver then
		giver.BrickColor = BrickColor.new("Bright green")
	end

	-- Clear any BuyObject entries
	local buyObject = script.Parent:FindFirstChild("BuyObject")
	if buyObject then
		for _, child in pairs(buyObject:GetChildren()) do
			child:Destroy()
		end
	end

	-- Reset steal protection
	CanSteal = true
	
	-- Clear the collectedParts table
	collectedParts = {}

	print("✅ Purchase handler fully reset!")
end