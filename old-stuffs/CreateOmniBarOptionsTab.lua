local PaneBackdrop = {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 5, bottom = 3 }
}

function createOmniBarOptionsTab(parent, underFrame) 
    local self = {}
    self.frame = CreateFrame("Frame", nil, parent)
    self.frame:SetPoint("TOPLEFT", underFrame, "BOTTOMLEFT", 0, 0)
    self.frame:SetHeight(255)
    self.frame:SetWidth(400)
    self.frame:SetFrameStrata("FULLSCREEN_DIALOG")

    --self.titletext = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
   -- self.titletext:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 10, -5)
   -- self.titletext:SetText("OmniBar Options")

    self.border = CreateFrame("Frame", nil, self.frame)
    self.border:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 1, -27)
    self.border:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -1, 0)
    self.border:SetBackdrop(PaneBackdrop)
    self.border:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
    self.border:SetBackdropBorderColor(0.4, 0.4, 0.4)

    self.content = CreateFrame("Frame", nil, self.border)
    self.content:SetPoint("TOPLEFT", self.border, "TOPLEFT", 10, -7)
    self.content:SetPoint("BOTTOMRIGHT", self.border, "BOTTOMRIGHT", -10, 7)

    self.tabButtons = {}
    local function createTabButton(i, buttonText, x)
        local tab = CreateFrame("Button", "OmniBarOptionsTabButton" ..buttonText, self.border, "OptionsFrameTabButtonTemplate")
        tab:SetScript("OnClick", function() print(buttonText) end)
        return tab
    end

    local function SetTabs(tabs)
        local width = self.frame:GetWidth() or 0
        local usedWidth = 0
        local row = 1

        for _, tab in ipairs(self.tabButtons) do tab:Hide() end

        for i, buttonText in ipairs(tabs) do
            local tab = self.tabButtons[i] or createTabButton(i, buttonText, x)
            tab:SetText(buttonText)
            tab:Show()
            self.tabButtons[i] = tab

            local tabWidth = tab:GetWidth()
            if usedWidth + tabWidth > width then
                row = row + 1
                usedWidth = 0
            end
            tab:SetPoint("TOPLEFT", self.border, "TOPLEFT", usedWidth, -(row - 1) * 20)
            usedWidth = usedWidth + tabWidth + 5
        end

        -- Adjust the width of the container frame to fit all tabs
      --  self.frame:SetWidth(totalWidth)
    end

    self.SetTabs = SetTabs
    return self
end


--[[
{
    tabButtons = {
        [1] = {[0] =userdata: 12345}
        },
        [2] = {[0] =userdata: 12345}
    },
    SetTabs = function:1234,
    content = {[0] =userdata: 12345},
    frame = {[0] =userdata: 12345},
    border = {[0] =userdata: 12345},
    titleText = {[0] =userdata: 12345},


}

]]