--[[
	Collision Group Setup Script
	Run this ONCE in the command bar or as a script in ServerScriptService
	This prevents players from flinging orbs while keeping normal physics
--]]

local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

-- Define collision groups
local PLAYER_GROUP = "Players"
local ORB_GROUP = "Orbs"
local WORLD_GROUP = "Default" -- Default group for world geometry

-- Create collision groups (safe to run multiple times)
local function createGroup(name)
	local success = pcall(function()
		PhysicsService:CreateCollisionGroup(name)
	end)
	if success then
		print("Created collision group:", name)
	else
		print("Collision group already exists:", name)
	end
end

-- Set up groups
createGroup(PLAYER_GROUP)
createGroup(ORB_GROUP)

-- Configure collision rules
-- Orbs should NOT collide with Players (prevents flinging)
PhysicsService:CollisionGroupSetCollidable(ORB_GROUP, PLAYER_GROUP, false)

-- Orbs SHOULD collide with the world/ground
PhysicsService:CollisionGroupSetCollidable(ORB_GROUP, WORLD_GROUP, true)

-- Orbs SHOULD collide with each other (prevents stacking)
PhysicsService:CollisionGroupSetCollidable(ORB_GROUP, ORB_GROUP, true)

print("✅ Collision groups configured!")
print("- Orbs will NOT collide with players (no flinging)")
print("- Orbs WILL collide with ground and each other")

-- Function to set player collision group
local function setupCharacter(character)
	task.wait(0.1) -- Wait for character to load
	
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(part, PLAYER_GROUP)
		end
	end
	
	-- Listen for new parts added to character
	character.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(descendant, PLAYER_GROUP)
		end
	end)
end

-- Apply to all current players
for _, player in ipairs(Players:GetPlayers()) do
	if player.Character then
		setupCharacter(player.Character)
	end
	
	player.CharacterAdded:Connect(setupCharacter)
end

-- Apply to new players
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(setupCharacter)
end)

print("✅ Player collision group handler installed!")
print("Place this script in ServerScriptService for automatic setup")