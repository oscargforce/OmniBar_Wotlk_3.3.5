local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")

-- Factory function to create a new OmniBar instance
function CreateOmniBarWidget(barKey, barSettings)
    -- Create the main frame (OmniBar)
    local omniBarFrame = CreateFrame("Frame", barKey, UIParent)
    omniBarFrame:SetSize(1, 1)  -- Placeholder size
    
    local position = barSettings.position
    omniBarFrame:SetPoint(position.point, UIParent, position.relativePoint, position.x, position.y)
    omniBarFrame:SetFrameStrata("MEDIUM")
    omniBarFrame:SetMovable(true)
    omniBarFrame:SetClampedToScreen(true)
    omniBarFrame:SetDontSavePosition(true)

    -- Create the anchor frame
    local anchor = CreateFrame("Frame", "$parentAnchor", omniBarFrame)
    anchor:SetSize(barSettings.anchorWidth, 30)
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
    text:SetText(barSettings.name)
    text:SetPoint("CENTER")
    text:SetTextColor(1, 1, 0, 1)
    omniBarFrame.text = text

    -- Scripts for dragging the anchor
    OmniBar:MakeFrameDraggable(anchor, omniBarFrame)

    -- Create the icons container
    local iconsContainer = CreateFrame("Frame", "$parentIcons", omniBarFrame)
    iconsContainer:SetSize(1, 1)  -- Placeholder size
    iconsContainer:SetPoint("CENTER", anchor)
    iconsContainer:SetScale(barSettings.scale)

    -- Button template (action buttons for OmniBar)
    local function CreateOmniBarIcon(iconPath)
        local button = CreateFrame("Button", nil, iconsContainer)
        button:SetSize(36, 36)
        button:SetPoint("CENTER")

        local icon = button:CreateTexture("$parentIcon", "ARTWORK")
        icon:SetTexture(iconPath)
        icon:SetDrawLayer("ARTWORK", 2) -- put it above the Border
        icon:SetAllPoints(button)
        icon:SetAlpha(1)
        button.icon = icon
       
        if barSettings.showBorder then
			icon:SetTexCoord(0, 0, 0, 1, 1, 0, 1, 1)
	    else
		    icon:SetTexCoord(0.07, 0.9, 0.07, 0.9)
		end

        local countdownFrame = CreateFrame("Frame", "$parentCountdownFrame", button)
        countdownFrame:SetAllPoints(button)
        countdownFrame:SetFrameLevel(7) 
        local countdownText = countdownFrame:CreateFontString("$parentCountdown", "OVERLAY", "GameFontNormalLarge")
        countdownText:SetPoint("CENTER", countdownFrame, "CENTER", 0, 0)
        countdownText:SetFont(OmniBar.db.profile.fontStyle, OmniBar.db.profile.fontSize)
        countdownText:SetText("") 
        countdownText:SetTextColor(1, 1, 1, 1) 
        button.countdownFrame = countdownFrame
        button.countdownText = countdownText

        local cooldown = CreateFrame("Cooldown", "$parentCooldown", button, "CooldownFrameTemplate")
        cooldown:SetAllPoints(icon)
        cooldown:SetReverse(true)
        cooldown:SetFrameLevel(6) 
        button.cooldown = cooldown

        local timerFrame = CreateFrame("Frame")
        timerFrame:Hide()
        button.timerFrame = timerFrame
       
        local targetHighlight = button:CreateTexture("$parentTargetHighlight", "OVERLAY")
        targetHighlight:SetTexture("Interface\\AddOns\\OmniBar\\arts\\textures.blp")
        targetHighlight:SetTexCoord(0.52343750, 0.97656250, 0.38476563, 0.49609375)
        targetHighlight:SetSize(72, 72)
        targetHighlight:SetPoint("CENTER", button, "CENTER")
        targetHighlight:SetBlendMode("ADD") 
        targetHighlight:SetDrawLayer("ARTWORK", 1)
        local targetColor = barSettings.targetHighlightColor
        targetHighlight:SetVertexColor(targetColor.r, targetColor.g, targetColor.b, targetColor.a)
        targetHighlight:Hide()
        button.targetHighlight = targetHighlight

        local focusHighlight = button:CreateTexture("$parentFocusHighlight", "OVERLAY")
        focusHighlight:SetTexture("Interface\\AddOns\\OmniBar\\arts\\textures.blp")
        focusHighlight:SetTexCoord(0.52343750, 0.97656250, 0.38476563, 0.49609375)
        focusHighlight:SetSize(72, 72)
        focusHighlight:SetPoint("CENTER", button, "CENTER")
        focusHighlight:SetBlendMode("ADD") 
        focusHighlight:SetDrawLayer("ARTWORK", 1)
        local focusColor = barSettings.focusHighlightColor
        focusHighlight:SetVertexColor(focusColor.r, focusColor.g, focusColor.b, focusColor.a)
        focusHighlight:Hide()
        button.focusHighlight = focusHighlight

       ------------------- OmniCD ANIMATION --------------------
        local transition = button:CreateTexture(nil, "OVERLAY")
        transition:SetTexture("Interface\\AddOns\\OmniBar\\arts\\textures.blp") -- top purple image in the blp file
        transition:SetSize(42, 41)
        transition:SetPoint("CENTER", button, "CENTER")
        transition:SetTexCoord(0.52343750, 0.97656250, 0.25781250, 0.36914063)
        transition:SetAlpha(0) 
    
        local border = button:CreateTexture(nil, "OVERLAY") 
        border:SetTexture("Interface\\AddOns\\OmniBar\\arts\\textures.blp") -- bottom purple image in the blp file
        border:SetSize(58, 57)
        border:SetPoint("CENTER", button, "CENTER")
        border:SetTexCoord(0.52343750, 0.97656250, 0.38476563, 0.49609375)
        border:SetAlpha(0)
    
        local glow = button:CreateTexture(nil, "OVERLAY")
        glow:SetTexture("Interface\\AddOns\\OmniBar\\arts\\iconalert.blp") -- white glowing border image in the blp file
        glow:SetSize(58, 57)
        glow:SetPoint("CENTER", button, "CENTER")
        glow:SetTexCoord(0.00781250, 0.50781250, 0.53515625, 0.78515625)
        glow:SetAlpha(0)
        
        local transitionAnim = transition:CreateAnimationGroup()
        local transitionAlpha = transitionAnim:CreateAnimation("Alpha")
        transitionAlpha:SetDuration(0.15)
        transitionAlpha:SetChange(1)
    
        local transitionScale = transitionAnim:CreateAnimation("Scale")
        transitionScale:SetStartDelay(0.15)
        transitionScale:SetDuration(0.2)
        transitionScale:SetScale(1.381, 1.381)
    
        local borderAnim = border:CreateAnimationGroup()
        local borderAlpha = borderAnim:CreateAnimation("Alpha")
        borderAlpha:SetChange(1)
        borderAlpha:SetOrder(1)
    
        local borderAlphaFade = borderAnim:CreateAnimation("Alpha")
        borderAlphaFade:SetStartDelay(0.22)
        borderAlphaFade:SetDuration(0.13)
        borderAlphaFade:SetChange(-1)
        borderAlphaFade:SetOrder(2)
    
        local glowAnim = glow:CreateAnimationGroup()
        local glowIn = glowAnim:CreateAnimation("Alpha")
        glowIn:SetDuration(0.15)
        glowIn:SetChange(1)
    
        local glowOut = glowAnim:CreateAnimation("Alpha")
        glowOut:SetDuration(0.15)
        glowOut:SetChange(-1)
        glowOut:SetOrder(2)

        local function PlayOmniCDAnimation()
            glowAnim:Play()
            borderAnim:Play()
            transitionAnim:Play()
        end

        ------------------- DEFAULT ANIMATION --------------------

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

        local function PlayDefaultAnimation()
            flashAnim:Play()
            newItemAnim:Play()
        end

        function button:PlayNewIconAnimation(glowSetting)
            if glowSetting == "none" then return end

            targetHighlight:Hide()
            focusHighlight:Hide()

             if glowSetting == "omnicd" then
                PlayOmniCDAnimation()
             else
                PlayDefaultAnimation()
             end
        end

        function button:StopNewIconAnimation()
           if flashAnim:IsPlaying() then flashAnim:Stop() end
	       if newItemAnim:IsPlaying() then newItemAnim:Stop() end
           if glowAnim:IsPlaying() then glowAnim:Stop() end
           if borderAnim:IsPlaying() then borderAnim:Stop() end
           if transitionAnim:IsPlaying() then transitionAnim:Stop() end
        end

        function button:IsAnimating()
           return flashAnim:IsPlaying() or newItemAnim:IsPlaying() or glowAnim:IsPlaying() or borderAnim:IsPlaying() or transitionAnim:IsPlaying()
        end

        newItemAnim:SetScript("OnFinished", function()
            local currentBarKey = button:GetParent():GetParent().key
            local currentBarSettings = OmniBar.db.profile.bars[currentBarKey]
            OmniBar:ShowHighlightAfterAnimation(button, currentBarSettings)
        end)

        transitionAnim:SetScript("OnFinished", function()
            local currentBarKey = button:GetParent():GetParent().key
            local currentBarSettings = OmniBar.db.profile.bars[currentBarKey]
            OmniBar:ShowHighlightAfterAnimation(button, currentBarSettings)
        end)

        return button
    end

    omniBarFrame.iconsContainer = iconsContainer
    omniBarFrame.CreateOmniBarIcon = CreateOmniBarIcon

    return omniBarFrame
end