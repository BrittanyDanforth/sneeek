-- Conveyor 1 - Gentler version that won't fling parts
local conveyor = script.Parent
local speed = 16 -- Reduced from 23 to be gentler

conveyor.Touched:Connect(function(hit)
	if hit and hit.Parent and not hit.Anchored then
		-- Only push parts, not players
		if not hit.Parent:FindFirstChild("Humanoid") then
			-- Use gentler velocity
			hit.Velocity = conveyor.CFrame.LookVector * speed + Vector3.new(0, hit.Velocity.Y, 0)
		end
	end
end)