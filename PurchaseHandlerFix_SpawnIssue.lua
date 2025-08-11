-- Fixed processPurchase function - Replace this in your PurchaseHandler script

function processPurchase(button, playerStats)
	local price = button.Price.Value
	local objectName = button.Object.Value

	-- Deduct cost and spawn object
	playerStats.Value = playerStats.Value - price

	if Objects[objectName] then
		local newObject = Objects[objectName]:Clone()
		newObject.Parent = purchasedObjects
		
		-- REMOVED THE SPAWN ANIMATION
		-- Objects now spawn exactly where they're supposed to be
		-- No more floating or underground objects!
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