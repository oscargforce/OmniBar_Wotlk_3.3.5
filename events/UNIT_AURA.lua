local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")


function OmniBar:OnUnitAura(barFrame, event, unit)
    if self.zone ~= "arena" then return end
    local barSettings = self.db.profile.bars[barFrame.key]
    local trackedUnit = barSettings.trackedUnit

    if trackedUnit == "allEnemies" then
        if not unit:match("^arena[1-5]$") then return end
    elseif trackedUnit ~= unit then
        return
    end

    self:DetectSpecByAura(unit, barFrame)
end
