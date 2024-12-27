local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")

local timerFrame = CreateFrame("Frame")
timerFrame:Hide()

function OmniBar:PLAYER_REGEN_ENABLED()
    if self.zone == "arena" then return end

    print("starting the timer")
    local timeRemaining = 30
    
    timerFrame:Show()
    timerFrame:SetScript("OnUpdate", function(self, elapsed)
        timeRemaining = timeRemaining - elapsed
        
        if timeRemaining <= 0 then
            OmniBar:RefreshBarsWithActiveIcons()
            timerFrame:Hide()
            timerFrame:SetScript("OnUpdate", nil)
            return
        end
    end)
end


function OmniBar:PLAYER_REGEN_DISABLED()
    if self.zone == "arena" then return end

    timerFrame:Hide() 
    timerFrame:SetScript("OnUpdate", nil) -- Delete the timer
    print("Combat again, deleted the existing timer")
end
