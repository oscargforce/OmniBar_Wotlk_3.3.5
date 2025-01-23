local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local IsInInstance = IsInInstance
local wipe = wipe

function OmniBar:PLAYER_ENTERING_WORLD()
    print("OnPlayerEnteringWorld")
    local _, zone = IsInInstance()
  
    -- Prevent unnecessary refresh on login or reload if the zone hasn't changed.
    if self.zone and self.zone ~= zone then
        self:RefreshBarsWithActiveIcons()
        self:ClearPartyMemberGUIDs()
        wipe(self.combatLogCache)
        print("PLAYER_ENTERING_WORLD: RefreshBarsWithActiveIcons")  
    end
    
    self.zone = zone

    -- Bit of overhead with registering the event here, but it's necessary to ensure the zone is correct. Note to self is to improve this, when Im smarter
    self:UpdateSpellTrackingEventForBars(zone)
    
    if self.zone == "arena" then
        self:HandleMidGameReloadsForArenaUpdate()
    end
end
