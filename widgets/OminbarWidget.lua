local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")

-- Factory function to create a new OmniBar instance
function CreateOmniBarWidget(barKey, settings)
    -- Create the main frame (OmniBar)
    local OmniBarFrame = CreateFrame("Frame", barKey, UIParent)
    OmniBarFrame:SetSize(1, 1)  -- Placeholder size

    local position = settings.position
    OmniBarFrame:SetPoint(position.point, UIParent, position.relativePoint, position.x, position.y)
    OmniBarFrame:SetFrameStrata("MEDIUM")
    OmniBarFrame:SetMovable(true)
    OmniBarFrame:SetClampedToScreen(true)
    OmniBarFrame:SetDontSavePosition(true)

    -- Create the anchor frame
    local Anchor = CreateFrame("Frame", "$parentAnchor", OmniBarFrame)
    Anchor:SetSize(settings.anchorWidth, 30)
    Anchor:SetPoint("CENTER")
    Anchor:EnableMouse(true)
    Anchor:SetClampedToScreen(true)
    Anchor:SetScale(settings.scale)
    OmniBarFrame.anchor = Anchor

    -- Background texture for the anchor
    local Background = Anchor:CreateTexture("$parentBackground", "BACKGROUND")
    Background:SetAllPoints()
    Background:SetTexture(0, 0, 0, 0.3)
    OmniBarFrame.background = Background

    -- Text label for the anchor
    local Text = Anchor:CreateFontString("$parentText", "ARTWORK", "GameFontNormal")
    Text:SetText(settings.name)
    Text:SetPoint("CENTER")
    Text:SetTextColor(1, 1, 0, 1)
    OmniBarFrame.text = Text

    -- Scripts for dragging the anchor
    OmniBar:MakeFrameDraggable(Anchor, OmniBarFrame)

    -- Create the icons container
    local IconsContainer = CreateFrame("Frame", "$parentIcons", Anchor)
    IconsContainer:SetSize(1, 1)  -- Placeholder size
    IconsContainer:SetPoint("LEFT", Anchor)

    -- Button template (action buttons for OmniBar)
    local function CreateOmniBarIcon(iconPath)
        local Button = CreateFrame("Button", nil, IconsContainer)
        Button:SetSize(36, 36)
        Button:SetPoint("CENTER")

        local Border = Button:CreateTexture("$parentBorder", "OVERLAY")
        Border:SetTexture("Interface\\AddOns\\OmniBar\\arts\\UI-ActionButton-Border.blp")
        Border:SetDrawLayer("ARTWORK", 1) -- z-index for textures.
        Border:SetPoint("CENTER", Button, "CENTER", 0.7, 0.5) -- 0.9 also good
        Border:SetSize(70, 70) -- small .blp image, need to be scaled to match button
        Border:SetBlendMode("ADD") -- This makes the dark background in the image transperent
      -- Border:SetVertexColor(0.639, 0.207, 0.933, 1) -- purple color, kinda cool
      --. Border:SetTexCoord(0.2, 0.8, 0.2, 0.8)
        Border:Hide()   
        Button.border = Border

        local CountdownFrame = CreateFrame("Frame", "$parentCountdown", Button, "BackdropTemplate")
        CountdownFrame:SetAllPoints(Button)
        CountdownFrame:SetFrameLevel(7) 
        local CountdownText = CountdownFrame:CreateFontString("$parentCountdown", "OVERLAY", "GameFontNormalLarge")
        CountdownText:SetPoint("CENTER", CountdownFrame, "CENTER", 0, 0)
        CountdownText:SetFont("Fonts\\FRIZQT__.TTF", 15)
        CountdownText:SetText("") 
        CountdownText:SetTextColor(1, 1, 1, 1) 
        Button.countdownText = CountdownText
       
        local Icon = Button:CreateTexture("$parentIcon", "ARTWORK")
        Icon:SetTexture(iconPath)
        Icon:SetDrawLayer("ARTWORK", 2) -- put it above the Border
        Icon:SetAllPoints(Button) -- sets SetPoint and Size to match button:)
        Button.icon = Icon
    
        if settings.showBorder then
			Icon:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1)
	    else
		    Icon:SetTexCoord(0.07, 0.9, 0.07, 0.9)
		end
        
        local Cooldown = CreateFrame("Cooldown", "$parentCooldown", Button, "CooldownFrameTemplate")
        Cooldown:SetAllPoints(Icon)
        Cooldown:SetReverse(true)
        Cooldown:SetFrameLevel(6) 
        Button.cooldown = Cooldown

        local TimerFrame = CreateFrame("Frame")
        TimerFrame:Hide()
        Button.timerFrame = TimerFrame

        -- add this in initializeBar?
        -- Scripts for cooldown finish and interaction
     --   Cooldown:SetScript("OnHide", OmniBar_CooldownFinish) -- Assumes OmniBar_CooldownFinish is defined

        return Button
    end

    OmniBarFrame.iconsContainer = IconsContainer
    OmniBarFrame.CreateOmniBarIcon = CreateOmniBarIcon

    return OmniBarFrame
end

 --[[ EXAMPLE WHAT THE TABLE BAR1 TABLE WOULD LOOK LIKE

self.barFrames = {
 ["OmniBar1"] = {
    key = "OmniBar1",
    CreateOmniBarIcon = function:1234,
    trackedCooldowns = {
        ["Mind Freeze"] = {
            duration = 120,
            icon = path,
        },
    },
    activeCooldowns = {
        ["Mind Freeze"] = { endTime = 140 }
        ["Berserking"] = { endTime = 140 }
    }, 
    icons = {
        [1] = {
            icon = {
                [0] = userdata: 0xE7AF150,
            },
            border = {
                [0] = userdata: 0xE7AF150,
            },
            cooldown = {
                [0] = userdata: 0xDE2FDAC,
            },
             countdownText = {
                 [0] = userdata: 0xD865A98,   
            },
        },
    },
    anchor = {
        [0] = userdata: 0xE5994B0,
    },
    iconsContainer = {
        [0] = userdata: 0xE5994B0,
    },
    background = {
        [0] = userdata: 0xE7A91C5,
    },
    text = {
        [0] = userdata: 0xD865A98,
        [1] = userdata: 0xE5977FC,
    },
}
}

]]