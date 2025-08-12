-- Money Shop Server Script (Complete Working Version)
-- Place in: ServerScriptService/MoneyShop.server.lua
-- This version works alongside your tycoon's dev products

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

-- Wait a moment for tycoon scripts to set up their ProcessReceipt
task.wait(2)

-- Store the existing ProcessReceipt (from tycoon)
local existingProcessReceipt = MarketplaceService.ProcessReceipt

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

-- Get or create player money value
local function getOrCreatePlayerMoney(playerName)
	local moneyValue = playerMoneyFolder:FindFirstChild(playerName)
	if not moneyValue then
		moneyValue = Instance.new("IntValue")
		moneyValue.Name = playerName
		moneyValue.Value = 0
		moneyValue.Parent = playerMoneyFolder
		print("MoneyShop: Created money value for", playerName)
	end
	return moneyValue
end

-- Helper functions for formatting
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
			-- Default to short format
			cashDisplay.Value = convertShort(amount)
			print("MoneyShop: Updated", player.Name, "display to", cashDisplay.Value)
		end
	end
end

-- Process receipt - handles BOTH money shop AND tycoon products
MarketplaceService.ProcessReceipt = function(receiptInfo)
	local productId = receiptInfo.ProductId
	local cashAmount = PRODUCT_TO_CASH[productId]
	
	-- Check if it's a money shop product
	if cashAmount then
		-- This is a money shop product, handle it
		local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if not player then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		
		-- Award the cash
		local moneyValue = getOrCreatePlayerMoney(player.Name)
		local oldValue = moneyValue.Value
		moneyValue.Value = moneyValue.Value + cashAmount
		
		print(string.format("MoneyShop: Awarded %d cash to %s (was %d, now %d)", 
			cashAmount, player.Name, oldValue, moneyValue.Value))
		
		-- Update display
		updateCashDisplay(player, moneyValue.Value)
		
		-- Use global API if available
		if _G.AddPlayerMoney then
			pcall(function()
				_G.AddPlayerMoney(player.Name, 0) -- Triggers display update
			end)
		end
		
		return Enum.ProductPurchaseDecision.PurchaseGranted
	else
		-- Not a money shop product - pass to tycoon handler
		if existingProcessReceipt then
			return existingProcessReceipt(receiptInfo)
		else
			-- No other handler exists
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
	end
end

-- Monitor players for display updates
Players.PlayerAdded:Connect(function(player)
	-- Ensure money value exists
	getOrCreatePlayerMoney(player.Name)
	
	-- Watch for leaderstats creation
	player.ChildAdded:Connect(function(child)
		if child.Name == "leaderstats" then
			wait(0.5)
			local moneyValue = playerMoneyFolder:FindFirstChild(player.Name)
			if moneyValue and moneyValue.Value > 0 then
				updateCashDisplay(player, moneyValue.Value)
			end
		end
	end)
	
	-- Monitor existing leaderstats
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local moneyValue = playerMoneyFolder:FindFirstChild(player.Name)
		if moneyValue then
			-- Update when value changes
			moneyValue.Changed:Connect(function()
				updateCashDisplay(player, moneyValue.Value)
			end)
			
			-- Initial update
			if moneyValue.Value > 0 then
				updateCashDisplay(player, moneyValue.Value)
			end
		end
	end
end)

-- Handle players already in game
for _, player in pairs(Players:GetPlayers()) do
	local moneyValue = getOrCreatePlayerMoney(player.Name)
	
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		moneyValue.Changed:Connect(function()
			updateCashDisplay(player, moneyValue.Value)
		end)
		
		if moneyValue.Value > 0 then
			updateCashDisplay(player, moneyValue.Value)
		end
	end
end

print("MoneyShop: Initialized successfully!")
print("MoneyShop: Products:", PRODUCT_TO_CASH)
print("MoneyShop: Will work alongside tycoon dev products")