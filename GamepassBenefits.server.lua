-- Gamepass Benefits Manager
-- Place in: ServerScriptService/GamepassBenefits.server.lua

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

-- Configure your gamepass IDs here
local PASS_2X_CASH = 1398974710 -- 2x Cash
local PASS_AUTO_COLLECT = 0     -- TODO: Replace with your Auto Collect Cash pass ID
local PASS_RAINBOW_CARPET = 0   -- TODO: Replace with your Rainbow Carpet pass ID

-- Utility: safe ownership check
local function userOwnsPass(userId, passId)
    if type(passId) ~= "number" or passId <= 0 then return false end
    local ok, owns = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, userId, passId)
    if not ok then
        warn("UserOwnsGamePassAsync failed:", userId, passId)
        return false
    end
    return owns == true
end

-- Find tycoon model for a player (expects an ObjectValue named "Owner")
local function findTycoonForPlayer(player)
    for _, inst in ipairs(workspace:GetDescendants()) do
        local ownerVal = inst:FindFirstChild("Owner")
        if ownerVal and ownerVal.Value == player then
            return inst
        end
    end
    return nil
end

-- Ensure PlayerMoney IntValue exists in ServerStorage
local function getOrCreatePlayerMoney(player)
    local folder = ServerStorage:FindFirstChild("PlayerMoney")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "PlayerMoney"
        folder.Parent = ServerStorage
    end
    local money = folder:FindFirstChild(player.Name)
    if not money then
        money = Instance.new("IntValue")
        money.Name = player.Name
        money.Value = 0
        money.Parent = folder
    end
    return money
end

-- Auto collect scheduler per player
local autoLoops = {}

local function startAutoCollect(player)
    if autoLoops[player] then return end
    autoLoops[player] = true
    coroutine.wrap(function()
        while autoLoops[player] and player.Parent do
            -- Verify pass still owned
            if not userOwnsPass(player.UserId, PASS_AUTO_COLLECT) then
                break
            end
            local tycoon = findTycoonForPlayer(player)
            if tycoon then
                local moneyValue = tycoon:FindFirstChild("CurrencyToCollect")
                if moneyValue and moneyValue:IsA("IntValue") and moneyValue.Value > 0 then
                    local playerMoney = getOrCreatePlayerMoney(player)
                    playerMoney.Value = playerMoney.Value + moneyValue.Value
                    moneyValue.Value = 0
                end
            end
            task.wait(2)
        end
        autoLoops[player] = nil
    end)()
end

local function stopAutoCollect(player)
    autoLoops[player] = nil
end

-- Grant Rainbow Carpet tool if available
local function giveRainbowCarpet(player)
    if not userOwnsPass(player.UserId, PASS_RAINBOW_CARPET) then return end
    local backpack = player:FindFirstChildOfClass("Backpack")
    if not backpack then return end
    if backpack:FindFirstChild("RainbowCarpet") then return end
    local toolsFolder = ServerStorage:FindFirstChild("Tools")
    if not toolsFolder then
        warn("Tools folder not found in ServerStorage. Create ServerStorage/Tools/RainbowCarpet (Tool).")
        return
    end
    local tool = toolsFolder:FindFirstChild("RainbowCarpet")
    if not tool or not tool:IsA("Tool") then
        warn("RainbowCarpet Tool not found in ServerStorage/Tools. Please add it.")
        return
    end
    local clone = tool:Clone()
    clone.Parent = backpack
end

-- Monitor players
Players.PlayerAdded:Connect(function(player)
    -- Attributes for quick checks
    player:SetAttribute("Has2xCash", userOwnsPass(player.UserId, PASS_2X_CASH))
    player:SetAttribute("HasAutoCollect", userOwnsPass(player.UserId, PASS_AUTO_COLLECT))
    player:SetAttribute("HasRainbowCarpet", userOwnsPass(player.UserId, PASS_RAINBOW_CARPET))

    -- Auto collect loop
    if player:GetAttribute("HasAutoCollect") then
        startAutoCollect(player)
    end

    -- Grant carpet on spawn
    player.CharacterAdded:Connect(function()
        if player:GetAttribute("HasRainbowCarpet") then
            giveRainbowCarpet(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    stopAutoCollect(player)
end)

-- Also listen for gamepass purchase completions to refresh attributes/benefits
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
    if not wasPurchased then return end
    if PASS_AUTO_COLLECT > 0 and gamePassId == PASS_AUTO_COLLECT then
        player:SetAttribute("HasAutoCollect", true)
        startAutoCollect(player)
    elseif PASS_RAINBOW_CARPET > 0 and gamePassId == PASS_RAINBOW_CARPET then
        player:SetAttribute("HasRainbowCarpet", true)
        giveRainbowCarpet(player)
    elseif gamePassId == PASS_2X_CASH then
        player:SetAttribute("Has2xCash", true)
    end
end)

print("GamepassBenefits: initialized. Configure PASS_AUTO_COLLECT and PASS_RAINBOW_CARPET IDs.")

-- Gamepass Benefits Manager
-- Place in: ServerScriptService/GamepassBenefits.server.lua

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

-- Configure your gamepass IDs here
local PASS_2X_CASH = 1398974710 -- 2x Cash
local PASS_AUTO_COLLECT = 0     -- TODO: Replace with your Auto Collect Cash pass ID
local PASS_RAINBOW_CARPET = 0   -- TODO: Replace with your Rainbow Carpet pass ID

-- Utility: safe ownership check
local function userOwnsPass(userId, passId)
	if type(passId) ~= "number" or passId <= 0 then return false end
	local ok, owns = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, userId, passId)
	if not ok then
		warn("UserOwnsGamePassAsync failed:", userId, passId)
		return false
	end
	return owns == true
end

-- Find tycoon model for a player (expects an ObjectValue named "Owner")
local function findTycoonForPlayer(player)
	for _, inst in ipairs(workspace:GetDescendants()) do
		local ownerVal = inst:FindFirstChild("Owner")
		if ownerVal and ownerVal.Value == player then
			return inst
		end
	end
	return nil
end

-- Ensure PlayerMoney IntValue exists in ServerStorage
local function getOrCreatePlayerMoney(player)
	local folder = ServerStorage:FindFirstChild("PlayerMoney")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "PlayerMoney"
		folder.Parent = ServerStorage
	end
	local money = folder:FindFirstChild(player.Name)
	if not money then
		money = Instance.new("IntValue")
		money.Name = player.Name
		money.Value = 0
		money.Parent = folder
	end
	return money
end

-- Auto collect scheduler per player
local autoLoops = {}

local function startAutoCollect(player)
	if autoLoops[player] then return end
	autoLoops[player] = true
	coroutine.wrap(function()
		while autoLoops[player] and player.Parent do
			-- Verify pass still owned
			if not userOwnsPass(player.UserId, PASS_AUTO_COLLECT) then
				break
			end
			local tycoon = findTycoonForPlayer(player)
			if tycoon then
				local moneyValue = tycoon:FindFirstChild("CurrencyToCollect")
				if moneyValue and moneyValue:IsA("IntValue") and moneyValue.Value > 0 then
					local playerMoney = getOrCreatePlayerMoney(player)
					playerMoney.Value = playerMoney.Value + moneyValue.Value
					moneyValue.Value = 0
				end
			end
			task.wait(2) -- collection interval
		end
		autoLoops[player] = nil
	end)()
end

local function stopAutoCollect(player)
	autoLoops[player] = nil
end

-- Grant Rainbow Carpet tool if available
local function giveRainbowCarpet(player)
	if not userOwnsPass(player.UserId, PASS_RAINBOW_CARPET) then return end
	local backpack = player:FindFirstChildOfClass("Backpack")
	if not backpack then return end
	if backpack:FindFirstChild("RainbowCarpet") then return end
	local toolsFolder = ServerStorage:FindFirstChild("Tools")
	if not toolsFolder then
		warn("Tools folder not found in ServerStorage. Create ServerStorage/Tools/RainbowCarpet (Tool).")
		return
	end
	local tool = toolsFolder:FindFirstChild("RainbowCarpet")
	if not tool or not tool:IsA("Tool") then
		warn("RainbowCarpet Tool not found in ServerStorage/Tools. Please add it.")
		return
	end
	local clone = tool:Clone()
	clone.Parent = backpack
end

-- Monitor players
Players.PlayerAdded:Connect(function(player)
	-- Attributes for quick checks
	player:SetAttribute("Has2xCash", userOwnsPass(player.UserId, PASS_2X_CASH))
	player:SetAttribute("HasAutoCollect", userOwnsPass(player.UserId, PASS_AUTO_COLLECT))
	player:SetAttribute("HasRainbowCarpet", userOwnsPass(player.UserId, PASS_RAINBOW_CARPET))

	-- Auto collect loop
	if player:GetAttribute("HasAutoCollect") then
		startAutoCollect(player)
	end

	-- Grant carpet on spawn
	player.CharacterAdded:Connect(function()
		if player:GetAttribute("HasRainbowCarpet") then
			giveRainbowCarpet(player)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	stopAutoCollect(player)
end)

-- Also listen for gamepass purchase completions to refresh attributes/benefits
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
	if not wasPurchased then return end
	if PASS_AUTO_COLLECT > 0 and gamePassId == PASS_AUTO_COLLECT then
		player:SetAttribute("HasAutoCollect", true)
		startAutoCollect(player)
	elseif PASS_RAINBOW_CARPET > 0 and gamePassId == PASS_RAINBOW_CARPET then
		player:SetAttribute("HasRainbowCarpet", true)
		giveRainbowCarpet(player)
	elseif gamePassId == PASS_2X_CASH then
		player:SetAttribute("Has2xCash", true)
	end
end)

print("GamepassBenefits: initialized. Configure PASS_AUTO_COLLECT and PASS_RAINBOW_CARPET IDs.")

