local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local _, addon = ...
local specSpellTable = addon.specSpellTable
local GetBuffNameFromTrinket = addon.GetBuffNameFromTrinket
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
        3) Chore: Add all the talents to the specSpellTable
    
    Core Features This File Handle:
      - Only handle bars with party tracking and show unused icons enabled.
      - Reset icons when a new Party 1 is detected. 
      - Maintain icons when the same Party 1 is detected. 
      - Prevent adding more icons if a player logs out but avoid resetting existing icons to keep cooldown track. 
      - Does not filter icons when a player is out of range upon being invited. A message is sent to the user. Note: This only affects spec spells and items.
]]

--[[
Each bar maintains its own independent state, enabling users to track the same unit across multiple bars simultaneously.
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
    print("new partyUnit player update the bar")
    self:ResetIcons(barFrame)
    partyGUIDCache[barKey][trackedUnit] = currentPartyGUID


    local className = UnitClass(trackedUnit)
    local race = UnitRace(trackedUnit)

    local unitTrinkets = {}
    local didInspect = false
    if CheckInteractDistance(trackedUnit, 1) then 
        NotifyInspect(trackedUnit)
        unitTrinkets = self:GetPartyUnitsTrinkets(trackedUnit) 
        didInspect = true
    else
        if self.db.profile.showOutOfRangeMessages then
            print("|cFFFF0000[OmniBar]|r: |cFFFFFF00" .. trackedUnit .. "|r was not in range for inspection. |cFF00FF00The spells may not match the unit's current talents.|r Please |cFF00FFFF/reload|r when closer to the unit. This message can be disabled in the options menu 'Show Out of Range Messages'.")
        end
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
            shouldTrack = unitTrinkets[spellName] or false
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
                local trinketBuffName = GetBuffNameFromTrinket(itemName)
                trinkets[trinketBuffName] = true
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


