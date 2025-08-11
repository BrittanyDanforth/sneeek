-- FIXED purchase function - simple version that works for ALL objects
function processPurchase(button, playerStats)
	local price = button.Price.Value
	local objectName = button.Object.Value

	-- Deduct cost
	playerStats.Value = playerStats.Value - price

	-- Spawn object EXACTLY as it is, no modifications
	if Objects[objectName] then
		local newObject = Objects[objectName]:Clone()
		newObject.Parent = purchasedObjects
		
		-- That's it! No animations, no moving, no CFrame changes
		-- Objects spawn exactly where they were designed to be
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