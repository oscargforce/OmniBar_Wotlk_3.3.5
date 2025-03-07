local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local addonName, addon = ...
local crossSpecSpells = addon.crossSpecSpells
local UnitIsPlayer = UnitIsPlayer
local UnitIsEnemy = UnitIsEnemy
local UnitIsUnit = UnitIsUnit
local UnitClass = UnitClass
local UnitRace = UnitRace
local GetUnitName = GetUnitName
local UnitGUID = UnitGUID

local function ShouldTrackSpell(spellName, spellData, unitClass, unitRace, spec)
    if unitClass == spellData.className then
        if spellData.spec and not spellData.partySpecOnly then
            local crossSpecInfo = crossSpecSpells[spellName]
            if spec and crossSpecInfo and crossSpecInfo[spec] then
                return true
            end

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

    return false
end

local function CreateSharedCdCache(spellCache, unitGUID)
    local _, firstCd = next(spellCache.sharedCds)
    local sharedDuration = firstCd.sharedDuration or nil
    local expires = sharedDuration and spellCache.timestamp + sharedDuration or spellCache.expires
    return {
        sourceGUID = unitGUID,
        playerName = spellCache.playerName,
        timestamp = spellCache.timestamp,
        expires = expires
    }
end

local function IsFriendlyPlayer(unit)
    return UnitIsPlayer(unit) and not UnitIsEnemy("player", unit)
end

function OmniBar:OnPlayerTargetChanged(barFrame, event)
    local unit = (event == "PLAYER_TARGET_CHANGED" and "target") or (event == "PLAYER_FOCUS_CHANGED" and "focus")
    local barKey = barFrame.key
    local barSettings = self.db.profile.bars[barKey]

    if self.zone == "arena" and barSettings.trackedUnit == "allEnemies" then
        self:UpdateArenaUnitHighlights(barFrame, barSettings, unit)
        return
    end

    -- 1) Clean up existing state
    self:CleanupCombatLogCache()
    self:ClearSpecProcessedData(unit)

    if barSettings.trackedUnit == "allEnemies" then
        self:ProcessAllEnemiesTargetChange(unit, barFrame, barSettings, barKey)
        return
    end
   
    self:ResetIcons(barFrame)
    self:ToggleAnchorVisibility(barFrame)
    if not UnitIsPlayer(unit) then return end

    -- 2) Get basic unit information
    local unitClass = UnitClass(unit)
    local unitRace = UnitRace(unit)
    local unitName = GetUnitName(unit)
    local unitGUID = UnitGUID(unit)
   
    -- 3) Get cached data+
    local cachedSpells = self.combatLogCache[unitName]
    local cachedSpec = cachedSpells and cachedSpells.spec

    -- 4) Process tracked spells
    local unusedAlpha = barSettings.unusedAlpha
    
    for spellName, spellData in pairs(barFrame.trackedSpells) do
        local hasCachedCooldown = cachedSpells and cachedSpells[spellName] and cachedSpells[spellName].createIcon[barKey]

        if barSettings.showUnusedIcons then
            if ShouldTrackSpell(spellName, spellData, unitClass, unitRace, cachedSpec) then
                local icon = self:CreateIconToBar(barFrame, barSettings.showBorder, spellName, spellData, unitGUID, unit)
                icon:SetAlpha(unusedAlpha)
            end
        end
       
        if hasCachedCooldown then
            self:OnCooldownUsed(barFrame, barSettings, unit, unitGUID, spellName, spellData, cachedSpells[spellName])
        end
    end

    if cachedSpec then
        self:AdjustUnusedIconsCooldownForSpec(barFrame, unitGUID, cachedSpec, barSettings)
    end

    -- Icons reset on target/focus switches, and shared cooldowns aren't preserved. A fake combat log cache is used to handle this
    if cachedSpells then
        for spellName, spellCache in pairs(cachedSpells) do
            if spellCache.sharedCds then
                local sharedCdCache = CreateSharedCdCache(spellCache, unitGUID)
                self:SharedCooldownsHandler(barFrame, barSettings, unit, unitGUID, spellName, sharedCdCache)
            end
        end
    end

    if barSettings.showUnusedIcons then
        self:ArrangeIcons(barFrame, barSettings)
    end
    
    self:ToggleAnchorVisibility(barFrame)
end


function OmniBar:ProcessAllEnemiesTargetChange(unit, barFrame, barSettings, barKey)    
    if IsFriendlyPlayer(unit) then
        return
    end

    -- Get unit states
    local targetExists = UnitExists("target")
    local focusExists = UnitExists("focus")
    local isSameUnit = targetExists and focusExists and UnitIsUnit("target", "focus")
    
    local existingIcons = {}
    local showUnusedIcons = barSettings.showUnusedIcons
    
    -- Get unit names
    local targetGUID = targetExists and UnitGUID("target")
    local focusGUID = focusExists and UnitGUID("focus")
    
    -- Remove icons for units that are no longer referenced anywhere
    for i = #barFrame.icons, 1, -1 do
        local icon = barFrame.icons[i]
        local keepIcon = barFrame.activeIcons[icon]

        if not keepIcon and showUnusedIcons then
            -- Keep if the unit name matches either current target or focus
            keepIcon = (targetExists and icon.unitGUID == targetGUID) or
                      (focusExists and icon.unitGUID == focusGUID)
        end
        
        if keepIcon then
            local key = icon.spellName .. icon.unitGUID
            existingIcons[key] = icon
            
            -- Update the icon's unitType if needed
            if targetExists and icon.unitGUID == targetGUID then
                icon.unitType = "target"
            elseif focusExists and icon.unitGUID == focusGUID then
                icon.unitType = "focus"
            end
        else
            self:ReturnIconToPool(icon)
            table.remove(barFrame.icons, i)
        end
    end

    self:ToggleAnchorVisibility(barFrame)

    if not UnitIsPlayer(unit) then 
        self:ArrangeIcons(barFrame, barSettings)
        self:UpdateWorldUnitHighlights(barFrame, barSettings, targetExists, focusExists, isSameUnit)
        return 
    end
    
    -- Don't add duplicate icons if the same unit is target and focus
    if isSameUnit then
        self:ArrangeIcons(barFrame, barSettings)
        self:UpdateWorldUnitHighlights(barFrame, barSettings, targetExists, focusExists, isSameUnit)
        return
    end
    
    -- Get unit info
    local unitClass = UnitClass(unit)
    local unitRace = UnitRace(unit)
    local unitName = GetUnitName(unit)
    local unitGUID = (unit == "target") and targetGUID or focusGUID
    
    local cachedSpells = self.combatLogCache[unitName]
    local cachedSpec = cachedSpells and cachedSpells.spec

    local unusedAlpha = barSettings.unusedAlpha
   
    for spellName, spellData in pairs(barFrame.trackedSpells) do
        local iconKey = spellName .. unitGUID
        local existingIcon = existingIcons[iconKey]
        local hasCachedCooldown = cachedSpells and cachedSpells[spellName] and cachedSpells[spellName].createIcon[barKey]
    
        if not existingIcon then
            if showUnusedIcons then
                if ShouldTrackSpell(spellName, spellData, unitClass, unitRace, cachedSpec) then
                    local icon = self:CreateIconToBar(barFrame, barSettings.showBorder, spellName, spellData, unitGUID, unit)
                    icon:SetAlpha(unusedAlpha)
                end
            end

            if hasCachedCooldown then
                self:OnCooldownUsed(barFrame, barSettings, unit, unitGUID, spellName, spellData, cachedSpells[spellName])
            end
        end
    end

    if cachedSpec then
        self:AdjustUnusedIconsCooldownForSpec(barFrame, unitGUID, cachedSpec, barSettings)
    end

     -- Icons reset on target/focus switches, and shared cooldowns aren't preserved. A fake combat log cache is used to handle this
     if cachedSpells then
        for spellName, spellCache in pairs(cachedSpells) do
            if spellCache.sharedCds then
                local sharedCdCache = CreateSharedCdCache(spellCache, unitGUID)
                self:SharedCooldownsHandler(barFrame, barSettings, unit, unitGUID, spellName, sharedCdCache)
            end
        end
    end

    if showUnusedIcons then
        self:ArrangeIcons(barFrame, barSettings)
    end

    self:ToggleAnchorVisibility(barFrame)
    self:UpdateWorldUnitHighlights(barFrame, barSettings, targetExists, focusExists, nil, targetGUID, focusGUID)
end
