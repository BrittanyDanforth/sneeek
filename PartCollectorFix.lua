-- PART COLLECTOR FIX
-- Replace the part collector section in your PurchaseHandler with this code
-- This fixes the orb flinging issue

-- FIXED: Set up part collectors with proper handling to prevent flinging
local collectedParts = {} -- Track collected parts to prevent double collection

for _, collector in ipairs(essentials:GetChildren()) do
	if collector.Name == "PartCollector" then
		-- Make collector non-collidable to prevent physics issues
		collector.CanCollide = false
		collector.CanQuery = true
		collector.CanTouch = true
		
		collector.Touched:Connect(function(part)
			-- Check if part has already been collected
			if collectedParts[part] then return end
			
			local cashValue = part:FindFirstChild("Cash")
			if cashValue then
				-- Mark as collected immediately
				collectedParts[part] = true
				
				-- Add money
				Money.Value = Money.Value + cashValue.Value
				
				-- FIX: Anchor the part before destroying to prevent flinging
				part.Anchored = true
				part.CanCollide = false
				part.CanTouch = false
				part.CanQuery = false
				
				-- Make it invisible immediately
				if part:IsA("BasePart") then
					part.Transparency = 1
				end
				
				-- Hide any particle effects
				for _, child in ipairs(part:GetDescendants()) do
					if child:IsA("ParticleEmitter") then
						child.Enabled = false
					elseif child:IsA("PointLight") or child:IsA("SpotLight") then
						child.Enabled = false
					end
				end
				
				-- Destroy after a short delay
				Debris:AddItem(part, 0.1)
				
				-- Clean up tracking after a bit
				task.delay(1, function()
					collectedParts[part] = nil
				end)
			end
		end)
	end
end