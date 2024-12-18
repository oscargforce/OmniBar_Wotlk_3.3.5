--[[

    TODO:
        - Add a delete button
        - Add some space beween frame A and B
        - Maybe add some border between Frame A and B

]]
local classes = {"Death Knight", "Druid", "Hunter", "Mage", "Paladin", "Priest", "Rogue", "Shaman", "Warlock", "Warrior"}

local PaneBackdrop = {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 5, bottom = 3 }
}

local spellTableMock = {
    ["Death Knight"] = {
        ["Mind Freeze"] = { cooldown = 15, checked = true, spellId = 47528 },
        ["Anti-Magic Shell"] = { cooldown = 45, checked = true, spellId = 48707 },
        ["Death Grip"] = { cooldown = 25, checked = true, spellId = 49576 },
        ["Icebound Fortitude"] = { cooldown = 180, checked = true, spellId = 48792 }
    },
    ["Druid"] = {
        ["Barkskin"] = { cooldown = 30, checked = true, spellId = 22812 },
        ["Nature's Grasp"] = { cooldown = 60, checked = true, spellId = 16689 },
        ["Rebirth"] = { cooldown = 600, checked = true, spellId = 20484 },
        ["Entangling Roots"] = { cooldown = 30, checked = true, spellId = 339 }
    },
    ["Hunter"] = {
        ["Feign Death"] = { cooldown = 30, checked = true, spellId = 5384 },
        ["Deterrence"] = { cooldown = 180, checked = true, spellId = 19263 },
        ["Tranquilizing Shot"] = { cooldown = 10, checked = true, spellId = 19801 },
        ["Kill Command"] = { cooldown = 6, checked = true, spellId = 1234}
    }
}

local marginBottomLabels = 20

local function CreateInlineCheckbox(parent, labelText, x, y, spellData)
    local checkbox = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", x, y)
    checkbox:SetSize(24, 24)

    local label = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint("LEFT", checkbox, "RIGHT", 5, 0) -- Position label to the right of the checkbox
    label:SetText(labelText)

    checkbox:SetScript("OnClick", function(self) 
        local isChecked = self:GetChecked()
        print(labelText .. (checked and " is checked!" or " is unchecked!"))
        spellData.checked = isChecked
    end)

    return checkbox
end


function CreateOmniBarPanel(index)
    local panel = CreateFrame("Frame", "OmniBarOptionsBarPanel" .. index, InterfaceOptionsFramePanelContainer)
    panel.name = "OmniBar" .. index
    panel.parent = "OmniBar"
    InterfaceOptions_AddCategory(panel)

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("OmniBar"..index.." Settings")

    local deleteButton = CreateFrame("Button", "$parentDeleteButton", panel, "UIPanelButtonTemplate")
    deleteButton:SetSize(160, 30)
    deleteButton:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -10, -8)
    deleteButton:SetText("Delete Bar")
    deleteButton:GetFontString():SetPoint("CENTER")
    deleteButton:SetScript("OnClick", function(self, button, down)
        print("Delete Button Clicked!")
    end)


    local contentContainer = CreateFrame("Frame", "$parentContentContainer", panel)
    contentContainer:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, -45)
    contentContainer:SetSize(412, 367) 

    
    local border = CreateFrame("Frame", nil, contentContainer)
    border:SetPoint("TOPLEFT", contentContainer, "TOPLEFT", 1, 0)
    border:SetPoint("BOTTOMRIGHT", contentContainer, "BOTTOMRIGHT", -1, 0)
    border:SetBackdrop(PaneBackdrop)
    border:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
    border:SetBackdropBorderColor(0.4, 0.4, 0.4)


    local classContainerFrame = CreateFrame("Frame", "$parentClassContainer", contentContainer)
    classContainerFrame:SetPoint("TOPLEFT", contentContainer, "TOPLEFT", 10, -5)
    classContainerFrame:SetSize(100, 300)
    local classContainerFrameText = classContainerFrame:CreateFontString(nil, "ARTWORK", "GameFontGreen")
    classContainerFrameText:SetText("Classes:")
    classContainerFrameText:SetPoint("TOPLEFT", 10, 0)

     -- Add a border between the Classes and the Spell checkboxes
    local classContainerBorder = CreateFrame("Frame", nil, classContainerFrame)
    classContainerBorder:SetPoint("TOPRIGHT", classContainerFrame, "TOPRIGHT", 0, 0) -- Attach to FrameA's right edge
    classContainerBorder:SetPoint("BOTTOMRIGHT", classContainerFrame, "BOTTOMRIGHT", 0, 0) -- Extend to bottom edge
    classContainerBorder:SetWidth(2) -- Width of the border

    -- Set the border color and texture
    classContainerBorder.texture = classContainerBorder:CreateTexture(nil, "BACKGROUND")
    classContainerBorder.texture:SetAllPoints(classContainerBorder)
    classContainerBorder.texture:SetTexture(0.5, 0.5, 0.5, 1) -- RGBA (gray, fully opaque)

    local frameBScroll = CreateFrame("ScrollFrame", "$parentFrameBScroll", contentContainer, "UIPanelScrollFrameTemplate")
    frameBScroll:SetPoint("TOPLEFT", classContainerFrame, "TOPRIGHT", 0, 0)
    frameBScroll:SetSize(312, 367)  -- FrameB takes the remaining width (300px here)

    local frameB = CreateFrame("Frame", "FrameB", frameBScroll)
    frameB:SetSize(200, 800)  -- Height will be dynamic
    frameB:SetPoint("TOPLEFT")

    local labelB = frameB:CreateFontString(nil, "ARTWORK", "GameFontGreen")
    labelB:SetPoint("TOPLEFT", 10, 0)
    labelB:SetText("Spells:")

    -- Set the scroll child for the scroll frame
    frameBScroll:SetScrollChild(frameB)

    -- Function to clear and populate frameB
    local function UpdateFrameB(className)
        -- Clear previous content
        for _, child in ipairs({ frameB:GetChildren() }) do
            child:Hide()
            child:ClearAllPoints()
            child:SetParent(nil)
            child = nil -- Ensure Lua garbage collects the child
        end

        -- Populate with spell checkboxes
        local spells = spellTableMock[className]
        if not spells then return end

        local yOffset = -marginBottomLabels
        for spellName, spellData in pairs(spells) do
            local checkbox = CreateInlineCheckbox(frameB, spellName, 10, yOffset, spellData)
            if spellData.checked then checkbox:SetChecked(true) end
            yOffset = yOffset - 30
        end
        

        -- Adjust frameB height based on the number of spells
        if spells then
            frameB:SetHeight(#spells * 30 + 20)
        else
            frameB:SetHeight(200) -- Default height if no spells
        end
    end
    
    for i, className in ipairs(classes) do
        -- Create a button for each class
        local classButton = CreateFrame("Button", "$parentClassItem" .. className, classContainerFrame)
        classButton:SetSize(80, 20)  -- Size of the button
        local yOffset = -(i - 1) * 30 - marginBottomLabels  
        classButton:SetPoint("TOPLEFT", classContainerFrame, "TOPLEFT", 0, yOffset)  -- Position
    
        -- Remove the default button background and border
        classButton:SetNormalFontObject("GameFontNormal")
        classButton:SetHighlightFontObject("GameFontHighlight")
        classButton:SetDisabledFontObject("GameFontDisable")
    
        -- Set button text (class name)
        classButton:SetText(className)
    
        classButton:SetScript("OnClick", function(self, button)
            print(className .. " button clicked!")
            UpdateFrameB(className)
        end)
    
        -- Optional: Set cursor to indicate it's clickable
        classButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
            GameTooltip:SetText("Click to select " .. className)
            GameTooltip:Show()
        end)
    
        classButton:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
    end
    
    return panel
end

--[[

    FrameA = classContainerFrame
    FrameB = SpellsContent
               Y             X
+----------------------------+   
|  FrameA      |    FrameB   |  
|              |             |
|  classes     |    spells   |
|              |             |
|              |             |
|              |             |
+----------------------------+

]]
