local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")

local combatTimerFrame = CreateFrame("Frame")
combatTimerFrame:Hide()

function OmniBar:PLAYER_REGEN_ENABLED()
    if self.zone == "arena" then return end

    local timeRemaining = 30
    
    combatTimerFrame:Show()
    combatTimerFrame:SetScript("OnUpdate", function(self, elapsed)
        timeRemaining = timeRemaining - elapsed
        
        if timeRemaining <= 0 then
            OmniBar:RefreshBarsWithActiveIcons()
            combatTimerFrame:SetScript("OnUpdate", nil)
            combatTimerFrame:Hide()
            return
        end
    end)
end


function OmniBar:PLAYER_REGEN_DISABLED()
    if self.zone == "arena" then return end

    combatTimerFrame:SetScript("OnUpdate", nil)
    combatTimerFrame:Hide() 
end
