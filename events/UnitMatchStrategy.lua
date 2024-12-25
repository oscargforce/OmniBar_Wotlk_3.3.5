--[[ 
    UNIT_CAST_SUCCEEDED can fire multiple times for the same spell if the same player targets multiple units (e.g., target, focus, arena1). 
    Without optimization, this would create multiple icons for the same spell. 
    In arenas, to improve performance, we only track arena1, arena2, and arena3 if the bar is set to track all enemies.
]]
local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")

local arenaUnits = {
    ["arena1"] = true,
    ["arena2"] = true,
    ["arena3"] = true,
}

local nonArenaEnemyUnits = {
    ["target"] = true,
    ["focus"] = true,
}

local function MatchesArenaUnit(unit, trackedUnit)
    if trackedUnit == "enemy" then
        return arenaUnits[unit] or false
    end

    return unit == trackedUnit
end

local function MatchesGeneralUnit(unit, trackedUnit)
    if trackedUnit == "enemy" then
        return nonArenaEnemyUnits[unit] or false
    end

    return unit == trackedUnit
end

-- Factory function
local function GetUnitMatchStrategy(zone)
    if zone == "arena" then
        return MatchesArenaUnit
    else
        return MatchesGeneralUnit
    end
end

-- OmniBar integration
function OmniBar:UnitMatchesTrackedUnit(unit, trackedUnit)
    if not trackedUnit then
        return false
    end

    local strategy = GetUnitMatchStrategy(self.zone)

    return strategy(unit, trackedUnit)
end
