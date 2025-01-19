local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local UnitIsPlayer = UnitIsPlayer
local UnitIsEnemy = UnitIsEnemy
local UnitIsUnit = UnitIsUnit
local UnitClass = UnitClass
local UnitRace = UnitRace
local GetUnitName = GetUnitName


-- /dump OmniBar.combatLogCache  /dump OmniBar.barFrames["OmniBar4"].icons

--[[

    
    TODOS: 
        1) Add spec spells to the bar if detected. 
        2) Update unit aura detection in world if I want to have that there.
        3) Remove showing items on target/focus and arena opponents, keep party members as is
        4) Add shared cds and reset cds logic
    
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
    self:RemoveExpiredSpellsFromCombatLogCache()
    self:ClearSpecProcessedData(unit)

    local barSettings = self.db.profile.bars[barFrame.key]
    if barSettings.trackedUnit == "allEnemies" then
        self:ProcessAllEnemiesTargetChange(unit, barFrame, barSettings)
        return
    end
   
    self:ResetIcons(barFrame)

    if not UnitIsPlayer(unit) then return end

    -- 2) Get basic unit information
    local unitClass = UnitClass(unit)
    local unitRace = UnitRace(unit)
    local unitName = GetUnitName(unit)
   
    -- 3) Get cached data+
    local cachedSpells = self.combatLogCache[unitName]
    local cachedSpec = cachedSpells and cachedSpells.spec

    -- 4) Process tracked spells
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


function OmniBar:ProcessAllEnemiesTargetChange(unit, barFrame, barSettings)
    if UnitIsPlayer(unit) and not UnitIsEnemy("player", unit) then
       return
    end 
    
    local existingIcons = {}
    local showUnusedIcons = barSettings.showUnusedIcons
    -- Remove previous unit icons, but keep the ones that have an active cd timer.
    for i = #barFrame.icons, 1, -1 do
        local icon = barFrame.icons[i]
        if not barFrame.activeIcons[icon] and showUnusedIcons then 
            if icon.unitType == unit then
                self:ReturnIconToPool(icon)
                table.remove(barFrame.icons, i)
            end
        else
            print("Keeping icon", icon.spellName, "for unit", icon.unitType)
            local key = icon.spellName .. icon.unitName
            existingIcons[key] = icon
        end
    end
    
    if not UnitIsPlayer(unit) then 
        self:ArrangeIcons(barFrame, barSettings)
        return 
    end

     -- Dont add dublicate icons if the same unit is target and focus.
     if barSettings.trackedUnit == "allEnemies" and UnitIsUnit("focus", "target") then
        for i, icon in ipairs(barFrame.icons) do
            if icon.unitType == "target" then
                icon.unitType = "focus"
            end
        end
        return
    end
  
    -- 2) Get basic unit information
    local unitClass = UnitClass(unit)
    local unitRace = UnitRace(unit)
    local unitName = GetUnitName(unit)
    -- 3) Get cached data
    local cachedSpells = self.combatLogCache[unitName]
    local cachedSpec = cachedSpells and cachedSpells.spec

    -- 4) Process tracked spells
    local unusedAlpha = barSettings.unusedAlpha
   
    for spellName, spellData in pairs(barFrame.trackedSpells) do
        local iconKey = spellName .. unitName
        local existingIcon = existingIcons[iconKey]
        local hasCachedCooldown = cachedSpells and cachedSpells[spellName]
    
        if not existingIcon then
            if showUnusedIcons then
                if ShouldTrackSpell(spellName, spellData, unitClass, unitRace, cachedSpec) then
                    local icon = self:CreateIconToBar(barFrame, spellName, spellData, unitName, unit)
                    icon:SetAlpha(unusedAlpha)
                end
            end

            if hasCachedCooldown then
                self:OnCooldownUsed(barFrame, barSettings, unit, spellName, spellData, hasCachedCooldown)
            end
        end
    end

    if showUnusedIcons then
        self:ArrangeIcons(barFrame, barSettings)
        if spellName == "Penance" then viewTable(barFrame.icons) end
    end
end
