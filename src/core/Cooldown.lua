local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local addonName, addon = ...
local sharedCds = addon.sharedCds
local MapPetToPlayerUnit = addon.MapPetToPlayerUnit
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

local function StartCooldownShading(icon, barSettings, barFrame, cachedSpell, sharedCdDuration)
    local now = GetTime()
    local startTime = now
    local duration = sharedCdDuration or icon.duration
    local remainingDuration = sharedCdDuration or icon.duration

    if cachedSpell then
        remainingDuration = cachedSpell.expires - now
        startTime = cachedSpell.timestamp
        duration = cachedSpell.duration  --I dont think this is needed.
    end

    local endTime = now + remainingDuration
    icon.endTime = endTime
    icon.startTime = startTime
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

local function ActivateIcon(barFrame, barSettings, icon, cachedSpell, sharedCdDuration)
    barFrame.activeIcons[icon] = true
    OmniBar:ToggleAnchorVisibility(barFrame)
    StartCooldownShading(icon, barSettings, barFrame, cachedSpell, sharedCdDuration)
end

local function GetUnitGUIDForCooldown(unit, barKey, cachedSpell)
    local mappedUnit = MapPetToPlayerUnit(unit)

    if mappedUnit:match("^arena[1-5]$") then
        return OmniBar.arenaOpponents[mappedUnit] and OmniBar.arenaOpponents[mappedUnit].unitGUID, mappedUnit
    end
  
    if mappedUnit:match("^party[1-4]$") then
        return OmniBar.partyMemberGUIDs[barKey] and OmniBar.partyMemberGUIDs[barKey][mappedUnit], mappedUnit
    end

    if cachedSpell and not cachedSpell.isPet then
        return cachedSpell.sourceGUID, mappedUnit
    end

    return UnitGUID(mappedUnit), mappedUnit
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

function OmniBar:SharedCooldownsHandler(spellName, unit, barFrame, barSettings, cachedSpell)
    local sharedCd = sharedCds[spellName]
    if not sharedCd then return end
    
    local unitGUID = GetUnitGUIDForCooldown(unit, barFrame.key, cachedSpell)

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

-- TEST ALL ENEMIES IN WORLD, TARGET AND FOCUS SAME CLASS
function OmniBar:OnCooldownUsed(barFrame, barSettings, unit, spellName, spellData, cachedSpell)
    local unitGUID, mappedUnit = GetUnitGUIDForCooldown(unit, barFrame.key, cachedSpell)

    if barSettings.showUnusedIcons then
        self:DetectSpecByAbility(spellName, unit, barFrame, barSettings, unitGUID)
        for i, icon in ipairs(barFrame.icons) do --and not barFrame.activeIcons[icon]
            if icon.spellName == spellName and icon.unitGUID == unitGUID then
                ActivateIcon(barFrame, barSettings, icon, cachedSpell)
                return
            end  
        end
        -- icon not found on bar, simply exit the function
        return
    end

    local icon = self:CreateIconToBar(barFrame, spellName, spellData, unitGUID, unit)
    self:AdjustCooldownForSpec(icon, spellData, mappedUnit, barFrame.key, cachedSpell)

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
                print("OnCooldownEnd removed", barFrame.icons[i].spellName, "from barFrame.icons")
                table.remove(barFrame.icons, i) -- maybe add this to self:ArrangeIcons ?? Need to remove the icon from the icons table after cd is done
                break
            end
        end

        self:ArrangeIcons(barFrame, barSettings)
    end
    
    self:ToggleAnchorVisibility(barFrame)
end
