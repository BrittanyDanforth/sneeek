-- Money Shop Server Script - MINIMAL FIX VERSION
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

-- Wait for PlayerMoney folder from UnifiedLeaderboard
local playerMoneyFolder
local attempts = 0
repeat
	wait(0.1)
	playerMoneyFolder = ServerStorage:FindFirstChild("PlayerMoney")
	attempts = attempts + 1
until playerMoneyFolder or attempts > 50

if not playerMoneyFolder then
	-- Create it if UnifiedLeaderboard hasn't yet
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

-- Function to update cash display on leaderboard
local function updateCashDisplay(player, amount)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local cashDisplay = leaderstats:FindFirstChild("Cash")
		if cashDisplay then
			cashDisplay.Value = convertShort(amount)
			print("MoneyShop: Updated cash display to", cashDisplay.Value)
		end
	end
end

-- REMOVED ProcessReceipt - This breaks tycoons!
-- Your money shop purchases need to be handled differently

-- Create RemoteFunction for money purchases
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local moneyProducts = Instance.new("RemoteFunction")
moneyProducts.Name = "MoneyShopProducts"
moneyProducts.Parent = ReplicatedStorage

-- Let client check if product is money product
moneyProducts.OnServerInvoke = function(player, action, productId)
	if action == "GetProducts" then
		return PRODUCT_TO_CASH
	elseif action == "ProcessPurchase" and productId then
		-- This will be called by YOUR ProcessReceipt in tycoon
		local cashAmount = PRODUCT_TO_CASH[productId]
		if cashAmount then
			local moneyValue = getOrCreatePlayerMoney(player.Name)
			local oldValue = moneyValue.Value
			moneyValue.Value = moneyValue.Value + cashAmount
			
			print(string.format("MoneyShop: Awarded %d cash to %s (was %d, now %d)", 
				cashAmount, player.Name, oldValue, moneyValue.Value))
			
			updateCashDisplay(player, moneyValue.Value)
			
			if _G.AddPlayerMoney then
				pcall(function()
					_G.AddPlayerMoney(player.Name, 0)
				end)
			end
			
			return true
		end
	end
	return false
end

-- Monitor for when players get their leaderstats
Players.PlayerAdded:Connect(function(player)
	-- Ensure money value exists
	getOrCreatePlayerMoney(player.Name)

	-- Watch for leaderstats creation
	player.ChildAdded:Connect(function(child)
		if child.Name == "leaderstats" then
			-- Wait for Cash StringValue to be created
			wait(0.5)
			local moneyValue = playerMoneyFolder:FindFirstChild(player.Name)
			if moneyValue and moneyValue.Value > 0 then
				updateCashDisplay(player, moneyValue.Value)
			end
		end
	end)

	-- Also monitor the Cash value if it already exists
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local cashDisplay = leaderstats:FindFirstChild("Cash")
		if cashDisplay then
			local moneyValue = playerMoneyFolder:FindFirstChild(player.Name)
			if moneyValue then
				-- Set up a connection to update display when value changes
				moneyValue.Changed:Connect(function()
					updateCashDisplay(player, moneyValue.Value)
				end)

				-- Initial update
				if moneyValue.Value > 0 then
					updateCashDisplay(player, moneyValue.Value)
				end
			end
		end
	end
end)

-- Handle players already in game
for _, player in pairs(Players:GetPlayers()) do
	local moneyValue = getOrCreatePlayerMoney(player.Name)

	-- Set up monitoring
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats and leaderstats:FindFirstChild("Cash") then
		moneyValue.Changed:Connect(function()
			updateCashDisplay(player, moneyValue.Value)
		end)

		-- Update display if they have money
		if moneyValue.Value > 0 then
			updateCashDisplay(player, moneyValue.Value)
		end
	end
end

print("MoneyShop: Initialized with products:", PRODUCT_TO_CASH)
print("MoneyShop: Monitoring PlayerMoney folder at", playerMoneyFolder:GetFullName())
print("⚠️ MoneyShop: ProcessReceipt must be handled by your tycoon!")