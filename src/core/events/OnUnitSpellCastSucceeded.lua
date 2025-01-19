--[[ 
    UNIT_CAST_SUCCEEDED can fire multiple times for the same spell if the same player targets multiple units (e.g., target, focus, arena1). 
    Without optimization, this would create multiple icons for the same spell. 
    In arenas, to improve performance, we only track arena1-5 if the bar is set to track all enemies.
]]
local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local UnitIsEnemy = UnitIsEnemy
local UnitIsUnit = UnitIsUnit
local UnitChannelInfo = UnitChannelInfo

local arenaUnits = {
    ["arena1"] = true,
    ["arena2"] = true,
    ["arena3"] = true,
    ["arena4"] = true,
    ["arena5"] = true,
    ["arenapet1"] = true,
    ["arenapet2"] = true,
    ["arenapet3"] = true,
    ["arenapet4"] = true,
    ["arenapet5"] = true,
}

local nonArenaEnemyUnits = {
    ["target"] = true,
    ["focus"] = true,
}

local function MatchesArenaUnit(unit, trackedUnit)
    if trackedUnit == "allEnemies" then
        return arenaUnits[unit] or false
    end

    if unit == trackedUnit then
        return true
    end

    if unit == trackedUnit:gsub("arena", "arenapet") then
        return true
    end

    if unit == trackedUnit:gsub("party", "partypet") then
        return true
    end

    return false
end

local function MatchesGeneralUnit(unit, trackedUnit)
    if trackedUnit == "allEnemies" then

        if not nonArenaEnemyUnits[unit] then
            return false
        end

        if not UnitIsEnemy("player", unit) then
            return false
        end 

        if UnitIsUnit("focus", "target") and unit == "focus" then
            return false
        end
        return nonArenaEnemyUnits[unit] or false 
    end
    
    if unit == trackedUnit then
        return true
    end

    if unit == trackedUnit:gsub("party", "partypet") then
        return true
    end
end

local function GetUnitMatchStrategy(zone)
    if zone == "arena" then
        return MatchesArenaUnit
    else
        return MatchesGeneralUnit
    end
end

local function UnitMatchesTrackedUnit(unit, trackedUnit)
    if not trackedUnit then
        return false
    end

    local strategy = GetUnitMatchStrategy(OmniBar.zone)

    return strategy(unit, trackedUnit)
end

-- Warmane fires UNIT_SPELLCAST_SUCCEEDED for each Penance tick, we need to filter out the first tick of the spell othwerwise we will display the icon multiple times.
local function IsFirstPenanceTick(unit)
    local name, _, _, _, startTime = UnitChannelInfo(unit)
    if not name or (GetTime() - (startTime/1000)) > 0.2 then 
        return false
    end

    return true
end

-- Maybe a bug, for example spirit wolves uses bash same ability as druid, we might display the icon if its tracked on druid but not on shaman. 
-- Need to test this, and if so add another condition icon.className == unit class, maybe want to add a cache for this to reduce the api calls.

-- Death knights death coil has same name as warlock spell :/ need to use some if statement on that spell
function OmniBar:OnUnitSpellCastSucceeded(barFrame, event, unit, spellName, spellRank)
    local barSettings = self.db.profile.bars[barFrame.key]
    if not UnitMatchesTrackedUnit(unit, barSettings.trackedUnit) then return end

    local spellData = barFrame.trackedSpells[spellName]
    if not spellData then return end
    if spellName == "Death Coil" and spellRank ~="Rank 6" then return end
    if spellName == "Penance" and not IsFirstPenanceTick(unit) then return end

    print("PASSED:", spellName)
    self:OnCooldownUsed(barFrame, barSettings, unit, spellName, spellData)
end

