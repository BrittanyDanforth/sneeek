--[[
	Tycoon Debug Monitor
	Provides real-time monitoring and debugging for tycoon systems
	Place in ServerScriptService
--]]

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")

local DEBUG_ENABLED = true
local LOG_TO_FILE = false -- Set to true to save logs

-- Data tracking
local TycoonData = {}
local PurchaseHistory = {}
local ErrorLog = {}
local PerformanceMetrics = {
	PartCollections = 0,
	Purchases = 0,
	Steals = 0,
	Errors = 0,
	StartTime = tick()
}

-- Create debug GUI for server owner
local function CreateDebugGui(player)
	if not DEBUG_ENABLED then return end
	
	local gui = Instance.new("ScreenGui")
	gui.Name = "TycoonDebugMonitor"
	gui.ResetOnSpawn = false
	
	-- Main frame
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 400, 0, 300)
	frame.Position = UDim2.new(1, -420, 0, 20)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 0
	frame.Parent = gui
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 30)
	title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	title.Text = "Tycoon Debug Monitor"
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Font = Enum.Font.SourceSansBold
	title.TextSize = 16
	title.Parent = frame
	
	-- Scrolling frame for logs
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -10, 1, -40)
	scroll.Position = UDim2.new(0, 5, 0, 35)
	scroll.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 4
	scroll.Parent = frame
	
	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll
	
	gui.Parent = player:WaitForChild("PlayerGui")
	
	return scroll, layout
end

-- Log function
local function Log(logType, message, data)
	if not DEBUG_ENABLED then return end
	
	local timestamp = os.date("%H:%M:%S")
	local logEntry = {
		Time = timestamp,
		Type = logType,
		Message = message,
		Data = data or {},
		Tick = tick()
	}
	
	-- Console output
	local color = ""
	if logType == "ERROR" then
		color = "📛"
		PerformanceMetrics.Errors += 1
	elseif logType == "PURCHASE" then
		color = "💰"
		PerformanceMetrics.Purchases += 1
	elseif logType == "STEAL" then
		color = "🔓"
		PerformanceMetrics.Steals += 1
	elseif logType == "COLLECT" then
		color = "📦"
		PerformanceMetrics.PartCollections += 1
	else
		color = "ℹ️"
	end
	
	print(string.format("[%s] %s %s: %s", timestamp, color, logType, message))
	
	-- Store in appropriate log
	if logType == "ERROR" then
		table.insert(ErrorLog, logEntry)
		if #ErrorLog > 100 then
			table.remove(ErrorLog, 1)
		end
	elseif logType == "PURCHASE" then
		table.insert(PurchaseHistory, logEntry)
		if #PurchaseHistory > 50 then
			table.remove(PurchaseHistory, 1)
		end
	end
end

-- Monitor tycoon function
local function MonitorTycoon(tycoon)
	local tycoonName = tycoon.Name
	
	TycoonData[tycoonName] = {
		Owner = nil,
		Money = 0,
		ButtonsPurchased = 0,
		TotalSpent = 0,
		PartsCollected = 0,
		LastActivity = tick()
	}
	
	local data = TycoonData[tycoonName]
	
	-- Monitor owner changes
	local ownerValue = tycoon:FindFirstChild("Owner")
	if ownerValue then
		ownerValue.Changed:Connect(function()
			data.Owner = ownerValue.Value
			Log("INFO", "Tycoon " .. tycoonName .. " claimed by " .. (ownerValue.Value and ownerValue.Value.Name or "nobody"))
		end)
	end
	
	-- Monitor money
	local moneyValue = tycoon:FindFirstChild("CurrencyToCollect")
	if moneyValue then
		moneyValue.Changed:Connect(function()
			local change = moneyValue.Value - data.Money
			data.Money = moneyValue.Value
			
			if change > 0 then
				data.PartsCollected += 1
			end
		end)
	end
	
	-- Monitor purchases
	local purchasedObjects = tycoon:FindFirstChild("PurchasedObjects")
	if purchasedObjects then
		purchasedObjects.ChildAdded:Connect(function(child)
			data.ButtonsPurchased += 1
			data.LastActivity = tick()
			
			-- Try to find the cost
			local cost = "Unknown"
			local buttons = tycoon:FindFirstChild("Buttons")
			if buttons then
				for _, button in pairs(buttons:GetChildren()) do
					if button:FindFirstChild("Object") and button.Object.Value == child.Name then
						cost = button:FindFirstChild("Price") and button.Price.Value or "Unknown"
						break
					end
				end
			end
			
			Log("PURCHASE", string.format("%s bought %s for %s", 
				data.Owner and data.Owner.Name or "Unknown",
				child.Name,
				tostring(cost)
			), {
				Tycoon = tycoonName,
				Object = child.Name,
				Cost = cost
			})
		end)
	end
end

-- Performance reporter
local function ReportPerformance()
	local uptime = tick() - PerformanceMetrics.StartTime
	local hours = math.floor(uptime / 3600)
	local minutes = math.floor((uptime % 3600) / 60)
	
	print("\n=== TYCOON PERFORMANCE REPORT ===")
	print(string.format("Uptime: %d hours, %d minutes", hours, minutes))
	print(string.format("Total Purchases: %d", PerformanceMetrics.Purchases))
	print(string.format("Total Collections: %d", PerformanceMetrics.PartCollections))
	print(string.format("Total Steals: %d", PerformanceMetrics.Steals))
	print(string.format("Total Errors: %d", PerformanceMetrics.Errors))
	print("=================================\n")
	
	-- Per-tycoon stats
	for name, data in pairs(TycoonData) do
		if data.Owner then
			print(string.format("Tycoon %s (Owner: %s)", name, data.Owner.Name))
			print(string.format("  - Buttons: %d, Money: %d", data.ButtonsPurchased, data.Money))
		end
	end
end

-- Export debug data
_G.TycoonDebug = {
	GetData = function()
		return {
			Tycoons = TycoonData,
			Purchases = PurchaseHistory,
			Errors = ErrorLog,
			Performance = PerformanceMetrics
		}
	end,
	
	Log = Log,
	
	ExportJSON = function()
		return HttpService:JSONEncode(_G.TycoonDebug.GetData())
	end,
	
	ClearLogs = function()
		PurchaseHistory = {}
		ErrorLog = {}
		Log("INFO", "Debug logs cleared")
	end
}

-- Initialize monitoring
local function Initialize()
	-- Find all tycoons
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:FindFirstChild("Owner") and obj:FindFirstChild("CurrencyToCollect") then
			Log("INFO", "Found tycoon: " .. obj.Name)
			MonitorTycoon(obj)
		end
	end
	
	-- Report performance every 5 minutes
	task.spawn(function()
		while true do
			task.wait(300)
			ReportPerformance()
		end
	end)
end

-- Start monitoring
Initialize()

Log("INFO", "Tycoon Debug Monitor initialized")
print("Access debug data with _G.TycoonDebug.GetData()")
print("Export JSON with _G.TycoonDebug.ExportJSON()")
print("Clear logs with _G.TycoonDebug.ClearLogs()")