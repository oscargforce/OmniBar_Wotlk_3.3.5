local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local wipe = wipe

local function PlayCooldownAnimation(barFrame, barSettings)
    local interval = 0.5
    local timeElapsed = 0
    local index = 1
    local isFirstTimePlaying = true
    
    local timerFrame = CreateFrame("Frame")
    timerFrame:Show()
    
    timerFrame:SetScript("OnUpdate", function(self, elapsed)
        timeElapsed = timeElapsed + elapsed
        if timeElapsed >= interval or isFirstTimePlaying then
            timeElapsed = 0
            isFirstTimePlaying = false

            if not OmniBar.testModeEnabled then 
                timerFrame:Hide()
                timerFrame:SetScript("OnUpdate", nil)
                timerFrame = nil
                barFrame.isInTestMode = nil
                barFrame.testModeClasses = nil
                return 
            end

            if index > #barFrame.icons then
                index = 1
            end

            if index <= #barFrame.icons then
                local icon = barFrame.icons[index]
                index = index + 1
                local randomNumber = math.random(10, 15)
                if not barFrame.activeIcons[icon] then
                    OmniBar:ActivateIcon(barFrame, barSettings, icon, nil , randomNumber)
                end
            end 
        end
    end)
end

local function PlayHiddenCooldownAnimation(barFrame, barSettings, spellsToPlay)
    local interval = 1
    local timeElapsed = 0
    local index = 1
    local isFirstTimePlaying = true
    
    local timerFrame = CreateFrame("Frame")
    timerFrame:Show()
    
    timerFrame:SetScript("OnUpdate", function(self, elapsed)
        timeElapsed = timeElapsed + elapsed
        if timeElapsed >= interval or isFirstTimePlaying then
            timeElapsed = 0
            isFirstTimePlaying = false

            if not OmniBar.testModeEnabled then 
                timerFrame:Hide()
                timerFrame:SetScript("OnUpdate", nil)
                timerFrame = nil
                barFrame.isInTestMode = nil
                barFrame.testModeClasses = nil
                for _, spellData in ipairs(spellsToPlay) do
                    spellData.spellName = nil
                end
                return 
            end
            
            local spellData = spellsToPlay[index]

            -- TODO: Maybe auto cancel test mode if the bar has 0 tracked spells.
            -- TODO: If testing mode is active and user switches to showUnusedIcons, we must stop the test mode.
            if not spellData then
                index = 1
                return 
            end
    
            local randomNumber = math.random(5, 20)
            local icon = OmniBar:CreateIconToBar(barFrame, barSettings.showBorder, spellData.spellName, spellData)
            OmniBar:ActivateIcon(barFrame, barSettings, icon, nil , randomNumber)
            OmniBar:ArrangeIcons(barFrame, barSettings)
            index = index + 1
           
        end
    end)
end


function OmniBar:TestBars(selectedBars, selectedClasses, showCooldowns)
    local barsToTest = selectedBars["All"] and self.barFrames or selectedBars
    
    for barKey, _ in pairs(barsToTest) do
        local barSettings = self.db.profile.bars[barKey]
        local barFrame = self.barFrames[barKey]

        barFrame.isInTestMode = true
        barFrame.testModeClasses = selectedClasses

        self:TestIcons(barSettings, barFrame, selectedClasses, showCooldowns)
    end

    print("|cff00ff00Test Mode Activated:|r |cffffffffOmniBar is now in test mode.|r") 
end

function OmniBar:TestIcons(barSettings, barFrame, selectedClasses, showCooldowns)
    if not barSettings.showUnusedIcons then
        self:TestHiddenIcons(barSettings, barFrame, selectedClasses)
        return
    end

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

    if showCooldowns then
        PlayCooldownAnimation(barFrame, barSettings)
    end
end

function OmniBar:TestHiddenIcons(barSettings, barFrame, selectedClasses)
    local spellsToPlay = {}

    for spellName, spellData in pairs(barFrame.trackedSpells) do 
        if selectedClasses[spellData.className] or selectedClasses["All"] then
            spellData.spellName = spellName
            table.insert(spellsToPlay, spellData)
        end
    end

    PlayHiddenCooldownAnimation(barFrame, barSettings, spellsToPlay)
end

function OmniBar:StopTestMode()
    if not self.testModeEnabled then return end
       
    self.testModeEnabled = false

    for _, barFrame in pairs(self.barFrames) do
        self:ResetIcons(barFrame)
        self:ToggleAnchorVisibility(barFrame)
    end

    print("|cffff0000Test Mode Stopped:|r |cffffffffOmniBar is no longer in test mode.|r")
end