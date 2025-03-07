local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")

local trackedHostileUnits = {
    allEnemies = true,
    target = true,
    focus = true,
}

local function SetSpellTrackingEventForBar(barFrame, trackedUnit, zone)
    if not trackedHostileUnits[trackedUnit] then 
        return 
    end
    
    -- Event: UnitSpellCastSucceeded can handle all scenarios in arenas
    if zone == "arena" then
        barFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    else
        barFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
end


function OmniBar:InitializeEventsTracking(barFrame, barSettings)
    self:UpdateUnitEventTracking(barFrame, barSettings)
    
    barFrame:SetScript("OnEvent", function (barFrame, event, ...) 
        OmniBar:OnEventHandler(barFrame, event, ...)
    end)
end

function OmniBar:UpdateUnitEventTracking(barFrame, barSettings)
    local trackedUnit = barSettings.trackedUnit

    -- Unregister previous events
    self:UnregisterAllBarEvents(barFrame)
    
    if trackedUnit:match("^arena[1-5]$") then
        barFrame:RegisterEvent("ARENA_OPPONENT_UPDATE")
        barFrame:RegisterEvent("UNIT_AURA")
    elseif trackedUnit:match("^party[1-4]$") then
        barFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
        barFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
    elseif trackedUnit == "target" then
        barFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    elseif trackedUnit == "focus" then
        barFrame:RegisterEvent("PLAYER_FOCUS_CHANGED") 
    else -- All enemies
        barFrame:RegisterEvent("ARENA_OPPONENT_UPDATE")
        barFrame:RegisterEvent("UNIT_AURA")
        barFrame:RegisterEvent("PLAYER_TARGET_CHANGED") 
        barFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
    end

    barFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    SetSpellTrackingEventForBar(barFrame, trackedUnit, self.zone)
end

function OmniBar:OnEventHandler(barFrame, event, ...)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        self:OnUnitSpellCastSucceeded(barFrame, event, ...)
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        self:OnCombatLogEventUnfiltered(barFrame, event, ...)
    elseif event == "PARTY_MEMBERS_CHANGED" then
        self:OnPartyMembersChanged(barFrame, event, ...)
    elseif event == "UNIT_INVENTORY_CHANGED" then
        self:OnUnitInventoryChanged(barFrame, event, ...)
    elseif event == "INSPECT_TALENT_READY" then
        self:OnInspectTalentReady(barFrame, event, ...)
    elseif event == "ARENA_OPPONENT_UPDATE" then
        self:OnArenaOpponentUpdate(barFrame, event, ...)
    elseif event == "UNIT_AURA" then
        self:OnUnitAura(barFrame, event, ...)
    elseif event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" then
        self:OnPlayerTargetChanged(barFrame, event, ...)
    end
end 

function OmniBar:UnregisterAllBarEvents(barFrame)
    barFrame:UnregisterEvent("ARENA_OPPONENT_UPDATE")
    barFrame:UnregisterEvent("INSPECT_TALENT_READY")
    barFrame:UnregisterEvent("PARTY_MEMBERS_CHANGED")
    barFrame:UnregisterEvent("PLAYER_FOCUS_CHANGED")
    barFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
    barFrame:UnregisterEvent("UNIT_AURA")
    barFrame:UnregisterEvent("UNIT_INVENTORY_CHANGED")
    barFrame:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    barFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

-- Uttil function to toggle combat log events based on zone
function OmniBar:UpdateSpellTrackingEventForBars(zone)
    for barKey, barFrame in pairs(self.barFrames) do
        local trackedUnit = self.db.profile.bars[barKey].trackedUnit
        SetSpellTrackingEventForBar(barFrame, trackedUnit, zone)
    end
end
