-- Global Tab Group Widget Function
function CreateOmniBarTabGroup(panel)
    local PaneBackdrop = {
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 5, bottom = 3 }
    }

    local function OnRelease(self)
        self.frame:ClearAllPoints()
        self.frame:Hide()
        self.status = nil
        for k in pairs(self.localstatus) do
            self.localstatus[k] = nil
        end
        self.tablist = nil
        for _, tab in pairs(self.tabs) do
            tab:Hide()
        end
        self:SetTitle()
    end

    local function UpdateTabLook(tab)
        if tab.disabled then
            tab:SetNormalFontObject(GameFontDisable)
        elseif tab.selected then
            tab:SetNormalFontObject(GameFontHighlight)
        else
            tab:SetNormalFontObject(GameFontNormal)
        end
    end

    local function Tab_SetSelected(tab, selected)
        tab.selected = selected
        UpdateTabLook(tab)
    end

    local function Tab_OnClick(tab)
        if not (tab.selected or tab.disabled) then
            tab.obj:SelectTab(tab.value)
        end
    end

    local function CreateTab(self, id)
        local tab = CreateFrame("Button", "OmniBarOptionsTab"..id, self.border, "OptionsFrameTabButtonTemplate")
        tab.obj = self
        tab.id = id
        tab:SetScript("OnClick", function() Tab_OnClick(tab) end)
        tab.SetSelected = Tab_SetSelected
        return tab
    end

    local function SetTitle(self, text)
        self.titletext:SetText(text or "")
        self:BuildTabs()
    end

    local function SelectTab(self, value)
        local found
        for _, tab in ipairs(self.tabs) do
            if tab.value == value then
                tab:SetSelected(true)
                found = true
            else
                tab:SetSelected(false)
            end
        end
        if found then
            self:OnTabSelected(value)
        end
    end

    local function BuildTabs(self)
        if not self.tablist then return end
        local width = self.frame:GetWidth() or 0
        local usedWidth = 0
        local row = 1

        for _, tab in ipairs(self.tabs) do tab:Hide() end

        for i, tabInfo in ipairs(self.tablist) do
            local tab = self.tabs[i] or CreateTab(self, i)
            tab:SetText(tabInfo.text)
            tab.value = tabInfo.value
            tab.disabled = tabInfo.disabled
            tab:Show()
            self.tabs[i] = tab

            local tabWidth = tab:GetWidth()
            if usedWidth + tabWidth > width then
                row = row + 1
                usedWidth = 0
            end
            tab:SetPoint("TOPLEFT", self.border, "TOPLEFT", usedWidth, -(row - 1) * 20)
            usedWidth = usedWidth + tabWidth + 5
        end
    end

    local function SetTabs(self, tabs)
        self.tablist = tabs
        self:BuildTabs()
    end

    -- Widget Constructor
    local function Constructor()
        local self = {}
        self.localstatus = {}
        self.tabs = {}

        -- Frame
        self.frame = CreateFrame("Frame", nil, parent)
        self.frame:SetHeight(100)
        self.frame:SetWidth(200)
        self.frame:SetFrameStrata("FULLSCREEN_DIALOG")

        -- Title
        self.titletext = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.titletext:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 10, -5)

        -- Border
        self.border = CreateFrame("Frame", nil, self.frame)
        self.border:SetBackdrop(PaneBackdrop)
        self.border:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
        self.border:SetBackdropBorderColor(0.4, 0.4, 0.4)
        self.border:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 3, -30)
        self.border:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -3, 3)

        -- Content
        self.content = CreateFrame("Frame", nil, self.border)
        self.content:SetPoint("TOPLEFT", self.border, "TOPLEFT", 10, -10)
        self.content:SetPoint("BOTTOMRIGHT", self.border, "BOTTOMRIGHT", -10, 10)

        -- Methods
        self.SetTitle = SetTitle
        self.SelectTab = SelectTab
        self.BuildTabs = BuildTabs
        self.SetTabs = SetTabs
        self.OnTabSelected = customCallback or function(value) end -- Callback for tab selection
        self.OnRelease = OnRelease

        return self
    end

    return Constructor()
end
