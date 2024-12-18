local function createTextLabel(text, underFrame, fontString, panel)
    local label = panel:CreateFontString(nil, "ARTWORK", fontString)
    label:SetPoint("TOPLEFT", underFrame, "BOTTOMLEFT", 0, -10)
    label:SetWidth(400)  -- Set a maximum width for the text
    label:SetWordWrap(true)  -- Enable word wrapping
    label:SetJustifyH("LEFT")  -- Align text to the left horizontally
    label:SetJustifyV("TOP")  -- Align text to the top vertically
    label:SetText(text)
    return label
end

 local tabs = { "OmniBar", "OmniBar2" }

local function createOptionsMenu()
    local panel = CreateFrame("Frame", "OmniBarOptionsPanel", InterfaceOptionsFramePanelContainer)
    panel.name = "OmniBar"
    InterfaceOptions_AddCategory(panel)

    CreateOmniBarsProfilesPanel()
    CreateOmniBarPanel(1)
    OnniBarLookTwoTest()

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("OmniBar")

    local versionLabel = createTextLabel("Version: 1.0.0", title, "GameFontHighlightSmall", panel)
    local authorLabel = createTextLabel("Author: Oscargforce", versionLabel, "GameFontHighlightSmall", panel)

    local testButton = CreateFrame("Button", "OmniBarOptionsTestButton", panel, "UIPanelButtonTemplate")
    testButton:SetSize(180, 30)
    testButton:SetPoint("BOTTOMLEFT", authorLabel, "BOTTOMLEFT", -10, -40)
    testButton:SetText("Test")
    testButton:GetFontString():SetPoint("CENTER") -- Ensure the text is properly positioned
    testButton:SetScript("OnClick", function(self, button, down) 
        print("Button", button, "down", down)
    end)

    local tabsContainer = createOmniBarOptionsTab(panel, testButton)
    tabsContainer.frame:SetPoint("TOPLEFT", testButton, "BOTTOMLEFT", 0, -10)
    tabsContainer.frame:SetHeight(295)
    tabsContainer.SetTabs({ "Bars", "Profiles" })

    -- Place createBarButton inside the tabsContainer's content
    local createBarButton = CreateFrame("Button", "OmniBarOptionsCreateBarButton", tabsContainer.content, "UIPanelButtonTemplate")
    local barTabContainer = createOmniBarOptionsTab(panel, createBarButton)
    createBarButton:SetSize(160, 30)
    createBarButton:SetPoint("TOPLEFT", tabsContainer.content, "TOPLEFT", 0, -10)
    createBarButton:SetText("Create Bar")
    createBarButton:GetFontString():SetPoint("CENTER")
    createBarButton:SetScript("OnClick", function(self, button, down)
        print("Create Bar button clicked")
        local lastItem = tabs[#tabs]
        local lastItemNumber = tonumber(lastItem:match("OmniBar(%d+)"))
        local a = "OmniBar".. lastItemNumber + 1
        print(a)
        table.insert(tabs, a)
        barTabContainer.SetTabs(tabs)
    end)

    -- Optional: Adjust barTabContainer placement (if needed later)
    barTabContainer.SetTabs(tabs)
    barTabContainer.frame:SetHeight(220)
    barTabContainer.frame:SetPoint("TOPLEFT", createBarButton, "BOTTOMLEFT", -10, -10)
end

local optionsInitFrame = CreateFrame("Frame")
optionsInitFrame:RegisterEvent("ADDON_LOADED")
optionsInitFrame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "OmniBar" then
        createOptionsMenu()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)