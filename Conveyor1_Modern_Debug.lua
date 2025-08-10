-- CONVEYOR SCRIPT 1 - MODERNIZED WITH DEBUG
-- This script controls one of the three conveyors in your tycoon

local RunService = game:GetService("RunService")
local part = script.Parent
local SPEED = 23

-- Unique identifier for this conveyor
local CONVEYOR_ID = "CONVEYOR_1"
local DEBUG_COLOR = Color3.fromRGB(255, 0, 0) -- Red for Conveyor 1

-- Initial debug info
print("=====================================")
print("🔴 " .. CONVEYOR_ID .. " INITIALIZING")
print("=====================================")
print("Location:", part:GetFullName())
print("Part Name:", part.Name)
print("Initial Position:", part.Position)
print("Initial Anchored:", part.Anchored)
print("Initial CanCollide:", part.CanCollide)
print("=====================================")

-- Ensure part is unanchored
if part.Anchored then
	warn(CONVEYOR_ID .. ": Part was anchored! Unanchoring for velocity to work...")
	part.Anchored = false
end

-- Add a SelectionBox for visual debugging (optional - remove in production)
local debugBox = part:FindFirstChild("DebugBox") or Instance.new("SelectionBox")
debugBox.Name = "DebugBox"
debugBox.Adornee = part
debugBox.Color3 = DEBUG_COLOR
debugBox.LineThickness = 0.1
debugBox.Transparency = 0.5
debugBox.Parent = part

-- Track performance
local loopCount = 0
local startTime = tick()
local lastDebugTime = tick()

-- Modern conveyor loop using task.wait
while part.Parent do
	loopCount = loopCount + 1
	
	-- Update velocity using modern AssemblyLinearVelocity if available
	local lookVector = part.CFrame.LookVector
	
	-- Try modern method first
	local success = pcall(function()
		part.AssemblyLinearVelocity = lookVector * SPEED
	end)
	
	-- Fallback to old method if needed
	if not success then
		part.Velocity = lookVector * SPEED
	end
	
	-- Debug output every 5 seconds
	if tick() - lastDebugTime >= 5 then
		print("\n📊 " .. CONVEYOR_ID .. " STATUS:")
		print("- Running for:", string.format("%.1f seconds", tick() - startTime))
		print("- Loop iterations:", loopCount)
		print("- Current velocity:", part.Velocity)
		print("- Look vector:", lookVector)
		print("- Still unanchored:", not part.Anchored)
		lastDebugTime = tick()
	end
	
	-- Modern wait
	task.wait(0.2)
end

print("❌ " .. CONVEYOR_ID .. " STOPPED - Part was removed!")