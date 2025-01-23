local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local addonName, addon = ...
local MapTrinketNameToBuffName = addon.MapTrinketNameToBuffName

function OmniBar:CreateBar() 
    local barKey = self:GenerateUniqueKey()
    -- Initialize bar settings in the database and UI
    self:InitializeBar(barKey)
    -- Add the bar to options
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
    if next(barFrame.activeIcons) then
        barFrame.anchor:Hide()
    else
        barFrame.anchor:Show()
    end
end


function OmniBar:UpdateBar(barKey, specificUpdate)
    local barFrame = self.barFrames[barKey]
    local barSettings = self.db.profile.bars[barKey]

    -- Lookup table for update operations
    local updateOperations = {
        name = function() self:UpdateBarName(barFrame, barSettings) end,
        scale = function() self:UpdateScale(barFrame, barSettings) end,
        resetIcons = function() self:ResetIcons(barFrame) end,
        buildSpellTracking = function() self:BuildTrackedSpells(barFrame, barSettings) end,
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
    local operationOrder = {"name", "scale", "resetIcons", "buildSpellTracking", "setUpIcons","border"}
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
            spec = string (optional),
            item = boolean (optional)
        }
    }
]]
function OmniBar:BuildTrackedSpells(barFrame, barSettings)
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

                spellName = MapTrinketNameToBuffName(spellName) -- if not trinket the func returns the orignal spellName

                if not trackedSpells[spellName] then
                    trackedSpells[spellName] = {
                        duration = spellData.duration - 0.2, -- subtract 0.2 due to latencys,
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
        end
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