-- Conveyor 4 - Like original but with better control
local SPEED = 10 -- Start slow, increase if needed (was 23)

while true do
	-- Set velocity but cap it to prevent flinging
	local currentVel = script.Parent.Velocity
	local targetVel = script.Parent.CFrame.lookVector * SPEED
	
	-- Only set X and Z velocity, preserve Y to prevent bouncing
	script.Parent.Velocity = Vector3.new(targetVel.X, currentVel.Y, targetVel.Z)
	
	wait(0.2)
end