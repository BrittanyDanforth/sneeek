-- Conveyor 2 - Using BodyVelocity for smoother movement
local conveyor = script.Parent
local speed = 16

conveyor.Touched:Connect(function(hit)
	if hit and hit.Parent and not hit.Anchored and not hit.Parent:FindFirstChild("Humanoid") then
		-- Add BodyVelocity for smoother, controlled movement
		if not hit:FindFirstChild("ConveyorVel") then
			local bv = Instance.new("BodyVelocity")
			bv.Name = "ConveyorVel"
			bv.MaxForce = Vector3.new(2000, 0, 2000) -- Lower force = less flinging
			bv.Velocity = conveyor.CFrame.LookVector * speed
			bv.Parent = hit
			
			-- Remove after 1 second so parts don't fly forever
			game:GetService("Debris"):AddItem(bv, 1)
		end
	end
end)