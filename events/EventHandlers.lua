function OmniBar:PLAYER_ENTERING_WORLD()
    local _, zone = IsInInstance()

    if self.zone and self.zone ~= zone then
        for _, barFrame in pairs(self.barFrames) do
            self:UpdateBar(barFrame.key, "refreshBarIconsState")
        end 
    end

    self.zone = zone
end

function OmniBar:CHAT_MSG_SYSTEM(event, chatMsg)
    if self.zone == "arena" then return end
    if not chatMsg:match("Duel starting: 3") then return end

    for _, barFrame in pairs(self.barFrames) do
        self:UpdateBar(barFrame.key, "refreshBarIconsState")
    end 
end

-- Death knights death coil has same name as warlock spell :/ need to use some if statement on that spell
function OmniBar:OnUnitSpellCastSucceeded(barFrame, event, unit, spellName, spellRank)
    local barSettings = self.db.profile.bars[barFrame.key]

    if not self:UnitMatchesTrackedUnit(unit, barSettings.trackedUnit) then return end

    local spellData = barFrame.trackedSpells[spellName]
    if not spellData then return end
    if spellName == "Death Coil" and spellRank ~="Rank 6" then return end

    print("PASSED:", spellName)
    self:OnCooldownUsed(barFrame, barSettings, spellName, spellData)
end

function OmniBar:OnCooldownUsed(barFrame, barSettings, spellName, spellData)
    if barSettings.showUnusedIcons then
        for i, icon in ipairs(barFrame.icons) do
            if icon.spellName == spellName then
                print("Creating icon for", spellName)
                barFrame.activeIcons[spellName] = icon
                self:ActivateIcon(barFrame, barSettings, icon, spellData.duration)
                return
            end  
        end
        -- If icon not found then we need to add it manually to the bar since we exceeded the totalMaxIconsToDisplay, and remove a unused bar.
    end

    -- Get or create icon for this spell
    local icon = self:GetIconFromPool(barFrame)
    icon.spellName = spellName 
    icon.icon:SetTexture(spellData.icon)
    table.insert(barFrame.icons, icon)
    self:ActivateIcon(barFrame, barSettings, icon, spellData.duration)
end

function OmniBar:ActivateIcon(barFrame, barSettings, icon, duration)
    self:ToggleAnchorVisibility(barFrame)
    self:StartCooldownShading(icon, duration, barSettings, barFrame)
    self:ArrangeIcons(barFrame, barSettings)
end

local COLORS = {
    WHITE = "|cFFFFFFFF",
    YELLOW = "|cFFFFFF00",
    RED = "|cFFFF0000",
    END_TAG = "|r"
}

local function formatTimeText(timeLeft)
    local color
    if timeLeft >= 60 then
        -- Show minutes (e.g., 1m, 2m, etc.)
        local minutes = math.floor((timeLeft / 60) + 0.5) -- math.round hack in lua, now it matches omnicc timer :)
        color = COLORS.WHITE
        return string.format("%s%dm%s", color, minutes, COLORS.END_TAG)
    elseif timeLeft > 5 then
        color = COLORS.YELLOW
    else
        color = COLORS.RED
    end
    return string.format("%s%.0f%s", color, timeLeft, COLORS.END_TAG)
end

function OmniBar:StartCooldownShading(icon, duration, barSettings, barFrame)
    local startTime = GetTime()
    local endTime = startTime + duration

    icon.endTime = endTime
    icon:Show()
    icon:SetAlpha(1)
    icon:PlayNewIconAnimation()

    icon.cooldown:SetCooldown(startTime, duration)
    icon.cooldown:SetAlpha(barSettings.swipeAlpha)

    print("Icons pool OnUpdate", #self.iconPool)
    local lastUpdate = 0
    icon.timerFrame:Show() 
    icon.timerFrame:SetScript("OnUpdate", function(self, elapsed)
        lastUpdate = lastUpdate + elapsed
        if lastUpdate >= 0.2 then
            local timeLeft = endTime - GetTime()
            if timeLeft > 0 then
                -- need to add condition here, if barSettings.noCountdown, return early
                icon.countdownText:SetText(formatTimeText(timeLeft))
            else
                OmniBar:OnCooldownEnd(icon, barFrame, barSettings)
                print("BarFrame icons num:", #barFrame.icons)
            end
            lastUpdate = 0
        end
    end) 
end

function OmniBar:OnCooldownEnd(icon, barFrame, barSettings)
    self:ResetIconState(icon)
    
    if barSettings.showUnusedIcons then 
        barFrame.activeIcons[icon.spellName] = nil
        self:UpdateUnusedAlpha(barFrame, barSettings, icon) 
    else 
        self:ReturnIconToPool(icon) 
        for i = #barFrame.icons, 1, -1 do
            if barFrame.icons[i] == icon then
                print("Removed", barFrame.icons[i].spellName, "from barFrame.icons")
                table.remove(barFrame.icons, i) -- maybe add this to self:ArrangeIcons ?? Need to remove the icon from the icons table after cd is done
                break
            end
        end
    end
    print("ARRANGE ICONS")
    self:ArrangeIcons(barFrame, barSettings)
    self:ToggleAnchorVisibility(barFrame)
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

