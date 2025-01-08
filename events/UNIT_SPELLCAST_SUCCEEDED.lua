--[[ 
    UNIT_CAST_SUCCEEDED can fire multiple times for the same spell if the same player targets multiple units (e.g., target, focus, arena1). 
    Without optimization, this would create multiple icons for the same spell. 
    In arenas, to improve performance, we only track arena1-5 if the bar is set to track all enemies.
]]
local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")

local UnitIsEnemy = UnitIsEnemy
local UnitIsUnit = UnitIsUnit

local arenaUnits = {
    ["arena1"] = true,
    ["arena2"] = true,
    ["arena3"] = true,
    ["arena4"] = true,
    ["arena5"] = true,
    ["arenapet1"] = true,
    ["arenapet2"] = true,
    ["arenapet3"] = true,
    ["arenapet4"] = true,
    ["arenapet5"] = true,
}

local nonArenaEnemyUnits = {
    ["target"] = true,
    ["focus"] = true,
}

local function MatchesArenaUnit(unit, trackedUnit)
    if trackedUnit == "allEnemies" then
        return arenaUnits[unit] or false
    end

    if unit == trackedUnit then
        return true
    end

    if unit == trackedUnit:gsub("arena", "arenapet") then
        return true
    end

    if unit == trackedUnit:gsub("party", "partypet") then
        return true
    end

    return false
end

local function MatchesGeneralUnit(unit, trackedUnit)
    if trackedUnit == "allEnemies" then

        if not nonArenaEnemyUnits[unit] then
            return false
        end

        if not UnitIsEnemy("player", unit) then
            return false
        end 

        if UnitIsUnit("focus", "target") and unit == "focus" then
            return false
        end
        return nonArenaEnemyUnits[unit] or false 
    end
    
    if unit == trackedUnit then
        return true
    end

    if unit == trackedUnit:gsub("party", "partypet") then
        return true
    end
end

local function GetUnitMatchStrategy(zone)
    if zone == "arena" then
        return MatchesArenaUnit
    else
        return MatchesGeneralUnit
    end
end

function OmniBar:UnitMatchesTrackedUnit(unit, trackedUnit)
    if not trackedUnit then
        return false
    end

    local strategy = GetUnitMatchStrategy(self.zone)

    return strategy(unit, trackedUnit)
end

-- Maybe a bug, for example spirit wolves uses bash same ability as druid, we might display the icon if its tracked on druid but not on shaman. 
-- Need to test this, and if so add another condition icon.className == unit class, maybe want to add a cache for this to reduce the api calls.

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
        self:DetectSpecByAbility(spellName, barSettings.trackedUnit, barFrame)

        for i, icon in ipairs(barFrame.icons) do
            if icon.spellName == spellName then
                print("Activating icon:", spellName)
                barFrame.activeIcons[spellName] = icon
                self:ActivateIcon(barFrame, barSettings, icon, spellData.duration)
                return
            end  
        end
        -- icon not found on bar, simply exit the function
        return
    end

    -- Get or create icon for this spell
    local icon = self:CreateIconToBar(barFrame, spellName, spellData)
    self:ActivateIcon(barFrame, barSettings, icon, spellData.duration)
    self:ArrangeIcons(barFrame, barSettings)
end

function OmniBar:ActivateIcon(barFrame, barSettings, icon, duration)
    self:ToggleAnchorVisibility(barFrame)
    self:StartCooldownShading(icon, duration, barSettings, barFrame)
    -- self:ArrangeIcons(barFrame, barSettings) -- maybe we dont need this anymore?
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

        print("ARRANGE ICONS")
        self:ArrangeIcons(barFrame, barSettings)
    end
    
    self:ToggleAnchorVisibility(barFrame)
end