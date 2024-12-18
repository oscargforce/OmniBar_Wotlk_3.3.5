
local classes = {"Death Knight", "Druid", "Hunter", "Mage", "Paladin", "Priest", "Rogue", "Shaman", "Warlock", "Warrior"}

local PaneBackdrop  = {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 5, bottom = 3 }
}

local currentlySelectedButton = nil

local function createTitleButton(titleText, parent, yOffset, isSubTitle)
    -- Create the button
    local iconOptionsButton = CreateFrame("Button", nil, parent)
    local normalFont = isSubTitle and GameFontHighlightSmall or GameFontNormal -- Font for normal state
    local highlightFont = isSubTitle and GameFontHighlightSmall or GameFontHighlight -- Font for highlighted state
    iconOptionsButton:SetNormalFontObject(normalFont)
    iconOptionsButton:SetHighlightFontObject(highlightFont)
    iconOptionsButton:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, yOffset)
    iconOptionsButton:SetSize(187, 20)
    iconOptionsButton:SetText(titleText)

    -- Align the text to the left
    local fontString = iconOptionsButton:GetFontString()
    fontString:ClearAllPoints()
    fontString:SetPoint("LEFT", iconOptionsButton, "LEFT", 5, 0) -- Align 5px from the left
    fontString:SetJustifyH("LEFT") -- Set horizontal justification to left

    -- Create a highlight texture (invisible initially)
    local highlightTexture = iconOptionsButton:CreateTexture(nil, "BACKGROUND")
    highlightTexture:SetAllPoints(iconOptionsButton)
    highlightTexture:SetTexture(0, 0.5, 1, 0.3) -- Light transparent blue color
    highlightTexture:Hide() -- Start hidden

    -- Button click handler
    iconOptionsButton:SetScript("OnClick", function(self)
        -- Deselect the currently selected button
        if currentlySelectedButton and currentlySelectedButton ~= self then
            currentlySelectedButton:GetHighlightTexture():Hide() -- Remove highlight
            currentlySelectedButton:SetNormalFontObject(
                currentlySelectedButton.isSubTitle and GameFontHighlightSmall or GameFontNormal
            ) -- Reset font based on subtitle or normal
        end

        -- Highlight the clicked button
        if highlightTexture:IsShown() then
            -- Deselect this button
            highlightTexture:Hide()
            iconOptionsButton:SetNormalFontObject(normalFont)
            currentlySelectedButton = nil
        else
            -- Select this button
            highlightTexture:Show()
            iconOptionsButton:SetNormalFontObject(highlightFont)
            currentlySelectedButton = self
        end
    end)

    -- Store additional properties for better management
    iconOptionsButton.GetHighlightTexture = function()
        return highlightTexture
    end
    iconOptionsButton.isSubTitle = isSubTitle

    return iconOptionsButton
end

local function createToggleButton(parent, frameToToggle)
    local toggleButton = CreateFrame("Button", "fffe", parent, "UIPanelButtonTemplate")
    toggleButton:SetPoint("CENTER", parent, "RIGHT", 0, 0)
    toggleButton:SetSize(13, 13)
    local plusText = toggleButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    plusText:SetPoint("CENTER")
    plusText:SetText("+")

    local isCollapsed = false
    toggleButton:SetScript("OnClick", function(self) 
        if isCollapsed then
            -- Collapse
            frameToToggle:Hide()
            plusText:SetText("+")
        else
            -- Expand
            frameToToggle:Show()
            plusText:SetText("-")
        end
        isCollapsed = not isCollapsed  -- Toggle the state
    end)
end

local function createTitleAndSubTitles(name, parent, y)
       -- Create the Icon Options button
       local omniBar = createTitleButton(name, parent, y)
 
       -- Create the Party Icons frame (hidden by default)
       local omniBarSubTitles = CreateFrame("Frame", nil, parent)
       omniBarSubTitles:SetPoint("TOPLEFT", omniBar, "BOTTOMLEFT", 5, 0)
       omniBarSubTitles:SetSize(200, 300)
       omniBarSubTitles:Hide()  -- Initially hidden
   
       local yOffset = -5
       for i, className in ipairs(classes) do
           createTitleButton(className, omniBarSubTitles, yOffset, true)
           yOffset = yOffset - 20
       end
       
       createToggleButton(omniBar, omniBarSubTitles)

       return omniBarSubTitles
end


function OnniBarLookTwoTest()
    local panel  = CreateFrame("Frame", "OmniBarOptionsTESTPANEL", InterfaceOptionsFramePanelContainer)
    panel.name = "LookTwo"
    panel.parent = "OmniBar"
    InterfaceOptions_AddCategory(panel)

    local contentContainer = CreateFrame("Frame", "$parentContentContainer", panel)
    contentContainer:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, -45)
    contentContainer:SetSize(412, 367) 

    local border = CreateFrame("Frame", nil, contentContainer)
    border:SetPoint("TOPLEFT", contentContainer, "TOPLEFT", 1, 0)
    border:SetPoint("BOTTOMRIGHT", contentContainer, "BOTTOMRIGHT", -1, 0)
    border:SetBackdrop(PaneBackdrop)
    border:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
    border:SetBackdropBorderColor(0.4, 0.4, 0.4)

    local frameA = CreateFrame("Frame", "MainFrame", contentContainer)
    frameA:SetPoint("TOPLEFT", contentContainer, "TOPLEFT", 10, -5)
    frameA:SetSize(200, 300)
    
    -- Simple border for the container frame
    frameA:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    frameA:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
    frameA:SetBackdropBorderColor(0.4, 0.4, 0.4)

    -- Add a title to the panel
    local title = frameA:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 10, -10)
    title:SetText("Settings")

    local omnibar = createTitleAndSubTitles("OmniBar", frameA, -30)
    createTitleAndSubTitles("KickBar", omnibar, -20)

    local frameBScroll = CreateFrame("ScrollFrame", "$parentFrameBScroll", contentContainer, "UIPanelScrollFrameTemplate")
    frameBScroll:SetPoint("TOPLEFT", frameA, "TOPRIGHT", 0, 0)
    frameBScroll:SetSize(312, 367)  -- FrameB takes the remaining width (300px here)

    local frameB = CreateFrame("Frame", "FrameB", frameBScroll)
    frameB:SetSize(200, 800)  -- Height will be dynamic
    frameB:SetPoint("TOPLEFT")

    local labelB = frameB:CreateFontString(nil, "ARTWORK", "GameFontGreen")
    labelB:SetPoint("TOPLEFT", 10, 0)
    labelB:SetText("Spells:")

    -- Set the scroll child for the scroll frame
    frameBScroll:SetScrollChild(frameB)

end