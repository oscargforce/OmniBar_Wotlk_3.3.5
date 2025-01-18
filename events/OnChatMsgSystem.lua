local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local wipe = wipe

function OmniBar:CHAT_MSG_SYSTEM(event, chatMsg)
    if self.currentRealm ~= "Blackrock [PvP only]" then return end
    if self.zone == "arena" then return end
    if not chatMsg:match("Duel starting: %d+") then return end

    wipe(self.combatLogCache)
    self:RefreshBarsWithActiveIcons()
end
