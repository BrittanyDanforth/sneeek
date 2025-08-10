-- Money Shop Server Script (Handles Developer Product Purchases)
-- Place in: ServerScriptService/MoneyShop.server.lua
-- 
-- IMPORTANT: Replace the product IDs below with your actual Developer Product IDs
-- from Creator Dashboard > Monetization > Developer Products

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

-- Map your real product IDs to the cash to award
local PRODUCT_TO_CASH = {
    [12345678] = 1000,   -- 1k Cash (REPLACE WITH YOUR PRODUCT ID)
    [23456789] = 10000,  -- 10k Cash (REPLACE WITH YOUR PRODUCT ID)
    [34567890] = 50000,  -- 50k Cash (REPLACE WITH YOUR PRODUCT ID)
}