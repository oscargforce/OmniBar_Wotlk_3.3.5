local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local UnitGUID = UnitGUID
local UnitClass = UnitClass
local UnitRace = UnitRace
local UnitExists = UnitExists

local processedBars = {}

-- Caches and returns the arena units class and race.
 local function GetUnitData(unit)
    local arenaOpponents = OmniBar.arenaOpponents

    if not arenaOpponents[unit] then
        local unitGUID = UnitGUID(unit)
        print("GUID:", unit, unitGUID)
        local unitClass = UnitClass(unit) 
        local unitRace = UnitRace(unit)  
        arenaOpponents[unit] = {
            unitGUID = unitGUID,
            className = unitClass,
            race = unitRace,
            spec = nil
        }

        return unitClass, unitRace, unitGUID
    end

    return arenaOpponents[unit].className, arenaOpponents[unit].race, arenaOpponents[unit].unitGUID
end

-- Reset state of the unit data and processed bars.
local function ClearUnitData(unit)
    local arenaOpponents = OmniBar.arenaOpponents

    arenaOpponents[unit] = nil
    for barKey, units in pairs(processedBars) do
        units[unit] = nil
    end

    OmniBar:ClearSpecProcessedData(unit)
    OmniBar.isArenaMatchInProgress = false
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
    local arenaOpponents = OmniBar.arenaOpponents
    
    return arenaOpponents[unit] and arenaOpponents[unit].className and arenaOpponents[unit].race
end

local function ShouldTrackSpell(spellName, spellData, unitClass, unitRace)
    if unitClass == spellData.className then
        if spellData.spec then 
            return false 
        end
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

    OmniBar.isArenaMatchInProgress = true
    local unitClass, unitRace, unitGUID = GetUnitData(unit)
    MarkBarAsProcessed(barKey, unit)

    for spellName, spellData in pairs(barFrame.trackedSpells) do
        if ShouldTrackSpell(spellName, spellData, unitClass, unitRace) then
            OmniBar:CreateIconToBar(barFrame, spellName, spellData, unitGUID, unit)
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

    self.isArenaMatchInProgress = true
    local unitClass, unitRace, unitGUID = GetUnitData(unit)
    MarkBarAsProcessed(barKey, unit)

    for spellName, spellData in pairs(barFrame.trackedSpells) do
        if ShouldTrackSpell(spellName, spellData, unitClass, unitRace) then
            self:CreateIconToBar(barFrame, spellName, spellData, unitGUID, unit)
        end
    end

    self:ArrangeIcons(barFrame, barSettings)
    self:UpdateUnusedAlpha(barFrame, barSettings)
end

-- Util function called in OmniBar:PLAYER_ENTERING_WORLD()
function OmniBar:HandleMidGameReloadsForArenaUpdate()
    if not UnitExists("arena1") then return end

    for barKey, barSettings in pairs(self.db.profile.bars) do
        local barFrame = self.barFrames[barKey]

        if barSettings.showUnusedIcons then
            -- Handle bars tracking all arena enemies
            if barSettings.trackedUnit == "allEnemies" then
                local existingUnits = {}

                -- Collect all active arena units
                for i = 1, 5 do
                    local unit = "arena" .. i
                    if UnitExists(unit) then
                        table.insert(existingUnits, unit)
                    end
                end

                for _, unit in ipairs(existingUnits) do
                    self:OnArenaOpponentUpdate(barFrame, "", unit, "seen")
                end

            -- Handle bars tracking specific arena units
            elseif barSettings.trackedUnit:match("^arena[1-5]$") then
                if UnitExists(barSettings.trackedUnit) then
                    self:OnArenaOpponentUpdate(barFrame, "", barSettings.trackedUnit, "seen")
                end
            end
        end
    end
end
