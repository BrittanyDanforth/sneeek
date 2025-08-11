-- Money Shop Server Script (Handles Developer Product Purchases)
-- Place in: ServerScriptService/MoneyShop.server.lua

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

-- Map your real product IDs to the cash to award
local PRODUCT_TO_CASH = {
	[3366419712] = 1000,    -- 1k Cash
	[3366420012] = 5000,    -- 5k Cash
	[3366420478] = 10000,   -- 10k Cash
	[3366420800] = 25000,   -- 25k Cash
}

-- Ensure PlayerMoney folder exists
local function ensurePlayerMoneyFolder()
	local folder = ServerStorage:FindFirstChild("PlayerMoney")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "PlayerMoney"
		folder.Parent = ServerStorage
		print("Created PlayerMoney folder")
	end
	return folder
end

-- Get or create player money value
local function getOrCreatePlayerMoney(playerName)
	local folder = ensurePlayerMoneyFolder()
	local moneyValue = folder:FindFirstChild(playerName)
	if not moneyValue then
		moneyValue = Instance.new("IntValue")
		moneyValue.Name = playerName
		moneyValue.Value = 0
		moneyValue.Parent = folder
		print("Created money value for", playerName)
	end
	return moneyValue
end

-- When player joins, ensure they have a money value
Players.PlayerAdded:Connect(function(player)
	-- Create money value immediately when they join
	getOrCreatePlayerMoney(player.Name)
	print("Player joined, ensured money value exists for:", player.Name)
end)

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
	
	-- Get or create the money value
	local moneyValue = getOrCreatePlayerMoney(player.Name)
	moneyValue.Value = moneyValue.Value + cashAmount
	
	print(string.format("Awarded %d cash to %s (new total: %d)", cashAmount, player.Name, moneyValue.Value))
	
	-- Update leaderboard if it exists
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local cashDisplay = leaderstats:FindFirstChild("Cash")
		if cashDisplay then
			-- Check if we should show short format
			local settings = _G.Settings or {
				LeaderboardSettings = {ShowShortCurrency = true},
				ConvertShort = function(self, value)
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
				end,
				ConvertComma = function(self, value)
					local formatted = tostring(value)
					while true do
						local newFormatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
						if k == 0 then break end
						formatted = newFormatted
					end
					return formatted
				end
			}
			
			if settings.LeaderboardSettings.ShowShortCurrency then
				cashDisplay.Value = settings:ConvertShort(moneyValue.Value)
			else
				cashDisplay.Value = settings:ConvertComma(moneyValue.Value)
			end
		end
	end
	
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- Set the callback
MarketplaceService.ProcessReceipt = processReceipt

-- Handle players already in game
for _, player in pairs(Players:GetPlayers()) do
	getOrCreatePlayerMoney(player.Name)
end

print("Money Shop Server loaded with products:", PRODUCT_TO_CASH)
print("PlayerMoney folder:", ensurePlayerMoneyFolder():GetFullName())