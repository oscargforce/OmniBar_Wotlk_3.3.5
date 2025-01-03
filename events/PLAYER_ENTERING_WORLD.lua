local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")

function OmniBar:PLAYER_ENTERING_WORLD()
    local _, zone = IsInInstance()
 
    -- Prevent unnecessary refresh on login or reload if the zone hasn't changed.
    if self.zone and self.zone ~= zone then
        self:RefreshBarsWithActiveIcons()
        print("PLAYER_ENTERING_WORLD: RefreshBarsWithActiveIcons")
    end

    self.zone = zone
end
