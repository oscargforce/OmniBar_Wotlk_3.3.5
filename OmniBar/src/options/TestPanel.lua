local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local AceGUI = LibStub("AceGUI-3.0")

local selectedBars = {}
local selectedClasses = {}
local showCooldowns = true
local classList = {
    "All",
    "Death Knight",
    "Druid",
    "Hunter",
    "General",
    "Mage",
    "Paladin",
    "Priest",
    "Rogue",
    "Shaman",
    "Warlock",
    "Warrior",
}

local testPanel = AceGUI:Create("Frame")
testPanel:Hide()
testPanel:SetTitle("OmniBar Test Panel")
testPanel:SetWidth(440)
testPanel:SetHeight(380)
testPanel:SetLayout("Flow")

local barDropdown = AceGUI:Create("Dropdown")
barDropdown:SetLabel("Select Bars")
barDropdown:SetMultiselect(true)
barDropdown:SetCallback("OnValueChanged", function(_, _, key, isChecked)
    if isChecked then
        selectedBars[key] = true
    else
        selectedBars[key] = nil
    end
end)
testPanel:AddChild(barDropdown)

local spacer1 = AceGUI:Create("Label")
spacer1:SetText(" ")  
spacer1:SetFullWidth(true)
testPanel:AddChild(spacer1)

local classHeading = AceGUI:Create("Label")
classHeading:SetText("Select Classes")
classHeading:SetColor(1, 1, 0)
testPanel:AddChild(classHeading)

local spacer2 = AceGUI:Create("Label")
spacer2:SetText(" ")  
spacer2:SetFullWidth(true)
testPanel:AddChild(spacer2)

local checkboxes = {}

for i, class in ipairs(classList) do
    local classCheckbox = AceGUI:Create("CheckBox")
    classCheckbox:SetLabel(class)
    classCheckbox:SetValue(false)
    checkboxes[class] = classCheckbox

    classCheckbox:SetCallback("OnValueChanged", function(_, _, isChecked)
        if class == "All" then
            for otherClass, checkbox in pairs(checkboxes) do
                if otherClass ~= "All" then
                    checkbox:SetDisabled(isChecked)
                    checkbox:SetValue(false)
                    selectedClasses[otherClass] = isChecked and true or nil
                end
            end
        end
        
        if isChecked then
            selectedClasses[class] = true
        else
            selectedClasses[class] = nil
        end
    end)

    testPanel:AddChild(classCheckbox)
end

local animationHeading = AceGUI:Create("Label")
animationHeading:SetText("Animations")
animationHeading:SetColor(1, 1, 0)
testPanel:AddChild(animationHeading)

local spacer3 = AceGUI:Create("Label")
spacer3:SetText(" ")  
spacer3:SetFullWidth(true)
testPanel:AddChild(spacer3)

local cooldownCheckbox = AceGUI:Create("CheckBox")
cooldownCheckbox:SetLabel("Show Cooldowns")
cooldownCheckbox:SetValue(showCooldowns)
testPanel:AddChild(cooldownCheckbox)

local tooltip = CreateFrame("GameTooltip", "OmniBarTestPanelTooltip", UIParent, "GameTooltipTemplate")

cooldownCheckbox:SetCallback("OnEnter", function(widget)
    tooltip:SetOwner(widget.frame, "ANCHOR_RIGHT", -100, 0)
    --tooltip:SetText("Enable this if you want to test the cooldown animations")
    tooltip:AddLine("Cooldown Animations", 1, 1, 0)  -- Yellow text
    
    -- Set the description in white
    tooltip:AddLine("Enable this to test cooldown animations.\n\nNote: If 'Show Unused Icons' is unchecked, cooldown animations will always be displayed.", 1, 1, 1, true)
    tooltip:Show()
end)

cooldownCheckbox:SetCallback("OnLeave", function()
    tooltip:Hide()
end)

cooldownCheckbox:SetCallback("OnValueChanged", function(_, _, isChecked)
    showCooldowns = isChecked
end)

local testButton = AceGUI:Create("Button")
testButton:SetText("Test Bars")
testButton:SetWidth(200)
testPanel:AddChild(testButton)

testButton:SetCallback("OnClick", function()
    if OmniBar.testModeEnabled then
        testButton:SetText("Test Bars")
        OmniBar:StopTestMode()
        return
    end

    testPanel:Hide()
    OmniBar.testModeEnabled = true
    LibStub("AceConfigRegistry-3.0"):NotifyChange("OmniBar")
    OmniBar:TestBars(selectedBars, selectedClasses, showCooldowns)
    testButton:SetText("Stop Testing")
    selectedBars = {}
end)

function OmniBar:OpenTestPanel()
    local barList = {}
    for barKey, barSettings in pairs(self.db.profile.bars) do
        barList[barKey] = barSettings.name
    end

    barList["All"] = "All"

    barDropdown:SetList(barList)
    testButton:SetText(self.testModeEnabled and "Stop Testing" or "Test Bars")
    testPanel:Show()
end
