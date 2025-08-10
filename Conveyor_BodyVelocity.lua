-- Advanced Conveyor Script using BodyVelocity
-- More reliable than setting Velocity directly

local conveyorPart = script.Parent
local SPEED = 23

-- Ensure part is unanchored
conveyorPart.Anchored = false

-- Create BodyVelocity object for smooth movement
local bodyVelocity = conveyorPart:FindFirstChild("BodyVelocity")
if not bodyVelocity then
	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(4000, 0, 4000) -- Only apply force on X and Z axes
	bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	bodyVelocity.Parent = conveyorPart
end

-- Update velocity based on part's orientation
while conveyorPart.Parent do
	local lookVector = conveyorPart.CFrame.LookVector
	bodyVelocity.Velocity = lookVector * SPEED
	task.wait(0.2)
end