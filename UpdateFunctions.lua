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
        createIcons = function() self:CreateIconsToBar(barFrame, barSettings) end,
        border = function() self:UpdateBorder(barFrame, barSettings) end,
        arrangeIcons = function() self:ArrangeIcons(barFrame, barSettings) end,
        showUnusedIcons = function() self:UpdateShowUnusedIcons(barFrame, barSettings) end,
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
    local operationOrder = {"name", "scale", "resetIcons", "updateSpellTracking", "createIcons", "border"}
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
    print("Icons left in pool:", #self.iconPool)
end

function OmniBar:UpdateShowUnusedIcons(barFrame, barSettings)
    local showUnusedIcons = barSettings.showUnusedIcons

    if showUnusedIcons then
        -- not needed but good to have, will create dublicate if icons already exists
        wipe(barFrame.icons)
        print("Update BarFrame icons left:", #barFrame.icons)
        self:CreateIconsToBar(barFrame, barSettings)
        print("Update BarFrame icons left:", #barFrame.icons)
    else
        self:ResetIcons(barFrame) --back to pool
    end
    print("Icons left in pool:", #self.iconPool)
end

function OmniBar:UpdateSpellTrackingForBar(barFrame, barSettings)
    local trackedSpells = barFrame.trackedSpells
    wipe(trackedSpells)
    
    local spellTable = addon.spellTable
    
    for className, spells in pairs(barSettings.cooldowns) do
        for spellName, isTracking in pairs(spells) do
            if isTracking then
                local spellData = spellTable[className][spellName]
                if not spellData then print(spellName, "does not exist") end
                if not trackedSpells[spellName] then
                    trackedSpells[spellName] = {
                        duration = spellData.duration,
                        icon = spellData.icon, -- ??
                    }
                end
            end
        end
    end
end