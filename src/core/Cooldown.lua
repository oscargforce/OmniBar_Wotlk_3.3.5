local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local addonName, addon = ...
local sharedCds = addon.sharedCds
local MapPetToPlayerUnit = addon.MapPetToPlayerUnit
local GetTime = GetTime
local GetUnitName = GetUnitName
local UnitExists = UnitExists

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

local function StartCooldownShading(icon, duration, barSettings, barFrame, cachedSpell)
    local now = GetTime()
    local startTime = now
    local remainingDuration = duration

    if cachedSpell then
        remainingDuration = cachedSpell.expires - now
        startTime = cachedSpell.timestamp
        duration = cachedSpell.duration 
    end

    local endTime = now + remainingDuration
    icon.endTime = endTime
    icon:SetAlpha(1)
    if not cachedSpell then
        icon:PlayNewIconAnimation()
    end

    icon.cooldown:SetCooldown(startTime, duration)
    icon.cooldown:SetAlpha(barSettings.swipeAlpha)

    local lastUpdate = 0
    icon.timerFrame:Show() 
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

local function ActivateIcon(barFrame, barSettings, icon, duration, cachedSpell)
    OmniBar:ToggleAnchorVisibility(barFrame)
    StartCooldownShading(icon, duration, barSettings, barFrame, cachedSpell)
end

local function HandleSharedCooldowns(spellName, barFrame, barSettings)
    local sharedCd = sharedCds[spellName]
    if not sharedCd then return end

    for i, icon in ipairs(barFrame.icons) do
        if sharedCd[icon.spellName] then
            print("Shared cd cooldown for", icon.spellName)
           
            barFrame.activeIcons[icon] = true
            local sharedCdDuration = sharedCd[icon.spellName]
            ActivateIcon(barFrame, barSettings, icon, sharedCdDuration)
        end
    end
end

local function GetUnitGUIDForCooldown(self, unit, cachedSpell)
    local mappedUnit = MapPetToPlayerUnit(unit)
    if self.zone == "arena" then
        return self.arenaOpponents[mappedUnit] and self.arenaOpponents[mappedUnit].unitGUID
    end

    return UnitGUID(mappedUnit)
end

local function RemoveInactiveIconsInWorldZone(icon, barFrame, barSettings)
    if OmniBar.zone == "arena" then return end
    if barSettings.trackedUnit ~= "allEnemies" then return end
    
    local currentUnitGUID = UnitGUID(icon.unitType)
    local currentUnitName = GetUnitName(icon.unitType)

    if icon.unitName ~= currentUnitName or
        (icon.unitType == "target" and not UnitExists("target")) or
        (icon.unitType == "focus" and not UnitExists("focus")) then
        print("RemoveInactiveIconsInWorldZone removing icon", icon.spellName, "from", icon.unitType, currentUnitName)
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

-- TEST ALL ENEMIES IN WORLD, TARGET AND FOCUS SAME CLASS
function OmniBar:OnCooldownUsed(barFrame, barSettings, unit, spellName, spellData, cachedSpell)
    if barSettings.showUnusedIcons then
        self:DetectSpecByAbility(spellName, unit, barFrame, barSettings)
        local unitName = MapPetToPlayerUnit(unit)
        HandleSharedCooldowns(spellName, barFrame, barSettings)

        for i, icon in ipairs(barFrame.icons) do
            if icon.spellName == spellName and icon.unitName == unitName then
                barFrame.activeIcons[icon] = true
                ActivateIcon(barFrame, barSettings, icon, spellData.duration, cachedSpell)
                return
            end  
        end
        -- icon not found on bar, simply exit the function
        return
    end

    -- Get or create icon for this spell
    local unitName = cachedSpell and cachedSpell.playerName or GetUnitName(unit)
    -- Maybe need to map pet unit to player unit here
    local icon = self:CreateIconToBar(barFrame, spellName, spellData, unitName, unit)

    ActivateIcon(barFrame, barSettings, icon, spellData.duration, cachedSpell)
    self:ArrangeIcons(barFrame, barSettings)
end


function OmniBar:OnCooldownEnd(icon, barFrame, barSettings)
    if barSettings.showUnusedIcons then 
        barFrame.activeIcons[icon] = nil

        self:ResetIconState(icon)
        RemoveInactiveIconsInWorldZone(icon, barFrame, barSettings)
        self:UpdateUnusedAlpha(barFrame, barSettings, icon) 
    else 
        self:ReturnIconToPool(icon) 
        for i = #barFrame.icons, 1, -1 do
            if barFrame.icons[i] == icon then
                print("OnCooldownEnd removed", barFrame.icons[i].spellName, "from barFrame.icons")
                table.remove(barFrame.icons, i) -- maybe add this to self:ArrangeIcons ?? Need to remove the icon from the icons table after cd is done
                break
            end
        end

        self:ArrangeIcons(barFrame, barSettings)
    end
    
    self:ToggleAnchorVisibility(barFrame)
end
