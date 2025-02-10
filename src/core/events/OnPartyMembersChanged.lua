local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local _, addon = ...
local talentTreeCoordinates = addon.talentTreeCoordinates
local MapTrinketNameToBuffName = addon.MapTrinketNameToBuffName
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


local inspectQueue = InspectQueueOmniBar:New()

function OmniBar:OnPartyMembersChanged(barFrame, event, isInEditMode)
    local barKey = barFrame.key
    local barSettings = self.db.profile.bars[barKey]
    print("OnPartyMembersChanged:", barKey )

    local trackedUnit = barSettings.trackedUnit
    local currentPartyGUID = UnitGUID(trackedUnit)
    local partyMemberGUIDs = self.partyMemberGUIDs

    if not partyMemberGUIDs[barKey] then
        partyMemberGUIDs[barKey] = {}
    end

    if not partyMemberGUIDs[barKey][trackedUnit] then
        partyMemberGUIDs[barKey][trackedUnit] = ""
        if not self.partyMemberSpecs[trackedUnit] then
            self.partyMemberSpecs[trackedUnit] = ""
        end
    end

    local previousPartyGUID = partyMemberGUIDs[barKey][trackedUnit]
 
    -- If the tracked unit is no longer in the party, reset icons
    if not currentPartyGUID then
        print(barKey, "If the tracked unit is no longer in the party, reset icons")
        partyMemberGUIDs[barKey][trackedUnit] = ""
        self.partyMemberSpecs[trackedUnit] = ""
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
    partyMemberGUIDs[barKey][trackedUnit] = currentPartyGUID

    inspectQueue:AddToQueue(trackedUnit, barFrame)
end 

local function BackUpSpecDetection(className)
    local talents = talentTreeCoordinates[className]

    for _, talentInfo in pairs(talents) do
        if talentInfo.spec then
            local hasTalent = select(5, GetTalentInfo(
                talentInfo.talentGroup,
                talentInfo.index,
                true, -- Inspecting the unit
                false, -- Not for a pet
                GetActiveTalentGroup(true) -- Inspect unit's active spec [eg primary or secondary spec]
            )) > 0

            if hasTalent then
                return talentInfo.spec
            end
        end
    end

    return ""
end

-- Runs after NotifyInspect is called
function OmniBar:OnInspectTalentReady(barFrame, event, ...)
    local barKey = barFrame.key
    local barSettings = self.db.profile.bars[barKey]
    print("OnInspectTalentReady", barSettings.name)
    local trackedUnit = barSettings.trackedUnit
    local showUnusedIcons = barSettings.showUnusedIcons

    local className = UnitClass(trackedUnit)
    local race = UnitRace(trackedUnit)
    local unitGUID = self.partyMemberGUIDs[barKey][trackedUnit]
    local unitTrinkets = self:GetPartyUnitsTrinkets(trackedUnit) 
    local spec = self.partyMemberSpecs[trackedUnit]
    local specFound = spec ~= ""
  
    for spellName, spellData in pairs(barFrame.trackedSpells) do
        local shouldTrack = false
        if className == spellData.className then
            shouldTrack = true

            if spellData.spec then
                shouldTrack = self:CheckSpecAbilitiesForUnit(className, spellName)
                if shouldTrack and not specFound then
                    spec = self:GetSpecFromSpellTable(spellName)
                    local t = spec or "nil"
                    print("|cFFFFFF00" .. "spec = " .. t .. "|r")
                    if spec and spec ~= "" then 
                        print("|cFFFF0000" .. "I should print once" .. "|r")
                        specFound = true 
                    end
                end
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

        if shouldTrack and showUnusedIcons then
            self:CreateIconToBar(barFrame, barSettings.showBorder, spellName, spellData, unitGUID, trackedUnit)
        end

    end

    if not spec or spec == "" then
        spec = BackUpSpecDetection(className)
        print("|cFFFFFF00".."partyMemberSpec after backup ".. spec .. "|r")
    end
    
    if showUnusedIcons and spec ~= "" then
        print("|cFFFFFF00".."showUnusedIcons partyMemberSpec".. spec .. "|r")
        self:AdjustUnusedIconsCooldownForSpec(barFrame, unitGUID, spec, barSettings)
    end

    if showUnusedIcons then
        self:ArrangeIcons(barFrame, barSettings)
        self:UpdateUnusedAlpha(barFrame, barSettings)
    end

    self.partyMemberSpecs[trackedUnit] = spec

    self:ToggleAnchorVisibility(barFrame)
    inspectQueue:InspectComplete(barFrame)
end

function OmniBar:GetPartyUnitsTrinkets(trackedUnit)
    local trinkets = {}
    for slot = 13, 14 do -- Trinket slots
        local itemLink = GetInventoryItemLink(trackedUnit, slot)
        if itemLink then
            local itemName = GetItemInfo(itemLink)
            if itemName then
                local trinketBuffName = MapTrinketNameToBuffName(itemName)
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

function OmniBar:ClearPartyMemberGUIDs()
    for barKey, partyGUIDs in pairs(self.partyMemberGUIDs) do
        for partyGUID, _ in pairs(partyGUIDs) do
            partyGUIDs[partyGUID] = ""
        end
    end
end