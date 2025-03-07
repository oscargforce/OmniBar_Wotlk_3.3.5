local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local UnitGUID = UnitGUID

local function SetHighlightColor(unit, highlight, barSettings)
   if unit == "target" then
        local targetColor = barSettings.targetHighlightColor
        highlight:SetVertexColor(targetColor.r, targetColor.g, targetColor.b, targetColor.a)
    else
        local focusColor = barSettings.focusHighlightColor
        highlight:SetVertexColor(focusColor.r, focusColor.g, focusColor.b, focusColor.a)
    end 
end

local function ShowHighlight(icon, unitGUID, highlight, barSettings)
    if icon.unitGUID == unitGUID then
        SetHighlightColor(icon.unitType, highlight, barSettings)
        highlight:Show()
    end
end

local function UpdateTargetFocusHighlight(barSettings, icon, targetExists, focusExists, isSameUnit, targetGUID, focusGUID)
    icon.targetHighlight:Hide()
    icon.focusHighlight:Hide()

    if not barSettings.highlightTarget and icon.unitType == "target" then
        return
    end

    if not barSettings.highlightFocus and icon.unitType == "focus" then
        return
    end

    -- Exit if only one unit exists
    if targetExists ~= focusExists then
        return
    end

    -- Handle both units existing
    if targetExists and focusExists then
        if isSameUnit then
            if icon.unitType == "target" or icon.unitType == "focus" then
                ShowHighlight(icon, targetGUID, icon.targetHighlight, barSettings)
            end
        else
            if icon.unitType == "target" then
                ShowHighlight(icon, targetGUID, icon.targetHighlight, barSettings)
            elseif icon.unitType == "focus" then
                ShowHighlight(icon, focusGUID, icon.focusHighlight, barSettings)
            end
        end
    end
end

function OmniBar:UpdateWorldUnitHighlights(barFrame, barSettings, targetExists, focusExists, isSameUnit, targetGUID, focusGUID)
    if not barSettings.highlightTarget and not barSettings.highlightFocus then
        return
    end

    for _, icon in ipairs(barFrame.icons) do
        if not icon:IsAnimating() then
            UpdateTargetFocusHighlight(barSettings, icon, targetExists, focusExists, isSameUnit, targetGUID, focusGUID)
        end
    end
end

function OmniBar:UpdateArenaUnitHighlights(barFrame, barSettings, unit)
    local shouldHighlightTarget = barSettings.highlightTarget
    local shouldHighlightFocus = barSettings.highlightFocus

    if not shouldHighlightTarget and not shouldHighlightFocus then
        return
    end

    if not shouldHighlightTarget and unit == "target" then
        return
    end

    if not shouldHighlightFocus and unit == "focus" then
        return
    end

    local targetExists = UnitExists("target")
    local focusExists = UnitExists("focus")
    local isSameUnit = targetExists and focusExists and UnitIsUnit("target", "focus")
    local targetGUID = targetExists and UnitGUID("target")
    local focusGUID = focusExists and UnitGUID("focus")

    for i, icon in ipairs(barFrame.icons) do
       
        icon.targetHighlight:Hide()
        icon.focusHighlight:Hide()

        if isSameUnit and icon.unitGUID == targetGUID then 
            SetHighlightColor("target", icon.targetHighlight, barSettings)
            icon.targetHighlight:Show()
        elseif targetExists and focusExists and icon.unitGUID == targetGUID then
            SetHighlightColor("target", icon.targetHighlight, barSettings)
            icon.targetHighlight:Show()
        elseif targetExists and focusExists and icon.unitGUID == focusGUID then
            SetHighlightColor("focus", icon.focusHighlight, barSettings)
            icon.focusHighlight:Show()
        elseif focusExists and not targetExists and icon.unitGUID == focusGUID then
            SetHighlightColor("focus", icon.focusHighlight, barSettings)
            icon.focusHighlight:Show()
        elseif targetExists and not focusExists and icon.unitGUID == targetGUID then
            SetHighlightColor("target", icon.targetHighlight, barSettings)
            icon.targetHighlight:Show()
        end
    end
end

function OmniBar:ShowHighlightAfterAnimation(icon, barSettings)
    if barSettings.trackedUnit ~= "allEnemies" then  
        return
    end

    local shouldHighlightTarget = barSettings.highlightTarget
    local shouldHighlightFocus = barSettings.highlightFocus

    if not shouldHighlightTarget and not shouldHighlightFocus then
        return
    end

    local targetExists = UnitExists("target")
    local focusExists = UnitExists("focus")

    if self.zone == "arena" then 
        local targetGUID = targetExists and UnitGUID("target")
        local focusGUID = focusExists and UnitGUID("focus")

        if shouldHighlightTarget and targetExists and icon.unitGUID == targetGUID then
            icon.targetHighlight:Show()
        elseif shouldHighlightFocus and focusExists and icon.unitGUID == focusGUID then
            icon.focusHighlight:Show()
        end

        return
    end

    ------------ Non-arena logic --------------
    if not targetExists or not focusExists then 
        return 
    end
   
    -- Don't show highlights if target and focus are the same unit
    if targetExists and focusExists and UnitIsUnit("target", "focus") then 
        return 
    end

    if shouldHighlightTarget and icon.unitType == "target" then
        icon.targetHighlight:Show()
    elseif shouldHighlightFocus and icon.unitType == "focus" then 
        icon.focusHighlight:Show()
    end

end

--------------- Option Panel functions ----------------

function OmniBar:UpdateHighlightVisibility(barFrame, featureIsEnabled, unit)
    local unitGUID = unit == "target" and UnitGUID("target") or UnitGUID("focus")

    for i, icon in ipairs(barFrame.icons) do
        local highlight = unit == "target" and icon.targetHighlight or icon.focusHighlight

        if unitGUID == icon.unitGUID then 
            if featureIsEnabled then 
                highlight:Show()
            else
                highlight:Hide()
            end
        end
    end
end

function OmniBar:UpdateTargetHighlightColor(barFrame, r, g, b, a)
    for i, icon in ipairs(barFrame.icons) do
        icon.targetHighlight:SetVertexColor(r, g, b, a)
    end
end

function OmniBar:UpdateFocusHighlightColor(barFrame, r, g, b, a)
    for i, icon in ipairs(barFrame.icons) do
        icon.focusHighlight:SetVertexColor(r, g, b, a)
    end
end