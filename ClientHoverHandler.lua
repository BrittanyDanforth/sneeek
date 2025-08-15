--[[
	Client-Side Hover Handler
	Handles button hover effects locally for zero server performance impact
--]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Wait for remotes
local remotesFolder = ReplicatedStorage:WaitForChild("TycoonRemotes")
local hoverRemote = remotesFolder:WaitForChild("ButtonHoverEffect")

-- Track registered buttons
local registeredButtons = {}
local currentHoveredButton = nil

-- Hover settings
local HOVER_SCALE = 1.02
local HOVER_TWEEN_TIME = 0.2
local DETECTION_RADIUS = 10

-- Register a button for hover effects
local function registerButton(button)
	if not button or registeredButtons[button] then return end
	
	local head = button:FindFirstChild("Head")
	if not head then return end
	
	registeredButtons[button] = {
		head = head,
		originalSize = head.Size,
		isHovering = false
	}
end

-- Remove a button from hover tracking
local function removeButton(button)
	if not button then return end
	
	-- Reset to original size if hovering
	local data = registeredButtons[button]
	if data and data.isHovering then
		TweenService:Create(data.head,
			TweenInfo.new(HOVER_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Size = data.originalSize}
		):Play()
	end
	
	registeredButtons[button] = nil
end

-- Handle hover effect
local function applyHoverEffect(buttonData)
	if buttonData.isHovering then return end
	buttonData.isHovering = true
	
	TweenService:Create(buttonData.head,
		TweenInfo.new(HOVER_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = buttonData.originalSize * HOVER_SCALE}
	):Play()
end

-- Remove hover effect
local function removeHoverEffect(buttonData)
	if not buttonData.isHovering then return end
	buttonData.isHovering = false
	
	TweenService:Create(buttonData.head,
		TweenInfo.new(HOVER_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Size = buttonData.originalSize}
	):Play()
end

-- Main hover detection loop
RunService.Heartbeat:Connect(function()
	local character = player.Character
	if not character then return end
	
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end
	
	local playerPosition = humanoidRootPart.Position
	local closestButton = nil
	local closestDistance = math.huge
	
	-- Find closest button within range
	for button, data in pairs(registeredButtons) do
		if data.head and data.head.Parent and data.head.Transparency < 1 and data.head.CanCollide then
			local distance = (data.head.Position - playerPosition).Magnitude
			
			if distance < DETECTION_RADIUS and distance < closestDistance then
				closestDistance = distance
				closestButton = button
			end
		end
	end
	
	-- Update hover states
	if closestButton ~= currentHoveredButton then
		-- Remove hover from previous button
		if currentHoveredButton and registeredButtons[currentHoveredButton] then
			removeHoverEffect(registeredButtons[currentHoveredButton])
		end
		
		-- Apply hover to new button
		if closestButton and registeredButtons[closestButton] then
			applyHoverEffect(registeredButtons[closestButton])
		end
		
		currentHoveredButton = closestButton
	end
end)

-- Handle remote events
hoverRemote.OnClientEvent:Connect(function(action, button)
	if action == "register" then
		registerButton(button)
	elseif action == "remove" then
		removeButton(button)
	end
end)

-- Clean up on character death
player.CharacterRemoving:Connect(function()
	-- Remove all hover effects
	for button, data in pairs(registeredButtons) do
		if data.isHovering then
			removeHoverEffect(data)
		end
	end
	currentHoveredButton = nil
end)