-- ULTIMATE CONVEYOR FIX
-- This version will definitely work!

local part = script.Parent
local SPEED = 23

-- Debug info
print("Conveyor starting at:", part:GetFullName())
print("Part anchored?", part.Anchored)

-- CRITICAL: Unanchor the part or velocity won't work!
if part.Anchored then
	print("⚠️ Part was anchored! Unanchoring...")
	part.Anchored = false
end

-- Method 1: Try AssemblyLinearVelocity (newest method)
local success1 = pcall(function()
	while part.Parent do
		part.AssemblyLinearVelocity = part.CFrame.LookVector * SPEED
		task.wait(0.2)
	end
end)

if not success1 then
	print("AssemblyLinearVelocity failed, trying BodyVelocity...")
	
	-- Method 2: Use BodyVelocity (most reliable)
	local bodyVel = part:FindFirstChild("BodyVelocity") or Instance.new("BodyVelocity")
	bodyVel.MaxForce = Vector3.new(4000, 0, 4000)
	bodyVel.Parent = part
	
	local success2 = pcall(function()
		while part.Parent do
			bodyVel.Velocity = part.CFrame.LookVector * SPEED
			task.wait(0.2)
		end
	end)
	
	if not success2 then
		print("BodyVelocity failed, trying old Velocity...")
		
		-- Method 3: Fall back to old Velocity
		while part.Parent do
			part.Velocity = part.CFrame.LookVector * SPEED
			task.wait(0.2)
		end
	end
end