local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")

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
    viewTable(barFrame)
    for i, button in ipairs(barFrame.icons) do
        print(#barFrame.icons)
        if barSettings.showBorder then
            button.icon:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1)
        else
            button.icon:SetTexCoord(0.07, 0.9, 0.07, 0.9) 
        end

    end
end