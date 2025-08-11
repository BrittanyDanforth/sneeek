-- Money Shop Server Script (Handles Developer Product Purchases)
-- Place in: ServerScriptService/MoneyShop.server.lua

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

-- Map your real product IDs to the cash to award
local PRODUCT_TO_CASH = {
	[3366419712] = 1000,    -- 1k Cash
	[3366420012] = 5000,    -- 5k Cash
	[3366420478] = 10000,   -- 10k Cash
	[3366420800] = 25000,   -- 25k Cash
}

-- Get PlayerMoney folder
local function getPlayerMoneyFolder()
	return ServerStorage:WaitForChild("PlayerMoney", 10)
end

-- Process receipt callback
local function processReceipt(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		-- Player probably left, we'll grant it next time they join
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	local productId = receiptInfo.ProductId
	local cashAmount = PRODUCT_TO_CASH[productId]
	
	if not cashAmount then
		warn("Unknown product ID:", productId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	-- Award the cash using the global money API
	local success = false
	if _G.AddPlayerMoney then
		success = _G.AddPlayerMoney(player.Name, cashAmount)
	else
		-- Fallback: directly modify the value
		local playerMoneyFolder = getPlayerMoneyFolder()
		if playerMoneyFolder then
			local moneyValue = playerMoneyFolder:FindFirstChild(player.Name)
			if moneyValue then
				moneyValue.Value = moneyValue.Value + cashAmount
				success = true
			end
		end
	end
	
	if success then
		print(string.format("Awarded %d cash to %s", cashAmount, player.Name))
		return Enum.ProductPurchaseDecision.PurchaseGranted
	else
		warn("Failed to award cash to", player.Name)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

-- Set the callback
MarketplaceService.ProcessReceipt = processReceipt

print("Money Shop Server loaded with products:", PRODUCT_TO_CASH)