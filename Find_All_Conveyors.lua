-- Script to find ALL conveyor-related parts and scripts
-- Place this in ServerScriptService and run once

print("========================================")
print("🔍 SEARCHING FOR ALL CONVEYOR SCRIPTS")
print("========================================")

local conveyorScripts = {}
local conveyorParts = {}

-- Function to search for conveyor-related items
local function searchForConveyors(parent, path)
	path = path or parent:GetFullName()
	
	for _, child in ipairs(parent:GetChildren()) do
		-- Check for conveyor scripts
		if child:IsA("Script") and (child.Name:lower():find("conveyor") or child.Name:lower():find("conveyer")) then
			table.insert(conveyorScripts, {
				script = child,
				path = child:GetFullName()
			})
		end
		
		-- Check for conveyor parts
		if child:IsA("BasePart") and (child.Name:lower():find("conv") or child.Name:lower():find("conveyor") or child.Name:lower():find("conveyer")) then
			table.insert(conveyorParts, {
				part = child,
				path = child:GetFullName(),
				hasScript = #child:GetChildren() > 0
			})
		end
		
		-- Recursive search
		if child:IsA("Model") or child:IsA("Folder") then
			searchForConveyors(child, path .. "." .. child.Name)
		end
	end
end

-- Search all tycoons
for _, tycoonKit in ipairs(workspace:GetChildren()) do
	if tycoonKit.Name:find("Tycoon") then
		searchForConveyors(tycoonKit)
	end
end

-- Report findings
print("\n📜 CONVEYOR SCRIPTS FOUND:", #conveyorScripts)
for i, data in ipairs(conveyorScripts) do
	print(i .. ". " .. data.path)
	
	-- Check script content
	local source = data.script.Source
	if source then
		local hasVelocity = source:find("Velocity")
		local hasWait = source:find("wait")
		local hasWhileLoop = source:find("while true")
		print("   - Has Velocity:", hasVelocity and "YES" or "NO")
		print("   - Has wait:", hasWait and "YES" or "NO")
		print("   - Has while loop:", hasWhileLoop and "YES" or "NO")
	end
end

print("\n⚙️ CONVEYOR PARTS FOUND:", #conveyorParts)
for i, data in ipairs(conveyorParts) do
	local part = data.part
	print(i .. ". " .. data.path)
	print("   - Size:", tostring(part.Size))
	print("   - Anchored:", part.Anchored)
	print("   - CanCollide:", part.CanCollide)
	print("   - Has Scripts:", data.hasScript)
	
	-- Check for velocity-related objects
	local bodyVel = part:FindFirstChild("BodyVelocity")
	local bodyPos = part:FindFirstChild("BodyPosition")
	if bodyVel then
		print("   - Has BodyVelocity:", bodyVel.Velocity)
	end
	if bodyPos then
		print("   - Has BodyPosition")
	end
end

-- Check for duplicate conveyor systems
print("\n⚠️ CHECKING FOR DUPLICATES:")
local conveyorModels = {}
for _, child in ipairs(workspace:GetDescendants()) do
	if child:IsA("Model") and (child.Name == "Conveyer" or child.Name == "ConveyerArea" or child.Name == "Conveyor") then
		table.insert(conveyorModels, child:GetFullName())
	end
end

for _, path in ipairs(conveyorModels) do
	print("- " .. path)
end

print("\n========================================")
print("✅ CONVEYOR SEARCH COMPLETE")
print("========================================")