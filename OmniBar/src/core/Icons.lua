local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local next = next
local GetUnitName = GetUnitName
local UnitExists = UnitExists

function OmniBar:CreateIconToBar(barFrame, showBorder, spellName, spellData, unitGUID, unit)
    local icon = self:GetIconFromPool(barFrame)
    icon.icon:SetTexture(spellData.icon)
    icon.spellName = spellName
    icon.priority = spellData.priority 
    icon.className = spellData.className
    icon.spellId = spellData.spellId
    icon.duration = spellData.duration
    icon.race = spellData.race or nil
    icon.item = spellData.item or nil
    icon.unitGUID = unitGUID or nil
    icon.unitType = unit or nil

    self:UpdateIconBorder(showBorder, icon)
    icon:Show()
    table.insert(barFrame.icons, icon)
    return icon
end

function OmniBar:UpdateIconBorder(showBorder, icon)
    if showBorder then
        icon.icon:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1)
    else
        icon.icon:SetTexCoord(0.07, 0.9, 0.07, 0.9) 
    end
end

-- Avoid resetting spellName, priority, and className here to prevent issues with showUnusedIcons when the cooldown countdown ends.
function OmniBar:ResetIconState(icon)
    icon.countdownText:SetText("")
    icon.timerFrame:Hide()
    icon.timerFrame:SetScript("OnUpdate", nil) -- Delete the timer
    icon.cooldown:Hide()
    icon.endTime = nil
    icon.startTime = nil
end

function OmniBar:GetIconFromPool(barFrame)
    -- Reuse an icon from the pool if available
    if #self.iconPool > 0 then
        local icon = table.remove(self.iconPool)
        icon:SetParent(barFrame.iconsContainer)
        self:MakeFrameDraggable(icon, barFrame)
        return icon
    end
    -- Otherwise, create a new icon
    local icon = barFrame.CreateOmniBarIcon()
    self:MakeFrameDraggable(icon, barFrame)
    return icon
end

function OmniBar:CreateIconsToPool(barFrame)
    for spellName, spellData in pairs(barFrame.trackedSpells) do
        if spellData then  
            local icon = barFrame.CreateOmniBarIcon()
            self:ReturnIconToPool(icon)
        end
    end
end

function OmniBar:ReturnIconToPool(icon)
    self:ResetIconState(icon)
    icon.spellName = nil
    icon.className = nil
    icon.item = nil
    icon.race = nil
    icon.priority = nil
    icon.spellId = nil
    icon.duration = nil
    icon.unitGUID = nil
    icon.unitType = nil
    icon.targetHighlight:Hide()
    icon.focusHighlight:Hide()
    icon.playerNameText:SetText("")
    icon:StopNewIconAnimation()
    icon:Hide()
    icon:ClearAllPoints()
    icon:SetParent(nil) -- Remove from parent to avoid layout conflicts
    table.insert(self.iconPool, icon)
end

function OmniBar:ResetIcons(barFrame)
    for _, icon in ipairs(barFrame.icons) do
        self:ReturnIconToPool(icon)
    end

    -- Clear the icons table (reuse pool instead of removing actual icons)
    wipe(barFrame.icons) 
    wipe(barFrame.activeIcons) 
end

function OmniBar:RefreshBarsWithActiveIcons()
    for _, barFrame in pairs(self.barFrames) do
        if next(barFrame.activeIcons) then
            self:RefreshIconVisibility(barFrame, self.db.profile.bars[barFrame.key])
        end 
    end 
end

function OmniBar:MakeFrameDraggable(icon, barFrame)
    local isLocked = self.db.profile.isBarsLocked
    
    icon:SetMovable(not isLocked)
    icon:EnableMouse(not isLocked)
     -- Clear old scripts to avoid dragging the wrong bar
    icon:SetScript("OnMouseDown", nil)
    icon:SetScript("OnMouseUp", nil)

    icon:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            barFrame:StartMoving()
        end
    end)
    icon:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            barFrame:StopMovingOrSizing()
            -- Save position
            local point, _, relativePoint, x, y = barFrame:GetPoint()
            OmniBar:SetPosition(barFrame, { point = point, relativePoint = relativePoint, x = x, y = y })
        end
    end)
end

function OmniBar:ToggleIconLock(barFrame, isBarsLocked)
    for _, icon in ipairs(barFrame.icons) do
        if isBarsLocked then
            icon:SetMovable(false)
            icon:EnableMouse(false)
        else
            icon:SetMovable(true)
            icon:EnableMouse(true)
        end
    end
end

local function GetCachedArenaUnitName(unit)
    if OmniBar.arenaOpponents[unit] and OmniBar.arenaOpponents[unit].unitName then
        return OmniBar.arenaOpponents[unit].unitName
    end

    local unitName = GetUnitName(unit)
    OmniBar.arenaOpponents[unit].unitName = unitName

    return unitName
end

function OmniBar:SetUnitNameTextForHiddenIcons(icon, cachedSpell, barSettings, unit)
    if not barSettings.showNames then return end
    if barSettings.trackedUnit ~= "allEnemies" then return end

    if self.zone == "arena" then
        playerName = GetCachedArenaUnitName(unit)
    else
        playerName = cachedSpell and cachedSpell.playerName or GetUnitName(unit)
    end

    icon.playerNameText:SetText(playerName)
end

function OmniBar:SetUnitNameText(icon, cachedSpell, barSettings, unit)
    if not barSettings.showNames then return end
    if barSettings.trackedUnit ~= "allEnemies" then return end
    
    if self.zone ~= "arena" then
        if unit == "nonTargetedPlayer" or UnitExists("target") and UnitExists("focus") then
            local playerName = cachedSpell and cachedSpell.playerName or GetUnitName(unit)
            icon.playerNameText:SetText(playerName)
        end
        return
    end

    local playerName = GetCachedArenaUnitName(unit)
    icon.playerNameText:SetText(playerName)
end