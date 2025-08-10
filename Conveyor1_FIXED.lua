-- FIXED Conveyor Script 1 - Keeps parts anchored
-- This script moves objects that touch the conveyor, NOT the conveyor itself

local conveyor = script.Parent
local SPEED = 23

-- Make sure conveyor stays anchored
conveyor.Anchored = true

-- Function to move objects on the conveyor
local function moveObject(hit)
	-- Check if the object can be moved
	if hit and hit.Parent and not hit.Anchored then
		-- Apply velocity in the conveyor's forward direction
		local bodyVelocity = hit:FindFirstChild("BodyVelocity")
		
		if not bodyVelocity then
			bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = Vector3.new(4000, 0, 4000)
			bodyVelocity.Parent = hit
		end
		
		-- Set velocity in the conveyor's look direction
		bodyVelocity.Velocity = conveyor.CFrame.LookVector * SPEED
	end
end

-- Function to stop moving objects
local function stopObject(hit)
	if hit and hit:FindFirstChild("BodyVelocity") then
		hit.BodyVelocity:Destroy()
	end
end

-- Connect touch events
conveyor.Touched:Connect(moveObject)
conveyor.TouchEnded:Connect(stopObject)

print("Conveyor 1 initialized - Part remains anchored, moves touching objects")