local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")

local function SortIcons(barFrame, showUnusedIcons)
    if not showUnusedIcons then
        -- Sort icons based on endTime (or default to math.huge)
        table.sort(barFrame.icons, function(a, b)
            local aEndTime = a.endTime or math.huge
            local bEndTime = b.endTime or math.huge 
            return aEndTime < bEndTime
        end) 
    else
        table.sort(barFrame.icons, function (a, b) 
            -- Sort alphabetically by className
            if a.className ~= b.className then
                return a.className < b.className 
            end

            -- Sort by priority within the same class
            if a.priority == b.priority then
                return a.spellId < b.spellId
            end
            return a.priority > b.priority    
        end)
    end 
end

local BASE_ICON_SIZE = 36
function OmniBar:ArrangeIcons(barFrame, barSettings, skipSort)
    local maxIconsPerRow = barSettings.maxIconsPerRow
    local maxIconsTotal = barSettings.maxIconsTotal
    local margin = barSettings.margin

    local iconsPerRow, rows = 0, 1
    local growDirection = barSettings.isRowGrowingUpwards and 1 or -1 
    local numActive = #barFrame.icons

    if not skipSort then 
        SortIcons(barFrame, barSettings.showUnusedIcons) 
    end

     -- Remove excess icons if necessary
    if numActive > maxIconsTotal then
        local excessIcons = numActive - maxIconsTotal
        for i = 1, excessIcons do
            local icon = barFrame.icons[#barFrame.icons] 
            barFrame.icons[#barFrame.icons] = nil
            self:ReturnIconToPool(icon)
        end
    end 

    numActive = #barFrame.icons
    local columns = maxIconsPerRow < numActive and maxIconsPerRow or numActive

    for i, icon in ipairs(barFrame.icons) do
        icon:ClearAllPoints()
    
        if i > 1 then
            iconsPerRow = iconsPerRow + 1
            if iconsPerRow >= columns then
                icon:SetPoint("CENTER", barFrame.iconsContainer, "CENTER", 
                            (-BASE_ICON_SIZE - margin) * (columns - 1) / 2, 
                            (BASE_ICON_SIZE + margin) * rows * growDirection)
                iconsPerRow = 0
                rows = rows + 1
            else
                icon:SetPoint("TOPLEFT", barFrame.icons[i-1], "TOPRIGHT", margin, 0)
                -- icon:SetPoint("TOPRIGHT", barFrame.icons[i-1], "TOPLEFT", -1 * margin, 0) Aling right, but not working with margin.
            end
        else
            icon:SetPoint("CENTER", barFrame.iconsContainer, "CENTER", 
                            (-BASE_ICON_SIZE - margin) * (columns - 1) / 2, 0)
        end
    end
end