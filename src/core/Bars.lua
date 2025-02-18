local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local addonName, addon = ...
local spellTable = addon.spellTable
local MapTrinketNameToBuffName = addon.MapTrinketNameToBuffName
local MapBuffNameToTrinketName = addon.MapBuffNameToTrinketName
local next = next

--  This file contains functions to update the bar settings, which is configured in the options menu

function OmniBar:CreateBar() 
    local barKey = self:GenerateUniqueKey()
    self:InitializeBar(barKey)
    self:AddBarToOptions(barKey)

    print("Bar created with key:", barKey)
end

function OmniBar:SetPosition(barFrame, newPosition)
    if not barFrame then return end
    local barKey = barFrame.key
    local position = self.db.profile.bars[barKey].position

    -- Update position in database
    position.point = newPosition.point
    position.relativePoint = newPosition.relativePoint
    position.x = newPosition.x
    position.y = newPosition.y
end

function OmniBar:ToggleAnchorVisibility(barFrame)
    if next(barFrame.activeIcons) or self.db.profile.isBarsLocked then
        barFrame.anchor:Hide()
        return 
    end

    if self.db.profile.bars[barFrame.key].showUnusedIcons and #barFrame.icons > 0 then
        barFrame.anchor:Hide()
        return
    end
    
    barFrame.anchor:Show()
end

function OmniBar:GetBarData(barKey)
    return self.barFrames[barKey], self.db.profile.bars[barKey]
end

function OmniBar:UpdateTrackedUnit(barKey)
    local barFrame, barSettings = self:GetBarData(barKey)
    self:UpdateUnitEventTracking(barFrame, barSettings)

    if barFrame.isInTestMode then
        self:TestIcons(barSettings, barFrame, barFrame.testModeClasses)
    else
        self:ResetIcons(barFrame)
        self:SetupBarIcons(barFrame, barSettings)
    end
end

function OmniBar:SetupBarIcons(barFrame, barSettings)
    local trackedUnit = barSettings.trackedUnit
    
     if trackedUnit:match("^arena[1-5]$") then
        -- something
    elseif trackedUnit:match("^party[1-4]$") then
        self:OnEventHandler(barFrame, "PARTY_MEMBERS_CHANGED", "editMode")
    elseif trackedUnit == "target" then
        self:OnEventHandler(barFrame, "PLAYER_TARGET_CHANGED")
    elseif trackedUnit == "focus" then
        self:OnEventHandler(barFrame, "PLAYER_FOCUS_CHANGED")
    elseif trackedUnit == "allEnemies" and self.zone ~= "arena" then
        self:OnEventHandler(barFrame, "PLAYER_TARGET_CHANGED")
        self:OnEventHandler(barFrame, "PLAYER_FOCUS_CHANGED")
    end
end

function OmniBar:UpdateColumns(barKey)
    local barFrame, barSettings = self:GetBarData(barKey)

    if #barFrame.icons > 0 then
        self:ArrangeIcons(barFrame, barSettings, true)
    end
end

function OmniBar:BuildTrackedSpells(barFrame, barSettings)
    local trackedSpells = barFrame.trackedSpells
    wipe(trackedSpells)
    
    for className, spells in pairs(barSettings.cooldowns) do
        for spellName, spellConfig in pairs(spells) do
            if spellConfig.isTracking then
                self:AddSpellToTrackedSpells(trackedSpells, className, spellName, spellConfig)
            end
        end
    end
end

function OmniBar:AddSpellToTrackedSpells(trackedSpells, className, spellName, spellConfig)
    local spellData = spellTable[className][spellName]

    if not spellData then  
        print(spellName, "does not exist in the table: trackedSpells. Add it to the table then preform /relod")
        return
    end

    spellName = MapTrinketNameToBuffName(spellName)

    if not trackedSpells[spellName] then
        trackedSpells[spellName] = {
            duration = spellData.duration,
            icon = spellData.icon,
            priority = spellConfig.priority or 1,
            className = className,
            spellId = spellData.spellId,
            race = spellData.race or nil,
            spec = spellData.spec or nil,
            item = spellData.item or nil,
            adjust = spellData.adjust or nil,
        }
    end
end

function OmniBar:UpdateSpellTracking(barKey, isChecked, spellName, className, spellConfig)
    local barFrame, barSettings = self:GetBarData(barKey)

    if isChecked then
        self:AddSpellToTrackedSpells(barFrame.trackedSpells, className, spellName, spellConfig)
        if barFrame.isInTestMode then
            self:TestIcons(barSettings, barFrame, barFrame.testModeClasses)
        else
            self:SetupBarIcons(barFrame, barSettings)
        end
    else
        self:RemoveSpellFromTrackedSpells(barFrame, barSettings, spellName)
    end
    
end

function OmniBar:RemoveSpellFromTrackedSpells(barFrame, barSettings, spellName)
    barFrame.trackedSpells[spellName] = nil

    if #barFrame.icons > 0 then
        local needsRearranging = false

        for i, icon in ipairs(barFrame.icons) do
            if icon.spellName == spellName then
                self:ReturnIconToPool(icon)
                table.remove(barFrame.icons, i)
                barFrame.activeIcons[icon] = nil
                needsRearranging = true
                break
            end
        end

        if needsRearranging then
            self:ArrangeIcons(barFrame, barSettings)
        end
    end
end

function OmniBar:UpdateBarName(barKey)
    local barFrame, barSettings = self:GetBarData(barKey)
    barFrame.text:SetText(barSettings.name)

    local width = barFrame.text:GetWidth() + 28
    barSettings.anchorWidth = width
    barFrame.anchor:SetSize(width, 30)
end

function OmniBar:UpdateScale(barKey, scaleValue)
    local barFrame, barSettings = self:GetBarData(barKey)
    barFrame.iconsContainer:SetScale(barSettings.scale)
end

function OmniBar:UpdateBorders(barKey)
    local barFrame, barSettings = self:GetBarData(barKey)

    for i, icon in ipairs(barFrame.icons) do
        self:UpdateIconBorder(barSettings.showBorder, icon)
    end
    print("Border: Icons left in pool:", #self.iconPool)
end

function OmniBar:RefreshIconVisibility(barFrame, barSettings)
    local showUnusedIcons = barSettings.showUnusedIcons

    if showUnusedIcons then
        self:ResetIcons(barFrame)
        self:SetupBarIcons(barFrame, barSettings)
        self:UpdateUnusedAlpha(barFrame, barSettings)
    else
        self:ResetIcons(barFrame)
    end
 
    self:ToggleAnchorVisibility(barFrame)
end

function OmniBar:UpdateUnusedAlpha(barFrame, barSettings, singleIconUpdate)
    if not barSettings.showUnusedIcons then return end

    local unusedAlpha = barSettings.unusedAlpha

    if not singleIconUpdate then
        for _, icon in ipairs(barFrame.icons) do
            if not barFrame.activeIcons[icon] then
                icon:SetAlpha(unusedAlpha)
            end
        end
        return
    end
    singleIconUpdate:SetAlpha(unusedAlpha)
end

function OmniBar:UpdateSwipeAlpha(barFrame, barSettings, singleIconUpdate)
    local swipeAlpha = barSettings.swipeAlpha

    if not singleIconUpdate then
        for _, icon in ipairs(barFrame.icons) do
            icon.cooldown:SetAlpha(swipeAlpha)
        end
        return
    end

    singleIconUpdate:SetAlpha(swipeAlpha)
end

function OmniBar:UpdatePriority(barKey)
    local barFrame, barSettings = self:GetBarData(barKey)

    local trackedSpells = barFrame.trackedSpells

    for spellName, spellData in pairs(trackedSpells) do
        local mappedSpellName = MapBuffNameToTrinketName(spellName)
        spellData.priority = barSettings.cooldowns[spellData.className][mappedSpellName].priority or 1
    end

    if #barFrame.icons > 0 then
        for i, icon in ipairs(barFrame.icons) do
            local mappedSpellName = MapBuffNameToTrinketName(icon.spellName)
            icon.priority = barSettings.cooldowns[icon.className][mappedSpellName].priority or 1
        end

        self:ArrangeIcons(barFrame, barSettings)
    end
end

function OmniBar:UpdateMaxIcons(barKey)
    local barFrame, barSettings = self:GetBarData(barKey)
    local maxIcons = barSettings.maxIconsTotal
    local currentIcons = #barFrame.icons
    
    if currentIcons > maxIcons then
        self:ArrangeIcons(barFrame, barSettings)                                     
    elseif currentIcons > 0 and currentIcons < maxIcons and barFrame.isInTestMode and currentIcons >= (maxIcons - 20) then 
        self:TestIcons(barSettings, barFrame, barFrame.testModeClasses)
    elseif currentIcons > 0 and currentIcons < maxIcons and currentIcons >= (maxIcons - 20) then -- Threshold to prevent unnecessary function calls. Set to 20 to ensure icons are created if the slider is moved quickly.
        self:SetupBarIcons(barFrame, barSettings)
    end
end
