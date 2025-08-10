-- FIXED Conveyor Script 2 - Alternative implementation
-- Keeps conveyor anchored, moves objects on top

local conveyor = script.Parent
local SPEED = 23
local RunService = game:GetService("RunService")

-- Ensure conveyor is anchored
conveyor.Anchored = true

-- Table to track objects on the conveyor
local objectsOnConveyor = {}

-- Function when object touches conveyor
local function onTouch(hit)
	if hit and hit.Parent and not hit.Anchored then
		-- Only move parts that are not already being moved
		if not objectsOnConveyor[hit] then
			objectsOnConveyor[hit] = true
			
			-- Create BodyPosition and BodyVelocity for smooth movement
			local bodyVel = Instance.new("BodyVelocity")
			bodyVel.MaxForce = Vector3.new(4000, 0, 4000)
			bodyVel.Velocity = conveyor.CFrame.LookVector * SPEED
			bodyVel.Parent = hit
			
			-- Store reference
			hit:SetAttribute("ConveyorVelocity", true)
		end
	end
end

-- Function when object leaves conveyor
local function onTouchEnd(hit)
	if hit and objectsOnConveyor[hit] then
		objectsOnConveyor[hit] = nil
		
		-- Remove velocity
		local bodyVel = hit:FindFirstChild("BodyVelocity")
		if bodyVel and hit:GetAttribute("ConveyorVelocity") then
			bodyVel:Destroy()
			hit:SetAttribute("ConveyorVelocity", nil)
		end
	end
end

-- Connect events
conveyor.Touched:Connect(onTouch)
conveyor.TouchEnded:Connect(onTouchEnd)

-- Cleanup when conveyor is removed
conveyor.AncestryChanged:Connect(function()
	if not conveyor.Parent then
		for obj in pairs(objectsOnConveyor) do
			if obj and obj.Parent then
				local bodyVel = obj:FindFirstChild("BodyVelocity")
				if bodyVel then
					bodyVel:Destroy()
				end
			end
		end
	end
end)

print("Conveyor 2 initialized - Enhanced tracking system")