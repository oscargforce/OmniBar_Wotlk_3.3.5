local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local AceGUI = LibStub("AceGUI-3.0")

-- Export Frame
function OmniBar:CreateExportFrame()
    if self.exportFrame then return end
    
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Export OmniBar Profile")
    frame:SetWidth(500)
    frame:SetHeight(300)
    frame:SetLayout("Fill")
    frame:SetCallback("OnClose", function(widget) 
        AceGUI:Release(widget)
        self.exportFrame = nil
    end)
    
    local editBox = AceGUI:Create("MultiLineEditBox")
    editBox:SetLabel("Copy this code to share your profile:")
    editBox:DisableButton(true)
    editBox:SetNumLines(10)
    frame:AddChild(editBox)
    
    self.exportFrame = frame
    self.exportEditBox = editBox
end

function OmniBar:ShowExport()
    self:CreateExportFrame()
    
    local exported = self:ExportProfile()
    if exported then
        self.exportEditBox:SetText(exported)
        self.exportFrame:Show()
        self.exportEditBox:SetFocus()
        self.exportEditBox:HighlightText()
    else
        print("|cffff0000OmniBar:|r Failed to export profile")
    end
end

-- Import Frame
function OmniBar:CreateImportFrame()
    if self.importFrame then return end
    
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("Import OmniBar Profile")
    frame:SetWidth(500)
    frame:SetHeight(350)
    frame:SetLayout("Flow")
    frame:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
        self.importFrame = nil
    end)
    
    local editBox = AceGUI:Create("MultiLineEditBox")
    editBox:SetLabel("Paste the profile code here:")
    editBox:SetNumLines(10)
    editBox:SetFullWidth(true)
    editBox:SetCallback("OnTextChanged", function(widget, event, text)
        -- Enable import button when text is pasted
        if text and text:len() > 0 then
            self.importButton:SetDisabled(false)
            self.importStatusText:SetText("|cff00ff00Ready to import|r")
        else
            self.importButton:SetDisabled(true)
            self.importStatusText:SetText("Paste a code to import an OmniBar profile.")
        end
    end)
    frame:AddChild(editBox)
    
    local statusText = AceGUI:Create("Label")
    statusText:SetText("Paste a code to import an OmniBar profile.")
    statusText:SetFullWidth(true)
    statusText:SetColor(1, 0.82, 0)
    frame:AddChild(statusText)
    
    local spacer = AceGUI:Create("Label")
    spacer:SetText(" ")
    spacer:SetFullWidth(true)
    frame:AddChild(spacer)
    
    local importButton = AceGUI:Create("Button")
    importButton:SetText("Import Profile")
    importButton:SetWidth(200)
    importButton:SetDisabled(true)
    importButton:SetCallback("OnClick", function()
        local text = editBox:GetText()
        local data, err = self:DecodeProfile(text)
        
        if not data then
            statusText:SetText("|cffff0000Import failed: " .. (err or "Unknown error") .. "|r")
            statusText:SetColor(1, 0, 0)
            return
        end
        
        local success, profileName = self:ImportProfile(data)
        if success then
            statusText:SetText("|cff00ff00Profile imported successfully as '" .. profileName .. "'|r")
            statusText:SetColor(0, 1, 0)
            importButton:SetDisabled(true)
            print("|cff00ff00OmniBar:|r Profile imported successfully")
        else
            statusText:SetText("|cffff0000Import failed: " .. (profileName or "Unknown error") .. "|r")
            statusText:SetColor(1, 0, 0)
        end
    end)
    frame:AddChild(importButton)
    
    self.importFrame = frame
    self.importEditBox = editBox
    self.importButton = importButton
    self.importStatusText = statusText
end

function OmniBar:ShowImport()
    self:CreateImportFrame()
    
    self.importEditBox:SetText("")
    self.importButton:SetDisabled(true)
    self.importStatusText:SetText("Paste a code to import an OmniBar profile.")
    self.importStatusText:SetColor(1, 0.82, 0)
    
    self.importFrame:Show()
    self.importEditBox:SetFocus()
end