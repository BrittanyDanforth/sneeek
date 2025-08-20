--[[
	Modern Tycoon Core Script
	Improved version with better debugging, cleaner code, and modern practices
--]]

local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

-- Configuration
local Settings
local settingsLocations = {
	script.Parent.Parent.Parent:FindFirstChild("Settings"),
	script.Parent.Parent:FindFirstChild("Settings"),
	game.ServerScriptService:FindFirstChild("Settings"),
	game.ServerStorage:FindFirstChild("Settings")
}

for _, location in ipairs(settingsLocations) do
	if location and location:IsA("ModuleScript") then
		Settings = require(location)
		print("[TYCOON] Found Settings at:", location:GetFullName())
		break
	end
end

if not Settings then
	warn("[TYCOON] Settings module not found! Using defaults.")
	Settings = {
		Sounds = {Collect = 131886985, Purchase = 203785492, ErrorBuy = 138090596},
		FadeInTime = 0.5,
		FadeOutTime = 0.5,
		StealSettings = {Stealing = true, StealPercent = 0.25, PlayerProtection = 60},
	}
end

local TeamColor = script.Parent.TeamColor.Value
local Money = script.Parent.CurrencyToCollect
local Owner = script.Parent.Owner

local DEBUG_MODE = true

local Objects = {}
local ButtonDebounces = {}
local CollectorDebounce = false
local StealDebounce = {}

-- Initialize
script.Parent.Essentials.Spawn.TeamColor = TeamColor
script.Parent.Essentials.Spawn.BrickColor = TeamColor

local function debugPrint(...)
	if DEBUG_MODE then
		print("[TYCOON]", script.Parent.Name, ...)
	end
end

local SoundCache = {}
local function PlaySound(part, soundId)
	if not part or not soundId then return end
	local cacheKey = part:GetFullName() .. "_" .. tostring(soundId)
	if SoundCache[cacheKey] and SoundCache[cacheKey].Parent then
		SoundCache[cacheKey]:Play()
		return
	end
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. tostring(soundId)
	sound.Volume = 0.5
	sound.Parent = part
	SoundCache[cacheKey] = sound
	sound:Play()
	sound.Ended:Connect(function()
		if SoundCache[cacheKey] == sound then
			SoundCache[cacheKey] = nil
		end
	sound:Destroy()
	end)
end

-- Part collectors
local function SetupPartCollectors()
	debugPrint("Setting up part collectors...")
	local collectorCount = 0
	for _, collector in pairs(script.Parent.Essentials:GetChildren()) do
		if collector.Name == "PartCollector" then
			collectorCount += 1
			collector.Touched:Connect(function(part)
				if part:FindFirstChild("Cash") and part.Cash:IsA("IntValue") then
					local cashValue = part.Cash.Value
					-- 2x Cash multiplier via attribute or fallback check
					local grant = cashValue
					local ownerPlayer = Owner.Value
					if ownerPlayer then
						local has2x = ownerPlayer:GetAttribute("Has2xCash")
						if has2x == nil then
							local ok, owns = pcall(function()
								return MarketplaceService:UserOwnsGamePassAsync(ownerPlayer.UserId, 1398974710)
							end)
							has2x = ok and owns or false
							ownerPlayer:SetAttribute("Has2xCash", has2x)
						end
						if has2x then grant = grant * 2 end
					end
					Money.Value = Money.Value + grant
					debugPrint("Collected part:", cashValue, "grant:", grant, "Total:", Money.Value)
					if part:IsA("BasePart") then
						local tween = TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Transparency = 1, Size = part.Size * 0.5})
						tween:Play()
						tween.Completed:Connect(function()
							part:Destroy()
						end)
					else
						part:Destroy()
					end
				end
			end)
		end
	end
	debugPrint("Initialized", collectorCount, "part collectors")
end

-- Player collector
local function SetupPlayerCollector()
	local giver = script.Parent.Essentials.Giver
	if not giver then
		warn("Giver part not found!")
		return
	end
	debugPrint("Setting up player collector...")

	giver.Touched:Connect(function(hit)
		if CollectorDebounce then return end
		local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then return end
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player then return end
		if Owner.Value == player then
			if Money.Value <= 0 then return end
			CollectorDebounce = true
			local original = giver.BrickColor
			giver.BrickColor = BrickColor.new("Bright red")
			local stats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
			if stats then
				local collected = Money.Value
				stats.Value += collected
				Money.Value = 0
				PlaySound(giver, Settings.Sounds.Collect)
			else
				warn("Player stats not found for", player.Name)
			end
			wait(1)
			giver.BrickColor = original
			CollectorDebounce = false
		end
	end)
end

-- Buttons
local function SetupButtons()
	local buttons = script.Parent:WaitForChild("Buttons", 10)
	if not buttons then warn("Buttons folder not found!") return end
	for _, button in pairs(buttons:GetChildren()) do
		task.spawn(function()
			local head = button:FindFirstChild("Head")
			if not head then return end
			local objectValue = button:FindFirstChild("Object")
			if not objectValue or not objectValue.Value then
				head.CanCollide = false
				head.Transparency = 1
				return
			end
			local purchaseObject = script.Parent.Purchases:FindFirstChild(objectValue.Value)
			if purchaseObject then
				Objects[purchaseObject.Name] = purchaseObject:Clone()
				purchaseObject:Destroy()
			else
				head.CanCollide = false
				head.Transparency = 1
				return
			end
			head.Touched:Connect(function(hit)
				if not head.CanCollide or head.Transparency >= 1 then return end
				local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
				if not humanoid or humanoid.Health <= 0 then return end
				local player = Players:GetPlayerFromCharacter(hit.Parent)
				if not player or Owner.Value ~= player then return end
				local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
				if not playerStats then return end
				local price = button.Price.Value
				local gamepass = button:FindFirstChild("Gamepass")
				if gamepass and gamepass.Value > 0 then
					local hasPass = false
					local ok, owns = pcall(function()
						return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepass.Value)
					end)
					if ok then hasPass = owns end
					if hasPass then
						ProcessPurchase(button, player, playerStats, 0)
					else
						MarketplaceService:PromptGamePassPurchase(player, gamepass.Value)
					end
				elseif button:FindFirstChild("DevProduct") and button.DevProduct.Value > 0 then
					MarketplaceService:PromptProductPurchase(player, button.DevProduct.Value)
				else
					if playerStats.Value >= price then
						ProcessPurchase(button, player, playerStats, price)
					else
						PlaySound(head, Settings.Sounds.ErrorBuy)
					end
				end
			end)
		end)
	end
end

function ProcessPurchase(button, player, stats, cost)
	local objectName = button.Object.Value
	local object = Objects[objectName]
	if not object then return end
	stats.Value -= cost
	object.Parent = script.Parent.PurchasedObjects
	local head = button:FindFirstChild("Head")
	if head then
		head.CanCollide = false
		local tween = TweenService:Create(head, TweenInfo.new(Settings.FadeOutTime, Enum.EasingStyle.Quad), {Transparency = 1})
		tween:Play()
	end
end

task.spawn(SetupPartCollectors)
task.spawn(SetupPlayerCollector)
task.spawn(SetupButtons)

debugPrint("Tycoon core initialized for", Owner.Value and Owner.Value.Name or "unowned tycoon")

