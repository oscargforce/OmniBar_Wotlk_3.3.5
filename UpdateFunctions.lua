local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local addonName, addon = ...
local GetBuffNameFromTrinket = addon.GetBuffNameFromTrinket

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
        updateEvents = function() self:UpdateUnitEventTracking(barFrame, barSettings) end,
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

--[[ Updates the spell tracking for a specific bar
    @param barFrame - The UI frame for the bar
    @param barSettings - Saved variable for the bar eg self.profile.bars[barKey]
    
    Structure of trackedSpells:
    {
        [spellName] = {
            duration = number,
            icon = string,
            priority = number,
            className = string,
            spellId = number,
            race = string (optional),
            spec = boolean (optional),
            item = boolean (optional)
        }
    }
]]
function OmniBar:UpdateSpellTrackingForBar(barFrame, barSettings)
    local trackedSpells = barFrame.trackedSpells
    wipe(trackedSpells)
    
    local spellTable = addon.spellTable
    
    for className, spells in pairs(barSettings.cooldowns) do
        for spellName, spellConfig in pairs(spells) do
            if spellConfig.isTracking then
                local spellData = spellTable[className][spellName]

                if not spellData then  
                    print(spellName, "does not exist in the table: trackedSpells. Add it to the table then preform /relod")
                    return
                end

                spellName = GetBuffNameFromTrinket(spellName) -- if not trinket the func returns the orignal spellName

                if not trackedSpells[spellName] then
                    trackedSpells[spellName] = {
                        duration = spellData.duration,
                        icon = spellData.icon,
                        priority = spellConfig.priority or 1,
                        className = className,
                        spellId = spellData.spellId
                    }

                    if spellData.race then
                        trackedSpells[spellName].race = spellData.race
                    end
                    if spellData.spec then
                        trackedSpells[spellName].spec = spellData.spec
                    end
                    if spellData.item then
                        trackedSpells[spellName].item = spellData.item
                    end
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

function OmniBar:UpdateUnitEventTracking(barFrame, barSettings)
    local trackedUnit = barSettings.trackedUnit
    -- Unregister previous events
    barFrame:UnregisterEvent("ARENA_OPPONENT_UPDATE")
    barFrame:UnregisterEvent("PARTY_MEMBERS_CHANGED")
    barFrame:UnregisterEvent("UNIT_INVENTORY_CHANGED")
    barFrame:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    
    if trackedUnit:match("^arena[1-5]$") then
        barFrame:RegisterEvent("ARENA_OPPONENT_UPDATE")
    elseif trackedUnit:match("^party[1-4]$") then
        barFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
        barFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
    elseif trackedUnit == "target" then
        -- barFrame:RegisterEvent("")
    elseif trackedUnit == "focus" then
        -- barFrame:RegisterEvent("") 
    else
        -- all enemies, maybe not need anything?
    end

    -- Always register UNIT_SPELLCAST_SUCCEEDED
    barFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
end