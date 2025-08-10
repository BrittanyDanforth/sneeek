-- Conveyor Script for Cinnamoroll Tycoon
local conveyor = script.Parent
local speed = 16 -- Gentler than 23 to prevent flinging

while true do
	script.Parent.Velocity = script.Parent.CFrame.lookVector * 16
	wait(0.1)
end