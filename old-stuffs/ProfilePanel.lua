local function createTextLabel(text, underFrame, fontString, panel)
    local label = panel:CreateFontString(nil, "ARTWORK", fontString)
    label:SetPoint("TOPLEFT", underFrame, "BOTTOMLEFT", 0, -10)
    label:SetWidth(400) 
    label:SetWordWrap(true)  
    label:SetJustifyH("LEFT")  
    label:SetJustifyV("TOP")  
    label:SetText(text)
    return label
end

function CreateOmniBarsProfilesPanel()
    local profilesPanel  = CreateFrame("Frame", "OmniBarOptionsProfilesPanel", InterfaceOptionsFramePanelContainer)
    profilesPanel.name = "Profiles"
    profilesPanel.parent = "OmniBar"
    InterfaceOptions_AddCategory(profilesPanel)

    local profilePanelTitle = profilesPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    profilePanelTitle:SetPoint("TOPLEFT", 16, -16)
    profilePanelTitle:SetText("OmniBar Profiles")
    local profilePanelTitleText = createTextLabel("Save your current settings into a profile. Which can be reused account wide among your other characters", profilePanelTitle, "GameFontHighlightSmall", profilesPanel)

    local profilePanelInput = CreateFrame("EditBox", "$parentInput", profilesPanel, "InputBoxTemplate")
    profilePanelInput:SetPoint("TOPLEFT", profilePanelTitle, "BOTTOMLEFT", 0, -40) 
    profilePanelInput:SetSize(200, 20) 
    profilePanelInput:SetAutoFocus(false) 
    profilePanelInput:SetMaxLetters(100) 

    local saveProfileButton = CreateFrame("Button", "$parentSaveButton", profilesPanel, "UIPanelButtonTemplate")
    saveProfileButton:SetPoint("LEFT", profilePanelInput, "RIGHT", 10, 0) 
    saveProfileButton:SetSize(100, 20) 
    saveProfileButton:SetText("Save")

    saveProfileButton:SetScript("OnClick", function()
        local inputText = profilePanelInput:GetText()
        print("Saved text: " .. inputText) 
    end)

    local dropdownLabel = createTextLabel("Select Profile", profilePanelInput, "GameFontNormalSmall", profilesPanel)
    local dropdown = CreateFrame("Frame", "$parentDropdown", profilesPanel, "UIDropDownMenuTemplate") 
    dropdownLabel:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 0, 5) 
    dropdown:SetPoint("TOPLEFT", profilePanelInput, "TOPLEFT", -20, -40)

    local function Dropdown_OnClick(self)
        UIDropDownMenu_SetSelectedID(dropdown, self:GetID())
        print("Selected option: " .. self:GetText())
    end
    local function Dropdown_Initialize(self, level)
        -- Option 1
        local info = UIDropDownMenu_CreateInfo()  -- Create a new menu item info
        info.text = "Option 1"
        info.value = 1
        info.func = Dropdown_OnClick
        info.checked = false  -- Ensure no pre-checking unless selected
        UIDropDownMenu_AddButton(info, level)
    
        -- Option 2
        info = UIDropDownMenu_CreateInfo()  -- Create a new menu item info
        info.text = "Option 2"
        info.value = 2
        info.func = Dropdown_OnClick
        info.checked = false
        UIDropDownMenu_AddButton(info, level)
    
        -- Option 3
        info = UIDropDownMenu_CreateInfo()  -- Create a new menu item info
        info.text = "Option 3"
        info.value = 3
        info.func = Dropdown_OnClick
        info.checked = false
        UIDropDownMenu_AddButton(info, level)
    end
    UIDropDownMenu_Initialize(dropdown, Dropdown_Initialize)
    UIDropDownMenu_SetWidth(dropdown, 150)
    UIDropDownMenu_SetButtonWidth(dropdown, 124)
    UIDropDownMenu_SetText(dropdown, "Select an Option")

end