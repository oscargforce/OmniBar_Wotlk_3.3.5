local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local _, addon = ...
local specSpellTable = addon.specSpellTable
local GetTrinketNameFromBuff = addon.GetTrinketNameFromBuff
local IsActiveBattlefieldArena = IsActiveBattlefieldArena
local UnitGUID = UnitGUID
local UnitClass = UnitClass
local UnitRace = UnitRace
local CheckInteractDistance = CheckInteractDistance
local NotifyInspect = NotifyInspect
local GetTalentInfo = GetTalentInfo
local GetActiveTalentGroup = GetActiveTalentGroup
local ClearInspectPlayer = ClearInspectPlayer
local GetInventoryItemLink = GetInventoryItemLink
local GetItemInfo = GetItemInfo

--[[ 

    TODO:
      7) Feat: update party1 depending if party member change spec, can be done by UnitSpellCastSucceeded and then creating some onUpdate function to check if we need to inspect unit
      8) Feat: Add a reset so when teleported to a new instance such as arena, we clean the state, so that we filter the players spells/race (I think this is done by in PLAYER_ENTERING_WORLD NEED TO TEST TOMORROW)
    
    If new party 1 -> reset icons DONE
    if same party 1 -> Dont reset icons DONE
    if players logs out -> dont add more icons, but we dont want to reset icons. DONE
    If out of range when invited, we are not filter icons
]]

--[[
   Without using `barFrame.key` as the cache key, creating multiple bars would cause icon creation issues. 
    The check `if not isInEditMode and previousPartyGUID ~= "" and currentPartyGUID == previousPartyGUID` 
    would prevent new icons from being created across bars tracking the same party unit.

    By nesting the GUID cache under `barFrame.key`, each bar maintains its own unique party unit tracking, 
    ensuring icons are correctly created for every bar.

local partyGUIDCache = {
        ["OmniBar1"] =  {
            ["party1"] = "",
      },
        ["OmniBar2"] =  {
            ["party1"] = "",
      },
}        
]]

local partyGUIDCache = {}

function OmniBar:OnPartyMembersChanged(barFrame, event, isInEditMode)
    local barKey = barFrame.key
    local barSettings = self.db.profile.bars[barKey]
    print("OnPartyMembersChanged:", barKey )
    if not barSettings.showUnusedIcons then return end
	if IsActiveBattlefieldArena() then return end
    
    local trackedUnit = barSettings.trackedUnit
    local currentPartyGUID = UnitGUID(trackedUnit)

    if not partyGUIDCache[barKey] then
        partyGUIDCache[barKey] = {}
    end

    if not partyGUIDCache[barKey][trackedUnit] then
        partyGUIDCache[barKey][trackedUnit] = ""
    end

    local previousPartyGUID = partyGUIDCache[barKey][trackedUnit]
 
    -- If the tracked unit is no longer in the party, reset icons
    if not currentPartyGUID then
        print("check if still in party or partyUnit exist in the group")
        self:ResetIcons(barFrame)
        partyGUIDCache[barKey][trackedUnit] = ""
        self:ToggleAnchorVisibility(barFrame)
        return
    end

    -- If the same player is still in the same party slot and we're not in edit mode then no changes required as the unit hasn't changed
    if not isInEditMode and previousPartyGUID ~= "" and currentPartyGUID == previousPartyGUID then
        print(trackedUnit, "If same player then return, no changes for this unit during this event")
        return
    end

    -- If a new player is now occupying this party slot (the party unit has changed),
    -- we need to update the bar to reflect the abilities and cooldowns of the new player.
 --   if currentPartyGUID ~= previousPartyGUID then
        print("new partyUnit player update the bar")
        self:ResetIcons(barFrame)
        partyGUIDCache[barKey][trackedUnit] = currentPartyGUID
--    end

    local className = UnitClass(trackedUnit)
    local race = UnitRace(trackedUnit)

    local unitTrinkets = {}
    local didInspect = false
    if CheckInteractDistance(trackedUnit, 1) then 
        NotifyInspect(trackedUnit)
        unitTrinkets = self:GetPartyUnitsTrinkets(trackedUnit) 
        didInspect = true
    else
       print("|cFFFF0000[OmniBar]|r: |cFFFFFF00" .. trackedUnit .. "|r was not in range for inspection. |cFF00FF00The spells may not match the unit's current talents.|r Please |cFF00FFFF/reload|r when closer to the unit.")
    end

    -- filter the tracked cooldowns based on class, race, talents and items equipped
    for spellName, spellData in pairs(barFrame.trackedSpells) do
        local shouldTrack = false
        if className == spellData.className then
            shouldTrack = true

            if spellData.spec and didInspect then
                shouldTrack = self:CheckSpecAbilitiesForUnit(className, spellName)
                print(spellName, shouldTrack)
            end

        end

        if spellData.race and spellData.race == race then
            shouldTrack = true
        end

        if spellName == "PvP Trinket" and race ~= "Human" then
            shouldTrack = true
        end

        if spellData.item and didInspect then
            local trinketName = GetTrinketNameFromBuff(spellName)
            shouldTrack = unitTrinkets[trinketName] or false
        end

        if shouldTrack then
            self:CreateIconToBar(barFrame, spellName, spellData)
        end

    end

    if didInspect then 
        ClearInspectPlayer()
    end

    -- arrange the icons by priority
    self:ArrangeIcons(barFrame, barSettings)
    self:UpdateUnusedAlpha(barFrame, barSettings)
end

function OmniBar:GetPartyUnitsTrinkets(trackedUnit)
    local trinkets = {}
    for slot = 13, 14 do -- Trinket slots
        local itemLink = GetInventoryItemLink(trackedUnit, slot)
        if itemLink then
            local itemName = GetItemInfo(itemLink)
            if itemName then
                print(itemName)
                trinkets[itemName] = true
            end
        end
    end

    return trinkets
end

function OmniBar:CheckSpecAbilitiesForUnit(className, spellName)
    if not specSpellTable[className] or not specSpellTable[className][spellName] then return false end
    print("CheckSpecAbilitiesForUnit")
    local spell = specSpellTable[className][spellName]
    local hasTalent = select(5, GetTalentInfo(
            spell.talentGroup,
            spell.index,
            true, -- Inspecting the unit
            false, -- Not for a pet
            GetActiveTalentGroup(true) -- Inspect unit's active spec [eg primary or secondary spec]
        )) > 0

    return hasTalent
end


