local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")

-- Death knights death coil has same name as warlock spell :/ need to use some if statement on that spell
function OmniBar:OnUnitSpellCastSucceeded(barFrame, event, unitId, spellName, spellRank,a,b,c,d,f,e,g)
    --if not unitId:match("arena%d") then return end
    if not unitId:match("party%d") then return end
    print("a:", spellRank)

    local spellData = barFrame.trackedSpells[spellName]
    if not spellData then return end
    if spellName == "Death Coil" and spellRank ~="Rank 6" then return end
    print("PASSED:", spellName)
    self:OnCooldownUsed(barFrame, barFrame.key, spellName, spellData)
end

function OmniBar:OnCooldownUsed(barFrame, barKey, spellName, spellData)
    local barSettings = self.db.profile.bars[barKey]

    if barSettings.showUnusedIcons then
        for i, icon in ipairs(barFrame.icons) do
            if icon.spellName == spellName then
                icon:SetAlpha(1.0)
                self:StartCooldownShading(icon, spellData.duration, barSettings, barFrame, spellName)
                return
            end  
        end
    end

    -- Get or create icon for this spell
    local icon = self:GetIconFromPool(barFrame)
    icon.spellName = spellName 
    icon.icon:SetTexture(spellData.icon)
    table.insert(barFrame.icons, icon)

    self:StartCooldownShading(icon, spellData.duration, barSettings, barFrame, spellName)
    
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

function OmniBar:OnCooldownEnd(icon, barFrame, barSettings, spellName)
    icon.countdownText:SetText("") 
    icon.timerFrame:Hide() 
    icon.timerFrame:SetScript("OnUpdate", nil) -- Delete the timer
    if barSettings.showUnusedIcons then 
        icon.cooldown:Hide() 
    else 
        self:ReturnIconToPool(icon) 
        for i = #barFrame.icons, 1, -1 do
            if barFrame.icons[i] == icon then
                print("Removed", barFrame.icons[i].spellName, "from barFrame.icons")
                table.remove(barFrame.icons, i) -- maybe add this to self:ArrangeIcons ?? Need tp remove the icon from the icons table after cd is done
                break
            end
        end
    end
    print("ARRANGE ICONS")
    self:ArrangeIcons(barFrame, barSettings)
end

function OmniBar:StartCooldownShading(icon, duration, barSettings, barFrame, spellName)
    local startTime = GetTime()
    local endTime = startTime + duration

    icon.endTime = endTime
    icon:Show()

    icon.cooldown:SetCooldown(startTime, duration)
    icon.cooldown:SetAlpha(1)

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
                OmniBar:OnCooldownEnd(icon, barFrame, barSettings, spellName)
                print("BarFrame icons num:", #barFrame.icons)
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

