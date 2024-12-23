local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")

-- Factory function to create a new OmniBar instance
function CreateOmniBarWidget(barKey, settings)
    -- Create the main frame (OmniBar)
    local omniBarFrame = CreateFrame("Frame", barKey, UIParent)
    omniBarFrame:SetSize(1, 1)  -- Placeholder size

    local position = settings.position
    omniBarFrame:SetPoint(position.point, UIParent, position.relativePoint, position.x, position.y)
    omniBarFrame:SetFrameStrata("MEDIUM")
    omniBarFrame:SetMovable(true)
    omniBarFrame:SetClampedToScreen(true)
    omniBarFrame:SetDontSavePosition(true)

    -- Create the anchor frame
    local anchor = CreateFrame("Frame", "$parentAnchor", omniBarFrame)
    anchor:SetSize(settings.anchorWidth, 30)
    anchor:SetPoint("CENTER")
    anchor:EnableMouse(true)
    anchor:SetClampedToScreen(true)
    omniBarFrame.anchor = anchor
  
    -- Background texture for the anchor
    local background = anchor:CreateTexture("$parentBackground", "BACKGROUND")
    background:SetAllPoints()
    background:SetTexture(0, 0, 0, 0.3)
    omniBarFrame.background = background

    -- Text label for the anchor
    local text = anchor:CreateFontString("$parentText", "ARTWORK", "GameFontNormal")
    text:SetText(settings.name)
    text:SetPoint("CENTER")
    text:SetTextColor(1, 1, 0, 1)
    omniBarFrame.text = text

    -- Scripts for dragging the anchor
    OmniBar:MakeFrameDraggable(anchor, omniBarFrame)

    -- Create the icons container
    local iconsContainer = CreateFrame("Frame", "$parentIcons", omniBarFrame)
    iconsContainer:SetSize(1, 1)  -- Placeholder size
    iconsContainer:SetPoint("LEFT", anchor)
    iconsContainer:SetScale(settings.scale)

    -- Button template (action buttons for OmniBar)
    local function CreateOmniBarIcon(iconPath)
        local button = CreateFrame("Button", nil, iconsContainer)
        button:SetSize(36, 36)
        button:SetPoint("CENTER")

        local icon = button:CreateTexture("$parentIcon", "ARTWORK")
        icon:SetTexture(iconPath)
        icon:SetDrawLayer("ARTWORK", 2) -- put it above the Border
        icon:SetAllPoints(button) -- sets SetPoint and Size to match button:)
        icon:SetAlpha(1) -- sets SetPoint and Size to match button:)
        button.icon = icon

        
        if settings.showBorder then
			icon:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1)
	    else
		    icon:SetTexCoord(0.07, 0.9, 0.07, 0.9)
		end
        
    --[[  
        RENAME: To like FocusTexture, target Texure etc...

        local border = button:CreateTexture("$parentBorder", "OVERLAY")
        border:SetTexture("Interface\\AddOns\\OmniBar\\arts\\UI-ActionButton-Border.blp")
        border:SetDrawLayer("ARTWORK", 1) -- z-index for textures.
        border:SetPoint("CENTER", button, "CENTER", 0.7, 0.5) -- 0.9 also good
        border:SetSize(70, 70) -- small .blp image, need to be scaled to match button
        border:SetBlendMode("ADD") -- This makes the dark background in the image transperent
      -- border:SetVertexColor(0.639, 0.207, 0.933, 1) -- purple color, kinda cool
      --. border:SetTexCoord(0.2, 0.8, 0.2, 0.8)
        border:Hide()   
        button.border = border 
        ]]

        -- New Item animation
        local newItemGlow = button:CreateTexture("$parentNewItem", "OVERLAY")
        newItemGlow:SetTexture("Interface\\AddOns\\OmniBar\\arts\\Bags.blp")
        newItemGlow:SetTexCoord(0.542969, 0.695312, 0.164062, 0.316406) -- bags-blue-glow
        newItemGlow:SetAllPoints(button)
        newItemGlow:SetBlendMode("ADD")
        newItemGlow:SetAlpha(0)

        local newItemAnim = newItemGlow:CreateAnimationGroup()
        local phase1 = newItemAnim:CreateAnimation("Alpha")
        phase1:SetSmoothing("NONE")
        phase1:SetDuration(0)
        phase1:SetOrder(1)
        phase1:SetChange(1)

        local phase2 = newItemAnim:CreateAnimation("Alpha")
        phase2:SetSmoothing("NONE")
        phase2:SetDuration(1)
        phase2:SetOrder(2)
        phase2:SetChange(-0.4) 

        local phase3 = newItemAnim:CreateAnimation("Alpha")
        phase3:SetSmoothing("NONE")
        phase3:SetDuration(1)
        phase3:SetOrder(3)
        phase3:SetChange(1)

        local phase4 = newItemAnim:CreateAnimation("Alpha")
        phase4:SetSmoothing("NONE")
        phase4:SetDuration(1)
        phase4:SetOrder(4)
        phase4:SetChange(-1) 
     
        local flash = button:CreateTexture("$parentFlash", "OVERLAY")
        flash:SetTexture("Interface\\AddOns\\OmniBar\\arts\\Bags.blp")
        flash:SetTexCoord(0.00390625, 0.355469, 0.00390625, 0.355469) -- bags-glow-flash
        flash:SetAlpha(0)
        flash:SetBlendMode("ADD")
        flash:SetAllPoints(button)

        local flashAnim = flash:CreateAnimationGroup()
        local flashPhase1 = flashAnim:CreateAnimation("Alpha")
        flashPhase1:SetSmoothing("NONE") 
        flashPhase1:SetDuration(0) 
        flashPhase1:SetOrder(1) 
        flashPhase1:SetChange(1) 

        local flashPhase2 = flashAnim:CreateAnimation("Alpha")
        flashPhase2:SetSmoothing("OUT") 
        flashPhase2:SetDuration(1) 
        flashPhase2:SetOrder(2) 
        flashPhase2:SetChange(-1) 

        function button:PlayNewIconAnimation()
            flashAnim:Play()
            newItemAnim:Play()
        end

        function button:StopNewIconAnimation()
            if flashAnim:IsPlaying() then flashAnim:Stop() end
	        if newItemAnim:IsPlaying() then newItemAnim:Stop() end
        end

        newItemAnim:SetScript("OnFinished", function()
            print("ANIMATION DONE")
        end)

        local countdownFrame = CreateFrame("Frame", "$parentCountdownFrame", button)
        countdownFrame:SetAllPoints(button)
        countdownFrame:SetFrameLevel(7) 
        local countdownText = countdownFrame:CreateFontString("$parentCountdown", "OVERLAY", "GameFontNormalLarge")
        countdownText:SetPoint("CENTER", countdownFrame, "CENTER", 0, 0)
        countdownText:SetFont("Fonts\\FRIZQT__.TTF", 15)
        countdownText:SetText("") 
        countdownText:SetTextColor(1, 1, 1, 1) 
        button.countdownText = countdownText
    

        local cooldown = CreateFrame("Cooldown", "$parentCooldown", button, "CooldownFrameTemplate")
        cooldown:SetAllPoints(icon)
        cooldown:SetReverse(true)
        cooldown:SetFrameLevel(6) 
        button.cooldown = cooldown

        local timerFrame = CreateFrame("Frame")
        timerFrame:Hide()
        button.timerFrame = timerFrame

        -- add this in initializeBar?
        -- Scripts for cooldown finish and interaction
     --   Cooldown:SetScript("OnHide", OmniBar_CooldownFinish) -- Assumes OmniBar_CooldownFinish is defined

        return button
    end

    omniBarFrame.iconsContainer = iconsContainer
    omniBarFrame.CreateOmniBarIcon = CreateOmniBarIcon

    return omniBarFrame
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