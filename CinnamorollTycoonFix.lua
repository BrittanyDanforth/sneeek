--[[
	Cinnamoroll Tycoon Fix
	Ensures the Cinnamoroll tycoon starts fresh and works with the new purchase handler
	Place this in ServerScriptService
--]]

local function fixCinnamorollTycoon()
	print("🎀 Looking for Cinnamoroll tycoon...")
	
	-- Find the Cinnamoroll tycoon
	local cinnamorollTycoon = nil
	
	-- Search in common locations
	local searchLocations = {
		workspace:FindFirstChild("Cinnamoroll tycoon"),
		workspace:FindFirstChild("CinnamorollTycoon"),
		workspace
	}
	
	for _, location in ipairs(searchLocations) do
		if location then
			-- Deep search for the tycoon
			for _, descendant in ipairs(location:GetDescendants()) do
				if descendant.Name == "Cinnamoroll" or descendant.Name:lower():find("cinnamoroll") then
					if descendant:FindFirstChild("Owner") and 
					   descendant:FindFirstChild("Buttons") and 
					   descendant:FindFirstChild("PurchasedObjects") then
						cinnamorollTycoon = descendant
						print("✅ Found Cinnamoroll tycoon at:", descendant:GetFullName())
						break
					end
				end
			end
		end
		if cinnamorollTycoon then break end
	end
	
	if not cinnamorollTycoon then
		warn("❌ Could not find Cinnamoroll tycoon!")
		return
	end
	
	-- Clear any pre-built objects
	local purchasedObjects = cinnamorollTycoon:FindFirstChild("PurchasedObjects")
	if purchasedObjects then
		local objectCount = #purchasedObjects:GetChildren()
		if objectCount > 0 then
			print("🧹 Clearing", objectCount, "pre-built objects...")
			for _, obj in pairs(purchasedObjects:GetChildren()) do
				obj:Destroy()
			end
		end
	end
	
	-- Reset money
	local money = cinnamorollTycoon:FindFirstChild("CurrencyToCollect")
	if money and money:IsA("NumberValue") then
		money.Value = 0
		print("💰 Reset money to 0")
	end
	
	-- Reset owner
	local owner = cinnamorollTycoon:FindFirstChild("Owner")
	if owner and owner:IsA("ObjectValue") then
		owner.Value = nil
		print("👤 Cleared owner")
	end
	
	-- Reset all buttons
	local buttons = cinnamorollTycoon:FindFirstChild("Buttons")
	if buttons then
		print("🔘 Resetting", #buttons:GetChildren(), "buttons...")
		
		for _, button in pairs(buttons:GetChildren()) do
			local head = button:FindFirstChild("Head")
			if head then
				-- Get dependency info
				local dependency = button:FindFirstChild("Dependency")
				
				if dependency and dependency.Value and dependency.Value ~= "" then
					-- This is a dependent button - hide it
					head.Transparency = 1
					head.CanCollide = false
					print("  ⏸️ Hidden button:", button.Name, "(waits for", dependency.Value, ")")
				else
					-- This is a base button - make it visible
					head.Transparency = 0
					head.CanCollide = true
					head.BrickColor = BrickColor.new("Really red")
					print("  ✅ Enabled button:", button.Name)
				end
			end
		end
	end
	
	-- Check if the purchase handler exists
	local purchaseHandler = cinnamorollTycoon:FindFirstChild("PurchaseHandler", true)
	if purchaseHandler then
		print("📄 Found purchase handler at:", purchaseHandler:GetFullName())
		
		-- Disable and re-enable to force reload
		if purchaseHandler:IsA("Script") then
			purchaseHandler.Disabled = true
			task.wait(0.1)
			purchaseHandler.Disabled = false
			print("🔄 Restarted purchase handler")
		end
	end
	
	-- Fire TycoonReady signal
	local tycoonReady = cinnamorollTycoon:FindFirstChild("TycoonReady")
	if not tycoonReady then
		tycoonReady = Instance.new("BindableEvent")
		tycoonReady.Name = "TycoonReady"
		tycoonReady.Parent = cinnamorollTycoon
		print("📢 Created TycoonReady signal")
	end
	
	-- Wait for physics to settle then fire ready signal
	task.wait(0.5)
	tycoonReady:Fire()
	print("🚀 Fired TycoonReady signal!")
	
	-- Final check
	task.wait(1)
	if purchasedObjects and #purchasedObjects:GetChildren() > 0 then
		warn("⚠️ Objects still exist after reset - clearing again!")
		for _, obj in pairs(purchasedObjects:GetChildren()) do
			obj:Destroy()
		end
	end
	
	print("✨ Cinnamoroll tycoon reset complete!")
end

-- Run the fix
fixCinnamorollTycoon()

-- Also monitor for when players join
game.Players.PlayerAdded:Connect(function(player)
	task.wait(3) -- Give them time to claim
	
	-- Check if they claimed Cinnamoroll
	local cinnamorollTycoon = workspace:FindFirstChild("Cinnamoroll tycoon")
	if cinnamorollTycoon then
		for _, tycoon in ipairs(cinnamorollTycoon:GetDescendants()) do
			if tycoon:FindFirstChild("Owner") and tycoon.Owner:IsA("ObjectValue") then
				if tycoon.Owner.Value == player then
					local purchasedObjects = tycoon:FindFirstChild("PurchasedObjects")
					if purchasedObjects and #purchasedObjects:GetChildren() > 0 then
						print("⚠️", player.Name, "claimed pre-built Cinnamoroll tycoon!")
						fixCinnamorollTycoon()
					end
				end
			end
		end
	end
end)

-- Add a command for manual reset (optional)
game.Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		if message:lower() == "/resetcinnamoroll" then
			-- Check if player is authorized (you can add admin check here)
			print("💬 Manual reset requested by", player.Name)
			fixCinnamorollTycoon()
		end
	end)
end)