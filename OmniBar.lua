OmniBar = LibStub("AceAddon-3.0"):NewAddon("OmniBar", "AceConsole-3.0")
local addonName, addon = ...
local cooldownsTable = addon.cooldownsTable
local GetSpellInfo = GetSpellInfo
local GetItemInfo = GetItemInfo

local DEFAULT_BAR_SETTINGS = {
    name = "OmniBar",
    anchorWidth = 80,
    scale = 1,
    position = { point = "CENTER", relativePoint = "CENTER", x = 0, y = 0 },
    showBorder = true,
    isRowGrowingUpwards = true,
    maxIconsPerRow = 15,
    maxIconsTotal = 30,
    margin = 4,
    showUnusedIcons = true,
    trackUnit = "enemy",
    cooldowns = {},
}
 

local function AddIconsToCooldownsTable()
    for _, spellTable in pairs(cooldownsTable) do
        for _, spellData in pairs(spellTable) do
            local icon
            if not spellData.item then 
                local _, _, spellIcon = GetSpellInfo(spellData.spellId)  
                icon = spellIcon 
            else
                local _, _, _, _, _, _, _, _, _, itemIcon = GetItemInfo(spellData.spellId)
                icon = itemIcon
            end
            spellData.icon = icon
        end
    end
end

-- Register options and initialize the addon
function OmniBar:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("OMNIBAR_TEST", { profile = { bars = {} } })
    self.barFrames = {}
    self.barIndex = 1
    self.iconPool = {}
    self.db.RegisterCallback(self, "OnProfileChanged", "OnEnable")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnEnable")
	self.db.RegisterCallback(self, "OnProfileReset", "OnEnable")
    self:SetupOptions()
    AddIconsToCooldownsTable()
end


-- runs after OmniBar:OnInitialize()
function OmniBar:OnEnable()
    -- Step 1: Clean up existing bars, 
    -- NOTE: When does this loop ever run? Is frames not removed on reload
    for barKey, barFrame in pairs(self.barFrames) do
        print("Cleaning up bar:", barKey)
        self:Delete(barKey, barFrame, true)
    end

    -- Step 2: Create a default bar if none exist
    if next(self.db.profile.bars) == nil then
        print("Creating default bar")
        local defaultKey = self:GenerateUniqueKey()
        self:InitializeBar(defaultKey)
    else
        -- Else initialize existing bars from the database
        for barKey, settings in pairs(self.db.profile.bars) do
            print("Adding existing bars")
            self:InitializeBar(barKey, settings)
        end

    end

    -- Step 3: Add all bars to the options menu
    for barKey, _ in pairs(self.db.profile.bars) do
        self:AddBarToOptions(barKey)
    end
    
end

function OmniBar:Delete(barKey, barFrame, keepProfile)
    local targetFrame  = barFrame or self.barFrames[barKey]

    targetFrame:Hide()
    -- dont think i need this override local barKey = targetFrame.key
    if not keepProfile then
        self.db.profile.bars[barKey] = nil 
        self.options.args[barKey] = nil
    end
    targetFrame.anchor:Hide()
    wipe(targetFrame.icons)
    targetFrame.anchor = nil
    targetFrame.background = nil
    targetFrame.text = nil
    self.barFrames[barKey] = nil

	LibStub("AceConfigRegistry-3.0"):NotifyChange("OmniBar")
end

function OmniBar:GenerateUniqueKey()
    local key
    repeat
        key = "OmniBar" .. self.barIndex
        self.barIndex = self.barIndex + 1
    until not self.db.profile.bars[key]
    print("Key name:", key)
    return key
end

function OmniBar:InitializeBar(barKey, settings)
    if (not self.db.profile.bars[barKey]) then
        self.db.profile.bars[barKey] = {}

        local defaultBarSettings = addon.DeepCopyTable(DEFAULT_BAR_SETTINGS)

		for a,b in pairs(defaultBarSettings) do
			self.db.profile.bars[barKey][a] = b
		end

        self.db.profile.bars[barKey].name = barKey 
	end

    local barSettings = settings or self.db.profile.bars[barKey]
    local barFrame = CreateOmniBarWidget(barKey, barSettings)
    barFrame.key = barKey
    barFrame.icons = {}
    barFrame.trackedCooldowns = {}
    barFrame.activeCooldowns = {}
    barFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    barFrame:SetScript("OnEvent", function (...) 
        self:OnUnitSpellCastSucceded(...)
    end)
    self.barFrames[barKey] = barFrame

    -- Populate barFrame.trackedCooldowns table with tracked cds
    self:UpdateCooldownTrackingForBar(barFrame, barSettings)
    -- Render the icon to the bar
    self:CreateIconsToBar(barFrame, barSettings)
     
    -- Hide/show icons
    self:UpdateShowUnusedIcons(barFrame, barSettings)
   
end
 
function OmniBar:CreateIconsToBar(barFrame, barSettings)
    for cooldownName, cooldownData in pairs(barFrame.trackedCooldowns) do
        -- change this later to if cooldownData then... and remove the print
        if not cooldownData then print(cooldownName,"Does not exist in cooldownsTable") end

        local icon = self:GetIconFromPool(barFrame)
        icon.icon:SetTexture(cooldownData.icon)
        icon:Show()
        
        table.insert(barFrame.icons, icon)
    end
    

    self:ArrangeIcons(barFrame, barSettings)
end

function OmniBar:GetIconFromPool(barFrame)
    -- Reuse an icon from the pool if available
    if #self.iconPool > 0 then
        local icon = table.remove(self.iconPool)
        icon:SetParent(barFrame.iconsContainer)
        icon:Show()
        self:MakeFrameDraggable(icon, barFrame)
        return icon
    end
    print("creating new icon")
    -- Otherwise, create a new icon
    local icon = barFrame.CreateOmniBarIcon()
    self:MakeFrameDraggable(icon, barFrame)
    return icon
end

function OmniBar:ArrangeIcons(barFrame, barSettings, onylActiveIcons)
    local maxIconsPerRow = barSettings.maxIconsPerRow
    local isRowGrowingUpwards = barSettings.isRowGrowingUpwards
    local maxIconsTotal = barSettings.maxIconsTotal
    local margin = barSettings.margin

    -- Variables to track positioning
    local xOffset = 0
    local yOffset = 0
    local rowIndex = 0  -- Icons placed in the current row
    local iconCount = 0  -- Icons placed in the current row
    local padding = 36 -- 36px spacing between icons

    local iconsToArrange = onylActiveIcons and barFrame.activeCooldonws or barFrame.icons
    
    -- Loop through all active icons in the bar
    for i, icon in ipairs(barFrame.icons) do
        if icon:IsShown() then

            if iconCount >= maxIconsTotal then 
                self:ReturnIconToPool(icon)
                barFrame.icons[i] = nil  -- Remove reference from the table
            end

            -- Position the icon
            icon:ClearAllPoints()
            icon:SetPoint("LEFT", barFrame.iconsContainer, "LEFT", xOffset, yOffset)

            -- Update xOffset for the next icon in the row
            iconCount = iconCount + 1
            rowIndex = rowIndex + 1
            xOffset = rowIndex * (padding + margin)

            -- Check if we reached the max icons per row
            if rowIndex >= maxIconsPerRow then
                rowIndex = 0
                xOffset = 0  -- Reset horizontal position

                -- Adjust yOffset to move to the next row
                if isRowGrowingUpwards then
                    yOffset = yOffset + (padding + margin)  -- Move up
                else
                    yOffset = yOffset - (padding + margin)  -- Move down
                end
            end
        end
    end
end

function OmniBar:ReturnIconToPool(icon)
    icon:Hide()
    icon:ClearAllPoints()
    icon:SetParent(nil) -- Remove from parent to avoid layout conflicts
    table.insert(self.iconPool, icon)
end

function OmniBar:ResetIcons(barFrame)
    if not barFrame or not barFrame.icons or next(barFrame.icons) == nil then
        return 
    end

    for _, icon in ipairs(barFrame.icons) do
        self:ReturnIconToPool(icon)
    end

    -- Clear the icons table (reuse pool instead of removing actual icons)
    wipe(barFrame.icons) 
end

function OmniBar:CreateBar() 
    local barKey = self:GenerateUniqueKey()
    -- Initialize bar settings in the database and UI
    self:InitializeBar(barKey)
    -- Add the bar to options
    self:AddBarToOptions(barKey)

    print("Bar created with key:", barKey)
end

function OmniBar:MakeFrameDraggable(icon, barFrame)
    icon:SetMovable(true)
    icon:EnableMouse(true)
     -- Clear old scripts to avoid dragging the wrong bar
    icon:SetScript("OnMouseDown", nil)
    icon:SetScript("OnMouseUp", nil)

    icon:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            barFrame:StartMoving()
        end
    end)
    icon:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            barFrame:StopMovingOrSizing()
            -- Save position
            local point, _, relativePoint, x, y = barFrame:GetPoint()
            OmniBar:SetPosition(barFrame, { point = point, relativePoint = relativePoint, x = x, y = y })
        end
    end)
end

function OmniBar:SetPosition(barFrame, newPosition)
    if not barFrame then return end
    local barKey = barFrame.key
    local position = self.db.profile.bars[barKey].position

    -- Update position in database
    position.point = newPosition.point
    position.relativePoint = newPosition.relativePoint
    position.x = newPosition.x
    position.y = newPosition.y
end








-- should i keep?
function OmniBar:RefreshAllBars(full)
	for barKey, barSettings in pairs(self.db.profile.bars) do
		local frame = self.barFrames[barKey]
		if not frame then return end
        frame.text:SetText(barSettings.name)
	end
end
























function OmniBar:printTable(table)
    local function printTable(t, indent)
        if not indent then
            indent = 0  -- Default indentation level
        end
    
        -- Check if the table is valid
        if type(t) ~= "table" then
            print("Not a valid table.")
            return
        end
    
        for key, value in pairs(t) do
            -- Indentation
            local prefix = string.rep("  ", indent)
            
            -- If the value is a table, recursively call printTable
            if type(value) == "table" then
                print(prefix .. key .. " = {")
                printTable(value, indent + 1)
                print(prefix .. "}")
            else
                -- Print the key and value
                print(prefix .. key .. " = " .. tostring(value))
            end
        end
    end
    printTable(table)
end