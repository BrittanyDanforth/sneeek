-- Run this in Command Bar to disable old tycoon kits
local oldKits = {
    "SpidermanTycoon",
    "Venom Tycoon", 
    "Zednov's Tycoon Kit"
}

for _, kitName in ipairs(oldKits) do
    local kit = workspace:FindFirstChild(kitName)
    if kit then
        -- Disable all scripts in the kit
        for _, descendant in ipairs(kit:GetDescendants()) do
            if descendant:IsA("Script") or descendant:IsA("LocalScript") then
                descendant.Disabled = true
            end
        end
        -- Move to ServerStorage so it's out of the way
        kit.Parent = game.ServerStorage
        print("Disabled and moved:", kitName)
    end
end

print("Old tycoon kits disabled!")