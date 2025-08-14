--[[
	Gate Control - Simple Fix
	NEVER destroys the gate, just hides it so it can be reset
]]

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local Teams = game:GetService("Teams")
local TweenService = game:GetService("TweenService")

-- Get references
local gateModel = script.Parent
local touchPart = gateModel:WaitForChild("Head")
local tycoon = gateModel.Parent.Parent

-- Store original state
local ORIGINAL_TRANSPARENCY = 0
local ORIGINAL_CAN_COLLIDE = true

-- Debounce
local isClaiming = false

-- Function to show/hide gate
local function setGateVisible(visible)
	if visible then
		touchPart.Transparency = ORIGINAL_TRANSPARENCY
		touchPart.CanCollide = ORIGINAL_CAN_COLLIDE
		isClaiming = false
	else
		touchPart.Transparency = 1
		touchPart.CanCollide = false
	end
end

-- Watch for owner changes
tycoon.Owner.Changed:Connect(function()
	if tycoon.Owner.Value == nil then
		-- No owner = show the gate
		setGateVisible(true)
		print("🚪 Gate visible again for", tycoon.Name)
	end
end)

-- Touch handler
local function onTouched(hit)
	if isClaiming then return end
	
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player then return end
	
	if tycoon.Owner.Value ~= nil then return end
	
	local playerStats = ServerStorage.PlayerMoney:FindFirstChild(player.Name)
	if not playerStats or not playerStats:FindFirstChild("OwnsTycoon") then
		warn("Player " .. player.Name .. " is missing stats")
		return
	end
	
	if playerStats.OwnsTycoon.Value ~= nil then
		return -- Already owns a tycoon
	end
	
	-- Claim the tycoon!
	isClaiming = true
	
	tycoon.Owner.Value = player
	playerStats.OwnsTycoon.Value = tycoon
	
	-- Set team
	local team = Teams:FindFirstChild(tycoon.Name)
	if team then
		player.Team = team
	else
		local teamColor = tycoon:FindFirstChild("TeamColor")
		if teamColor then
			player.TeamColor = teamColor.Value
		end
	end
	
	print("✅", player.Name, "claimed", tycoon.Name)
	
	-- Hide gate (DON'T DESTROY!)
	setGateVisible(false)
end

touchPart.Touched:Connect(onTouched)