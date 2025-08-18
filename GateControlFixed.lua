--[[
	Modern and Safe Tycoon Claim Script - FIXED VERSION
	- Fixes race conditions so two players can't claim at once
	- Properly recreates gate when tycoon is reset
	- Uses modern Roblox practices
]]

-- Services
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Teams = game:GetService("Teams")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Get references
local gateModel = script.Parent
local touchPart = gateModel:WaitForChild("Head")
local tycoon = gateModel.Parent.Parent

-- Store original properties for reset
local originalTransparency = touchPart.Transparency
local originalCanCollide = touchPart.CanCollide
local originalCFrame = touchPart.CFrame

-- Debounce flag
local isClaiming = false

-- Function to reset the gate to its original state
local function resetGate()
	touchPart.Transparency = originalTransparency
	touchPart.CanCollide = originalCanCollide
	touchPart.CFrame = originalCFrame
	isClaiming = false
	print("🔄 Gate reset for", tycoon.Name)
end

-- Monitor owner changes to reset gate when tycoon becomes unclaimed
tycoon.Owner.Changed:Connect(function()
	if tycoon.Owner.Value == nil then
		-- Tycoon is unclaimed, reset the gate
		resetGate()
	end
end)

-- Main claim function
local function onTycoonClaimed(hit)
	-- GUARD CLAUSE #1: If someone is already claiming this tycoon, stop
	if isClaiming then
		return
	end

	-- GUARD CLAUSE #2: Check if it's a valid player
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player then
		return
	end

	-- GUARD CLAUSE #3: Check if tycoon already has an owner
	if tycoon.Owner.Value ~= nil then
		return
	end

	-- GUARD CLAUSE #4: Check if player already owns a tycoon
	local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
	if not playerStats or not playerStats:FindFirstChild("OwnsTycoon") then
		warn("Player " .. player.Name .. " is missing stats and cannot claim a tycoon.")
		return
	end

	if playerStats.OwnsTycoon.Value ~= nil then
		return -- Player already owns a tycoon
	end

	-- All checks passed! Lock the gate
	isClaiming = true

	-- 1. Assign Ownership
	tycoon.Owner.Value = player
	playerStats.OwnsTycoon.Value = tycoon

	-- 2. Assign Team
	local team = Teams:FindFirstChild(tycoon.Name)
	if team then
		player.Team = team
	else
		local teamColor = tycoon:FindFirstChild("TeamColor")
		if teamColor then
			player.TeamColor = teamColor.Value
		end
	end

	print("✅ " .. player.Name .. " has successfully claimed " .. tycoon.Name)

	-- 3. Make gate non-collidable and fade it
	touchPart.CanCollide = false
	local fadeOutTween = TweenService:Create(touchPart, TweenInfo.new(0.5), {Transparency = 1})
	fadeOutTween:Play()
	
	-- Don't destroy the gate! Just hide it so it can be reset later
end

-- Connect the touch event
touchPart.Touched:Connect(onTycoonClaimed)