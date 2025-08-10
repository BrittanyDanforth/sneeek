-- Settings Module for Unified Leaderboard
-- Configure your leaderboard settings here

local Settings = {}

-- Leaderboard Configuration
Settings.LeaderboardSettings = {
    -- Enable/Disable Features
    KOs = true,                    -- Enable kill tracking
    WOs = true,                    -- Enable death tracking (Wipeouts)
    ShowCurrency = true,           -- Enable currency display
    ShowShortCurrency = true,      -- Show currency in short format (1K, 1M, etc.)
    
    -- Stat Names (as they appear on the leaderboard)
    KillsName = "KOs",            -- Name for kills stat
    DeathsName = "Wipeouts",      -- Name for deaths stat
}

-- Currency Configuration
Settings.CurrencyName = "Cash"     -- Name for currency stat

-- Helper Functions for Currency Display
function Settings:ConvertShort(value)
    if value >= 1000000000000 then
        return string.format("%.1fT", value / 1000000000000)
    elseif value >= 1000000000 then
        return string.format("%.1fB", value / 1000000000)
    elseif value >= 1000000 then
        return string.format("%.1fM", value / 1000000)
    elseif value >= 1000 then
        return string.format("%.1fK", value / 1000)
    else
        return tostring(value)
    end
end

function Settings:ConvertComma(value)
    local formatted = tostring(value)
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted
end

return Settings