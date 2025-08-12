-- Money Shop Server Script - NO PROCESS RECEIPT VERSION
-- This version does NOT set ProcessReceipt, allowing your tycoons to handle dev products
-- Place in: ServerScriptService

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

-- Create RemoteFunction for money shop purchases
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local purchaseMoneyProduct = Instance.new("RemoteFunction")
purchaseMoneyProduct.Name = "PurchaseMoneyProduct"
purchaseMoneyProduct.Parent = ReplicatedStorage

-- Handle money purchases via remote function instead
purchaseMoneyProduct.OnServerInvoke = function(player, productId)
	-- Verify it's a money product
	local cashAmount = PRODUCT_TO_CASH[productId]
	if not cashAmount then
		return false
	end
	
	-- Prompt the purchase
	MarketplaceService:PromptProductPurchase(player, productId)
	return true
end

-- Listen for successful purchases and award cash
MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, isPurchased)
	if not isPurchased then return end
	
	local player = Players:GetPlayerByUserId(userId)
	if not player then return end
	
	local cashAmount = PRODUCT_TO_CASH[productId]
	if not cashAmount then return end
	
	-- Award the cash
	local playerMoneyFolder = ServerStorage:FindFirstChild("PlayerMoney")
	if not playerMoneyFolder then
		playerMoneyFolder = Instance.new("Folder")
		playerMoneyFolder.Name = "PlayerMoney"
		playerMoneyFolder.Parent = ServerStorage
	end
	
	local moneyValue = playerMoneyFolder:FindFirstChild(player.Name)
	if not moneyValue then
		moneyValue = Instance.new("IntValue")
		moneyValue.Name = player.Name
		moneyValue.Value = 0
		moneyValue.Parent = playerMoneyFolder
	end
	
	moneyValue.Value = moneyValue.Value + cashAmount
	print(string.format("💵 Awarded %d cash to %s (total: %d)", cashAmount, player.Name, moneyValue.Value))
end)

print("MoneyShop: Initialized WITHOUT ProcessReceipt")
print("MoneyShop: Your tycoons can now handle their own dev products!")