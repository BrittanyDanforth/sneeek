--[[
	Fix Teams Only Script
	This ONLY fixes the TeamColor issues that are breaking teams
	Place in ServerScriptService
--]]

print("🎨 === FIXING TEAM COLORS === 🎨")

-- Wait a moment for everything to load
wait(1)

-- Fix TeamColor for all tycoons
local function fixTycoonTeamColors()
	-- Define team colors for each tycoon
	local tycoonColors = {
		HelloKitty = "Hot pink",
		Cinnamoroll = "Pastel Blue", 
		Kuromi = "Black",
		MyMelody = "Pink"
	}
	
	-- Fix SpidermanTycoon tycoons
	local spidermanTycoon = workspace:FindFirstChild("SpidermanTycoon")
	if spidermanTycoon then
		local innerTycoon = spidermanTycoon:FindFirstChild("Spiderman tycoon")
		if innerTycoon then
			-- Add TeamColor to the inner tycoon model
			if not innerTycoon:FindFirstChild("TeamColor") then
				local tc = Instance.new("BrickColorValue")
				tc.Name = "TeamColor"
				tc.Value = BrickColor.new("Really red")
				tc.Parent = innerTycoon
				print("✅ Added TeamColor to Spiderman tycoon")
			end
			
			-- Fix individual tycoons inside
			local tycoons = innerTycoon:FindFirstChild("Tycoons")
			if tycoons then
				for tycoonName, colorName in pairs(tycoonColors) do
					local tycoon = tycoons:FindFirstChild(tycoonName)
					if tycoon and not tycoon:FindFirstChild("TeamColor") then
						local tc = Instance.new("BrickColorValue")
						tc.Name = "TeamColor"
						tc.Value = BrickColor.new(colorName)
						tc.Parent = tycoon
						print("✅ Added TeamColor", colorName, "to", tycoonName)
					end
				end
			end
		end
	end
	
	-- Also check the main Tycoons folder
	local mainTycoons = workspace:FindFirstChild("Tycoons")
	if mainTycoons then
		-- Add TeamColor to Tycoons folder itself (for PurchaseHandler line 33)
		if not mainTycoons:FindFirstChild("TeamColor") then
			local tc = Instance.new("BrickColorValue")
			tc.Name = "TeamColor"
			tc.Value = BrickColor.new("Medium stone grey")
			tc.Parent = mainTycoons
			print("✅ Added TeamColor to main Tycoons folder")
		end
		
		-- Fix PurchaseHandler's TeamColor
		local purchaseHandler = mainTycoons:FindFirstChild("PurchaseHandler")
		if purchaseHandler and not purchaseHandler:FindFirstChild("TeamColor") then
			local tc = Instance.new("BrickColorValue")
			tc.Name = "TeamColor"
			tc.Value = BrickColor.new("Medium stone grey")
			tc.Parent = purchaseHandler
			print("✅ Added TeamColor to PurchaseHandler")
		end
	end
end

-- Run the fix
fixTycoonTeamColors()

-- Also create teams in Teams service if they don't exist
local Teams = game:GetService("Teams")
local function createTeams()
	local teamsToCreate = {
		{name = "HelloKitty", color = BrickColor.new("Hot pink")},
		{name = "Cinnamoroll", color = BrickColor.new("Pastel Blue")},
		{name = "Kuromi", color = BrickColor.new("Black")},
		{name = "MyMelody", color = BrickColor.new("Pink")}
	}
	
	for _, teamInfo in ipairs(teamsToCreate) do
		if not Teams:FindFirstChild(teamInfo.name) then
			local team = Instance.new("Team")
			team.Name = teamInfo.name
			team.TeamColor = teamInfo.color
			team.AutoAssignable = false
			team.Parent = Teams
			print("✅ Created team:", teamInfo.name)
		end
	end
end

createTeams()

print("🎨 === TEAM FIX COMPLETE === 🎨")
print("Teams should now work properly!")