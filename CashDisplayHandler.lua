-- Cash Display Handler
-- Add this to your tycoon to handle cash display updates
-- Place in the same folder as your CurrencyToCollect value

local tycoon = script.Parent
local currencyToCollect = tycoon:WaitForChild("CurrencyToCollect")
local owner = tycoon:WaitForChild("Owner")

-- Find all cash displays (TextLabels showing cash amount)
local function findCashDisplays()
	local displays = {}
	
	-- Common locations for cash displays
	local searchLocations = {
		tycoon:FindFirstChild("CashDisplay"),
		tycoon:FindFirstChild("MoneyDisplay"),
		tycoon:FindFirstChild("CollectorParts"),
		tycoon:FindFirstChild("Essentials"),
	}
	
	for _, location in pairs(searchLocations) do
		if location then
			for _, descendant in pairs(location:GetDescendants()) do
				if descendant:IsA("TextLabel") or descendant:IsA("TextBox") then
					-- Check if it looks like a cash display
					local text = descendant.Text
					if text:match("%$") or text:match("%d") or text:lower():match("cash") or text:lower():match("money") then
						table.insert(displays, descendant)
						print("Found cash display:", descendant:GetFullName())
					end
				end
			end
		end
	end
	
	-- Also check for SurfaceGuis and BillboardGuis
	for _, descendant in pairs(tycoon:GetDescendants()) do
		if descendant:IsA("SurfaceGui") or descendant:IsA("BillboardGui") then
			local textLabel = descendant:FindFirstChildOfClass("TextLabel")
			if textLabel then
				table.insert(displays, textLabel)
				print("Found display in GUI:", textLabel:GetFullName())
			end
		end
	end
	
	return displays
end

-- Update all displays
local function updateDisplays(value)
	local displays = findCashDisplays()
	
	for _, display in pairs(displays) do
		display.Text = "$" .. tostring(value)
	end
	
	if #displays > 0 then
		print("Updated", #displays, "cash displays to $" .. value)
	end
end

-- Update when currency changes
currencyToCollect.Changed:Connect(function()
	updateDisplays(currencyToCollect.Value)
end)

-- Reset displays when owner changes
owner.Changed:Connect(function()
	if owner.Value == nil then
		-- No owner, reset displays to 0
		updateDisplays(0)
		print("Reset cash displays (no owner)")
	end
end)

-- Initial update
updateDisplays(currencyToCollect.Value)