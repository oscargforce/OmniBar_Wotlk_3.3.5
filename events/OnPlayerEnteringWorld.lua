local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
--local IsInInstance = IsInInstance

local function IsValidWorldUnit(trackedUnit)
    return trackedUnit == "allEnemies" or trackedUnit == "target" or trackedUnit == "focus"
end


function OmniBar:PLAYER_ENTERING_WORLD()
    print("OnPlayerEnteringWorld")
    local _, zone = IsInInstance()
  
    -- Prevent unnecessary refresh on login or reload if the zone hasn't changed.
    if self.zone and self.zone ~= zone then
        self:RefreshBarsWithActiveIcons()
        self:ClearPartyGUIDCache()
        self:UpdateSpellTrackingEventForAllBars(zone)
        print("PLAYER_ENTERING_WORLD: RefreshBarsWithActiveIcons")  

       --[[  if zone == "arena" then
            self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        else
            self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        end ]]
    end
    
    self.zone = zone

    if self.zone == "arena" then
        self:HandleMidGameReloadsForArenaUpdate()
    end
end
