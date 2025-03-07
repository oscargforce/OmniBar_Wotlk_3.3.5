local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local wipe = wipe

local function isDuelComplete(chatMsg)
    local winner, loser = chatMsg:match("^(.+) has defeated (.+) in a duel$")
    
    if not winner and not loser then 
        return false 
    end
    
    local localPlayerName = OmniBar.localPlayerName
    if winner == localPlayerName or loser == localPlayerName then
        return true
    end

    return false
end

function OmniBar:CHAT_MSG_SYSTEM(event, chatMsg)
    if self.zone == "arena" then return end

    if isDuelComplete(chatMsg) then 
        self.isDuelInProgress = false
        return
    end

    if self.currentRealm ~= "Blackrock [PvP only]" then return end

    if not chatMsg:match("Duel starting: %d+") then return end

    wipe(self.combatLogCache)
    self:RefreshBarsWithActiveIcons()
    self.isDuelInProgress = true
end
