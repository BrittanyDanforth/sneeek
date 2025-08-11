--[[
	Fully Polished Purchase Handler - Complete Version
	Fixes: Button positioning, floating/underground buttons, part collection, smooth animations
	All issues addressed with detailed handling
--]]

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Get settings and references
local Settings = require(script.Parent.Parent.Parent.Settings)
local Objects = {}
local TeamColor = script.Parent:WaitForChild("TeamColor").Value
local Money = script.Parent:WaitForChild("CurrencyToCollect")
local Stealing = Settings.StealSettings
local CanSteal = true

-- Set spawn colors
local essentials = script.Parent:WaitForChild("Essentials")
local spawn = essentials:WaitForChild("Spawn")
spawn.TeamColor = TeamColor
spawn.BrickColor = TeamColor

-- Sound function with validation
local function playSound(part, soundId)
	if not part or not soundId then return end
	if part:FindFirstChild("Sound") then return end

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. tostring(soundId)
	sound.Volume = 0.5
	sound.Parent = part

	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

-- PART COLLECTOR - Smooth collection without flinging
local collectedParts = {}

for _, collector in ipairs(essentials:GetChildren()) do
	if collector.Name == "PartCollector" then
		-- Make collector non-collidable to prevent flinging
		collector.CanCollide = false
		collector.CanTouch = true
		collector.CanQuery = false

		collector.Touched:Connect(function(part)
			if collectedParts[part] or not part:IsDescendantOf(workspace) then return end

			local cashValue = part:FindFirstChild("Cash")
			if cashValue and cashValue:IsA("IntValue") then
				collectedParts[part] = true
				
				-- Add money
				Money.Value = Money.Value + cashValue.Value

				-- Stop part physics
				if part.AssemblyLinearVelocity then
					part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				end
				if part.AssemblyAngularVelocity then
					part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
				end
				
				part.Anchored = true
				part.CanCollide = false
				part.CanTouch = false
				part.CanQuery = false

				-- Quick fade animation
				if part:IsA("BasePart") then
					local fadeTween = TweenService:Create(part, 
						TweenInfo.new(0.3, Enum.EasingStyle.Linear),
						{Transparency = 1}
					)

					-- Fade visual elements
					for _, child in ipairs(part:GetDescendants()) do
						if child:IsA("Decal") or child:IsA("Texture") then
							TweenService:Create(child,
								TweenInfo.new(0.3, Enum.EasingStyle.Linear),
								{Transparency = 1}
							):Play()
						elseif child:IsA("ParticleEmitter") then
							child.Enabled = false
						elseif child:IsA("PointLight") or child:IsA("SpotLight") then
							TweenService:Create(child,
								TweenInfo.new(0.3, Enum.EasingStyle.Linear),
								{Brightness = 0}
							):Play()
						end
					end

					fadeTween:Play()
					fadeTween.Completed:Connect(function()
						if part and part.Parent then
							part:Destroy()
						end
					end)
				else
					part:Destroy()
				end

				-- Clean tracking
				task.delay(0.5, function()
					collectedParts[part] = nil
				end)
			end
		end)
	end
end

-- PLAYER MONEY COLLECTOR
local collectorDebounce = {}
local giver = essentials:WaitForChild("Giver")

giver.Touched:Connect(function(hit)
	local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player then return end

	-- Owner collecting
	if script.Parent.Owner.Value == player then
		if collectorDebounce[player] then return end
		collectorDebounce[player] = true

		giver.BrickColor = BrickColor.new("Bright red")

		local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
		if playerStats and Money.Value > 0 then
			playSound(essentials, Settings.Sounds.Collect)
			playerStats.Value = playerStats.Value + Money.Value
			Money.Value = 0
		end

		task.wait(1)
		giver.BrickColor = BrickColor.new("Sea green")
		collectorDebounce[player] = nil

	-- Stealing
	elseif Stealing.Stealing and CanSteal then
		CanSteal = false

		task.delay(Stealing.PlayerProtection, function()
			CanSteal = true
		end)

		local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
		if playerStats and Money.Value > 0 then
			local stealAmount = math.floor(Money.Value * Stealing.StealPrecent)
			if stealAmount > 0 then
				playSound(essentials, Settings.Sounds.Collect)
				playerStats.Value = playerStats.Value + stealAmount
				Money.Value = Money.Value - stealAmount
			end
		end
	else
		playSound(essentials, Settings.Sounds.ErrorBuy)
	end
end)

-- BUTTON SETUP - FIX POSITIONING ISSUES
local buttons = script.Parent:WaitForChild("Buttons")
local purchases = script.Parent:WaitForChild("Purchases")
local purchasedObjects = script.Parent:WaitForChild("PurchasedObjects")

-- Tween settings
local fadeInInfo = TweenInfo.new(
	Settings.FadeInTime or 0.5,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.Out
)

local fadeOutInfo = TweenInfo.new(
	Settings.FadeOutTime or 0.5,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.In
)

-- FIX BUTTON POSITIONS ON STARTUP
local function fixButtonPosition(button)
	local head = button:FindFirstChild("Head")
	if not head then return end
	
	-- Ensure button head is properly positioned
	if head:IsA("BasePart") then
		-- Make sure button is anchored
		head.Anchored = true
		
		-- Check if button has a base/platform it should be on
		local base = button:FindFirstChild("Base") or button:FindFirstChild("Platform")
		if base and base:IsA("BasePart") then
			-- Position head relative to base
			head.CFrame = base.CFrame + Vector3.new(0, (base.Size.Y/2) + (head.Size.Y/2) + 0.1, 0)
		else
			-- Ensure button isn't underground
			-- Raycast down to find ground
			local ray = workspace:Raycast(
				head.Position + Vector3.new(0, 10, 0),
				Vector3.new(0, -50, 0),
				RaycastParams.new()
			)
			
			if ray and ray.Instance then
				-- Position button slightly above ground
				head.Position = ray.Position + Vector3.new(0, head.Size.Y/2 + 0.1, 0)
			end
		end
		
		-- Ensure proper collision
		head.CanCollide = true
		head.CanTouch = true
	end
end

-- Process each button
for _, button in ipairs(buttons:GetChildren()) do
	task.spawn(function()
		-- Fix button position first
		fixButtonPosition(button)
		
		local head = button:FindFirstChild("Head")
		if not head then return end

		-- Load object for this button
		local objectValue = button:FindFirstChild("Object")
		if not objectValue then 
			warn("No Object value for button:", button.Name)
			return 
		end
		
		local objectName = objectValue.Value
		local purchaseObject = purchases:FindFirstChild(objectName)

		if purchaseObject then
			Objects[objectName] = purchaseObject:Clone()
			-- Fix object position if needed
			if Objects[objectName]:IsA("Model") then
				local primaryPart = Objects[objectName].PrimaryPart or Objects[objectName]:FindFirstChildWhichIsA("BasePart")
				if primaryPart then
					-- Ensure model isn't positioned underground
					local pos = primaryPart.Position
					if pos.Y < -50 then
						warn("Object", objectName, "appears to be underground, adjusting...")
						Objects[objectName]:TranslateBy(Vector3.new(0, 100, 0))
					end
				end
			end
			purchaseObject:Destroy()
		else
			warn("Object missing for button:", button.Name, "Object:", objectName)
			head.CanCollide = false
			head.Transparency = 1
			return
		end

		-- Handle dependencies
		local dependency = button:FindFirstChild("Dependency")
		if dependency then
			head.CanCollide = false
			head.Transparency = 1

			-- Wait for dependency
			local success, dependencyObject = pcall(function()
				return purchasedObjects:WaitForChild(dependency.Value, 30)
			end)
			
			if not success or not dependencyObject then
				warn("Dependency not found for button:", button.Name)
				return
			end

			-- Fix position before fading in
			fixButtonPosition(button)

			-- Fade in
			if Settings.ButtonsFadeIn then
				local tween = TweenService:Create(head, fadeInInfo, {Transparency = 0})
				tween:Play()
				tween.Completed:Wait()
			else
				head.Transparency = 0
			end

			head.CanCollide = true
		end

		-- Button touch handling
		local purchaseDebounce = {}

		head.Touched:Connect(function(hit)
			if not head.CanCollide or head.Transparency > 0.9 then return end

			local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
			if not humanoid or humanoid.Health <= 0 then return end

			local player = Players:GetPlayerFromCharacter(hit.Parent)
			if not player or player ~= script.Parent.Owner.Value then return end

			-- Debounce
			if purchaseDebounce[player] then return end
			purchaseDebounce[player] = true

			task.defer(function()
				task.wait(0.5)
				purchaseDebounce[player] = nil
			end)

			local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
			if not playerStats then return end

			-- Gamepass
			local gamepass = button:FindFirstChild("Gamepass")
			if gamepass and gamepass.Value >= 1 then
				local hasPass = false
				local success, result = pcall(function()
					return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepass.Value)
				end)

				if success then hasPass = result end

				if hasPass then
					processPurchase(button, playerStats)
				else
					MarketplaceService:PromptGamePassPurchase(player, gamepass.Value)
				end
				return
			end

			-- Dev Product
			local devProduct = button:FindFirstChild("DevProduct")
			if devProduct and devProduct.Value >= 1 then
				MarketplaceService:PromptProductPurchase(player, devProduct.Value)
				return
			end

			-- Regular purchase
			local price = button:FindFirstChild("Price")
			if price and playerStats.Value >= price.Value then
				processPurchase(button, playerStats)
				playSound(head, Settings.Sounds.Purchase)
			else
				playSound(head, Settings.Sounds.ErrorBuy)
			end
		end)
	end)
end

-- PURCHASE FUNCTION - Simple and reliable
function processPurchase(button, playerStats)
	local price = button.Price.Value
	local objectName = button.Object.Value

	-- Deduct cost
	playerStats.Value = playerStats.Value - price

	-- Spawn object without modifications
	if Objects[objectName] then
		local newObject = Objects[objectName]:Clone()
		
		-- Ensure we're not spawning underground
		if newObject:IsA("Model") then
			local primaryPart = newObject.PrimaryPart or newObject:FindFirstChildWhichIsA("BasePart")
			if primaryPart and primaryPart.Position.Y < -50 then
				warn("Spawning", objectName, "above ground to prevent underground placement")
				newObject:SetPrimaryPartCFrame(CFrame.new(primaryPart.Position + Vector3.new(0, 60, 0)))
			end
		elseif newObject:IsA("BasePart") and newObject.Position.Y < -50 then
			newObject.Position = newObject.Position + Vector3.new(0, 60, 0)
		end
		
		newObject.Parent = purchasedObjects
	end

	-- Fade out button
	local head = button:FindFirstChild("Head")
	if head then
		head.CanCollide = false

		if Settings.ButtonsFadeOut then
			local tween = TweenService:Create(head, fadeOutInfo, {Transparency = 1})
			tween:Play()
		else
			head.Transparency = 1
		end
	end
end

-- BUYOBJECT HANDLER
local buyObject = script.Parent:WaitForChild("BuyObject")

buyObject.ChildAdded:Connect(function(child)
	task.wait(0.1)

	local cost = child:FindFirstChild("Cost")
	local button = child:FindFirstChild("Button")
	local stats = child:FindFirstChild("Stats")

	if cost and button and stats and button.Value and stats.Value then
		local tempButton = {
			Price = cost,
			Object = button.Value:FindFirstChild("Object")
		}
		if tempButton.Object then
			processPurchase(tempButton, stats.Value)
		end
	end

	task.wait(10)
	if child and child.Parent then
		child:Destroy()
	end
end)

-- GAMEPASS HANDLER
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
	if not wasPurchased then return end
	if script.Parent.Owner.Value ~= player then return end

	for _, button in ipairs(buttons:GetChildren()) do
		local gamepass = button:FindFirstChild("Gamepass")
		if gamepass and gamepass.Value == gamePassId then
			local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
			if playerStats then
				processPurchase(button, playerStats)
				playSound(button:FindFirstChild("Head"), Settings.Sounds.Purchase)
			end
			break
		end
	end
end)

-- DEVPRODUCT HANDLER
if not _G.ProcessReceiptRegistered then
	_G.ProcessReceiptRegistered = true
	
	MarketplaceService.ProcessReceipt = function(receiptInfo)
		local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if not player then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		-- Find tycoon
		local tycoon = nil
		for _, t in ipairs(workspace:GetDescendants()) do
			if t:FindFirstChild("Owner") and t.Owner.Value == player then
				tycoon = t
				break
			end
		end

		if not tycoon then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		-- Find button
		local buttons = tycoon:FindFirstChild("Buttons")
		if buttons then
			for _, button in ipairs(buttons:GetChildren()) do
				local devProduct = button:FindFirstChild("DevProduct")
				if devProduct and devProduct.Value == receiptInfo.ProductId then
					local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
					if playerStats then
						local purchase = Instance.new("Model")
						Instance.new("NumberValue", purchase).Name = "Cost"
						purchase.Cost.Value = 0
						
						local buttonValue = Instance.new("ObjectValue", purchase)
						buttonValue.Name = "Button"
						buttonValue.Value = button
						
						local statsValue = Instance.new("ObjectValue", purchase)
						statsValue.Name = "Stats"
						statsValue.Value = playerStats
						
						purchase.Parent = tycoon:FindFirstChild("BuyObject")
						
						return Enum.ProductPurchaseDecision.PurchaseGranted
					end
				end
			end
		end

		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

print("✅ Fully Polished Purchase Handler loaded!")
print("   ✓ Fixed button positioning on startup")
print("   ✓ Underground/floating detection and correction")
print("   ✓ Smooth part collection")
print("   ✓ All purchase types handled")