--[[
	Tycoon Reset Fix
	This script ensures tycoons start fresh and aren't pre-built
	Place this in ServerScriptService
--]]

local function resetTycoon(tycoonModel)
	print("🔧 Resetting tycoon:", tycoonModel.Name)
	
	-- Find the PurchasedObjects folder
	local purchasedObjects = tycoonModel:FindFirstChild("PurchasedObjects")
	if purchasedObjects then
		-- Clear all existing objects
		for _, obj in pairs(purchasedObjects:GetChildren()) do
			obj:Destroy()
		end
		print("  ✓ Cleared", #purchasedObjects:GetChildren(), "pre-existing objects")
	end
	
	-- Reset the owner
	local owner = tycoonModel:FindFirstChild("Owner")
	if owner and owner:IsA("ObjectValue") then
		owner.Value = nil
		print("  ✓ Cleared owner")
	end
	
	-- Reset the money
	local money = tycoonModel:FindFirstChild("CurrencyToCollect")
	if money and money:IsA("NumberValue") then
		money.Value = 0
		print("  ✓ Reset money to 0")
	end
	
	-- Reset all buttons to initial state
	local buttons = tycoonModel:FindFirstChild("Buttons")
	if buttons then
		for _, button in pairs(buttons:GetChildren()) do
			local head = button:FindFirstChild("Head")
			if head then
				-- Check if button has dependency
				local dependency = button:FindFirstChild("Dependency")
				if dependency and dependency.Value and dependency.Value ~= "" then
					-- Hide dependent buttons
					head.Transparency = 1
					head.CanCollide = false
				else
					-- Show base buttons
					head.Transparency = 0
					head.CanCollide = true
					head.BrickColor = BrickColor.new("Really red")
				end
			end
		end
		print("  ✓ Reset", #buttons:GetChildren(), "buttons")
	end
	
	-- Fire TycoonReady signal after reset
	local tycoonReady = tycoonModel:FindFirstChild("TycoonReady")
	if tycoonReady and tycoonReady:IsA("BindableEvent") then
		task.wait(0.1) -- Let physics settle
		tycoonReady:Fire()
		print("  ✓ Fired TycoonReady signal")
	end
end

-- Find and reset all tycoons on server start
local function resetAllTycoons()
	print("🔄 Starting tycoon reset process...")
	
	-- Common tycoon locations
	local tycoonLocations = {
		workspace:FindFirstChild("Tycoons"),
		workspace:FindFirstChild("SpidermanTycoon"),
		workspace:FindFirstChild("Venom Tycoon"),
		workspace:FindFirstChild("Zednov's Tycoon Kit"),
		workspace:FindFirstChild("Cinnamoroll tycoon")
	}
	
	local tycoonsReset = 0
	
	for _, location in pairs(tycoonLocations) do
		if location then
			-- Search for tycoon models
			for _, descendant in pairs(location:GetDescendants()) do
				if descendant:FindFirstChild("Owner") and 
				   descendant:FindFirstChild("Buttons") and 
				   descendant:FindFirstChild("PurchasedObjects") then
					resetTycoon(descendant)
					tycoonsReset = tycoonsReset + 1
				end
			end
		end
	end
	
	print("✅ Reset", tycoonsReset, "tycoons successfully!")
end

-- Reset all tycoons when server starts
resetAllTycoons()

-- Also reset when a player claims a tycoon
game.Players.PlayerAdded:Connect(function(player)
	-- Wait a bit for them to claim a tycoon
	task.wait(2)
	
	-- Find their tycoon
	for _, location in pairs(workspace:GetDescendants()) do
		if location:FindFirstChild("Owner") and location.Owner:IsA("ObjectValue") then
			if location.Owner.Value == player then
				-- Make sure it's reset properly
				local purchasedObjects = location:FindFirstChild("PurchasedObjects")
				if purchasedObjects and #purchasedObjects:GetChildren() > 0 then
					print("⚠️ Player", player.Name, "claimed pre-built tycoon - resetting!")
					resetTycoon(location)
				end
			end
		end
	end
end)