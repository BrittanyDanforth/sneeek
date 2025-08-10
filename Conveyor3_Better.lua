-- Conveyor 3 - Continuous gentle push
local conveyor = script.Parent
local speed = 12 -- Even slower for very gentle movement

while true do
	-- Find all parts touching the conveyor
	local touching = workspace:GetPartBoundsInBox(conveyor.CFrame, conveyor.Size)
	
	for _, part in pairs(touching) do
		if part ~= conveyor and part.Parent and not part.Anchored then
			if not part.Parent:FindFirstChild("Humanoid") then
				-- Apply gentle velocity
				part.Velocity = conveyor.CFrame.LookVector * speed + Vector3.new(0, part.Velocity.Y, 0)
			end
		end
	end
	
	wait(0.1) -- Update more frequently for smoother movement
end