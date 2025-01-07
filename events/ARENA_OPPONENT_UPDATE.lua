local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local UnitClass = UnitClass
local UnitRace = UnitRace

--[[
    local arenaOpponents = {
        ["arena1"] = {
            ["class"] = "Warrior",
            ["race"] = "Human"
        }
    }

    local processedBars = {
        ["OmniBar1"] = {
            ["arena1"] = true
        }
        ["OmniBar2"] = {
            ["arena1"] = true
        }
    }

/dump arenaOpponents
/dump processedBars
]]

 local arenaOpponents = {}
 local processedBars = {}

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

local function ClearUnitData(unit)
    arenaOpponents[unit] = nil
    for barKey, units in pairs(processedBars) do
        units[unit] = nil
    end
end

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
    return arenaOpponents[unit] and arenaOpponents[unit].class and arenaOpponents[unit].race
end


function OmniBar:OnArenaOpponentUpdate(barFrame, event, unit, updateReason)
    local barKey = barFrame.key
    local barSettings = self.db.profile.bars[barKey]
    if not barSettings.showUnusedIcons then return end
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

    print("unitClass", unitClass, "unitRace", unitRace)

    for spellName, spellData in pairs(barFrame.trackedSpells) do
        local shouldTrack = false

        if unitClass == spellData.className then
            shouldTrack = true
        end

        if spellData.race and spellData.race == unitRace then
            shouldTrack = true
        end

        if spellName == "PvP Trinket" and unitRace ~= "Human" then
            shouldTrack = true
        end

        if shouldTrack then
            self:CreateIconToBar(barFrame, spellName, spellData)
        end
    end

    self:ArrangeIcons(barFrame, barSettings)
    self:UpdateUnusedAlpha(barFrame, barSettings)
end
