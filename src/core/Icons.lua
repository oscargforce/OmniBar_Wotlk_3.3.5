local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local next = next

function OmniBar:CreateIconToBar(barFrame, spellName, spellData, unitGUID, unit)
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

    icon:Show()
    table.insert(barFrame.icons, icon)
    return icon
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
        -- change this later to if spellData then... and remove the print
        if not spellData then print(spellName,"Does not exist in spellTable") end

        local icon = barFrame.CreateOmniBarIcon()
        self:ReturnIconToPool(icon)
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
            self:UpdateBar(barFrame.key, "refreshBarIconsState")
        end 
    end 
end

function OmniBar:MakeFrameDraggable(icon, barFrame)
    icon:SetMovable(true)
    icon:EnableMouse(true)
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