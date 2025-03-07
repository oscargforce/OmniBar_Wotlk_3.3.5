local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")

local BASE_ICON_SIZE = 36

local function SortIconsByPriority(barFrame)
    table.sort(barFrame.icons, function(a, b)
        -- First sort alphabetically by className
        if a.className ~= b.className then
            return a.className < b.className 
        end
        
        -- Then by priority
        if a.priority ~= b.priority then
            return a.priority > b.priority
        end
        
        -- Finally by spell ID for consistent ordering
        return a.spellId < b.spellId
    end)
end

local function SortIconsByRemainingTime(barFrame)
    table.sort(barFrame.icons, function(a, b)
        local aEndTime = a.endTime or math.huge
        local bEndTime = b.endTime or math.huge 
        return aEndTime < bEndTime
    end)
end

local function SortIconsByTimeAdded(barFrame)
    table.sort(barFrame.icons, function(a, b)
        if a.startTime == b.startTime then
            return a.spellId < b.spellId
        end

        return a.startTime < b.startTime
    end)
end

local function SortIcons(barFrame, showUnusedIcons, iconSortingMethod)
    if showUnusedIcons then
        SortIconsByPriority(barFrame)
    elseif iconSortingMethod == "remainingTime" then
        SortIconsByRemainingTime(barFrame)
    elseif iconSortingMethod == "timeAdded" then
        SortIconsByTimeAdded(barFrame)
    end
end

local function CenteredGridLayout(barFrame, barSettings, skipSort)
    local maxIconsPerRow = barSettings.maxIconsPerRow
    local maxIconsTotal = barSettings.maxIconsTotal
    local margin = barSettings.margin
    local iconMargin = barSettings.customCountdownText and barSettings.countdownTextXOffset ~= 0 and math.abs(barSettings.countdownTextXOffset) + 2 or margin
    
    local iconsPerRow, rows = 0, 1
    local growDirection = barSettings.isRowGrowingUpwards and 1 or -1 
    local numActive = #barFrame.icons

    if not skipSort then 
        SortIcons(barFrame, barSettings.showUnusedIcons, barSettings.iconSortingMethod) 
    end

    -- Remove excess icons if necessary
    if numActive > maxIconsTotal then
        local excessIcons = numActive - maxIconsTotal
        for i = 1, excessIcons do
            local icon = barFrame.icons[#barFrame.icons] 
            barFrame.icons[#barFrame.icons] = nil
            OmniBar:ReturnIconToPool(icon)
        end
    end 

    numActive = #barFrame.icons
    local columns = maxIconsPerRow < numActive and maxIconsPerRow or numActive

    for i, icon in ipairs(barFrame.icons) do
        icon:ClearAllPoints()
    
        if i > 1 then
            iconsPerRow = iconsPerRow + 1
            if iconsPerRow >= columns then
                -- For first icon in each row, use margin for vertical spacing
                -- and iconMargin for horizontal centering
                icon:SetPoint("CENTER", barFrame.iconsContainer, "CENTER", 
                            (-BASE_ICON_SIZE - iconMargin) * (columns - 1) / 2, 
                            (BASE_ICON_SIZE + margin) * rows * growDirection)
                iconsPerRow = 0
                rows = rows + 1
            else
                -- For icons within a row, use iconMargin for spacing
                icon:SetPoint("TOPLEFT", barFrame.icons[i-1], "TOPRIGHT", iconMargin, 0)
            end
        else
            -- First icon overall - use iconMargin for horizontal centering
            icon:SetPoint("CENTER", barFrame.iconsContainer, "CENTER", 
                            (-BASE_ICON_SIZE - iconMargin) * (columns - 1) / 2, 0)
        end
    end
end

local function DirectionalFlowLayout(barFrame, barSettings, skipSort)
    local maxIconsPerRow = barSettings.maxIconsPerRow
    local isRowGrowingUpwards = barSettings.isRowGrowingUpwards
    local maxIconsTotal = barSettings.maxIconsTotal
    local margin = barSettings.margin
    local iconMargin = barSettings.customCountdownText and barSettings.countdownTextXOffset ~= 0 and math.abs(barSettings.countdownTextXOffset) + 2 or margin
    local alignment = barSettings.iconAlignment

    -- Variables to track positioning
    local xOffset = 0
    local yOffset = 0
    local rowIndex = 0  
    local iconCount = 0 
    local padding = BASE_ICON_SIZE 

    if not skipSort then 
        SortIcons(barFrame, barSettings.showUnusedIcons, barSettings.iconSortingMethod) 
    end

    for i, icon in ipairs(barFrame.icons) do
        if icon:IsShown() then

            if iconCount >= maxIconsTotal then 
                OmniBar:ReturnIconToPool(icon)
                barFrame.icons[i] = nil  -- Remove reference from the table
            end

            -- Position the icon
            icon:ClearAllPoints()
            icon:SetPoint(alignment, barFrame.iconsContainer, alignment, xOffset, yOffset)

            -- Update xOffset for the next icon in the row
            iconCount = iconCount + 1
            rowIndex = rowIndex + 1

            if alignment == "LEFT" then 
                xOffset = -rowIndex * (padding + iconMargin)
            else
                xOffset = rowIndex * (padding + iconMargin) 
            end

            -- Check if we reached the max icons per row
            if rowIndex >= maxIconsPerRow then
                rowIndex = 0
                xOffset = 0  -- Reset horizontal position

                -- Adjust yOffset to move to the next row
                if isRowGrowingUpwards then
                    yOffset = yOffset + (padding + margin)  -- Move up
                else
                    yOffset = yOffset - (padding + margin)  -- Move down
                end
            end
        end
    end
end

function OmniBar:ArrangeIcons(barFrame, barSettings, skipSort)
    if barSettings.iconAlignment == "CENTER" then
        CenteredGridLayout(barFrame, barSettings, skipSort)
    else
        DirectionalFlowLayout(barFrame, barSettings, skipSort)
    end
end
