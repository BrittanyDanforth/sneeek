-- FIXED Conveyor Script 3 - Simple and reliable
-- Most similar to your original script but with fixes

local conveyor = script.Parent
local SPEED = 23

-- CRITICAL: Keep conveyor anchored!
conveyor.Anchored = true

-- Simple function to move parts
conveyor.Touched:Connect(function(hit)
	-- Check if it's a valid part to move
	if hit and hit.Parent and not hit.Anchored then
		-- Only add velocity to parts that don't already have it
		if not hit:FindFirstChild("ConveyorMover") then
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Name = "ConveyorMover"
			bodyVelocity.MaxForce = Vector3.new(4000, 0, 4000)
			bodyVelocity.Velocity = conveyor.CFrame.LookVector * SPEED
			bodyVelocity.Parent = hit
			
			-- Remove velocity after a delay (so parts don't fly forever)
			game:GetService("Debris"):AddItem(bodyVelocity, 2)
		end
	end
end)

print("Conveyor 3 initialized - Simple fixed version")