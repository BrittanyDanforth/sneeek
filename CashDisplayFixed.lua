-- Cash Display Script - FIXED
-- This goes inside the TextLabel in your collector parts display

local tycoon = script.Parent.Parent.Parent.Parent.Parent.Parent
local currencyToCollect = tycoon:WaitForChild("CurrencyToCollect")
local owner = tycoon:WaitForChild("Owner")

-- Function to update display
local function updateDisplay()
	script.Parent.Text = "$" .. currencyToCollect.Value
end

-- Show initial value
updateDisplay()

-- Update when money changes
currencyToCollect.Changed:Connect(function()
	updateDisplay()
end)

-- IMPORTANT: Reset to $0 when owner leaves!
owner.Changed:Connect(function()
	if owner.Value == nil then
		-- No owner = reset display to $0
		script.Parent.Text = "$0"
	end
end)