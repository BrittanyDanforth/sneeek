--[[
ULTRA-SMOOTH & HIGH-PERFORMANCE SLITHER.IO SNAKE SYSTEM V5.1 - LAG FIXED WITH SKIN SYSTEM
- Fixed segment pooling to remove segments from workspace
- Added periodic cleanup for orphaned segments
- Optimized memory management
- ENHANCED: Full skin system integration with proper attribute monitoring
- ENHANCED: Real-time skin changes without breaking movement or performance
- ENHANCED: Automatic skin application on spawn and skin changes
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Helper function to get table keys (moved up to be available)
local function getTableKeys(tbl)
	local keys = {}
	for k, _ in pairs(tbl or {}) do
		table.insert(keys, tostring(k))
	end
	return keys
end

-- ENHANCED: Direct SnakeSkins loading from server module
local SnakeSkins = nil
local function loadSnakeSkins()
	-- Try direct server module first
	local success, result = pcall(function()
		return require(script.Parent:WaitForChild("SnakeSkinsData", 2))
	end)

	if success and result then
		SnakeSkins = result
		print("✅ SnakeSkins loaded directly from server module with", #getTableKeys(result), "skins")
		for name, _ in pairs(result) do
			print("  - Found skin:", name)
		end
		return
	else
		warn("❌ Failed to load SnakeSkinsData:", tostring(result))
	end

	-- Fallback to ReplicatedStorage
	success, result = pcall(function()
		local module = ReplicatedStorage:WaitForChild("SnakeSkins", 2)
		if module then
			return require(module)
		end
	end)

	if success and result then
		SnakeSkins = result
		print("✅ SnakeSkins loaded from ReplicatedStorage")
	else
		warn("❌ Failed to load SnakeSkins from any source")
		SnakeSkins = {}
	end
end

-- Load skins immediately and retry if needed
loadSnakeSkins()
task.spawn(function()
	for i = 1, 5 do
		if SnakeSkins and next(SnakeSkins) then 
			print("✅ SnakeSkins loaded with", #getTableKeys(SnakeSkins), "skins")
			break 
		end
		task.wait(2)
		print("⏳ Retrying SnakeSkins load, attempt", i + 1)
		loadSnakeSkins()
	end
end)

-- Fast aliases
local Vector3new = Vector3.new
local CFramenew = CFrame.new
local CFramelookAt = CFrame.lookAt
local mathMin = math.min
local mathMax = math.max
local mathFloor = math.floor
local taskSpawn = task.spawn
local taskWait = task.wait

-- OPTIMIZED: Base config with performance settings from V5.1
local Config = {
	HeadSize = Vector3new(3, 3, 3),
	SegmentSize = Vector3new(2.5, 2.5, 2.5),
	SegmentSpacing = 2.2,
	InitialLength = 15,
	MaxSegments = 2450,
	HeadColor = Color3.fromRGB(180, 0, 255), -- Default purple (will be overridden by skins)
	BodyColors = {
		Color3.fromRGB(180, 0, 255),
		Color3.fromRGB(255, 0, 150),
		Color3.fromRGB(255, 80, 200),
		Color3.fromRGB(255, 0, 150),
		Color3.fromRGB(180, 0, 255),
	},
	FollowSpeed = 0.96,
	UpdateRate = 30,
	MinDistance = 0.02,
	BoostSpeed = 32,
	BoostFollowSpeed = 0.98,
	HeadMaterial = Enum.Material.ForceField,
	BodyMaterial = Enum.Material.Neon,
	GlowIntensity = 1.5,
	GlowRange = 4,
}

-- ENHANCED: Get active config with skin overrides
local function getActiveConfig(player)
	local activeConfig = {}
	for k, v in pairs(Config) do 
		activeConfig[k] = v 
	end

	-- Apply skin overrides if available
	local playerSkinName = player:GetAttribute("SelectedSkin")
	print("🔍 Getting skin config for:", playerSkinName, "Player:", player.Name)

	if playerSkinName and playerSkinName ~= "" then
		if not SnakeSkins then
			warn("❌ SnakeSkins module not loaded!")
			-- Try one more time
			loadSnakeSkins()
		end

		if SnakeSkins and SnakeSkins[playerSkinName] then
			local skinData = SnakeSkins[playerSkinName]
			print("📋 Applying skin data:", playerSkinName)
			print("   HeadColor:", tostring(skinData.HeadColor))
			print("   BodyColors count:", skinData.BodyColors and #skinData.BodyColors or "nil")

			for key, value in pairs(skinData) do
				if key ~= "Price" and key ~= "Description" then
					activeConfig[key] = value
					print("   Set", key, "to", tostring(value))
				end
			end
			print("✅ Applied skin config for", playerSkinName, "to player", player.Name)
			print("   Final HeadColor:", tostring(activeConfig.HeadColor))
			print("   Final BodyColors count:", #activeConfig.BodyColors)
			print("   First body color:", tostring(activeConfig.BodyColors[1]))
		else
			warn("❌ Skin", playerSkinName, "not found in SnakeSkins module!")
			if SnakeSkins then
				warn("   Available skins:", table.concat(getTableKeys(SnakeSkins), ", "))
			end
			-- Try to apply Classic skin as fallback
			if SnakeSkins and SnakeSkins["Classic"] then
				print("⚠️ Applying Classic skin as fallback")
				local classicData = SnakeSkins["Classic"]
				for key, value in pairs(classicData) do
					if key ~= "Price" and key ~= "Description" then
						activeConfig[key] = value
					end
				end
			end
		end
	end

	return activeConfig
end

-- Enhanced Segment Pooling with better cleanup
local SegmentPool = {}
local PoolSize = 0
local MAX_POOL_SIZE = 1000

-- Dedicated container for better organization
local SegmentContainer = workspace:FindFirstChild("SegmentContainer")
if not SegmentContainer then
	SegmentContainer = Instance.new("Folder")
	SegmentContainer.Name = "SegmentContainer"
	SegmentContainer.Parent = workspace
end

local function resetSegment(segment)
	segment.Anchored = true
	segment.CanCollide = false
	segment.CanQuery = false
	segment.CanTouch = false
	segment.Transparency = 0
	segment.Size = Config.SegmentSize
	segment.Material = Config.BodyMaterial
	segment.Shape = Enum.PartType.Ball
	segment.TopSurface = Enum.SurfaceType.Smooth
	segment.BottomSurface = Enum.SurfaceType.Smooth
	segment.Color = Config.BodyColors[1]
	segment.Name = "Segment"

	-- Clean up all children efficiently
	for _, child in segment:GetChildren() do
		if child:IsA("PointLight") or child:IsA("SelectionBox") or child:IsA("Attachment") then
			child:Destroy()
		end
	end
end

local function getSegment()
	if PoolSize > 0 then
		local segment = SegmentPool[PoolSize]
		SegmentPool[PoolSize] = nil
		PoolSize = PoolSize - 1
		resetSegment(segment)
		-- Re-parent to container when getting from pool
		segment.Parent = SegmentContainer
		return segment
	else
		local segment = Instance.new("Part")
		resetSegment(segment)
		segment.Parent = SegmentContainer
		return segment
	end
end

-- FIXED: Properly remove segments from workspace
local function returnSegment(segment)
	if not segment or not segment.Parent then return end

	-- Clean up the segment
	segment.Transparency = 1
	segment.CanCollide = false
	segment.CanQuery = false
	segment.CanTouch = false
	segment.Anchored = true

	-- Turn off lights and effects
	for _, child in segment:GetChildren() do
		if child:IsA("PointLight") then
			child.Enabled = false
		elseif child:IsA("SelectionBox") then
			child.Adornee = nil
		elseif child:IsA("Attachment") then
			child:Destroy()
		end
	end

	-- Only return to pool if we haven't exceeded max size
	if PoolSize < MAX_POOL_SIZE then
		PoolSize = PoolSize + 1
		SegmentPool[PoolSize] = segment
		-- CRITICAL FIX: Remove from workspace to prevent lag
		segment.Parent = nil
	else
		-- Destroy excess segments
		segment:Destroy()
	end
end

local function getOrCreateSnakeModel(player)
	local modelName = "SnakeModel_" .. player.UserId
	local existing = workspace:FindFirstChild(modelName)
	if existing and existing:IsA("Model") then
		return existing
	end
	local model = Instance.new("Model")
	model.Name = modelName
	model.Parent = workspace
	model:SetAttribute("IsSnakeModel", true)
	model:SetAttribute("OwnerUserId", player.UserId)
	return model
end

local function createSegment(index, position, color, config, parentModel)
	local segment = getSegment()
	segment.Name = "Segment" .. index
	segment.Size = config.SegmentSize
	segment.Material = config.BodyMaterial
	segment.Color = color
	segment.CFrame = CFramenew(position)
	segment.Parent = parentModel
	segment.Transparency = 0

	segment:SetAttribute("IsSnakeSegment", true)
	segment:SetAttribute("SegmentIndex", index)

	local light = segment:FindFirstChild("Glow")
	if not light then
		light = Instance.new("PointLight")
		light.Name = "Glow"
		light.Parent = segment
	end
	light.Color = color
	light.Brightness = config.GlowIntensity
	light.Range = config.GlowRange
	light.Enabled = true

	local outline = segment:FindFirstChild("Outline")
	if not outline then
		outline = Instance.new("SelectionBox")
		outline.Name = "Outline"
		outline.Parent = segment
	end
	outline.Adornee = segment
	outline.Color3 = Color3.fromRGB(255, 255, 255)
	outline.LineThickness = 0.03
	outline.Transparency = 1

	return segment
end

local function createVisualHead(rootPart, config, parentModel)
	local headPart = Instance.new("Part")
	headPart.Name = "SnakeHead"
	headPart.Size = config.HeadSize
	headPart.Material = config.HeadMaterial
	headPart.Color = config.HeadColor
	headPart.Shape = Enum.PartType.Ball
	headPart.CanCollide = false
	headPart.CanQuery = false
	headPart.CanTouch = false
	headPart.Anchored = true
	headPart.TopSurface = Enum.SurfaceType.Smooth
	headPart.BottomSurface = Enum.SurfaceType.Smooth
	headPart.Parent = parentModel

	headPart:SetAttribute("IsSnakeHead", true)
	headPart:SetAttribute("IsSnakeSegment", true)

	local headLight = Instance.new("PointLight")
	headLight.Color = config.HeadColor
	headLight.Brightness = config.GlowIntensity + 1
	headLight.Range = config.GlowRange + 2
	headLight.Parent = headPart

	local headOutline = Instance.new("SelectionBox")
	headOutline.Adornee = headPart
	headOutline.Color3 = Color3.fromRGB(255, 255, 255)
	headOutline.LineThickness = 0.08
	headOutline.Transparency = 1
	headOutline.Parent = headPart

	local function createEye(name, position, parent)
		local eye = Instance.new("Part")
		eye.Name = name
		eye.Size = Vector3new(0.6, 0.6, 0.6)
		eye.Material = Enum.Material.Neon
		eye.Color = Color3.fromRGB(255, 255, 255)
		eye.Shape = Enum.PartType.Ball
		eye.CanCollide = false
		eye.CanQuery = false
		eye.CanTouch = false
		eye.Anchored = false
		eye.Parent = parent
		eye.CFrame = parent.CFrame * CFramenew(position)

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = parent
		weld.Part1 = eye
		weld.Parent = parent

		return eye, weld
	end

	local function createPupil(name, position, parent)
		local pupil = Instance.new("Part")
		pupil.Name = name
		pupil.Size = Vector3new(0.25, 0.25, 0.25)
		pupil.Material = Enum.Material.Neon
		pupil.Color = Color3.fromRGB(0, 0, 0)
		pupil.Shape = Enum.PartType.Ball
		pupil.CanCollide = false
		pupil.CanQuery = false
		pupil.CanTouch = false
		pupil.Anchored = false
		pupil.Parent = parent
		pupil.CFrame = parent.CFrame * CFramenew(position)

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = parent
		weld.Part1 = pupil
		weld.Parent = parent

		return pupil, weld
	end

	local leftEye, leftEyeWeld = createEye("LeftEye", Vector3new(-0.6, 0.55, 0.8), headPart)
	local rightEye, rightEyeWeld = createEye("RightEye", Vector3new(0.6, 0.55, 0.8), headPart)
	local leftPupil, leftPupilWeld = createPupil("LeftPupil", Vector3new(0, 0, -0.2), leftEye)
	local rightPupil, rightPupilWeld = createPupil("RightPupil", Vector3new(0, 0, -0.2), rightEye)

	return {
		head = headPart,
		headLight = headLight,
		headOutline = headOutline,
		leftEye = leftEye,
		rightEye = rightEye,
		leftPupil = leftPupil,
		rightPupil = rightPupil,
		leftEyeWeld = leftEyeWeld,
		rightEyeWeld = rightEyeWeld,
		leftPupilWeld = leftPupilWeld,
		rightPupilWeld = rightPupilWeld,
	}
end

local playerSnakes = {}
if not _G.PlayerSnakes then
	_G.PlayerSnakes = {}
end

-- REMOVED: Apply skin changes function to improve performance
-- Skins are now only applied on spawn

local function createUltraSmoothSnake(character)
	print("🐍 Creating snake for character:", character.Name)

	-- ENSURE SnakeSkins is loaded before creating snake
	if not SnakeSkins or not next(SnakeSkins) then
		print("⏳ Waiting for SnakeSkins to load...")
		loadSnakeSkins()
		task.wait(0.5)

		-- Check again
		if not SnakeSkins or not next(SnakeSkins) then
			warn("❌ SnakeSkins still not loaded after waiting!")
		else
			print("✅ SnakeSkins now loaded with", #getTableKeys(SnakeSkins), "skins")
		end
	else
		print("✅ SnakeSkins already loaded with", #getTableKeys(SnakeSkins), "skins")
	end

	local humanoid = character:FindFirstChild("Humanoid") or character:WaitForChild("Humanoid", 5)
	local rootPart = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5)

	-- Try multiple ways to get the player
	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		-- Try by name
		player = Players:FindFirstChild(character.Name)
	end

	if not humanoid then
		warn("❌ No humanoid found for", character.Name)
		return
	end
	if not rootPart then
		warn("❌ No HumanoidRootPart found for", character.Name)
		return
	end
	if not player then
		warn("❌ No player found for", character.Name)
		return
	end

	local oldSnakeInstance = character:FindFirstChild("__SnakeInstance")
	if oldSnakeInstance then
		oldSnakeInstance:Destroy()
	end

	-- ENHANCED: Use new skin system
	local activeConfig = getActiveConfig(player)

	-- Validate config
	if not activeConfig.BodyColors or #activeConfig.BodyColors == 0 then
		warn("❌ Invalid skin config - missing BodyColors!")
		activeConfig.BodyColors = Config.BodyColors -- Fallback to default
	end
	if not activeConfig.HeadColor then
		warn("❌ Invalid skin config - missing HeadColor!")
		activeConfig.HeadColor = Config.HeadColor -- Fallback to default
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local lengthValue = leaderstats:FindFirstChild("Length")
		if lengthValue then
			lengthValue.Value = activeConfig.InitialLength
		end
	end

	for _, part in character:GetChildren() do
		if part:IsA("BasePart") then
			part.Transparency = 1
			part.CanCollide = false
		elseif part:IsA("Accessory") or part:IsA("Tool") then
			part:Destroy()
		end
	end

	local snakeModel = getOrCreateSnakeModel(player)
	for _, obj in snakeModel:GetChildren() do
		if obj:IsA("BasePart") then
			for _, child in obj:GetChildren() do
				if child:IsA("Attachment") then
					child:Destroy()
				end
			end
		end
		obj:Destroy()
	end

	local headParts = createVisualHead(rootPart, activeConfig, snakeModel)

	local segments = {}
	local startPos = rootPart.Position
	for i = 1, activeConfig.InitialLength do
		local pos = startPos - rootPart.CFrame.LookVector * (i * activeConfig.SegmentSpacing)
		local colorIndex = ((i - 1) % #activeConfig.BodyColors) + 1
		local color = activeConfig.BodyColors[colorIndex]
		local segment = createSegment(i, pos, color, activeConfig, snakeModel)
		segments[i] = segment
	end

	local currentLength = activeConfig.InitialLength
	local maxHistorySize = mathMin(mathFloor(activeConfig.MaxSegments * 1.1) + 10, 2000)
	local positionHistory = table.create(maxHistorySize)
	local historyHead = 1
	local initialHistoryPoint = { position = rootPart.Position, lookVector = rootPart.CFrame.LookVector }
	for i = 1, maxHistorySize do
		positionHistory[i] = initialHistoryPoint
	end

	local function addToHistory(data)
		positionHistory[historyHead] = data
		historyHead = (historyHead % maxHistorySize) + 1
	end

	local function getFromHistory(stepsBack)
		local index = historyHead - stepsBack
		if index < 1 then
			index = index + maxHistorySize
		end
		return positionHistory[index]
	end

	local connections = {}
	local isActive = true
	local updateCounter = 0
	local networkUpdateInterval = 2
	local lastNetworkUpdate = 0
	local vfxParts = {} -- Store VFX parts for cleanup

	local function growSnake(amount)
		amount = amount or 5
		local grew = false
		for i = 1, amount do
			if currentLength < activeConfig.MaxSegments then
				grew = true
				currentLength = currentLength + 1
				local colorIndex = ((currentLength - 1) % #activeConfig.BodyColors) + 1
				local color = activeConfig.BodyColors[colorIndex]
				local lastSegment = segments[#segments]
				local newPos = lastSegment and lastSegment.Position or rootPart.Position
				local segment = createSegment(currentLength, newPos, color, activeConfig, snakeModel)
				segments[currentLength] = segment

				segment.Transparency = 1
				segment.Size = Vector3new(0.05, 0.05, 0.05)
				taskSpawn(function()
					local growTime = 0.15
					local t = 0
					local startSize = Vector3new(0.05, 0.05, 0.05)
					local endSize = activeConfig.SegmentSize
					local heartbeat = RunService.Heartbeat

					while t < growTime and segment.Parent do
						t = t + heartbeat:Wait()
						if segment.Parent then
							local alpha = mathMin(t / growTime, 1)
							segment.Size = startSize:Lerp(endSize, alpha)
							segment.Transparency = 1 - alpha
						end
					end
					if segment.Parent then
						segment.Size = endSize
						segment.Transparency = 0
					end
				end)
			end
		end

		if grew and leaderstats and updateCounter % 5 == 0 then
			local lengthValue = leaderstats:FindFirstChild("Length")
			if lengthValue then
				lengthValue.Value = currentLength
			end

			-- Award coins for growth (1 coin per 5 segments)
			if currentLength % 5 == 0 then
				local currentCoins = player:GetAttribute("Coins") or 0
				player:SetAttribute("Coins", currentCoins + 1)
				print("💰 Awarded 1 coin for reaching length", currentLength)
			end
		end
	end

	local function cleanup()
		if not isActive then return end
		isActive = false

		for _, conn in connections do
			if typeof(conn) == "RBXScriptConnection" then
				conn:Disconnect()
			end
		end

		-- Clean up VFX parts
		if vfxParts then
			for _, vfxPart in pairs(vfxParts) do
				if vfxPart and vfxPart.Parent then
					vfxPart:Destroy()
				end
			end
		end

		for i, segment in pairs(segments) do
			if segment then
				returnSegment(segment)
			end
		end

		for name, part in pairs(headParts) do
			if typeof(part) == "Instance" and part.Parent then
				for _, child in part:GetChildren() do
					if child:IsA("Attachment") then
						child:Destroy()
					end
				end
				part:Destroy()
			end
		end

		if snakeModel and snakeModel.Parent then
			snakeModel:SetAttribute("BeingDestroyed", true)
			taskSpawn(function()
				taskWait(0.05)
				if snakeModel.Parent then
					snakeModel:Destroy()
				end
			end)
		end

		playerSnakes[player] = nil
		_G.PlayerSnakes[player] = nil

		local oldSnakeInstance = character:FindFirstChild("__SnakeInstance")
		if oldSnakeInstance then
			oldSnakeInstance:Destroy()
		end
	end

	local diedConn = humanoid.Died:Connect(cleanup)
	local ancestryConn = character.AncestryChanged:Connect(function()
		if not character.Parent then
			cleanup()
		end
	end)
	table.insert(connections, diedConn)
	table.insert(connections, ancestryConn)

	local heartbeatConn
	heartbeatConn = RunService.Heartbeat:Connect(function(dt)
		if not isActive or not rootPart.Parent then return end

		updateCounter = updateCounter + 1

		local isBoosting = humanoid.WalkSpeed > 16.1
		local followSpeed = isBoosting and activeConfig.BoostFollowSpeed or activeConfig.FollowSpeed

		local currentPos = rootPart.Position
		local currentCFrame = rootPart.CFrame
		local lookVector = currentCFrame.LookVector
		local headOffset = lookVector * 1.5
		local headPos = currentPos + headOffset

		if headParts.head and headParts.head.Parent then
			headParts.head.CFrame = CFramelookAt(headPos, headPos + lookVector)
		end

		local lastHistoryPoint = getFromHistory(1)
		local dist = (currentPos - lastHistoryPoint.position).Magnitude
		if dist > 0.015 then
			if dist > activeConfig.SegmentSpacing * 0.8 then
				local numInterpolations = mathMin(mathFloor(dist / (activeConfig.SegmentSpacing * 0.6)), 3)
				for i = 1, numInterpolations do
					local fraction = i / (numInterpolations + 1)
					local interpPos = lastHistoryPoint.position:Lerp(currentPos, fraction)
					local interpLook = lastHistoryPoint.lookVector:Lerp(lookVector, fraction).Unit
					addToHistory({ position = interpPos, lookVector = interpLook })
				end
			end
			addToHistory({ position = currentPos, lookVector = lookVector })
		end

		local currentTime = tick()

		for i = 1, currentLength do
			local segment = segments[i]
			if segment and segment.Parent then
				local delay = mathFloor(i * 1.15)
				local targetData = getFromHistory(delay)
				if targetData then
					local segmentPos = targetData.position - targetData.lookVector * (activeConfig.SegmentSpacing * 0.08)
					local currentSegmentPos = segment.Position
					local newPos = currentSegmentPos:Lerp(segmentPos, followSpeed)

					segment.CFrame = CFramenew(newPos)
				end
			end
		end

		if currentTime - lastNetworkUpdate > 0.1 then
			lastNetworkUpdate = currentTime
		end
	end)
	table.insert(connections, heartbeatConn)

	local snakeInstance = {
		segments = segments,
		headParts = headParts,
		cleanup = cleanup,
		grow = growSnake,
		model = snakeModel,
		isActive = function() return isActive end,
	}
	playerSnakes[player] = snakeInstance
	_G.PlayerSnakes[player] = snakeInstance

	-- ENHANCED: Apply VFX based on skin (after snake is fully created)
	local function applyVFX()
		-- Only apply VFX if skin has VFX data and it's not causing performance issues
		local skinData = activeConfig.VFX
		if not skinData or not skinData.Type then return end

		-- Limit VFX to prevent lag
		-- Using the outer vfxParts variable for cleanup

		-- Apply VFX to head only (not every segment to prevent lag)
		if skinData.Type == "Fire" and headParts.head then
			-- Simple fire effect on head
			local fire = Instance.new("Fire")
			fire.Size = 5
			fire.Heat = 5
			fire.Color = skinData.Color or Color3.fromRGB(255, 0, 0)
			fire.SecondaryColor = Color3.new(
				math.min(fire.Color.R * 0.7, 1),
				math.min(fire.Color.G * 0.7, 1),
				math.min(fire.Color.B * 0.7, 1)
			)
			fire.Parent = headParts.head
			table.insert(vfxParts, fire)

		elseif skinData.Type == "Frost" and headParts.head then
			-- Frost particles on head
			local attachment = Instance.new("Attachment")
			attachment.Parent = headParts.head

			local emitter = Instance.new("ParticleEmitter")
			emitter.Texture = skinData.ParticleTexture or "rbxasset://textures/particles/sparkles_main.dds"
			emitter.Rate = 20
			emitter.Lifetime = NumberRange.new(1, 2)
			emitter.Speed = NumberRange.new(2, 4)
			emitter.VelocitySpread = 180
			emitter.Color = ColorSequence.new(skinData.Color or Color3.fromRGB(150, 220, 255))
			emitter.LightEmission = 0.8
			emitter.Size = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0.5),
				NumberSequenceKeypoint.new(1, 0)
			}
			emitter.Parent = attachment
			table.insert(vfxParts, attachment)

		elseif skinData.Type == "Energy" then
			-- Energy glow on first few segments only
			for i = 1, math.min(3, #segments) do
				local segment = segments[i]
				if segment then
					local light = Instance.new("PointLight")
					light.Color = skinData.Color or activeConfig.HeadColor
					light.Brightness = activeConfig.GlowIntensity * 2
					light.Range = activeConfig.GlowRange * 1.5
					light.Parent = segment
					table.insert(vfxParts, light)
				end
			end

		elseif skinData.Type == "Lightning" and headParts.head then
			-- Electric effect on head
			local attachment = Instance.new("Attachment")
			attachment.Parent = headParts.head

			local beam = Instance.new("Beam")
			beam.Texture = "rbxasset://textures/particles/sparkle_main.dds"
			beam.Width0 = 0.5
			beam.Width1 = 0.1
			beam.Color = ColorSequence.new(skinData.Color or Color3.fromRGB(255, 255, 0))
			beam.LightEmission = 1
			beam.Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.5, 0.3),
				NumberSequenceKeypoint.new(1, 1)
			}
			beam.Attachment0 = attachment

			-- Create second attachment for beam
			local attachment2 = Instance.new("Attachment")
			attachment2.Parent = segments[1] or headParts.head
			attachment2.Position = Vector3.new(0, 2, 0)
			beam.Attachment1 = attachment2

			beam.Parent = headParts.head
			table.insert(vfxParts, beam)
			table.insert(vfxParts, attachment)
			table.insert(vfxParts, attachment2)
		end

		-- VFX parts are stored in the local vfxParts variable for cleanup
	end

	-- Apply VFX after a short delay to ensure snake is fully created
	task.spawn(function()
		task.wait(0.1)
		if isActive and headParts.head and headParts.head.Parent then
			applyVFX()
		end
	end)

	-- Cleanup function

	return snakeInstance
end

-- ENHANCED: Handle player with skin monitoring
local function handlePlayer(player)
	-- Check if UnifiedSkinSystem already created leaderstats
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	local length = leaderstats:FindFirstChild("Length")
	if not length then
		length = Instance.new("NumberValue")
		length.Name = "Length"
		length.Value = 0
		length.Parent = leaderstats
	end

	local coins = leaderstats:FindFirstChild("Coins")
	if not coins then
		coins = Instance.new("NumberValue")
		coins.Name = "Coins"
		coins.Value = player:GetAttribute("Coins") or 100
		coins.Parent = leaderstats

		-- Update coins when attribute changes
		player.AttributeChanged:Connect(function(name)
			if name == "Coins" then
				coins.Value = player:GetAttribute("Coins") or 0
			end
		end)
	end

	-- REMOVED: Let UnifiedSkinSystem handle skin initialization
	-- if not player:GetAttribute("SelectedSkin") then
	-- 	player:SetAttribute("SelectedSkin", "Classic") -- Server's default skin name
	-- end

	-- ENHANCED: Store the selected skin persistently
	local selectedSkinValue = Instance.new("StringValue")
	selectedSkinValue.Name = "PersistentSelectedSkin"
	selectedSkinValue.Value = player:GetAttribute("SelectedSkin") or "Classic"
	selectedSkinValue.Parent = player

	-- Monitor for skin changes and sync
	player:GetAttributeChangedSignal("SelectedSkin"):Connect(function()
		local newSkin = player:GetAttribute("SelectedSkin")
		if newSkin and newSkin ~= "" then
			selectedSkinValue.Value = newSkin
			print("📝 Skin preference updated for", player.Name, ":", newSkin)
		end
	end)

	local function onCharacterAdded(character)
		-- ENHANCED: Ensure skin persists through respawns
		task.wait(0.1) -- Small delay to ensure attributes are set

		-- Double-check skin is still set (in case something reset it)
		local currentSkin = player:GetAttribute("SelectedSkin")
		local persistentSkin = selectedSkinValue.Value

		if not currentSkin or currentSkin == "" then
			-- Restore from persistent value
			if persistentSkin and persistentSkin ~= "" then
				print("⚠️ SelectedSkin was reset, restoring from persistent:", persistentSkin)
				player:SetAttribute("SelectedSkin", persistentSkin)
			else
				print("⚠️ SelectedSkin was reset, waiting for UnifiedSkinSystem")
				-- Don't set it here, let UnifiedSkinSystem handle it
			end
		else
			print("✅ Spawning with skin:", currentSkin)
			-- Update persistent value if different
			if currentSkin ~= persistentSkin then
				selectedSkinValue.Value = currentSkin
			end
		end

		taskSpawn(createUltraSmoothSnake, character)
	end

	if player.Character then
		onCharacterAdded(player.Character)
	end
	player.CharacterAdded:Connect(onCharacterAdded)
end

Players.PlayerRemoving:Connect(function(player)
	local snakeInstance = playerSnakes[player]
	if snakeInstance then
		snakeInstance.cleanup()
	end
	playerSnakes[player] = nil
	_G.PlayerSnakes[player] = nil
end)

-- NEW: Periodic cleanup to prevent orphaned segments
task.spawn(function()
	while true do
		task.wait(10) -- Check every 10 seconds

		local validSegments = {}

		-- Collect all valid segments from active snakes
		for _, player in pairs(Players:GetPlayers()) do
			local snake = playerSnakes[player] or _G.PlayerSnakes[player]
			if snake and snake.segments then
				for _, seg in pairs(snake.segments) do
					if seg and seg.Parent then
						validSegments[seg] = true
					end
				end
			end
		end

		-- Check SegmentContainer for orphaned segments
		if SegmentContainer then
			for _, child in pairs(SegmentContainer:GetChildren()) do
				if child:IsA("BasePart") and child.Name:match("^Segment") then
					if not validSegments[child] then
						-- This is an orphaned segment, destroy it
						child:Destroy()
					end
				end
			end
		end

		-- Clean up snake models without active players
		for _, child in pairs(workspace:GetChildren()) do
			if child:IsA("Model") and child:GetAttribute("IsSnakeModel") then
				local userId = child:GetAttribute("OwnerUserId")
				local playerExists = false

				for _, player in pairs(Players:GetPlayers()) do
					if player.UserId == userId then
						playerExists = true
						break
					end
				end

				if not playerExists then
					child:Destroy()
				end
			end
		end
	end
end)

local function initialize()
	print("SLITHER.IO SYSTEM V5.1 - LAG FIXED WITH SKIN SYSTEM")
	for _, player in Players:GetPlayers() do
		handlePlayer(player)
	end
	Players.PlayerAdded:Connect(handlePlayer)
	print("✅ System ready with improved performance and skin integration!")
end

-- ENHANCED: Handle respawn events
local function handleRespawnEvent()
	local respawnEvent = ReplicatedStorage:FindFirstChild("RespawnSnake")
	if respawnEvent then
		respawnEvent.OnServerEvent:Connect(function(player)
			if not player then return end
			print("🔄 Respawning player with current skin:", player.Name)
			player:LoadCharacter()
		end)
	end
end

-- Initialize respawn handler with retry
handleRespawnEvent()
task.spawn(function()
	for i = 1, 5 do
		if ReplicatedStorage:FindFirstChild("RespawnSnake") then break end
		task.wait(1)
		handleRespawnEvent()
	end
end)

-- REMOVED: Global skin update function to improve performance
-- Skins now only apply on spawn/respawn

taskSpawn(initialize)
