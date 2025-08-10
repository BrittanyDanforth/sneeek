-- Conveyor Script for Cinnamoroll Tycoon
local conveyor = script.Parent
local speed = 16 -- Gentler than 23 to prevent flinging

conveyor.Touched:Connect(function(hit)
	if hit and hit.Parent and not hit.Anchored then
		-- Only push parts, not players
		if not hit.Parent:FindFirstChild("Humanoid") then
			-- Apply velocity in conveyor direction
			hit.Velocity = conveyor.CFrame.LookVector * speed
		end
	end
end)