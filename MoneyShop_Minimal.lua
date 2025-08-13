-- Money Shop Server Script (Handles Developer Product Purchases)
-- Place in: ServerScriptService/MoneyShop.server.lua
-- 
-- IMPORTANT: Replace the product IDs below with your actual Developer Product IDs
-- from Creator Dashboard > Monetization > Developer Products

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage") -- ADDED

-- Map your real product IDs to the cash to award
local PRODUCT_TO_CASH = {
	[3366419712] = 1000,    -- 1k Cash
	[3366420012] = 5000,    -- 5k Cash
	[3366420478] = 10000,   -- 10k Cash
	[3366420800] = 25000,   -- 25k Cash
}

-- DON'T SET ProcessReceipt - Let your tycoon handle it
-- Instead, we'll use PromptProductPurchaseFinished

-- Wait for PlayerMoney folder
local playerMoneyFolder
local attempts = 0
repeat
	wait(0.1)
	playerMoneyFolder = ServerStorage:FindFirstChild("PlayerMoney")
	attempts = attempts + 1
until playerMoneyFolder or attempts > 50

if not playerMoneyFolder then
	playerMoneyFolder = Instance.new("Folder")
	playerMoneyFolder.Name = "PlayerMoney"
	playerMoneyFolder.Parent = ServerStorage
end

-- Helper function
local function convertShort(value)
	value = tonumber(value) or 0
	if value >= 1000000000 then
		return string.format("%.1fB", value / 1000000000)
	elseif value >= 1000000 then
		return string.format("%.1fM", value / 1000000)
	elseif value >= 1000 then
		return string.format("%.1fK", value / 1000)
	else
		return tostring(value)
	end
end

-- Create RemoteEvent for client to request purchases
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local purchaseMoneyEvent = Instance.new("RemoteFunction")
purchaseMoneyEvent.Name = "PurchaseMoneyProduct"
purchaseMoneyEvent.Parent = ReplicatedStorage

purchaseMoneyEvent.OnServerInvoke = function(player, productId)
	if PRODUCT_TO_CASH[productId] then
		MarketplaceService:PromptProductPurchase(player, productId)
		return true
	end
	return false
end

-- Handle when purchase is finished (not ProcessReceipt)
MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, isPurchased)
	if not isPurchased then return end
	
	local cashAmount = PRODUCT_TO_CASH[productId]
	if not cashAmount then return end -- Not our product
	
	local player = Players:GetPlayerByUserId(userId)
	if not player then return end
	
	-- Award cash
	local moneyValue = playerMoneyFolder:FindFirstChild(player.Name)
	if not moneyValue then
		moneyValue = Instance.new("IntValue")
		moneyValue.Name = player.Name
		moneyValue.Value = 0
		moneyValue.Parent = playerMoneyFolder
	end
	
	moneyValue.Value = moneyValue.Value + cashAmount
	print("MoneyShop: Awarded", cashAmount, "to", player.Name)
	
	-- Update display
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local cashDisplay = leaderstats:FindFirstChild("Cash")
		if cashDisplay then
			cashDisplay.Value = convertShort(moneyValue.Value)
		end
	end
end)