--[[
	💰 CENTRALIZED RECEIPT ROUTER - UPDATED 💰
	Handles ALL dev product purchases:
	- Tycoon button purchases
	- Money shop purchases
	
	Place this in ServerScriptService (replace the old ReceiptRouter)
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

-- MONEY SHOP PRODUCTS (update these with your real IDs)
local MONEY_SHOP_PRODUCTS = {
	[3366419712] = 1000,    -- 1k Cash
	[3366420012] = 5000,    -- 5k Cash
	[3366420478] = 10000,   -- 10k Cash
	[3366420800] = 25000,   -- 25k Cash
}

-- Helper functions for cash display
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

local function convertComma(value)
	local formatted = tostring(value)
	while true do
		local newFormatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then break end
		formatted = newFormatted
	end
	return formatted
end

-- Update cash display on leaderboard
local function updateCashDisplay(player, amount)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local cashDisplay = leaderstats:FindFirstChild("Cash")
		if cashDisplay then
			-- Default to short display
			cashDisplay.Value = convertShort(amount)
			print("💰 Updated cash display to", cashDisplay.Value)
		end
	end
end

-- Single ProcessReceipt handler for entire game
MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	local productId = receiptInfo.ProductId
	print("💳 Processing receipt for", player.Name, "- Product ID:", productId)
	
	-- CHECK IF IT'S A MONEY SHOP PRODUCT FIRST
	local cashAmount = MONEY_SHOP_PRODUCTS[productId]
	if cashAmount then
		-- Handle money shop purchase
		local playerMoneyFolder = ServerStorage:FindFirstChild("PlayerMoney")
		if not playerMoneyFolder then
			warn("⚠️ PlayerMoney folder not found!")
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		
		local moneyValue = playerMoneyFolder:FindFirstChild(player.Name)
		if not moneyValue then
			moneyValue = Instance.new("IntValue")
			moneyValue.Name = player.Name
			moneyValue.Value = 0
			moneyValue.Parent = playerMoneyFolder
		end
		
		local oldValue = moneyValue.Value
		moneyValue.Value = moneyValue.Value + cashAmount
		
		print(string.format("💵 Money Shop: Awarded %d cash to %s (was %d, now %d)", 
			cashAmount, player.Name, oldValue, moneyValue.Value))
		
		-- Update display
		updateCashDisplay(player, moneyValue.Value)
		
		-- Call global API if exists
		if _G.AddPlayerMoney then
			pcall(function()
				_G.AddPlayerMoney(player.Name, 0) -- Trigger display update
			end)
		end
		
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	
	-- NOT A MONEY SHOP PRODUCT - CHECK TYCOON BUTTONS
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
		if devProduct and devProduct.Value == productId then
			-- Found the button! Process the purchase
			local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
			if playerStats then
				-- Trigger the purchase through BuyObject (the proper way)
				local buyObject = playerTycoon:FindFirstChild("BuyObject")
				if buyObject then
					local purchaseRequest = Instance.new("Model")
					purchaseRequest.Name = "DevProductPurchase_" .. tostring(productId)
					
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
					
					print("🏗️ Tycoon: Dev product purchase processed for", player.Name)
					return Enum.ProductPurchaseDecision.PurchaseGranted
				else
					warn("⚠️ No BuyObject folder found")
				end
			else
				warn("⚠️ No player stats found for", player.Name)
			end
		end
	end
	
	warn("⚠️ Unknown product ID:", productId)
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

print("💰 UPDATED Centralized Receipt Router loaded!")
print("📋 Handles both tycoon AND money shop purchases")
print("💵 Money shop products:", MONEY_SHOP_PRODUCTS)