--[[
	Polished Purchase Handler - Fixed Version
	Handles tycoon purchases and money collection with smooth animations
	Fixed: Spawn positions, part flinging, smooth fade effects
--]]

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
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

-- Modern sound function with error handling
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

-- MODERNIZED PART COLLECTOR WITH SMOOTH FADE
local collectedParts = {} -- Prevent double collection

for _, collector in ipairs(essentials:GetChildren()) do
	if collector.Name == "PartCollector" then
		-- Fix flinging by making collector non-collidable
		collector.CanCollide = false
		collector.CanTouch = true -- Ensure it can still detect touches
		collector.CanQuery = false

		collector.Touched:Connect(function(part)
			-- Skip if already collected or not a valid part
			if collectedParts[part] or not part:IsDescendantOf(workspace) then return end

			local cashValue = part:FindFirstChild("Cash")
			if cashValue and cashValue:IsA("IntValue") then
				-- Mark as collected immediately
				collectedParts[part] = true

				-- Add money
				Money.Value = Money.Value + cashValue.Value

				-- Stop the part completely
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

				-- Smooth fade animation
				if part:IsA("BasePart") then
					-- Store original transparency for meshes
					local meshPart = part:FindFirstChildOfClass("SpecialMesh") or part:FindFirstChildOfClass("MeshPart")
					
					-- Create fade tween (0.3 seconds - faster for better performance)
					local fadeTween = TweenService:Create(part, 
						TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{Transparency = 1}
					)

					-- Fade any visual elements
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
						elseif child:IsA("SpecialMesh") and child.VertexColor then
							-- Fade mesh to transparent
							TweenService:Create(child,
								TweenInfo.new(0.3, Enum.EasingStyle.Linear),
								{VertexColor = Vector3.new(1, 1, 1)}
							):Play()
						end
					end

					-- Play fade animation
					fadeTween:Play()

					-- Destroy after fade completes
					fadeTween.Completed:Connect(function()
						if part and part.Parent then
							part:Destroy()
						end
					end)
				else
					-- Non-basepart, just destroy
					part:Destroy()
				end

				-- Clean tracking table after animation
				task.delay(0.5, function()
					collectedParts[part] = nil
				end)
			end
		end)
	end
end

-- Modern player collector with debounce
local collectorDebounce = {}
local giver = essentials:WaitForChild("Giver")

giver.Touched:Connect(function(hit)
	local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player then return end

	-- Owner collecting money
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

	-- Stealing mechanic
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

-- Modern button setup with async loading
local buttons = script.Parent:WaitForChild("Buttons")
local purchases = script.Parent:WaitForChild("Purchases")
local purchasedObjects = script.Parent:WaitForChild("PurchasedObjects")

-- Tween settings for fading
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

-- Process each button
for _, button in ipairs(buttons:GetChildren()) do
	task.spawn(function()
		local head = button:FindFirstChild("Head")
		if not head then return end

		-- Load the object for this button
		local objectValue = button:FindFirstChild("Object")
		if not objectValue then 
			warn("No Object value for button:", button.Name)
			return 
		end
		
		local objectName = objectValue.Value
		local purchaseObject = purchases:FindFirstChild(objectName)

		if purchaseObject then
			Objects[objectName] = purchaseObject:Clone()
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

			-- Wait for dependency with timeout
			local dependencyObject = purchasedObjects:WaitForChild(dependency.Value, 30)
			if not dependencyObject then
				warn("Dependency timeout for button:", button.Name)
				return
			end

			-- Fade in button smoothly
			if Settings.ButtonsFadeIn then
				local tween = TweenService:Create(head, fadeInInfo, {Transparency = 0})
				tween:Play()
				tween.Completed:Wait()
			else
				head.Transparency = 0
			end

			head.CanCollide = true
		end

		-- Handle button touches
		local purchaseDebounce = {}

		head.Touched:Connect(function(hit)
			if not head.CanCollide then return end

			local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
			if not humanoid or humanoid.Health <= 0 then return end

			local player = Players:GetPlayerFromCharacter(hit.Parent)
			if not player or player ~= script.Parent.Owner.Value then return end

			-- Prevent spam clicking
			if purchaseDebounce[player] then return end
			purchaseDebounce[player] = true

			task.defer(function()
				task.wait(0.5)
				purchaseDebounce[player] = nil
			end)

			local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
			if not playerStats then return end

			-- Handle gamepass purchases
			local gamepass = button:FindFirstChild("Gamepass")
			if gamepass and gamepass.Value >= 1 then
				local hasPass = false
				local success, result = pcall(function()
					return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepass.Value)
				end)

				if success then
					hasPass = result
				end

				if hasPass then
					processPurchase(button, playerStats)
				else
					MarketplaceService:PromptGamePassPurchase(player, gamepass.Value)
				end
				return
			end

			-- Handle dev product purchases
			local devProduct = button:FindFirstChild("DevProduct")
			if devProduct and devProduct.Value >= 1 then
				MarketplaceService:PromptProductPurchase(player, devProduct.Value)
				return
			end

			-- Handle regular purchases
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

-- FIXED purchase function - no spawn animation causing floating/underground issues
function processPurchase(button, playerStats)
	local price = button.Price.Value
	local objectName = button.Object.Value

	-- Deduct cost
	playerStats.Value = playerStats.Value - price

	-- Spawn object at its EXACT designed position
	if Objects[objectName] then
		local newObject = Objects[objectName]:Clone()
		newObject.Parent = purchasedObjects
		
		-- NO SPAWN ANIMATION - objects appear exactly where they should
		-- This prevents floating or underground placement issues
		
		-- Optional: Add a subtle effect at spawn location
		if newObject:IsA("Model") and newObject.PrimaryPart then
			-- Create a quick flash effect at spawn
			local flashPart = Instance.new("Part")
			flashPart.Name = "SpawnFlash"
			flashPart.Size = Vector3.new(4, 0.1, 4)
			flashPart.Material = Enum.Material.Neon
			flashPart.BrickColor = BrickColor.new("Institutional white")
			flashPart.Transparency = 0.5
			flashPart.Anchored = true
			flashPart.CanCollide = false
			flashPart.CanTouch = false
			flashPart.CanQuery = false
			flashPart.CFrame = newObject:GetPrimaryPartCFrame() * CFrame.new(0, -2, 0)
			flashPart.Parent = workspace
			
			-- Fade out flash
			TweenService:Create(flashPart,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{Transparency = 1, Size = Vector3.new(8, 0.1, 8)}
			):Play()
			
			Debris:AddItem(flashPart, 0.6)
		end
	end

	-- Fade out button smoothly
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

-- Handle BuyObject folder (for dev products and special purchases)
local buyObject = script.Parent:WaitForChild("BuyObject")

buyObject.ChildAdded:Connect(function(child)
	task.wait(0.1) -- Small delay to ensure values are set

	local cost = child:FindFirstChild("Cost")
	local button = child:FindFirstChild("Button")
	local stats = child:FindFirstChild("Stats")

	if cost and button and stats and button.Value and stats.Value then
		-- Create a temporary button structure for processPurchase
		local tempButton = {
			Price = cost,
			Object = button.Value:FindFirstChild("Object")
		}
		if tempButton.Object then
			processPurchase(tempButton, stats.Value)
		end
	end

	-- Clean up after processing
	task.wait(10)
	if child and child.Parent then
		child:Destroy()
	end
end)

-- Handle gamepass purchases
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
	if not wasPurchased then return end
	if script.Parent.Owner.Value ~= player then return end -- Only process for tycoon owner

	-- Find the button for this gamepass
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

-- Global ProcessReceipt handler for dev products
if not _G.ProcessReceiptRegistered then
	_G.ProcessReceiptRegistered = true
	
	MarketplaceService.ProcessReceipt = function(receiptInfo)
		local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if not player then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		-- Find which tycoon owns this player
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

		-- Find button with this dev product in the owner's tycoon
		local buttons = tycoon:FindFirstChild("Buttons")
		if buttons then
			for _, button in ipairs(buttons:GetChildren()) do
				local devProduct = button:FindFirstChild("DevProduct")
				if devProduct and devProduct.Value == receiptInfo.ProductId then
					local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
					if playerStats then
						-- Process the purchase through BuyObject system
						local purchase = Instance.new("Model")
						Instance.new("NumberValue", purchase).Name = "Cost"
						purchase.Cost.Value = 0 -- Already paid via dev product
						
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

print("✅ Polished Purchase Handler loaded successfully!")
print("   - Fixed: Spawn positions (no floating/underground)")
print("   - Fixed: Part collection flinging")
print("   - Added: Smooth fade effects")
print("   - Added: Spawn flash effect")