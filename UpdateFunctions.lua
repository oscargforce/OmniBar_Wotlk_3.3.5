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
        updateCooldowns = function() self:UpdateCooldownTrackingForBar(barFrame, barSettings) end,
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
    local operationOrder = {"name", "scale", "resetIcons", "updateCooldowns", "createIcons", "border"}
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
    barFrame.anchor:SetScale(barSettings.scale)
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
        barFrame.iconsContainer:Show()  -- Show the entire container
    else
        barFrame.iconsContainer:Hide()  -- Hide the entire container
    end
end

-- MAYBE NOT STORE THE ICON PATH IN THE FRAME? CANT SEE A USE CASE FOR IT. UPDATE CREATEICONS TO LOOP OVER ADDONS.COOLDOWNSTABLE ISNTEAD
function OmniBar:UpdateCooldownTrackingForBar(barFrame, barSettings)
    local trackedCooldowns = barFrame.trackedCooldowns
    wipe(trackedCooldowns)
    
    local cooldownsTable = addon.cooldownsTable
    
    for className, cooldowns in pairs(barSettings.cooldowns) do
        for cooldownName, isTracking in pairs(cooldowns) do
            if isTracking then
                local cooldownData = cooldownsTable[className][cooldownName]
                
                if not trackedCooldowns[cooldownName] then
                    trackedCooldowns[cooldownName] = {
                        duration = cooldownData.duration,
                        icon = cooldownData.icon, -- ??
                    }
                end
            end
        end
    end
end