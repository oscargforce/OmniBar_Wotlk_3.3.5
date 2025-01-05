local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local _, addon = ...
local specSpellTable = addon.specSpellTable
local GetBuffNameFromTrinket = addon.GetBuffNameFromTrinket
local UnitGUID = UnitGUID
local GetNumPartyMembers = GetNumPartyMembers
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

      Each bar maintains its own independent state, enabling users to track the same unit across multiple bars simultaneously.
      local partyGUIDCache = {
        ["OmniBar1"] =  {
            ["party1"] = "",
            isQueued = false,
       },
        ["OmniBar2"] =  {
            ["party1"] = "",
            isQueued = false,
      },
}  
]]


local partyGUIDCache = {}
local isInspectionInProgress = false 
local hasAttemptedFirstInspection = false
local StartInspectionRetryTimer
 
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
        partyGUIDCache[barKey].isQueued = false
    end

    local previousPartyGUID = partyGUIDCache[barKey][trackedUnit]
 
    -- If the tracked unit is no longer in the party, reset icons
    if not currentPartyGUID then
        print(barKey, "If the tracked unit is no longer in the party, reset icons")
        self:ResetIcons(barFrame)
        partyGUIDCache[barKey][trackedUnit] = ""
        partyGUIDCache[barKey].isQueued = false
        self:ToggleAnchorVisibility(barFrame)
        hasAttemptedFirstInspection = false
        if GetNumPartyMembers() == 0 then
            isInspectionInProgress = false
        end
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

    -- prevent multiple bars for registering to the same event at the same time. This will cause race conditions.
    if not isInspectionInProgress and CheckInteractDistance(trackedUnit, 1) then 
        isInspectionInProgress = true
        hasAttemptedFirstInspection = true
        barFrame:RegisterEvent("INSPECT_TALENT_READY")
        NotifyInspect(trackedUnit)
        print(barKey,"Sent inspect request to", trackedUnit)
    else
        if hasAttemptedFirstInspection then
            partyGUIDCache[barKey].isQueued = true
            print(barKey, "IN QUEUE")

        else
            print(barKey, "SKIPPED QUEUE")
            barFrame:RegisterEvent("INSPECT_TALENT_READY")
            StartInspectionRetryTimer(trackedUnit, self.db.profile.showOutOfRangeMessages, barKey)
        end
        hasAttemptedFirstInspection = true
    end
end

-- Runs after NotifyInspect is called
function OmniBar:OnInspectTalentReady(barFrame, event, ...)
    local barKey = barFrame.key
    print(partyGUIDCache[barKey].isQueued, barKey, "OnInspectTalentReady")
    if partyGUIDCache[barKey].isQueued then 
        print(barKey, "RETURN from inspect event")
        return 
    end

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

    ClearInspectPlayer()
    barFrame:UnregisterEvent("INSPECT_TALENT_READY")

    self:ArrangeIcons(barFrame, barSettings)
    self:UpdateUnusedAlpha(barFrame, barSettings)
    isInspectionInProgress = false
    self:ProcessInspectionQueue()
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
    local spell = specSpellTable[className][spellName]
    local hasTalent = select(5, GetTalentInfo(
            spell.talentGroup,
            spell.index,
            true, -- Inspecting the unit
            false, -- Not for a pet
            GetActiveTalentGroup(true) -- Inspect unit's active spec [eg primary or secondary spec]
        )) > 0

    print("hasTalent:", spellName, hasTalent)
    return hasTalent
end


function OmniBar:ProcessInspectionQueue()
    for barKey, barData in pairs(partyGUIDCache) do
        if barData.isQueued then
            barData.isQueued = false
            print(barKey, "IsQueued = false")
            self.barFrames[barKey]:RegisterEvent("INSPECT_TALENT_READY")
            StartInspectionRetryTimer(self.db.profile.bars[barKey].trackedUnit, self.db.profile.showOutOfRangeMessages, barKey) 
            break  -- Only start one inspection at a time
        end
    end
end

StartInspectionRetryTimer = function (trackedUnit, showOutOfRangeMessages, barKey)
    local frame = CreateFrame("Frame")
    local timeElapsed = 0
    local totalTime = 15 
    local checkInterval = 1
    
    print(barKey, "RetryFetchingSpecAbilities")
    frame:SetScript("OnUpdate", function(self, elapsed)
        timeElapsed = timeElapsed + elapsed
        
        if timeElapsed >= checkInterval then
            timeElapsed = 0

            if totalTime <= 0 then
                if showOutOfRangeMessages then
                    print(string.format(
                        "|cFFFF0000[OmniBar]|r: |cFFFFFF00%s|r was not in range for inspection. " ..
                        "|cFF00FF00The spells may not match the unit's current talents.|r " ..
                        "Please |cFF00FFFF/reload|r when you are |cFFFFFF00within range|r to inspect the unit " ..
                        "(|cFF00FF00i.e., when you can right-click and inspect their armory in-game|r). " ..
                        "This message can be disabled in the options menu |cFF00FFFF'Show Out of Range Messages'|r.",
                        trackedUnit
                    ))
                end
                frame:SetScript("OnUpdate", nil)
                frame = nil
                return
            end

            if isInspectionInProgress then return end
            if partyGUIDCache[barKey].isQueued then return end
            
            if CheckInteractDistance(trackedUnit, 1) then
                ClearInspectPlayer()
                print(barKey, "StartInspectionRetryTimer: Inspected unit")
                NotifyInspect(trackedUnit)
                frame:SetScript("OnUpdate", nil)
                frame = nil
                return
            end
                
            totalTime = totalTime - checkInterval
        end
    end)
end























-- add self:ResetIcons(barFrame) before calling this function in OmniBar:OnInspectTalentReady. Othwerwise, the icons will be duplicated. Downside is any previous cooldowns will be lost.
function OmniBar:TESTINGONLY(barFrame, barSettings, didInspect)
    local trackedUnit = barSettings.trackedUnit
    local className = UnitClass(trackedUnit)
    local race = UnitRace(trackedUnit)
    local unitTrinkets = {}
    if didInspect then
        unitTrinkets = self:GetPartyUnitsTrinkets(trackedUnit) 
    end

    for spellName, spellData in pairs(barFrame.trackedSpells) do
        local shouldTrack = false
        if className == spellData.className then
            shouldTrack = true

            if spellData.spec and didInspect then
                shouldTrack = self:CheckSpecAbilitiesForUnit(className, spellName)
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

    self:ArrangeIcons(barFrame, barSettings)
    self:UpdateUnusedAlpha(barFrame, barSettings)
end