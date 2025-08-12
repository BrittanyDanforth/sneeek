-- Money Shop Server Script - TYCOON COMPATIBLE VERSION
-- This version only handles money shop products and lets tycoons handle their own
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

-- Store the old ProcessReceipt if one exists (probably from tycoon)
local oldProcessReceipt = MarketplaceService.ProcessReceipt

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
	print("MoneyShop: Created PlayerMoney folder")
else
	print("MoneyShop: Found existing PlayerMoney folder")
end

-- Helper functions
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

-- Update cash display
local function updateCashDisplay(player, amount)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local cashDisplay = leaderstats:FindFirstChild("Cash")
		if cashDisplay then
			cashDisplay.Value = convertShort(amount)
		end
	end
end

-- Process receipt - ONLY handles money products, passes others through
MarketplaceService.ProcessReceipt = function(receiptInfo)
	local productId = receiptInfo.ProductId
	local cashAmount = PRODUCT_TO_CASH[productId]
	
	-- If it's NOT a money product, pass it to the old handler (tycoon)
	if not cashAmount then
		if oldProcessReceipt then
			return oldProcessReceipt(receiptInfo)
		else
			-- Not our product and no other handler
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
	end
	
	-- It IS a money product, handle it
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	-- Get or create money value
	local moneyValue = playerMoneyFolder:FindFirstChild(player.Name)
	if not moneyValue then
		moneyValue = Instance.new("IntValue")
		moneyValue.Name = player.Name
		moneyValue.Value = 0
		moneyValue.Parent = playerMoneyFolder
	end
	
	-- Award cash
	local oldValue = moneyValue.Value
	moneyValue.Value = moneyValue.Value + cashAmount
	
	print(string.format("MoneyShop: Awarded %d cash to %s (was %d, now %d)", 
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

-- Monitor players for display updates
Players.PlayerAdded:Connect(function(player)
	-- Ensure money value exists
	local moneyValue = playerMoneyFolder:FindFirstChild(player.Name)
	if not moneyValue then
		moneyValue = Instance.new("IntValue")
		moneyValue.Name = player.Name
		moneyValue.Value = 0
		moneyValue.Parent = playerMoneyFolder
	end
	
	-- Watch for leaderstats
	player.ChildAdded:Connect(function(child)
		if child.Name == "leaderstats" then
			wait(0.5)
			if moneyValue.Value > 0 then
				updateCashDisplay(player, moneyValue.Value)
			end
		end
	end)
	
	-- Set up change monitoring
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		moneyValue.Changed:Connect(function()
			updateCashDisplay(player, moneyValue.Value)
		end)
		
		if moneyValue.Value > 0 then
			updateCashDisplay(player, moneyValue.Value)
		end
	end
end)

print("MoneyShop: Initialized (Tycoon Compatible Version)")
print("MoneyShop: Products:", PRODUCT_TO_CASH)
print("MoneyShop: Will pass non-money products to tycoon handler")