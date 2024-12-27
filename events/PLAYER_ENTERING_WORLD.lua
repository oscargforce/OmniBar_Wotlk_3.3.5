function OmniBar:PLAYER_ENTERING_WORLD()
    local _, zone = IsInInstance()

    if self.zone and self.zone ~= zone then
        self:RefreshBarsWithActiveIcons()
    end

    self.zone = zone
end
