-- PurchaseHandler Integration Example
-- Place this script in ServerScriptService or as a Script in your tycoon model

local PurchaseHandler = require(script.Parent.PurchaseHandler) -- Adjust path as needed

-- Function to initialize a tycoon with the purchase handler
local function setupTycoon(tycoonModel, player)
    -- Create Owner value if it doesn't exist
    local ownerValue = tycoonModel:FindFirstChild("Owner") or Instance.new("ObjectValue")
    ownerValue.Name = "Owner"
    ownerValue.Value = player
    ownerValue.Parent = tycoonModel
    
    -- Create the purchase handler
    local handler = PurchaseHandler.new(tycoonModel)
    handler:Initialize()
    
    -- Connect to player's money changes
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local money = leaderstats:FindFirstChild("Money") or leaderstats:FindFirstChild("Cash")
        if money then
            -- Update handler when money changes
            money.Changed:Connect(function()
                handler:UpdateMoney(money.Value)
            end)
            
            -- Set initial money
            handler:UpdateMoney(money.Value)
        end
    end
    
    -- Fix button positions on startup
    wait(1) -- Wait for physics to settle
    handler:FixButtonPositions()
    
    -- Return handler for further use
    return handler
end

-- Example of full tycoon initialization
local TycoonService = {}

function TycoonService:ClaimTycoon(player, tycoonModel)
    -- Check if tycoon is already claimed
    local owner = tycoonModel:FindFirstChild("Owner")
    if owner and owner.Value then
        return false, "Tycoon already claimed"
    end
    
    -- Set up the tycoon
    local handler = setupTycoon(tycoonModel, player)
    
    -- Store handler reference (optional)
    player:SetAttribute("TycoonHandler", handler)
    
    return true, "Tycoon claimed successfully"
end

-- Example usage in a tycoon claim pad
local function createClaimPad(tycoonModel)
    local claimPad = tycoonModel:FindFirstChild("ClaimPad")
    if not claimPad then return end
    
    claimPad.Touched:Connect(function(hit)
        local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        
        local player = game.Players:GetPlayerFromCharacter(hit.Parent)
        if not player then return end
        
        -- Check if player already owns a tycoon
        if player:GetAttribute("OwnsTycoon") then return end
        
        local success, message = TycoonService:ClaimTycoon(player, tycoonModel)
        if success then
            player:SetAttribute("OwnsTycoon", true)
            claimPad.BrickColor = BrickColor.new("Lime green")
            claimPad.CanCollide = false
            
            -- Optional: Show claim message
            game.ReplicatedStorage.RemoteEvents.ShowMessage:FireClient(player, message)
        end
    end)
end

-- Initialize all tycoons in the workspace
for _, tycoon in pairs(workspace.Tycoons:GetChildren()) do
    createClaimPad(tycoon)
end

-- Alternative: Direct integration in tycoon script
--[[
local handler = PurchaseHandler.new(script.Parent)
handler:Initialize()

-- Update money from leaderstats
game.Players.PlayerAdded:Connect(function(player)
    if script.Parent.Owner.Value == player then
        player.CharacterAdded:Wait()
        wait(1)
        
        local leaderstats = player:WaitForChild("leaderstats")
        local money = leaderstats:WaitForChild("Money")
        
        money.Changed:Connect(function()
            handler:UpdateMoney(money.Value)
        end)
        
        handler:UpdateMoney(money.Value)
        handler:FixButtonPositions()
    end
end)
--]]

return TycoonService