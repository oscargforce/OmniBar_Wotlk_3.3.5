--[[ 
    UNIT_CAST_SUCCEEDED can fire multiple times for the same spell if the same player targets multiple units (e.g., target, focus, arena1). 
    Without optimization, this would create multiple icons for the same spell. 
    In arenas, to improve performance, we only track arena1-5 if the bar is set to track all enemies.
]]
local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local addonName, addon = ...
local MapPetToPlayerUnit = addon.MapPetToPlayerUnit
local UnitIsEnemy = UnitIsEnemy
local UnitIsUnit = UnitIsUnit
local UnitGUID = UnitGUID
local UnitChannelInfo = UnitChannelInfo
local UnitIsPlayer = UnitIsPlayer

local arenaUnits = {
    ["arena1"] = true,
    ["arena2"] = true,
    ["arena3"] = true,
    ["arena4"] = true,
    ["arena5"] = true,
}

local nonArenaEnemyUnits = {
    ["target"] = true,
    ["focus"] = true,
}

local function MatchesArenaUnit(unit, trackedUnit)
    if trackedUnit == "allEnemies" then
        return arenaUnits[unit] or false
    end

    return unit == trackedUnit
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
    
    return unit == trackedUnit 
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

-- Warmane fires duplicate UNIT_SPELLCAST_SUCCEEDED events for certain spells like Penance and Typhoon. We need to filter these out to avoid adding duplicate icons.
local lastCastTimes = {}

local brokenWarmaneSpells = {
    ["Penance"] = true,
    ["Typhoon"] = true
}

local function IsFirstSpellCast(unit, spellName, barKey)
    if not brokenWarmaneSpells[spellName] then
        return true
    end

    local currentTime = GetTime()
    if not lastCastTimes[barKey] then
        lastCastTimes[barKey] = {}
    end

    if not lastCastTimes[barKey][unit] then
        lastCastTimes[barKey][unit] = {}
    end

    if lastCastTimes[barKey][unit][spellName] and (currentTime - lastCastTimes[barKey][unit][spellName]) < 2.2 then
        print("BLOCKED:", unit, spellName)
        return false
    end

    lastCastTimes[barKey][unit][spellName] = currentTime
    return true
end

local function GetUnitGUID(unit, barKey)
    if unit:match("^arena[1-5]$") then
        local opponent = OmniBar.arenaOpponents[unit]
        return opponent and opponent.unitGUID
    end
    
    if unit:match("^party[1-4]$") then
        local partyGUIDs = OmniBar.partyMemberGUIDs[barKey]
        return partyGUIDs and partyGUIDs[unit]
    end

    return UnitGUID(unit)
end

-- Maybe a bug, for example spirit wolves uses bash same ability as druid, we might display the icon if its tracked on druid but not on shaman. 
-- Need to test this, and if so add another condition icon.className == unit class, maybe want to add a cache for this to reduce the api calls.

-- Death knights death coil has same name as warlock spell :/ need to use some if statement on that spell

function OmniBar:OnUnitSpellCastSucceeded(barFrame, event, unit, spellName, spellRank)
    local barKey = barFrame.key
    local barSettings = self.db.profile.bars[barKey]

    local mappedUnit = MapPetToPlayerUnit(unit, barKey)

    if not UnitMatchesTrackedUnit(mappedUnit, barSettings.trackedUnit) then 
        return 
    end

    if spellName == "Death Coil" and spellRank ~="Rank 6" then 
        return 
    end

    if not IsFirstSpellCast(mappedUnit, spellName, barKey) then 
        return 
    end

    
    local unitGUID = GetUnitGUID(mappedUnit, barKey)
    self:DetectSpecByAbility(spellName, mappedUnit, barFrame, barSettings, unitGUID)
    self:ResetCooldownsForSpell(barFrame, barSettings, unitGUID, spellName)
    self:SharedCooldownsHandler(barFrame, barSettings, mappedUnit, unitGUID, spellName)
    local spellData = barFrame.trackedSpells[spellName]

    if not spellData then return end
    -- Prevent showing icons for enemy pets in the open world, let the combat log event handler handle it.
    if self.zone ~= "arena" and not UnitIsPlayer(mappedUnit) and UnitIsEnemy(mappedUnit, "player") then 
        return 
    end

    print("PASSED:", mappedUnit, spellName)
    self:OnCooldownUsed(barFrame, barSettings, mappedUnit, unitGUID, spellName, spellData)
end
