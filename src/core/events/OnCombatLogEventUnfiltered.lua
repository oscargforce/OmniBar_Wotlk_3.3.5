local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local GetTime = GetTime
local GetUnitName = GetUnitName
local UnitIsEnemy = UnitIsEnemy
local UnitGUID = UnitGUID
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local addonName, addon = ...
local sharedCds = addon.sharedCds
local spellTable = addon.spellTable
local resetCds = addon.resetCds
local IsWarlockDeathCoilSpell = addon.IsWarlockDeathCoilSpell
local bit_band = bit.band
local COMBATLOG_OBJECT_REACTION_HOSTILE = COMBATLOG_OBJECT_REACTION_HOSTILE

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

local function GetSpellDuration(spellData, playerSpec)
    if not spellData then
        return 0
    end
    -- If the spec affects the cooldown duration, adjust it. For example, Shadow Priests have a shorter fear cooldown than Discipline Priests.
    local hasSpecAdjustment = spellData.adjust and spellData.adjust[playerSpec]
    if hasSpecAdjustment then
        return spellData.adjust[playerSpec]
    end

    return spellData.duration
end

local function IsSourceHostile(sourceFlags)
	return bit_band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE
end

-- original omnibar also tracks SPELL_AURA_APPLIED 
function OmniBar:OnCombatLogEventUnfiltered(barFrame, event, ...)
    local timestamp, subEvent, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellId, spellName = ...

    -- 1) check what type of event
    if subEvent ~= "SPELL_CAST_SUCCESS" then 
        return 
    end

    -- 2) check if spell is relevant
    local spellData = barFrame.trackedSpells[spellName]
    local sharedCd = sharedCds[spellName]
    local playerSpec = self:GetSpecFromSpellTable(spellName)
    local spellsToReset = resetCds[spellName]

    if not spellData and not sharedCd and not playerSpec and not spellsToReset then 
        return 
    end

    if spellName == "Death Coil" and not IsWarlockDeathCoilSpell(spellId) then
        return
    end
    
    -- 3) If spell was casted by a pet, map it to the pet owners name.
    local petOwnerName = GetPetOwnerName(sourceGUID)
	local playerName = petOwnerName or sourceName
    
    -- 4) Create a cache for the player if it doesn't exist.
    self.combatLogCache[playerName] = self.combatLogCache[playerName] or {}
    local playerCache = self.combatLogCache[playerName]

    -- 4.1) Detect the spec of the player if it's not already cached.
    if not playerCache.spec then
        if playerSpec then
            playerCache.spec = playerSpec
        end
    end
    
    -- If the spell was only spec related we dont need more info, early return.
    if not spellData and not sharedCd and not spellsToReset then 
        return 
    end

    local now = GetTime()

    -- If the player does not track the spell, but it triggers a shared cooldown, cache it.
    if not spellData and sharedCd then
        local GENERAL_SPELLS = { ["Will of the Forsaken"] = true, ["PvP Trinket"] = true }
        local className = GENERAL_SPELLS[spellName] and "General" or GetPlayerInfoByGUID(sourceGUID)
        if not className then return end
        local spellDetails = spellTable[className][spellName]
        local duration = spellDetails.adjust and spellDetails.adjust[playerCache.spec] or spellDetails.duration

        playerCache[spellName] = {
            duration = duration, 
            expires = now + duration, 
            timestamp = now, 
            playerName = playerName, 
            sharedCds = sharedCd,
            createIcon = false
        }
        return
    end

    local duration = GetSpellDuration(spellData, playerSpec)

    -- 4.2) Add the spell to the cache so that if we switch targets to this unit, the cooldown is already saved for display.
    playerCache[spellName] = {
        duration = duration, -- actually using this property, dont think this is needed anymore. Im using icon.duration
        event = subEvent,
        expires = now + duration, -- actually using this property
        petOwnerName = petOwnerName,
        sourceFlags = sourceFlags,
        sourceGUID = sourceGUID,
        sourceName = sourceName,
        spellId = spellId,
        spellName = spellName,
        timestamp = now, -- actually using this property
        playerName = playerName, -- using ths property
        sharedCds = sharedCd or nil,
        createIcon = true,
    }

    -- 5) Activate icons for enemy pet abilities. The event UnitSpellCastSucceeded is not triggered by enemy pets in the open world (though it does work in arenas). 
    -- Similarly, Feign Death is not registered in the combat log. To work around this, the two events need to support each other.
    local barSettings = self.db.profile.bars[barFrame.key]
    local trackedUnit = barSettings.trackedUnit

    if petOwnerName then 
        local isEnemyPet, unit = PlayerNameMatchesTrackedUnit(playerName, trackedUnit)
      
        if isEnemyPet then
            local unitGUID = UnitGUID(unit)
            local cachedSpell = playerCache[spellName]
            self:OnCooldownUsed(barFrame, barSettings, unit, unitGUID, spellName, spellData, cachedSpell)
            return
        end
    end

    if spellsToReset then 
        self:CleanPlayerCache(playerCache, now, playerName)
        self:RemoveNonTargetActiveIcons(barFrame, barSettings, spellsToReset, playerCache[spellName])
    end

    -- Add the icon to the bar for non-targeted players
    if spellData and self.localPlayerGUID == destGUID and barSettings.trackedUnit == "allEnemies" then
        if not IsSourceHostile(sourceFlags) then return end

        if sourceGUID == UnitGUID("target") or sourceGUID == UnitGUID("focus") then return end

        if barSettings.showUnusedIcons then
            local shouldAddNewIcon = true
            for icon, _ in pairs(barFrame.activeIcons) do
                if icon.spellName == spellName and icon.unitGUID == sourceGUID then
                    shouldAddNewIcon = false
                    break
                end
            end

            if shouldAddNewIcon then
                local icon = self:CreateIconToBar(barFrame, barSettings.showBorder, spellName, spellData, sourceGUID, "nonTargetedPlayer")
                icon:SetAlpha(barSettings.unusedAlpha)
                self:ArrangeIcons(barFrame, barSettings)
            end
        end
            
        self:OnCooldownUsed(barFrame, barSettings, "nonTargetedPlayer", sourceGUID, spellName, spellData, playerCache[spellName])   
    end
end
