local maxContent = 0

function viewTable(tbl)
    if maxContent > 0 then return end

    -- Helper: Convert table to string
    local function tableToString(tbl, indent)
        indent = indent or 0
        local result = ""
        local function addIndent(level)
            return string.rep("  ", level)
        end
        result = result .. "{\n"
        for key, value in pairs(tbl) do
            local formattedKey = type(key) == "string" and "\"" .. key .. "\"" or tostring(key)
            result = result .. addIndent(indent + 1) .. "[" .. formattedKey .. "] = "
            if type(value) == "table" then
                result = result .. tableToString(value, indent + 1)
            elseif type(value) == "string" then
                result = result .. "\"" .. value .. "\""
            else
                result = result .. tostring(value)
            end
            result = result .. ",\n"
        end
        result = result .. addIndent(indent) .. "}"
        return result
    end

    -- Table string
    local content = tableToString(tbl)

    -- Main Frame
    local MainFrame = CreateFrame("Frame", "TableViewerFrame", UIParent)
    MainFrame:SetSize(600, 600) -- Adjust size
    MainFrame:SetPoint("CENTER")
    MainFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    MainFrame:SetBackdropColor(0, 0, 0, 1)
    MainFrame:EnableMouse(true)
    MainFrame:SetMovable(true)
    MainFrame:RegisterForDrag("LeftButton")
    MainFrame:SetScript("OnDragStart", MainFrame.StartMoving)
    MainFrame:SetScript("OnDragStop", MainFrame.StopMovingOrSizing)

    -- Close Button
    local CloseButton = CreateFrame("Button", nil, MainFrame, "UIPanelCloseButton")
    CloseButton:SetPoint("TOPRIGHT", MainFrame, "TOPRIGHT")
    CloseButton:SetScript("OnClick", function()
        MainFrame:Hide()
    end)

    -- Scroll Frame
    local ScrollFrame = CreateFrame("ScrollFrame", "TableViewerScrollFrame", MainFrame, "UIPanelScrollFrameTemplate")
    ScrollFrame:SetSize(570, 540)
    ScrollFrame:SetPoint("TOP", 0, -30)

    -- Content Frame
    local ContentFrame = CreateFrame("Frame", nil, ScrollFrame)
    ScrollFrame:SetScrollChild(ContentFrame)

    -- Font String for content
    local ContentText = ContentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    ContentText:SetPoint("TOPLEFT")
    ContentText:SetWidth(550) -- Width of the text
    ContentText:SetText(content)
    ContentText:SetJustifyH("LEFT")

    -- Dynamically calculate content height
    local textHeight = ContentText:GetStringHeight()
    ContentFrame:SetSize(550, textHeight)
	
    -- Adjust scroll frame height if necessary
    if textHeight > 540 then
        ScrollFrame:UpdateScrollChildRect()
    end

    -- Ensure no double rendering
    maxContent = 1
end


