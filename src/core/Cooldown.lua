local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local addonName, addon = ...
local sharedCds = addon.sharedCds
local GetTime = GetTime
local GetUnitName = GetUnitName
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitRace = UnitRace

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

function OmniBar:StartCooldownShading(icon, barSettings, barFrame, cachedSpell, sharedCdDuration)
    local now = GetTime()
    local startTime = now
    local duration = sharedCdDuration or icon.duration
    local remainingDuration = sharedCdDuration or icon.duration

    if cachedSpell then
        remainingDuration = cachedSpell.expires - now
        startTime = cachedSpell.timestamp
        if cachedSpell.duration then
            duration = cachedSpell.duration 
        end
    end

    local endTime = now + remainingDuration
    icon.endTime = endTime - 0.2 -- subtract 0.2 due to latencys,
    icon.startTime = startTime
    icon:SetAlpha(1)
    if not cachedSpell then
        icon:PlayNewIconAnimation()
    end

    icon.cooldown:SetCooldown(startTime, duration)
    icon.cooldown:SetAlpha(barSettings.swipeAlpha)

    local lastUpdate = 0
    icon.timerFrame:Show() 
    icon.timerFrame:SetScript("OnUpdate", nil) -- delete any existing timer
    icon.timerFrame:SetScript("OnUpdate", function(self, elapsed)
        lastUpdate = lastUpdate + elapsed
        if lastUpdate >= 0.1 then
            local timeLeft = endTime - GetTime()
            if timeLeft > 0 then
                -- need to add condition here, if barSettings.noCountdownText, return early
                icon.countdownText:SetText(formatTimeText(timeLeft))
            else
                OmniBar:OnCooldownEnd(icon, barFrame, barSettings)
            end
            lastUpdate = 0
        end
    end) 
end

local function ActivateIcon(barFrame, barSettings, icon, cachedSpell, sharedCdDuration)
    barFrame.activeIcons[icon] = true
    OmniBar:ToggleAnchorVisibility(barFrame)
    OmniBar:StartCooldownShading(icon, barSettings, barFrame, cachedSpell, sharedCdDuration)
end

local function RemoveInactiveIconsInWorldZone(icon, barFrame, barSettings)
    if OmniBar.zone == "arena" then return end
    if barSettings.trackedUnit ~= "allEnemies" then return end
    
    local currentUnitGUID = UnitGUID(icon.unitType)

    if icon.unitGUID ~= currentUnitGUID or
        (icon.unitType == "target" and not UnitExists("target")) or
        (icon.unitType == "focus" and not UnitExists("focus")) then
        print("RemoveInactiveIconsInWorldZone removing icon", icon.spellName, "from", icon.unitType, GetUnitName(icon.unitType))
        OmniBar:ReturnIconToPool(icon)
        for i = #barFrame.icons, 1, -1 do
            if barFrame.icons[i] == icon then
                table.remove(barFrame.icons, i)
                break
            end
        end
        OmniBar:ArrangeIcons(barFrame, barSettings)
    end 
end

function OmniBar:SharedCooldownsHandler(barFrame, barSettings, unit, unitGUID, spellName, cachedSpell)
    local sharedCd = sharedCds[spellName]
    if not sharedCd then return end
    
    if not barSettings.showUnusedIcons then
        for spell, spellConfig in pairs(sharedCd) do
            local spellData = barFrame.trackedSpells[spell]

            if spellConfig.showWhenHidden and spellData then
                local shouldAddIcon = true
                for i, icon in ipairs(barFrame.icons) do
                    if icon.spellName == spell and icon.unitGUID == unitGUID then
                        shouldAddIcon = false
                        break
                    end
                end

                if shouldAddIcon then
                    if spell == "Will of the Forsaken" and UnitRace(unit) ~= "Undead" then
                        return
                    end
                    local icon = self:CreateIconToBar(barFrame, spell, spellData, unitGUID, unit)
                    local sharedDuration = spellConfig.sharedDuration or nil
                    ActivateIcon(barFrame, barSettings, icon, cachedSpell, sharedDuration)
                    print("Hidden shared cd cooldown for", icon.spellName)
                    self:ArrangeIcons(barFrame, barSettings)
                end
            end
        end

        return
    end

    -- For showUnusedIcons
    for i, icon in ipairs(barFrame.icons) do
        local spell = sharedCd[icon.spellName]

        if spell and icon.unitGUID == unitGUID then
            local isActiveIcon = barFrame.activeIcons[icon]

            if isActiveIcon and not spell.sharedDuration then
                ActivateIcon(barFrame, barSettings, icon, cachedSpell)
                print("isActiveIcon shared cd cooldown for", icon.spellName)
            elseif not isActiveIcon then
                local sharedCdDuration = spell.sharedDuration or nil
                ActivateIcon(barFrame, barSettings, icon, cachedSpell, sharedCdDuration)
                print("Shared cd cooldown for", icon.spellName)
            end
        end

    end
end

function OmniBar:OnCooldownUsed(barFrame, barSettings, unit, unitGUID, spellName, spellData, cachedSpell)
    if barSettings.showUnusedIcons then
        for i, icon in ipairs(barFrame.icons) do
            if icon.spellName == spellName and icon.unitGUID == unitGUID then
                ActivateIcon(barFrame, barSettings, icon, cachedSpell)
                return
            end  
        end
        -- icon not found on bar, simply exit the function
        return
    end

    local icon = self:CreateIconToBar(barFrame, spellName, spellData, unitGUID, unit)
    self:AdjustCooldownForSpec(icon, spellData, unit, barFrame, barSettings, cachedSpell)

    ActivateIcon(barFrame, barSettings, icon, cachedSpell)
    self:ArrangeIcons(barFrame, barSettings)
end


function OmniBar:OnCooldownEnd(icon, barFrame, barSettings)
    barFrame.activeIcons[icon] = nil

    if barSettings.showUnusedIcons then 
        self:ResetIconState(icon)
        RemoveInactiveIconsInWorldZone(icon, barFrame, barSettings)
        self:UpdateUnusedAlpha(barFrame, barSettings, icon) 
    else 
        self:ReturnIconToPool(icon) 
        for i = #barFrame.icons, 1, -1 do
            if barFrame.icons[i] == icon then
                table.remove(barFrame.icons, i)
                break
            end
        end

        self:ArrangeIcons(barFrame, barSettings)
    end
    
    self:ToggleAnchorVisibility(barFrame)
end
