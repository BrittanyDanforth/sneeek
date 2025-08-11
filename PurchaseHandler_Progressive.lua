--[[
	Updated Purchase Handler with Progression System
	Combines your working purchase handler with proper dropper progression
	Fixed: Now hides buttons until prerequisites are met
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

-- PROGRESSION DATA - Define what unlocks what
local PROGRESSION_DATA = {
    -- Starting items (no requirements)
    ["1"] = { -- Buy Dropper - [$10,000]
        unlocks = {"2", "8"} -- Unlocks Dropper $20k and Conveyer $8k
    },
    ["2"] = { -- Buy Dropper - [$20,000]
        requires = {"1"},
        unlocks = {"3", "4"}
    },
    ["3"] = { -- Buy Dropper - [$12,000]
        requires = {"2"},
        unlocks = {"5", "16"}
    },
    ["4"] = { -- Buy Dropper - [$70]
        requires = {"2"},
        unlocks = {"7"}
    },
    ["5"] = { -- Buy Extra - [$35,000]
        requires = {"3"},
        unlocks = {"11"} -- Unlocks MEGA Dropper!
    },
    ["7"] = { -- Buy Floor - [$1,500]
        requires = {"4"},
        unlocks = {"18"}
    },
    ["8"] = { -- Buy Conveyer - [$8,000]
        requires = {"1"},
        unlocks = {"9"}
    },
    ["9"] = { -- Buy CORE Dropper - [$5,000]
        requires = {"8"},
        unlocks = {"10"}
    },
    ["10"] = { -- Buy POWER CORE Dropper - [$2,000]
        requires = {"9"},
        unlocks = {"14"}
    },
    ["11"] = { -- Buy MEGA Dropper - [$300] ⭐ KEY ITEM
        requires = {"5"},
        unlocks = {"12", "19", "13"} -- Unlocks Super, Walls, and Mega $7k
    },
    ["12"] = { -- Buy Super Dropper - [$1,000]
        requires = {"11"},
        unlocks = {"15"}
    },
    ["13"] = { -- Buy a Mega Dropper - [$7,000]
        requires = {"11"},
        unlocks = {"40"}
    },
    ["14"] = { -- Buy a Omega Dropper - [$15,000]
        requires = {"10"},
        unlocks = {"39"}
    },
    ["15"] = { -- Buy a Omega Dropper - [$9,000]
        requires = {"12"},
        unlocks = {"30"}
    },
    ["16"] = { -- Buy Path - [$10,000]
        requires = {"3"},
        unlocks = {"17"}
    },
    ["17"] = { -- Buy Path - [$10,000] (second one)
        requires = {"16"},
        unlocks = {"20"}
    },
    ["18"] = { -- Buy Path - [$250]
        requires = {"7"},
        unlocks = {"19"}
    },
    ["19"] = { -- Buy Walls - [$100]
        requires = {"18", "11"}, -- Requires both Path AND MEGA Dropper
        unlocks = {"21"}
    },
    ["20"] = { -- Buy Stair - [$2500]
        requires = {"17"},
        unlocks = {"21"}
    },
    -- Wall upgrades chain
    ["21"] = { -- Upgrade Walls - [$1,000]
        requires = {"19"},
        unlocks = {"25"}
    },
    ["25"] = { -- Upgrade Walls - [$12,000]
        requires = {"21"},
        unlocks = {"26"}
    },
    ["26"] = { -- Upgrade Walls - [$20,000]
        requires = {"25"},
        unlocks = {"27"}
    },
    ["27"] = { -- Upgrade Walls - [$28,000]
        requires = {"26"},
        unlocks = {"31"}
    },
    ["31"] = { -- Upgrade Walls - [$350]
        requires = {"27"},
        unlocks = {"35"}
    },
    ["35"] = { -- Upgrade Walls - [$7,000]
        requires = {"31"},
        unlocks = {"38"}
    },
    ["38"] = { -- Upgrade Walls - [$700]
        requires = {"35"},
        unlocks = {"30"}
    },
    ["30"] = { -- Upgrade Wall - [$35,000]
        requires = {"15", "38"},
        unlocks = {"32"}
    },
    ["32"] = { -- Upgrade Wall - [$45,000]
        requires = {"30"},
        unlocks = {"39"}
    },
    ["39"] = { -- Upgrade Roof - [$40,000]
        requires = {"14", "32"},
        unlocks = {}
    },
    ["40"] = { -- Buy an OwnerDoor - [$1,500]
        requires = {"13"},
        unlocks = {}
    }
}

-- Track purchased items
local purchasedItems = {}

-- Set spawn colors
local essentials = script.Parent:WaitForChild("Essentials")
local spawn = essentials:WaitForChild("Spawn")
spawn.TeamColor = TeamColor
spawn.BrickColor = TeamColor

-- Modern sound function
local function playSound(part, soundId)
	if part:FindFirstChild("Sound") then
		return
	end

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. tostring(soundId)
	sound.Volume = 0.5
	sound.Parent = part

	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

-- Check if button requirements are met
local function hasRequirements(buttonNumber)
    local data = PROGRESSION_DATA[tostring(buttonNumber)]
    if not data then return true end -- No data = always available
    
    if not data.requires then
        return true -- No requirements
    end
    
    -- Check all requirements
    for _, reqNum in pairs(data.requires) do
        if not purchasedItems[reqNum] then
            return false
        end
    end
    
    return true
end

-- Update button visibility based on progression
local function updateButtonVisibility()
    local buttons = script.Parent:WaitForChild("Buttons")
    
    for _, button in pairs(buttons:GetChildren()) do
        local head = button:FindFirstChild("Head")
        if head then
            local buttonNum = button.Name:match("%d+")
            
            if buttonNum then
                -- Already purchased - hide it
                if purchasedItems[buttonNum] then
                    head.Transparency = 1
                    head.CanCollide = false
                    local gui = head:FindFirstChildOfClass("SurfaceGui") or head:FindFirstChildOfClass("BillboardGui")
                    if gui then gui.Enabled = false end
                    
                -- Not purchased - check if it should be visible
                else
                    local data = PROGRESSION_DATA[buttonNum]
                    
                    -- Special case: Only button 1 starts visible
                    if buttonNum == "1" and next(purchasedItems) == nil then
                        head.Transparency = 0
                        head.CanCollide = true
                        local gui = head:FindFirstChildOfClass("SurfaceGui") or head:FindFirstChildOfClass("BillboardGui")
                        if gui then gui.Enabled = true end
                        
                    -- Check if this button has data and requirements are met
                    elseif data and hasRequirements(buttonNum) then
                        -- Show button
                        head.Transparency = 0
                        head.CanCollide = true
                        local gui = head:FindFirstChildOfClass("SurfaceGui") or head:FindFirstChildOfClass("BillboardGui")
                        if gui then gui.Enabled = true end
                        
                    else
                        -- Hide button - not in progression data or requirements not met
                        head.Transparency = 1
                        head.CanCollide = false
                        local gui = head:FindFirstChildOfClass("SurfaceGui") or head:FindFirstChildOfClass("BillboardGui")
                        if gui then gui.Enabled = false end
                    end
                end
            else
                -- No number in button name - hide it
                head.Transparency = 1
                head.CanCollide = false
                local gui = head:FindFirstChildOfClass("SurfaceGui") or head:FindFirstChildOfClass("BillboardGui")
                if gui then gui.Enabled = false end
            end
        end
    end
end

-- MODERNIZED PART COLLECTOR WITH SMOOTH FADE
local collectedParts = {} -- Prevent double collection

for _, collector in ipairs(essentials:GetChildren()) do
	if collector.Name == "PartCollector" then
		-- Fix flinging by making collector non-collidable
		collector.CanCollide = false

		collector.Touched:Connect(function(part)
			-- Skip if already collected
			if collectedParts[part] then return end

			local cashValue = part:FindFirstChild("Cash")
			if cashValue then
				-- Mark as collected immediately
				collectedParts[part] = true

				-- Add money
				Money.Value = Money.Value + cashValue.Value

				-- Stop the part in its tracks
				part.Anchored = true
				part.CanCollide = false
				part.CanTouch = false
				part.CanQuery = false

				-- Smooth fade animation
				if part:IsA("BasePart") then
					-- Create fade tween (0.5 seconds)
					local fadeTween = TweenService:Create(part, 
						TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
						{Transparency = 1}
					)

					-- Fade any visual elements
					for _, child in ipairs(part:GetDescendants()) do
						if child:IsA("Decal") or child:IsA("Texture") then
							TweenService:Create(child,
								TweenInfo.new(0.5, Enum.EasingStyle.Linear),
								{Transparency = 1}
							):Play()
						elseif child:IsA("ParticleEmitter") then
							child.Enabled = false
						elseif child:IsA("PointLight") or child:IsA("SpotLight") then
							TweenService:Create(child,
								TweenInfo.new(0.5, Enum.EasingStyle.Linear),
								{Brightness = 0}
							):Play()
						end
					end

					-- Play fade animation
					fadeTween:Play()

					-- Destroy after fade
					fadeTween.Completed:Connect(function()
						part:Destroy()
					end)
				else
					-- Non-basepart, just destroy
					part:Destroy()
				end

				-- Clean tracking table
				task.delay(1, function()
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
		if playerStats then
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

-- Initial visibility update
updateButtonVisibility()

-- Process each button
for _, button in ipairs(buttons:GetChildren()) do
	task.spawn(function()
		local head = button:FindFirstChild("Head")
		if not head then return end

		-- Load the object for this button
		local objectName = button:WaitForChild("Object").Value
		local purchaseObject = purchases:FindFirstChild(objectName)

		if purchaseObject then
			Objects[objectName] = purchaseObject:Clone()
			purchaseObject:Destroy()
		else
			warn("Object missing for button:", button.Name)
			head.CanCollide = false
			head.Transparency = 1
			return
		end

		-- Handle dependencies (keep existing functionality but respect progression)
		local dependency = button:FindFirstChild("Dependency")
		if dependency then
			-- Skip dependency handling - let progression system control visibility
			-- This prevents buttons from showing up just because their dependency exists
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
			local price = button:WaitForChild("Price").Value
			if playerStats.Value >= price then
				processPurchase(button, playerStats)
				playSound(head, Settings.Sounds.Purchase)
			else
				playSound(head, Settings.Sounds.ErrorBuy)
			end
		end)
	end)
end

-- Modern purchase function with smooth animations
function processPurchase(button, playerStats)
	local price = button.Price.Value
	local objectName = button.Object.Value

	-- Deduct cost and spawn object
	playerStats.Value = playerStats.Value - price

	if Objects[objectName] then
		local newObject = Objects[objectName]:Clone()
		newObject.Parent = purchasedObjects

		-- Optional spawn animation (drop from above)
		if newObject:IsA("Model") and newObject.PrimaryPart then
			local originalCFrame = newObject:GetPrimaryPartCFrame()
			newObject:SetPrimaryPartCFrame(originalCFrame + Vector3.new(0, 5, 0))

			-- Drop animation
			local primary = newObject.PrimaryPart
			TweenService:Create(primary, 
				TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
				{CFrame = originalCFrame}
			):Play()
		end
	end

	-- Mark button as purchased
	local buttonNum = button.Name:match("%d+")
	if buttonNum then
		purchasedItems[buttonNum] = true
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
	
	-- Update visibility for newly unlocked buttons
	updateButtonVisibility()
end

-- Handle BuyObject folder (for dev products and special purchases)
local buyObject = script.Parent:WaitForChild("BuyObject")

buyObject.ChildAdded:Connect(function(child)
	task.wait(0.1) -- Small delay to ensure values are set

	local cost = child:FindFirstChild("Cost")
	local button = child:FindFirstChild("Button")
	local stats = child:FindFirstChild("Stats")

	if cost and button and stats then
		processPurchase(button.Value, stats.Value)
	end

	-- Clean up after 10 seconds
	task.wait(10)
	if child.Parent then
		child:Destroy()
	end
end)

-- Handle gamepass purchases
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
	if not wasPurchased then return end

	-- Find the button for this gamepass
	for _, button in ipairs(buttons:GetChildren()) do
		local gamepass = button:FindFirstChild("Gamepass")
		if gamepass and gamepass.Value == gamePassId then
			local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
			if playerStats then
				processPurchase(button, playerStats)
			end
			break
		end
	end
end)

-- Handle dev product purchases properly
MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Find button with this dev product
	for _, button in ipairs(buttons:GetChildren()) do
		local devProduct = button:FindFirstChild("DevProduct")
		if devProduct and devProduct.Value == receiptInfo.ProductId then
			local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
			if playerStats then
				-- Create temp button for processPurchase
				local tempButton = {
					Price = {Value = 0}, -- Already paid
					Object = button.Object
				}
				processPurchase(tempButton, playerStats)
				return Enum.ProductPurchaseDecision.PurchaseGranted
			end
		end
	end

	return Enum.ProductPurchaseDecision.NotProcessedYet
end

-- Debug function to see button states
local function debugButtonStates()
    print("=== BUTTON VISIBILITY DEBUG ===")
    local buttons = script.Parent:WaitForChild("Buttons")
    
    for _, button in pairs(buttons:GetChildren()) do
        local head = button:FindFirstChild("Head")
        if head then
            local visible = head.Transparency == 0 and head.CanCollide
            local buttonNum = button.Name:match("%d+")
            local status = visible and "VISIBLE" or "HIDDEN"
            
            if visible then
                print("Button " .. button.Name .. " is " .. status)
                if buttonNum and PROGRESSION_DATA[buttonNum] then
                    local data = PROGRESSION_DATA[buttonNum]
                    if data.requires then
                        print("  Requires: " .. table.concat(data.requires, ", "))
                    end
                end
            end
        end
    end
    print("===============================")
end

-- Call debug after initial setup
task.wait(2)
debugButtonStates()

print("✅ Updated Purchase Handler with Progression loaded successfully!")