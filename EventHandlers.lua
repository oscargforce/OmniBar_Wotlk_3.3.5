local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")

--[[    
Example tables        

barFrame.trackedAbilities = {
    ["Mind Freeze"] = {
        duration = 120,
        icon = path,
    },
    ["Kick"] = {
        duration = 15,
        icon = path,
    },
}

barFrame.activeAbilitiess = {
        ["Mind Freeze"] = { endTime = 140, icon = frameRef }
        ["Berserking"] = { endTime = 140, icon = frameRef }
} 

]]


-- fix later
function OmniBar:OnUnitSpellCastSucceded(barFrame, event, unitId, spellName, spellRank)
    -- Quick fails
  --  if not unitId:match("arena%d") then return end
    if not unitId:match("party%d") then return end
   
    local spellData = barFrame.trackedSpells[spellName]
    if not spellData then return end

    self:OnCooldownUsed(barFrame, barFrame.key, spellName, spellData)
end

function OmniBar:OnCooldownUsed(barFrame, barKey, spellName, spellData)
    local barSettings = self.db.profile.bars[barKey]
    local now = GetTime()

    if barSettings.showUnusedIcons then
        for i, icon in ipairs(barFrame.icons) do
            if icon.spellName == spellName then
                self:StartCooldownShading(icon, spellData.duration)
                return
            end
            
        end
    end

        -- Get or create icon for this spell
        local icon = self:GetIconFromPool(barFrame)
        icon.spellName = spellName -- maybe not need???
        icon.icon:SetTexture(spellData.icon)
        icon.cooldown:SetCooldown(now, spellData.duration)
        icon:Show()

        table.insert(barFrame.icons, icon)
        -- Update or create spell tracking
   
        barFrame.activeSpells[spellName] = {
           endTime = now + spellData.duration,
           icon = icon
       }
        
        self:ArrangeIcons(barFrame, self.db.profile.bars[barKey])

end

function OmniBar:StartCooldownShading(icon, duration)
        icon:Show()
        local startTime = GetTime()
        local endTime = startTime + duration
    
        icon.cooldown:SetCooldown(startTime, duration)
        icon.cooldown:SetAlpha(1)

        local function SetFormattedTime(timeLeft)
            if timeLeft >= 60 then
                -- Show minutes (e.g., 1m, 2m, etc.)
                local minutes = math.floor((timeLeft / 60) + 0.5) -- math.round hack in lua, now it matches omnicc timer :)
                icon.countdownText:SetText(string.format("%dm", minutes))
            elseif timeLeft >= 10 then
                -- Less than 60 seconds, but more than 10 seconds, show seconds (e.g., 59, 58, 57)
                icon.countdownText:SetText(string.format("%.0f", timeLeft))
            else
                -- Less than 10 seconds, show countdown in single digits (e.g., 9, 8, 7)
                icon.countdownText:SetText(string.format("%.0f", timeLeft))
            end
        end
        
        local lastUpdate = 0
        icon.timerFrame:Show() -- Must show the frame to start the OnUpdate script
        icon.timerFrame:SetScript("OnUpdate", function(self, elapsed)
            lastUpdate = lastUpdate + elapsed
            if lastUpdate >= 0.2 then
                local timeLeft = endTime - GetTime()
                if timeLeft > 0 then
                    -- need to add condition here, if barSettings.noCountdown, return early
                    SetFormattedTime(timeLeft)
                else
                    icon:Hide()  
                    icon.countdownText:SetText("") 
                    icon.timerFrame:Hide() 
                    icon.timerFrame:SetScript("OnUpdate", nil) -- Delete the timer
                end
                lastUpdate = 0
            end
        end) 
end

--[[

local units = {
    target = "",
    arena1 = "",
    arena2 = "",
    arena3 = ""
}

local function ClearUnitClasses()
    for arenaUnit in pairs(unitClasses) do
        unitClasses[arenaUnit] = ""
    end
end

local function GetUnitClass(unitId)
    if unitClasses[unitId] ~= "" then
        return unitClasses[unitId]
    end
    local unitClass = UnitClass(unitId)
    unitClasses[unitId] = unitClass
    return unitClass
end

function OmniBar:UNIT_SPELLCAST_SUCCEEDED(event, unitId, spellName, spellRank)
    for barKey, barSettings in paris(self.db.profile.bars) do
        if barSettings.trackUnit == unitId then
            local unitClass = GetUnitClass(unitId)
            local spellData = self.db.profile.bars[barKey].cooldowns[unitClass][spellName]

            if not spellData or not spellData.isTracking then 
                return 
            end

            local icon = self:GetIconFromPool(barFrame)
            icon.icon:SetTexture(cooldownData.icon)
            icon:Show()

            self:ArrangeIcons(self.barFrames[barKey], barSettings)
        end
    end
end

]]

