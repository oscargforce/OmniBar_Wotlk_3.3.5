local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local UnitClass = UnitClass
local UnitRace = UnitRace

local arenaOpponents = {}
local processedBars = {}

-- Caches and returns the arena units class and race.
 local function GetUnitData(unit)
    if not arenaOpponents[unit] then
        local unitClass = UnitClass(unit) 
        local unitRace = UnitRace(unit) 
        arenaOpponents[unit] = {
            className = unitClass,
            race = unitRace
        }

        return unitClass, unitRace
    end

    return arenaOpponents[unit].className, arenaOpponents[unit].race
end

-- Reset state of the unit data and processed bars.
local function ClearUnitData(unit)
    arenaOpponents[unit] = nil
    for barKey, units in pairs(processedBars) do
        units[unit] = nil
    end
end

-- Mark the bar as processed for the unit. To prevent duplicate requests and icons.
local function MarkBarAsProcessed(barKey, unit)
    if not processedBars[barKey] then
        processedBars[barKey] = {}
    end
    processedBars[barKey][unit] = true
end

local function HasBarProcessedUnit(barKey, unit)
    return processedBars[barKey] and processedBars[barKey][unit]
end

local function AlreadyFilteredByClassAndRace(unit)
    return arenaOpponents[unit] and arenaOpponents[unit].className and arenaOpponents[unit].race
end

local function ShouldTrackSpell(spellName, spellData, unitClass, unitRace)
    if unitClass == spellData.className then
        return true
    end

    if spellData.race and spellData.race == unitRace then
        return true
    end

    if spellName == "PvP Trinket" and unitRace ~= "Human" then
        return true
    end

    return false
end

local function HandleAllArenaUnits(barFrame, barSettings, barKey, unit, updateReason)
    if not unit:match("^arena[1-5]$") then return end

    if updateReason == "cleared" then
        ClearUnitData(unit)
        if OmniBar.zone == "arena" then 
            OmniBar:ResetIcons(barFrame) 
        end
        return
    end

    if updateReason ~= "seen" then return end

    if AlreadyFilteredByClassAndRace(unit) and HasBarProcessedUnit(barKey, unit) then
        return
    end

    local unitClass, unitRace = GetUnitData(unit)
    MarkBarAsProcessed(barKey, unit)

    for spellName, spellData in pairs(barFrame.trackedSpells) do
        if ShouldTrackSpell(spellName, spellData, unitClass, unitRace) then
            OmniBar:CreateIconToBar(barFrame, spellName, spellData)
        end
    end

    OmniBar:ArrangeIcons(barFrame, barSettings)
    OmniBar:UpdateUnusedAlpha(barFrame, barSettings)
end

function OmniBar:OnArenaOpponentUpdate(barFrame, event, unit, updateReason)
    local barKey = barFrame.key
    local barSettings = self.db.profile.bars[barKey]

    if not barSettings.showUnusedIcons then return end

    local trackedUnit = barSettings.trackedUnit

    if trackedUnit == "allEnemies" then
        HandleAllArenaUnits(barFrame, barSettings, barKey, unit, updateReason)
        return
    end

    if unit ~= barSettings.trackedUnit then return end
    
    if updateReason == "cleared" then 
        ClearUnitData(unit)
        self:ResetIcons(barFrame)
        return
    end

    if updateReason ~= "seen" then return end

    if AlreadyFilteredByClassAndRace(unit) and HasBarProcessedUnit(barKey, unit) then
        return
    end

    local unitClass, unitRace = GetUnitData(unit)
    MarkBarAsProcessed(barKey, unit)

    for spellName, spellData in pairs(barFrame.trackedSpells) do
        if ShouldTrackSpell(spellName, spellData, unitClass, unitRace) then
            self:CreateIconToBar(barFrame, spellName, spellData)
        end
    end

    self:ArrangeIcons(barFrame, barSettings)
    self:UpdateUnusedAlpha(barFrame, barSettings)
end
