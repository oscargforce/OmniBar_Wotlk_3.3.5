local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local _, addon = ...
local talentTreeCoordinates = addon.talentTreeCoordinates
local GetBuffNameFromTrinket = addon.GetBuffNameFromTrinket
local UnitGUID = UnitGUID
local UnitClass = UnitClass
local UnitRace = UnitRace
local GetTalentInfo = GetTalentInfo
local GetActiveTalentGroup = GetActiveTalentGroup
local GetInventoryItemLink = GetInventoryItemLink
local GetItemInfo = GetItemInfo

--[[
    Core Features This File Handle:
      - Only handle party members changed event for bars that have showUnusedIcons enabled.
      - Reset icons when a NEW party unit is detected. 
      - Maintain icons when the SAME party unit is detected. 
      - Prevent adding more icons if a party unit logs out but avoid resetting existing icons to keep cooldown track. 
      - Does not filter icons when a party unit is out of range upon being invited. A message is sent to the user. Note: This only affects spec spells and items.
      - Each bar maintains its own independent state, enabling users to track the same unit across multiple bars simultaneously.

    How it works:
        - When a party member changes, the OnPartyMembersChanged() handler is triggered. The bar is reset, and the new party unit is added to the inspect queue.
        - InspectQueueOmniBar will dynamically check if the unit is in range before calling NotifyInspect(). If the unit is out of range, a message is sent to the user.
        - If the unit is in range, NotifyInspect() is called, and the OnInspectTalentReady() handler is triggered. The bar is updated with the new party unit's abilities and cooldowns.
]]


local partyGUIDCache = {}
local inspectQueue = InspectQueueOmniBar:New()


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
        print(barKey, "If the tracked unit is no longer in the party, reset icons")
        partyGUIDCache[barKey][trackedUnit] = ""
        inspectQueue:RemoveBarFromQueue(barFrame)
        OmniBar:ResetIcons(barFrame)
        OmniBar:ToggleAnchorVisibility(barFrame)
        return
    end

    -- If the same player is still in the same party slot and we're not in edit mode then no changes required as the unit hasn't changed
    if not isInEditMode and previousPartyGUID ~= "" and currentPartyGUID == previousPartyGUID then
        print(barKey, trackedUnit, "If same player then return, no changes for this unit during this event")
        return
    end

    -- If a new player is now occupying this party slot (the party unit has changed),
    -- we need to update the bar to reflect the abilities and cooldowns of the new player.
    print(barKey,"new partyUnit player update the bar")
    self:ResetIcons(barFrame)
    partyGUIDCache[barKey][trackedUnit] = currentPartyGUID

    inspectQueue:AddToQueue(trackedUnit, barFrame)
end 

-- Runs after NotifyInspect is called
function OmniBar:OnInspectTalentReady(barFrame, event, ...)
    print("OnInspectTalentReady")
    local barKey = barFrame.key
 
    local barSettings = self.db.profile.bars[barKey]
    local trackedUnit = barSettings.trackedUnit
    local className = UnitClass(trackedUnit)
    local race = UnitRace(trackedUnit)
    local unitTrinkets = self:GetPartyUnitsTrinkets(trackedUnit) 

    for spellName, spellData in pairs(barFrame.trackedSpells) do
        local shouldTrack = false
        if className == spellData.className then
            shouldTrack = true

            if spellData.spec then
                shouldTrack = self:CheckSpecAbilitiesForUnit(className, spellName)
            end

        end

        if spellData.race and spellData.race == race then
            shouldTrack = true
        end

        if spellName == "PvP Trinket" and race ~= "Human" then
            shouldTrack = true
        end

        if spellData.item then
            shouldTrack = unitTrinkets[spellName] or false
        end

        if shouldTrack then
            self:CreateIconToBar(barFrame, spellName, spellData)
        end

    end

    self:ArrangeIcons(barFrame, barSettings)
    self:UpdateUnusedAlpha(barFrame, barSettings)
    inspectQueue:InspectComplete(barFrame)

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
    if not talentTreeCoordinates[className] or not talentTreeCoordinates[className][spellName] then return false end
    local talentInfo = talentTreeCoordinates[className][spellName]
    local hasTalent = select(5, GetTalentInfo(
            talentInfo.talentGroup,
            talentInfo.index,
            true, -- Inspecting the unit
            false, -- Not for a pet
            GetActiveTalentGroup(true) -- Inspect unit's active spec [eg primary or secondary spec]
        )) > 0

    print("hasTalent:", spellName, hasTalent)
    return hasTalent
end



















