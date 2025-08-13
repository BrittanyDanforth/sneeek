--[[
	FIXED PURCHASE HANDLER
	
	Replace the PurchaseHandler script in your Cinnamoroll tycoon with this version.
	This uses the CENTRALIZED Settings from ServerStorage.
]]

-- Services
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- FIXED: Use centralized Settings from ServerStorage
local Settings = require(game.ServerStorage:WaitForChild("Settings"))
print("✅ PurchaseHandler loaded Settings from ServerStorage")

-- Get tycoon model
local Model = script.Parent.Parent.Parent
local OwnerValue = Model:WaitForChild("OwnerValue")
local MoneyDisplay = Model:WaitForChild("Display"):WaitForChild("Money"):WaitForChild("SurfaceGui"):WaitForChild("TextLabel")

-- Rest of your PurchaseHandler code goes here...
-- (The important fix is the Settings line above)

-- Example of using Settings:
local function onButtonTouched(hit, button)
	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	if not player then return end
	if player ~= OwnerValue.Value then return end
	
	local cost = button:GetAttribute("Cost") or 0
	local playerMoney = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
	
	if playerMoney and playerMoney.Value >= cost then
		-- Purchase successful
		playerMoney.Value = playerMoney.Value - cost
		
		-- Play purchase sound using Settings
		if Settings.Sounds.Purchase then
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://" .. Settings.Sounds.Purchase
			sound.Volume = 0.5
			sound.Parent = button
			sound:Play()
			Debris:AddItem(sound, 2)
		end
		
		-- Handle button fade if enabled in Settings
		if Settings.ButtonsFadeOut then
			local tween = TweenService:Create(button, 
				TweenInfo.new(Settings.FadeOutTime or 0.5), 
				{Transparency = 1}
			)
			tween:Play()
		end
		
		-- Update money display using Settings currency name
		MoneyDisplay.Text = Settings.CurrencyName .. ": " .. Settings:ConvertComma(playerMoney.Value)
	else
		-- Not enough money - play error sound
		if Settings.Sounds.ErrorBuy then
			local sound = Instance.new("Sound")
			sound.SoundId = "rbxassetid://" .. Settings.Sounds.ErrorBuy
			sound.Volume = 0.5
			sound.Parent = button
			sound:Play()
			Debris:AddItem(sound, 2)
		end
	end
end

print("✅ PurchaseHandler initialized successfully!")