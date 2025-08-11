-- SIMPLE PART COLLECTOR FIX
-- Just replace the PartCollector section in your PurchaseHandler with this:

-- Set up part collectors with modern practices
local collectedParts = {} -- Prevent double collection

for _, collector in ipairs(essentials:GetChildren()) do
	if collector.Name == "PartCollector" then
		-- Fix: Make collector non-collidable to prevent flinging
		collector.CanCollide = false
		
		collector.Touched:Connect(function(part)
			local cashValue = part:FindFirstChild("Cash")
			if cashValue and not collectedParts[part] then
				-- Mark as collected
				collectedParts[part] = true
				
				-- Add money
				Money.Value = Money.Value + cashValue.Value
				
				-- Fix: Anchor part before destroying to prevent flinging
				part.Anchored = true
				part.CanCollide = false
				
				-- Destroy
				Debris:AddItem(part, 0.1)
				
				-- Clean up tracking
				task.delay(0.5, function()
					collectedParts[part] = nil
				end)
			end
		end)
	end
end