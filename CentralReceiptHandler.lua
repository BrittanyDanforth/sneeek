--[[
	💰 CENTRAL RECEIPT HANDLER 💰
	This single script handles ALL dev product purchases
	Place in ServerScriptService
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

-- MONEY SHOP PRODUCTS
local MONEY_SHOP_PRODUCTS = {
	[3366419712] = 1000,    -- 1k Cash
	[3366420012] = 5000,    -- 5k Cash
	[3366420478] = 10000,   -- 10k Cash
	[3366420800] = 25000,   -- 25k Cash
}

-- Wait for PlayerMoney folder
local playerMoneyFolder
repeat
	task.wait(0.1)
	playerMoneyFolder = ServerStorage:FindFirstChild("PlayerMoney")
until playerMoneyFolder

-- Helper function to update cash display
local function updateCashDisplay(player, amount)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local cashDisplay = leaderstats:FindFirstChild("Cash")
		if cashDisplay then
			-- Convert to short format
			local displayValue = tostring(amount)
			if amount >= 1000000000 then
				displayValue = string.format("%.1fB", amount / 1000000000)
			elseif amount >= 1000000 then
				displayValue = string.format("%.1fM", amount / 1000000)
			elseif amount >= 1000 then
				displayValue = string.format("%.1fK", amount / 1000)
			end
			cashDisplay.Value = displayValue
		end
	end
end

-- Single ProcessReceipt handler for ALL products
MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	local productId = receiptInfo.ProductId
	
	-- CHECK IF IT'S A MONEY SHOP PRODUCT
	local cashAmount = MONEY_SHOP_PRODUCTS[productId]
	if cashAmount then
		-- Handle money purchase
		local moneyValue = playerMoneyFolder:FindFirstChild(player.Name)
		if not moneyValue then
			moneyValue = Instance.new("IntValue")
			moneyValue.Name = player.Name
			moneyValue.Value = 0
			moneyValue.Parent = playerMoneyFolder
		end
		
		moneyValue.Value = moneyValue.Value + cashAmount
		print("💰 Awarded", cashAmount, "cash to", player.Name)
		
		-- Update display
		updateCashDisplay(player, moneyValue.Value)
		
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	
	-- CHECK IF IT'S A TYCOON PRODUCT
	-- Find player's tycoon
	local playerTycoon = nil
	for _, descendant in ipairs(workspace:GetDescendants()) do
		if descendant.Name == "Owner" and descendant:IsA("ObjectValue") and descendant.Value == player then
			playerTycoon = descendant.Parent
			break
		end
	end
	
	if playerTycoon then
		-- Look for the button with this dev product
		local buttons = playerTycoon:FindFirstChild("Buttons")
		if buttons then
			for _, button in ipairs(buttons:GetChildren()) do
				local devProduct = button:FindFirstChild("DevProduct")
				if devProduct and devProduct.Value == productId then
					-- Found it! Process the tycoon purchase
					local buyObject = playerTycoon:FindFirstChild("BuyObject")
					if buyObject then
						-- Create purchase request
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
						statsValue.Value = playerMoneyFolder:FindFirstChild(player.Name)
						statsValue.Parent = purchaseRequest
						
						purchaseRequest.Parent = buyObject
						
						print("🏗️ Processed tycoon purchase for", player.Name)
						return Enum.ProductPurchaseDecision.PurchaseGranted
					end
				end
			end
		end
	end
	
	-- Unknown product
	warn("⚠️ Unknown product ID:", productId)
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

print("💰 Central Receipt Handler loaded!")
print("📦 Handles both money shop AND tycoon products")