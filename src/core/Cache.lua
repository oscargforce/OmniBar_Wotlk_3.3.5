local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local addonName, addon = ...
local resetCds = addon.resetCds
local next = next
local GetTime = GetTime
local UnitExists = UnitExists
local GetUnitName = GetUnitName

function OmniBar:CleanupCombatLogCache()
    local currentTime = GetTime()

    for playerName, playerCache in pairs(self.combatLogCache) do
        self:CleanPlayerCache(playerCache, currentTime, playerName)
    end
end

function OmniBar:CleanPlayerCache(playerCache, currentTime, playerName)
    for spellName, spellData in pairs(playerCache) do
        if spellData.expires and currentTime >= spellData.expires then
            self.combatLogCache[playerName][spellName] = nil
        elseif resetCds[spellName] then 
            for resetCd, _ in pairs(resetCds[spellName]) do
                local affectedSpell = self.combatLogCache[playerName][resetCd]
                if affectedSpell and spellData.timestamp >= affectedSpell.timestamp then
                    self.combatLogCache[playerName][resetCd] = nil
                end
            end
        end
    end
end

function OmniBar:RemoveNonTargetActiveIcons(barFrame, barSettings, spellsToReset, playerSpellCache)
    if barSettings.trackedUnit ~= "allEnemies" then
        return
    end

    if not next(barFrame.activeIcons) then
        return
    end
    local showUnusedIcons = barSettings.showUnusedIcons
    local sourceGUID = playerSpellCache.sourceGUID
    local sourceName = playerSpellCache.playerName
    local needsRearranging = false
    local currentTargetName = UnitExists("target") and GetUnitName("target") or ""
    local currentFocusName = UnitExists("focus") and GetUnitName("focus") or ""

    for i = #barFrame.icons, 1, -1 do
        local icon = barFrame.icons[i]
        if spellsToReset[icon.spellName] and barFrame.activeIcons[icon] and icon.unitGUID == sourceGUID then
            barFrame.activeIcons[icon] = nil
            
            if showUnusedIcons then 
                -- if target or focus does not exists then remove the icon
                if (icon.unitType == "target" and currentTargetName ~= sourceName) or
                   (icon.unitType == "focus" and currentFocusName ~= sourceName) then
                    self:ReturnIconToPool(icon)
                    table.remove(barFrame.icons, i)
                    needsRearranging = true
                   else
                    self:ResetIconState(icon)
                    self:UpdateUnusedAlpha(barFrame, barSettings, icon)
                end 
            else
                self:ReturnIconToPool(icon)
                table.remove(barFrame.icons, i)
                needsRearranging = true
            end
        end
    end

    if needsRearranging then 
        self:ArrangeIcons(barFrame, barSettings)
    end
end
