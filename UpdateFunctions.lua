local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local addonName, addon = ...

function OmniBar:UpdateBar(barKey, specificUpdate)
    local barFrame = self.barFrames[barKey]
    local barSettings = self.db.profile.bars[barKey]

    -- Lookup table for update operations
    local updateOperations = {
        name = function() self:UpdateBarName(barFrame, barSettings) end,
        scale = function() self:UpdateScale(barFrame, barSettings) end,
        resetIcons = function() self:ResetIcons(barFrame) end,
        updateSpellTracking = function() self:UpdateSpellTrackingForBar(barFrame, barSettings) end,
        setUpIcons = function() self:SetupBarIcons(barFrame, barSettings) end,
        border = function() self:UpdateBorder(barFrame, barSettings) end,
        arrangeIcons = function() self:ArrangeIcons(barFrame, barSettings, true) end,
        refreshBarIconsState = function() self:UpdateIconVisibilityAndState(barFrame, barSettings) end,
        unusedAlpha = function() self:UpdateUnusedAlpha(barFrame, barSettings) end,
        swipeAlpha = function() self:UpdateSwipeAlpha(barFrame, barSettings) end,
    }

    if specificUpdate then
        local operation = updateOperations[specificUpdate]

        if not operation then
            print(string.format("OmniBar: Invalid update operation '%s' for bar '%s'", specificUpdate, barKey))
            return
        end 

        operation()
        return  
    end
    
    -- Perform all required updates if no specific update is provided
    local operationOrder = {"name", "scale", "resetIcons", "updateSpellTracking", "setUpIcons","border"}
    for _, key in ipairs(operationOrder) do
        local operation = updateOperations[key]
        operation()
    end
end

function OmniBar:UpdateBarName(barFrame, barSettings)
    barFrame.text:SetText(barSettings.name)

    -- Adjust the bar's width based on the text width + padding
    local width = barFrame.text:GetWidth() + 28
    barSettings.anchorWidth = width
    barFrame.anchor:SetSize(width, 30)
end

function OmniBar:UpdateScale(barFrame, barSettings)
    barFrame.iconsContainer:SetScale(barSettings.scale)
end

function OmniBar:UpdateBorder(barFrame, barSettings)
    for i, button in ipairs(barFrame.icons) do
        if barSettings.showBorder then
            button.icon:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1)
        else
            button.icon:SetTexCoord(0.07, 0.9, 0.07, 0.9) 
        end
    end
    print("Border: Icons left in pool:", #self.iconPool)
end

function OmniBar:UpdateIconVisibilityAndState(barFrame, barSettings)
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
            icon:SetAlpha(unusedAlpha)
        end
        return
    end
    singleIconUpdate:SetAlpha(unusedAlpha)
end

local function getCorrectedSpellName(spellName)
    local nameMapping = {
        ["Bauble of True Blood"] = "Release of Light",
        ["Corroded Skeleton Key"] = "Hardened Skin",
    }

    return nameMapping[spellName] or spellName
end

function OmniBar:UpdateSpellTrackingForBar(barFrame, barSettings)
    local trackedSpells = barFrame.trackedSpells
    wipe(trackedSpells)
    
    local spellTable = addon.spellTable
    
    for className, spells in pairs(barSettings.cooldowns) do
        for spellName, spellConfig in pairs(spells) do
            if spellConfig.isTracking then
                local spellData = spellTable[className][spellName]

                if spellData then  
                    spellName = getCorrectedSpellName(spellName)
    
                    if not trackedSpells[spellName] then
                        trackedSpells[spellName] = {
                            duration = spellData.duration,
                            icon = spellData.icon,
                            priority = spellConfig.priority or 1,
                            className = className
                        }

                        if spellData.race then
                            trackedSpells[spellName].race = spellData.race
                        end
                    end
                else
                    print(spellName, "does not exist in the table: trackedSpells")
                end
            end
        end
    end
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