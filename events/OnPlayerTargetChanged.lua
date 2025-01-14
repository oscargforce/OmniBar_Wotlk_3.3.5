local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass
local UnitRace = UnitRace
local GetUnitName = GetUnitName
-- /dump OmniBar.combatLogCache  /dump OmniBar.barFrames["OmniBar1"]

--[[
    
    TODOS: 
        1) How to handle allEnemies here? Do we even need to?
        2) Change to adding spec icons if detected instead of removing them in arena and in world zones inside spec detection and change th if statemnts in arena opponents update


]]

local function ShouldTrackSpell(spellName, spellData, unitClass, unitRace, spec)
    if unitClass == spellData.className then
        if spellData.spec then
            return spec and spellData.spec == spec
        end
        return true
    end

    if spellData.race and spellData.race == unitRace then
        return true
    end

    if spellName == "PvP Trinket" then
        return unitRace ~= "Human"
    end

    if spellData.item then
        return true
    end

    return false
end

function OmniBar:OnPlayerTargetChanged(barFrame, event)
    local unit = (event == "PLAYER_TARGET_CHANGED" and "target") or (event == "PLAYER_FOCUS_CHANGED" and "focus")

    -- 1) Clean up existing state
    self:ResetIcons(barFrame)
    self:RemoveExpiredSpellsFromCombatLogCache()
    self:ClearSpecProcessedData(unit)

    if not UnitIsPlayer(unit) then return end

    -- 2) Get basic unit information
    local unitClass = UnitClass(unit)
    local unitRace = UnitRace(unit)
    local unitName = GetUnitName(unit)
   
    -- 3) Get cached data
    local cachedSpells = self.combatLogCache[unitName]
    local cachedSpec = cachedSpells and cachedSpells.spec

    -- 4) Process tracked spells
    local barSettings = self.db.profile.bars[barFrame.key]
    local unusedAlpha = barSettings.unusedAlpha
    
    for spellName, spellData in pairs(barFrame.trackedSpells) do
        if barSettings.showUnusedIcons then
            if ShouldTrackSpell(spellName, spellData, unitClass, unitRace, cachedSpec) then
                local icon = self:CreateIconToBar(barFrame, spellName, spellData)
                icon:SetAlpha(unusedAlpha)
            end
        end

        if cachedSpells and cachedSpells[spellName] then
            self:OnCooldownUsed(barFrame, barSettings, unit, spellName, spellData, cachedSpells[spellName])
        end
    end

    if barSettings.showUnusedIcons then
        self:ArrangeIcons(barFrame, barSettings)
    end
end