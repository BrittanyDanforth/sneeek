-- SUPER DEBUG CONVEYOR SCRIPT
-- This will print TONS of information about where this script is located

print("=====================================")
print("🎯 CONVEYOR SCRIPT DEBUG STARTING 🎯")
print("=====================================")
print("Script Name:", script.Name)
print("Script ClassName:", script.ClassName)
print("Script Full Path:", script:GetFullName())
print("=====================================")

-- Function to print the entire hierarchy
local function printHierarchy()
	print("\n📍 FULL HIERARCHY BREAKDOWN:")
	local current = script
	local level = 0
	
	-- Go up the tree
	while current do
		print(string.rep("  ", level) .. "└─ " .. current.Name .. " (" .. current.ClassName .. ")")
		current = current.Parent
		level = level + 1
		if level > 20 then break end -- Safety limit
	end
end

printHierarchy()

-- Check what model/part this script is attached to
print("\n🔍 IMMEDIATE PARENT INFO:")
print("Parent Name:", script.Parent.Name)
print("Parent Class:", script.Parent.ClassName)
print("Parent Position:", tostring(script.Parent.Position))
print("Parent Size:", tostring(script.Parent.Size))

-- Check if we're in CollectorParts
local collectorParts = script.Parent.Parent
if collectorParts and collectorParts.Name == "CollectorParts" then
	print("\n📦 COLLECTORPARTS FOUND:")
	print("CollectorParts children count:", #collectorParts:GetChildren())
	for i, child in ipairs(collectorParts:GetChildren()) do
		print("  - " .. child.Name .. " (" .. child.ClassName .. ")")
	end
end

-- Check if we're in Essentials
local essentials = script.Parent.Parent and script.Parent.Parent.Parent
if essentials and essentials.Name == "Essentials" then
	print("\n🏗️ ESSENTIALS FOUND:")
	print("Essentials children:")
	for i, child in ipairs(essentials:GetChildren()) do
		if child:IsA("Model") or child:IsA("Folder") then
			print("  - " .. child.Name .. " (" .. child.ClassName .. ") with " .. #child:GetChildren() .. " children")
		else
			print("  - " .. child.Name .. " (" .. child.ClassName .. ")")
		end
	end
end

-- Check if we're in a tycoon
local tycoon = script.Parent.Parent and script.Parent.Parent.Parent and script.Parent.Parent.Parent.Parent
if tycoon and (tycoon.Name:find("Cinnamoroll") or tycoon.Name:find("Tycoon")) then
	print("\n🏰 TYCOON FOUND:")
	print("Tycoon Name:", tycoon.Name)
	print("Tycoon Full Path:", tycoon:GetFullName())
	
	-- Check for owner
	local owner = tycoon:FindFirstChild("Owner")
	if owner then
		print("Tycoon Owner Value:", owner.Value and owner.Value.Name or "No Owner")
	end
	
	-- Check for other important folders
	local important = {"Buttons", "Purchases", "PurchasedObjects", "Essentials"}
	for _, folderName in ipairs(important) do
		local folder = tycoon:FindFirstChild(folderName)
		if folder then
			print("Found " .. folderName .. " with " .. #folder:GetChildren() .. " items")
		end
	end
end

print("\n⚙️ STARTING CONVEYOR MOVEMENT ⚙️")
print("Initial Velocity:", tostring(script.Parent.Velocity))
print("Initial CFrame:", tostring(script.Parent.CFrame))

-- Add debug for the actual conveyor movement
local loopCount = 0
local startTime = tick()

-- Modern conveyor script with debug
while true do
	loopCount = loopCount + 1
	
	-- Every 50 loops (10 seconds), print debug info
	if loopCount % 50 == 0 then
		print("\n📊 CONVEYOR STATUS UPDATE #" .. loopCount/50)
		print("Time Running:", string.format("%.1f seconds", tick() - startTime))
		print("Current Position:", tostring(script.Parent.Position))
		print("Current Velocity:", tostring(script.Parent.Velocity))
		print("LookVector:", tostring(script.Parent.CFrame.LookVector))
		print("Calculated Speed:", tostring(script.Parent.CFrame.LookVector * 23))
		
		-- Check if part still exists and is in workspace
		if not script.Parent:IsDescendantOf(workspace) then
			print("⚠️ WARNING: Conveyor part is no longer in workspace!")
		end
		
		-- Check anchored status
		if script.Parent.Anchored then
			print("⚠️ WARNING: Part is anchored! Velocity won't work!")
		end
	end
	
	-- Set the velocity
	script.Parent.Velocity = script.Parent.CFrame.LookVector * 23
	
	-- Use modern task.wait instead of wait
	task.wait(0.2)
	
	-- Safety check every loop
	if not script.Parent then
		print("❌ ERROR: Script parent was destroyed!")
		break
	end
end

print("❌ CONVEYOR SCRIPT ENDED UNEXPECTEDLY!")