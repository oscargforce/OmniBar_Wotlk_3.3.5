local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local GetTime = GetTime
local GetUnitName = GetUnitName
local UnitIsEnemy = UnitIsEnemy

local ORIGINAL_SUMMON_TITLES = {
    UNITNAME_SUMMON_TITLE1,
    UNITNAME_SUMMON_TITLE2,
    UNITNAME_SUMMON_TITLE3,
}

local petTooltip = CreateFrame("GameTooltip", "OmniBarPetTooltip", nil, "GameTooltipTemplate")
local petTooltipText = OmniBarPetTooltipTextLeft2

local function GetPetOwnerName(guid)
    if not guid then return end

    -- Temporarily set summon titles for the tooltip
    for i = 1, 3 do
        _G["UNITNAME_SUMMON_TITLE" .. i] = "OmniBar %s"
    end

    petTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    petTooltip:SetHyperlink("unit:" .. guid)
    local name = petTooltipText:GetText()

    -- Restore original summon titles
    for i = 1, 3 do
        _G["UNITNAME_SUMMON_TITLE" .. i] = ORIGINAL_SUMMON_TITLES[i]
    end

    if not name then return end

    local owner = name:match("OmniBar (.+)")
    if owner then return owner end
end

local function PlayerNameMatchesTrackedUnit(playerName, trackedUnit)
    if trackedUnit ~= "allEnemies" then
        local unitName = GetUnitName(trackedUnit)
        return playerName == unitName, trackedUnit
    end

    for _, unit in ipairs({"target", "focus"}) do
        local unitName = GetUnitName(unit)
        if playerName == unitName then
            if UnitIsEnemy("player", unit) then
                return true, unit
            end
        end
    end

    return false, nil
end


-- original omnibar also tracks SPELL_AURA_APPLIED 
function OmniBar:OnCombatLogEventUnfiltered(barFrame, event, ...)
    local timestamp, subEvent, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellId, spellName = ...

    -- 1) check what type of event
    if subEvent ~= "SPELL_CAST_SUCCESS" then 
        return 
    end

    -- 2) check if spell is in trackedSpells table
    local spellData = barFrame.trackedSpells[spellName]
    
    if not spellData then 
        return 
    end
    
    -- 3) If spell was casted by a pet, map it to the pet owners name.
    local petOwnerName = GetPetOwnerName(sourceGUID)
	local playerName = petOwnerName or sourceName
    
    -- 4) Add the spell to the cache so that if we switch targets to this unit, we already have the cooldown saved for display.
    self.combatLogCache[playerName] = self.combatLogCache[playerName] or {}

    local now = GetTime()
    self.combatLogCache[playerName][spellName] = {
        duration = spellData.duration, -- actually using this property
        event = subEvent,
        expires = now + spellData.duration, -- actually using this property
        petOwnerName = petOwnerName,
        sourceFlags = sourceFlags,
        sourceGUID = sourceGUID,
        sourceName = sourceName,
        spellId = spellId,
        spellName = spellName,
        timestamp = now, -- actually using this property
        playerName = playerName -- using ths property
    }

    -- 4.1) Detect the spec of the player if it's not already cached.
    if not self.combatLogCache[playerName].spec then
        local playerSpec = self:DetectSpecByCombatLogCache(spellName)
        if playerSpec then
            self.combatLogCache[playerName].spec = playerSpec
        end
    end

    -- 5) Activate icons for enemy pet abilities. The event UnitSpellCastSucceeded is not triggered by enemy pets in the open world (though it does work in arenas). 
    -- Similarly, Feign Death is not registered in the combat log. To work around this, we need to support each other, and UnitSpellCastSucceeded will handle the rest.
    local barSettings = self.db.profile.bars[barFrame.key]
    local trackedUnit = barSettings.trackedUnit

    if petOwnerName then 
        local isEnemyPet, unit = PlayerNameMatchesTrackedUnit(playerName, trackedUnit)
      
        if isEnemyPet then
            self:OnCooldownUsed(barFrame, barSettings, unit, spellName, spellData)
        end
    end
 
end
