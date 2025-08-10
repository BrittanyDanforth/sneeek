-- CONVEYOR SCRIPT 3 - MODERNIZED WITH DEBUG
-- This script controls one of the three conveyors in your tycoon

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local part = script.Parent
local SPEED = 23

-- Unique identifier for this conveyor
local CONVEYOR_ID = "CONVEYOR_3"
local DEBUG_COLOR = Color3.fromRGB(0, 0, 255) -- Blue for Conveyor 3

-- Initial debug info
print("=====================================")
print("🔵 " .. CONVEYOR_ID .. " INITIALIZING")
print("=====================================")
print("Location:", part:GetFullName())
print("Part Name:", part.Name)
print("Initial Position:", part.Position)
print("Initial Anchored:", part.Anchored)
print("Initial CanCollide:", part.CanCollide)
print("Part Material:", part.Material)
print("Part Transparency:", part.Transparency)
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

-- Create visual indicator for conveyor direction
local arrow = part:FindFirstChild("DirectionArrow")
if not arrow then
	arrow = Instance.new("Part")
	arrow.Name = "DirectionArrow"
	arrow.Size = Vector3.new(1, 0.5, 2)
	arrow.Shape = Enum.PartType.Wedge
	arrow.Material = Enum.Material.Neon
	arrow.BrickColor = BrickColor.new("Bright blue")
	arrow.CanCollide = false
	arrow.Anchored = true
	arrow.Parent = part
	
	-- Position arrow to show direction
	arrow.CFrame = part.CFrame * CFrame.new(0, part.Size.Y/2 + 1, 0)
end

-- Track performance and items
local loopCount = 0
local startTime = tick()
local lastDebugTime = tick()
local itemsTransported = 0

-- Detect items on conveyor
part.Touched:Connect(function(hit)
	if hit:FindFirstChild("Cash") then
		itemsTransported = itemsTransported + 1
	end
end)

-- Modern conveyor loop with optimizations
spawn(function()
	while part.Parent do
		loopCount = loopCount + 1
		
		-- Update velocity with all methods for maximum compatibility
		local lookVector = part.CFrame.LookVector
		local velocity = lookVector * SPEED
		
		-- Method 1: Modern AssemblyLinearVelocity
		pcall(function()
			part.AssemblyLinearVelocity = velocity
		end)
		
		-- Method 2: Classic Velocity
		part.Velocity = velocity
		
		-- Update direction arrow
		if arrow and arrow.Parent then
			arrow.CFrame = part.CFrame * CFrame.new(0, part.Size.Y/2 + 1, 0)
		end
		
		-- Debug output every 5 seconds
		if tick() - lastDebugTime >= 5 then
			print("\n📊 " .. CONVEYOR_ID .. " DETAILED STATUS:")
			print("- Running for:", string.format("%.1f seconds", tick() - startTime))
			print("- Loop iterations:", loopCount)
			print("- Current velocity:", part.Velocity)
			print("- Look vector:", lookVector)
			print("- Items transported:", itemsTransported)
			print("- Still unanchored:", not part.Anchored)
			print("- Part still exists:", part.Parent ~= nil)
			print("- Position:", part.Position)
			lastDebugTime = tick()
		end
		
		-- Modern wait with precise timing
		task.wait(0.2)
	end
end)

-- Cleanup function
part.AncestryChanged:Connect(function()
	if not part.Parent then
		print("🛑 " .. CONVEYOR_ID .. " REMOVED FROM GAME")
		if arrow and arrow.Parent then
			arrow:Destroy()
		end
	end
end)

print("✅ " .. CONVEYOR_ID .. " SUCCESSFULLY STARTED!")