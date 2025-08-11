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
local Settings = require(script.Parent.Parent.Parent.Settings)
local TeamColor = script.Parent.TeamColor.Value
local Money = script.Parent.CurrencyToCollect
local Owner = script.Parent.Owner

-- Debug mode
local DEBUG_MODE = true -- Set to false in production

-- State tracking
local Objects = {}
local ButtonDebounces = {}
local CollectorDebounce = false
local StealDebounce = {}

-- Initialize
script.Parent.Essentials.Spawn.TeamColor = TeamColor
script.Parent.Essentials.Spawn.BrickColor = TeamColor

-- Debug print function
local function debugPrint(...)
	if DEBUG_MODE then
		print("[TYCOON]", script.Parent.Name, ...)
	end
end

-- Sound management
local SoundCache = {}
local function PlaySound(part, soundId)
	-- Check cache for existing sound
	local cacheKey = part:GetFullName() .. "_" .. tostring(soundId)
	if SoundCache[cacheKey] and SoundCache[cacheKey].Parent then
		SoundCache[cacheKey]:Play()
		return
	end
	
	-- Create new sound
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. tostring(soundId)
	sound.Volume = 0.5
	sound.Parent = part
	
	-- Cache and play
	SoundCache[cacheKey] = sound
	sound:Play()
	
	-- Cleanup finished sounds
	sound.Ended:Connect(function()
		if SoundCache[cacheKey] == sound then
			SoundCache[cacheKey] = nil
		end
		sound:Destroy()
	end)
end

-- Enhanced part collector with debugging
local function SetupPartCollectors()
	debugPrint("Setting up part collectors...")
	local collectorCount = 0
	
	for _, collector in pairs(script.Parent.Essentials:GetChildren()) do
		if collector.Name == "PartCollector" then
			collectorCount = collectorCount + 1
			
			collector.Touched:Connect(function(part)
				if part:FindFirstChild("Cash") and part.Cash:IsA("IntValue") then
					local cashValue = part.Cash.Value
					Money.Value = Money.Value + cashValue
					
					debugPrint("Collected part worth", cashValue, "Total:", Money.Value)
					
					-- Visual feedback
					if part:IsA("BasePart") then
						local tween = TweenService:Create(part, 
							TweenInfo.new(0.2, Enum.EasingStyle.Quad), 
							{Transparency = 1, Size = part.Size * 0.5}
						)
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

-- Enhanced player collector with anti-spam
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
		
		-- Owner collection
		if Owner.Value == player then
			if Money.Value <= 0 then
				debugPrint(player.Name, "tried to collect but has 0 money")
				return
			end
			
			CollectorDebounce = true
			
			-- Visual feedback
			local originalColor = giver.BrickColor
			giver.BrickColor = BrickColor.new("Bright red")
			
			-- Get player stats
			local stats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
			if stats then
				local collected = Money.Value
				stats.Value = stats.Value + collected
				Money.Value = 0
				
				PlaySound(giver, Settings.Sounds.Collect)
				debugPrint(player.Name, "collected", collected, "cash. New total:", stats.Value)
				
				-- Update leaderboard if using global API
				if _G.SetPlayerMoney then
					_G.SetPlayerMoney(player.Name, stats.Value)
				end
			else
				warn("Player stats not found for", player.Name)
			end
			
			wait(1)
			giver.BrickColor = originalColor
			CollectorDebounce = false
			
		-- Stealing
		elseif Settings.StealSettings.Stealing then
			local stealKey = player.UserId
			
			if StealDebounce[stealKey] then
				PlaySound(giver, Settings.Sounds.ErrorBuy)
				debugPrint(player.Name, "steal on cooldown")
				return
			end
			
			if Money.Value <= 0 then
				debugPrint(player.Name, "tried to steal but tycoon has 0 money")
				return
			end
			
			StealDebounce[stealKey] = true
			
			local stats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
			if stats then
				local stealAmount = math.floor(Money.Value * Settings.StealSettings.StealPercent)
				stats.Value = stats.Value + stealAmount
				Money.Value = Money.Value - stealAmount
				
				PlaySound(giver, Settings.Sounds.Collect)
				debugPrint(player.Name, "stole", stealAmount, "cash from", Owner.Value and Owner.Value.Name or "unowned tycoon")
				
				-- Update leaderboard
				if _G.SetPlayerMoney then
					_G.SetPlayerMoney(player.Name, stats.Value)
				end
			end
			
			-- Cooldown
			task.delay(Settings.StealSettings.PlayerProtection, function()
				StealDebounce[stealKey] = nil
				debugPrint(player.Name, "can steal again")
			end)
		end
	end)
end

-- Enhanced button system with better debugging
local function SetupButtons()
	local buttons = script.Parent:WaitForChild("Buttons", 10)
	if not buttons then
		warn("Buttons folder not found!")
		return
	end
	
	debugPrint("Setting up buttons...")
	local buttonCount = 0
	
	for _, button in pairs(buttons:GetChildren()) do
		task.spawn(function()
			local head = button:FindFirstChild("Head")
			if not head then 
				warn("Button", button.Name, "missing Head part")
				return 
			end
			
			buttonCount = buttonCount + 1
			
			-- Load button object
			local objectValue = button:FindFirstChild("Object")
			if not objectValue or not objectValue.Value then
				warn("Button", button.Name, "missing Object value")
				head.CanCollide = false
				head.Transparency = 1
				return
			end
			
			local purchaseObject = script.Parent.Purchases:FindFirstChild(objectValue.Value)
			if purchaseObject then
				Objects[purchaseObject.Name] = purchaseObject:Clone()
				purchaseObject:Destroy()
				debugPrint("Loaded object", purchaseObject.Name, "for button", button.Name)
			else
				warn("Object", objectValue.Value, "not found for button", button.Name)
				head.CanCollide = false
				head.Transparency = 1
				return
			end
			
			-- Handle dependencies
			local dependency = button:FindFirstChild("Dependency")
			if dependency and dependency.Value ~= "" then
				head.CanCollide = false
				head.Transparency = 1
				
				debugPrint("Button", button.Name, "waiting for dependency:", dependency.Value)
				
				-- Wait for dependency
				script.Parent.PurchasedObjects.ChildAdded:Connect(function(child)
					if child.Name == dependency.Value then
						debugPrint("Dependency", dependency.Value, "met for button", button.Name)
						
						-- Fade in
						if Settings.ButtonsFadeIn then
							local fadeInfo = TweenInfo.new(Settings.FadeInTime, Enum.EasingStyle.Quad)
							local fadeTween = TweenService:Create(head, fadeInfo, {Transparency = 0})
							fadeTween:Play()
							fadeTween.Completed:Connect(function()
								head.CanCollide = true
							end)
						else
							head.Transparency = 0
							head.CanCollide = true
						end
					end
				end)
			end
			
			-- Button touch handler
			head.Touched:Connect(function(hit)
				if not head.CanCollide or head.Transparency >= 1 then return end
				
				local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
				if not humanoid or humanoid.Health <= 0 then return end
				
				local player = Players:GetPlayerFromCharacter(hit.Parent)
				if not player or Owner.Value ~= player then return end
				
				-- Debounce
				local debounceKey = player.UserId .. "_" .. button.Name
				if ButtonDebounces[debounceKey] then return end
				ButtonDebounces[debounceKey] = true
				
				-- Get player stats
				local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
				if not playerStats then 
					warn("Stats not found for", player.Name)
					ButtonDebounces[debounceKey] = nil
					return 
				end
				
				local price = button.Price.Value
				
				-- Handle gamepass
				local gamepass = button:FindFirstChild("Gamepass")
				if gamepass and gamepass.Value > 0 then
					debugPrint(player.Name, "checking gamepass", gamepass.Value, "for", button.Name)
					
					local hasPass = false
					local success, result = pcall(function()
						return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepass.Value)
					end)
					
					if success then
						hasPass = result
					end
					
					if hasPass then
						ProcessPurchase(button, player, playerStats, 0) -- Free for gamepass owners
					else
						MarketplaceService:PromptGamePassPurchase(player, gamepass.Value)
					end
					
				-- Handle dev product
				elseif button:FindFirstChild("DevProduct") and button.DevProduct.Value > 0 then
					debugPrint(player.Name, "prompting dev product", button.DevProduct.Value, "for", button.Name)
					MarketplaceService:PromptProductPurchase(player, button.DevProduct.Value)
					
				-- Regular purchase
				else
					if playerStats.Value >= price then
						ProcessPurchase(button, player, playerStats, price)
					else
						PlaySound(head, Settings.Sounds.ErrorBuy)
						debugPrint(player.Name, "cannot afford", button.Name, "- Cost:", price, "Has:", playerStats.Value)
					end
				end
				
				-- Debounce cooldown
				task.wait(0.5)
				ButtonDebounces[debounceKey] = nil
			end)
		end)
	end
	
	debugPrint("Initialized", buttonCount, "buttons")
end

-- Process purchase with enhanced feedback
function ProcessPurchase(button, player, stats, cost)
	local objectName = button.Object.Value
	local object = Objects[objectName]
	
	if not object then
		warn("Object not found for purchase:", objectName)
		return
	end
	
	-- Deduct cost
	stats.Value = stats.Value - cost
	
	-- Update leaderboard
	if _G.SetPlayerMoney then
		_G.SetPlayerMoney(player.Name, stats.Value)
	end
	
	-- Place object
	object.Parent = script.Parent.PurchasedObjects
	
	debugPrint(player.Name, "purchased", objectName, "for", cost, "- Balance:", stats.Value)
	
	-- Sound effect
	PlaySound(button.Head, Settings.Sounds.Purchase)
	
	-- Fade out button
	local head = button:FindFirstChild("Head")
	if head then
		head.CanCollide = false
		
		if Settings.ButtonsFadeOut then
			local fadeInfo = TweenInfo.new(Settings.FadeOutTime, Enum.EasingStyle.Quad)
			local fadeTween = TweenService:Create(head, fadeInfo, {Transparency = 1})
			fadeTween:Play()
		else
			head.Transparency = 1
		end
	end
	
	-- Fire purchase event if exists
	local purchaseEvent = script.Parent:FindFirstChild("PurchaseEvent")
	if purchaseEvent and purchaseEvent:IsA("BindableEvent") then
		purchaseEvent:Fire(player, objectName, cost)
	end
end

-- Remote purchase handler (for gamepasses/dev products)
script.Parent:WaitForChild("BuyObject").ChildAdded:Connect(function(child)
	task.wait() -- Let values populate
	
	local cost = child:FindFirstChild("Cost") and child.Cost.Value or 0
	local button = child:FindFirstChild("Button") and child.Button.Value
	local stats = child:FindFirstChild("Stats") and child.Stats.Value
	
	if button and stats then
		-- Find player from stats
		local playerName = stats.Parent and stats.Parent.Name
		local player = playerName and Players:FindFirstChild(playerName)
		
		if player then
			ProcessPurchase(button, player, stats, cost)
		end
	end
	
	-- Cleanup
	task.wait(1)
	child:Destroy()
end)

-- Initialize everything
task.spawn(SetupPartCollectors)
task.spawn(SetupPlayerCollector)
task.spawn(SetupButtons)

debugPrint("Tycoon core initialized for", Owner.Value and Owner.Value.Name or "unowned tycoon")