local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local wipe = wipe

function OmniBar:TestBars(selectedBars, selectedClasses)
    -- something
    for barKey, _ in pairs(selectedBars) do
        local barSettings = self.db.profile.bars[barKey]
        local barFrame = self.barFrames[barKey]

        barFrame.isInTestMode = true
        barFrame.testModeClasses = selectedClasses

        if barSettings.showUnusedIcons then 
            self:TestIcons(barSettings, barFrame, selectedClasses)
        else
            self:TestHiddenIcons(barSettings, barFrame, selectedClasses)
        end
        
    end
end

function OmniBar:TestIcons(barSettings, barFrame, selectedClasses)
    if #barFrame.icons > 0 then
        self:ResetIcons(barFrame)
    end
    
    local needsRearranging = false

    for spellName, spellData in pairs(barFrame.trackedSpells) do 
        if selectedClasses[spellData.className] or selectedClasses["All"] then
            -- need to add unitGUID and unit to CreateIconToBar
            local icon = self:CreateIconToBar(barFrame, barSettings.showBorders, spellName, spellData)
            self:UpdateUnusedAlpha(barFrame, barSettings, icon)
            needsRearranging = true
        end
    end

    if needsRearranging then
        self:ArrangeIcons(barFrame, barSettings)
    end

    self:ToggleAnchorVisibility(barFrame)
end

function OmniBar:TestHiddenIcons(barSettings, barFrame, selectedClasses)

end