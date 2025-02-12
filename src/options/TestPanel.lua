local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local AceGUI = LibStub("AceGUI-3.0")

local selectedBars = {}
local selectedClasses = {}

local classList = {
    ["All"] = "All",
    ["Death Knight"] = "Death Knight",
    ["Druid"] = "Druid",
    ["Hunter"] = "Hunter",
    ["Mage"] = "Mage",
    ["Paladin"] = "Paladin",
    ["Priest"] = "Priest",
    ["Rogue"] = "Rogue",
    ["Shaman"] = "Shaman",
    ["Warlock"] = "Warlock",
    ["Warrior"] = "Warrior",
}

local testPanel = AceGUI:Create("Frame")
testPanel:Hide()
testPanel:SetTitle("OmniBar Test Panel")
testPanel:SetWidth(250)
testPanel:SetHeight(250)
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

local classDropdown = AceGUI:Create("Dropdown")
classDropdown:SetLabel("Select Classes")
classDropdown:SetMultiselect(true)
classDropdown:SetList(classList)
classDropdown:SetCallback("OnValueChanged", function(_, _, key, isChecked)
    if isChecked then
        selectedClasses[key] = true
    else
        selectedClasses[key] = nil
    end
end)
testPanel:AddChild(classDropdown)

local spacer2 = AceGUI:Create("Label")
spacer2:SetText(" ")  
spacer2:SetFullWidth(true)
testPanel:AddChild(spacer2)

local testButton = AceGUI:Create("Button")
testButton:SetText("Test Bars")
testButton:SetWidth(200)
testPanel:AddChild(testButton)
testButton:SetCallback("OnClick", function()
--[[     local lists = {}
    lists.selectedClasses = {}
    lists.selectedBars = {}

    for class, _ in pairs(selectedClasses) do
        lists.selectedClasses[class] = true
    end

    for bar, _ in pairs(selectedBars) do
        lists.selectedBars[bar] = true
    end

    viewTable(lists) ]]
    testPanel:Hide()
    OmniBar:TestBars(selectedBars, selectedClasses)
end)

function OmniBar:OpenTestPanel()
    local barList = {}
    for barKey, barSettings in pairs(self.db.profile.bars) do
        barList[barKey] = barSettings.name
    end

    barList["All"] = "All"

    barDropdown:SetList(barList)
    testPanel:Show()
end
