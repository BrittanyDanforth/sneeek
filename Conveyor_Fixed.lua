-- Modern Conveyor Script (2025 Standards)
-- Works with both Velocity and AssemblyLinearVelocity

local RunService = game:GetService("RunService")

-- Get the part this script controls
local conveyorPart = script.Parent

-- Configuration
local CONVEYOR_SPEED = 23
local UPDATE_RATE = 0.2 -- How often to update velocity

-- Check if part is valid
if not conveyorPart:IsA("BasePart") then
	warn("Conveyor script must be attached to a BasePart!")
	return
end

-- Print location info once at startup
print("Conveyor initialized at:", conveyorPart:GetFullName())

-- Make sure part is unanchored for velocity to work
if conveyorPart.Anchored then
	warn("Conveyor part is anchored! Unanchoring it for velocity to work.")
	conveyorPart.Anchored = false
end

-- Set up AssemblyLinearVelocity for modern physics
if conveyorPart.AssemblyLinearVelocity then
	-- Use modern velocity property
	while conveyorPart.Parent do
		conveyorPart.AssemblyLinearVelocity = conveyorPart.CFrame.LookVector * CONVEYOR_SPEED
		task.wait(UPDATE_RATE)
	end
else
	-- Fallback to old Velocity property
	while conveyorPart.Parent do
		conveyorPart.Velocity = conveyorPart.CFrame.LookVector * CONVEYOR_SPEED
		task.wait(UPDATE_RATE)
	end
end