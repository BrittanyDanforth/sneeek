--[[
	💰 CENTRALIZED RECEIPT ROUTER 💰
	Handles ALL dev product purchases across all tycoons
	Prevents multiple ProcessReceipt conflicts in live games
	
	Place this in ServerScriptService
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

-- Single ProcessReceipt handler for entire game
MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	print("💳 Processing receipt for", player.Name, "- Product ID:", receiptInfo.ProductId)
	
	-- Find player's tycoon
	local playerTycoon = nil
	for _, tycoon in ipairs(workspace:GetDescendants()) do
		if tycoon.Name:find("tycoon") or tycoon.Name:find("Tycoon") then
			local owner = tycoon:FindFirstChild("Owner")
			if owner and owner:IsA("ObjectValue") and owner.Value == player then
				playerTycoon = tycoon
				break
			end
		end
	end
	
	if not playerTycoon then
		warn("⚠️ No tycoon found for player:", player.Name)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	-- Find the button with this dev product
	local buttons = playerTycoon:FindFirstChild("Buttons")
	if not buttons then
		warn("⚠️ No Buttons folder in tycoon")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	for _, button in ipairs(buttons:GetChildren()) do
		local devProduct = button:FindFirstChild("DevProduct")
		if devProduct and devProduct.Value == receiptInfo.ProductId then
			-- Found the button! Process the purchase
			local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
			if playerStats then
				-- Trigger the purchase through BuyObject (the proper way)
				local buyObject = playerTycoon:FindFirstChild("BuyObject")
				if buyObject then
					local purchaseRequest = Instance.new("Model")
					purchaseRequest.Name = "DevProductPurchase_" .. tostring(receiptInfo.ProductId)
					
					local cost = Instance.new("IntValue")
					cost.Name = "Cost"
					cost.Value = 0 -- Dev products are already paid for
					cost.Parent = purchaseRequest
					
					local buttonValue = Instance.new("ObjectValue")
					buttonValue.Name = "Button"
					buttonValue.Value = button
					buttonValue.Parent = purchaseRequest
					
					local statsValue = Instance.new("ObjectValue")
					statsValue.Name = "Stats"
					statsValue.Value = playerStats
					statsValue.Parent = purchaseRequest
					
					purchaseRequest.Parent = buyObject
					
					print("✅ Dev product purchase processed for", player.Name)
					return Enum.ProductPurchaseDecision.PurchaseGranted
				else
					warn("⚠️ No BuyObject folder found")
				end
			else
				warn("⚠️ No player stats found for", player.Name)
			end
		end
	end
	
	warn("⚠️ No button found for dev product ID:", receiptInfo.ProductId)
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

print("💰 Centralized Receipt Router loaded!")
print("📋 This handles ALL dev product purchases across all tycoons")