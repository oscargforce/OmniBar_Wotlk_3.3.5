OmniBar = LibStub("AceAddon-3.0"):NewAddon("OmniBar", "AceConsole-3.0", "AceEvent-3.0")
local addonName, addon = ...
local spellTable = addon.spellTable
local GetSpellInfo = GetSpellInfo
local GetItemInfo = GetItemInfo
local wipe = wipe

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
    unusedAlpha = 0.45,
    swipeAlpha = 0.65,
    trackedUnit = "enemies",
    cooldowns = {},
}
 
local function AddIconsToSpellTable()
    for className, spells in pairs(spellTable) do
        for _, spellData in pairs(spells) do
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
    self.db = LibStub("AceDB-3.0"):New("OMNIBAR_TEST", { profile = { bars = {}, showOutOfRangeMessages = true } })
    self.barFrames = {}
    self.barIndex = 1
    self.iconPool = {}
    self.db.RegisterCallback(self, "OnProfileChanged", "OnEnable")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnEnable")
	self.db.RegisterCallback(self, "OnProfileReset", "OnEnable")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("CHAT_MSG_SYSTEM")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:SetupOptions()
    AddIconsToSpellTable()
end

-- runs after OmniBar:OnInitialize()
function OmniBar:OnEnable()
    -- Step 1: Clean up existing bars, 
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
    print("OnEnabled: Icons left in pool:", #self.iconPool)
end

function OmniBar:Delete(barKey, barFrame, keepProfile)
    local targetFrame  = barFrame or self.barFrames[barKey]

    targetFrame:Hide()
    targetFrame:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    targetFrame:UnregisterEvent("ARENA_OPPONENT_UPDATE")
    targetFrame:UnregisterEvent("PARTY_MEMBERS_CHANGED")
    targetFrame:UnregisterEvent("UNIT_INVENTORY_CHANGED")

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
    barFrame.activeIcons = {} -- only used if show unused icons is enabled.
    barFrame.trackedSpells = {}
    self.barFrames[barKey] = barFrame

    -- Populate barFrame.trackedSpells table with tracked cds
    self:UpdateSpellTrackingForBar(barFrame, barSettings)
    self:InitializeEventsTracking(barFrame, barSettings)

    -- Maybe change, only createIconsToBar if trackedUnit == all enemies and showUnusedIcons
     -- Hide/show icons
    if barSettings.showUnusedIcons then
        self:SetupBarIcons(barFrame, barSettings)
    else
        self:CreateIconsToPool(barFrame)
    end  
   
end

function OmniBar:InitializeEventsTracking(barFrame, barSettings)
    self:UpdateUnitEventTracking(barFrame, barSettings)
    
    barFrame:SetScript("OnEvent", function (barFrame, event, ...) 
        OmniBar:OnEventHandler(barFrame, event, ...)
    end)
end

function OmniBar:OnEventHandler(barFrame, event, ...)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        self:OnUnitSpellCastSucceeded(barFrame, event, ...)
    elseif event == "PARTY_MEMBERS_CHANGED" then
        self:OnPartyMembersChanged(barFrame, event, ...)
    elseif event == "UNIT_INVENTORY_CHANGED" then
        self:OnUnitInventoryChanged(barFrame, event, ...)
    elseif event == "INSPECT_TALENT_READY" then
        self:OnInspectTalentReady(barFrame, event, ...)
    elseif event == "ARENA_OPPONENT_UPDATE" then
        self:OnArenaOpponentUpdate(barFrame, event, ...)
    end
end

function OmniBar:SetupBarIcons(barFrame, barSettings)
    local trackedUnit = barSettings.trackedUnit
    
     if trackedUnit:match("^arena[1-5]$") then
        -- something
    elseif trackedUnit:match("^party[1-4]$") then
        self:OnEventHandler(barFrame, "PARTY_MEMBERS_CHANGED", "editMode")
    elseif trackedUnit == "target" then
        -- something
    elseif trackedUnit == "focus" then
        -- something
    else
        -- tracked unit is all enemies hence just populate the bar directly.
        self:CreateIconsToBar(barFrame, barSettings)
        self:UpdateUnusedAlpha(barFrame, barSettings)
    end
end

function OmniBar:CreateIconsToPool(barFrame)
    for spellName, spellData in pairs(barFrame.trackedSpells) do
        -- change this later to if spellData then... and remove the print
        if not spellData then print(spellName,"Does not exist in spellTable") end

        local icon = barFrame.CreateOmniBarIcon()
        self:ReturnIconToPool(icon)
    end
end

function OmniBar:CreateIconToBar(barFrame, spellName, spellData)
    local icon = self:GetIconFromPool(barFrame)
    icon.icon:SetTexture(spellData.icon)
    icon.spellName = spellName
    icon.priority = spellData.priority 
    icon.className = spellData.className
    icon.spellId = spellData.spellId
    if spellData.race then 
        icon.race = spellData.race 
    end
    if spellData.item then 
        icon.item = spellData.item 
    end

    icon:Show()
    table.insert(barFrame.icons, icon)
    return icon
end
 
-- Maybe change this function to CreateIconToBar, so its single. Or rename to populate enemies bar.
function OmniBar:CreateIconsToBar(barFrame, barSettings)
    if not barSettings.showUnusedIcons or barSettings.trackedUnit ~= "enemies" then
        return
    end
    
    for spellName, spellData in pairs(barFrame.trackedSpells) do
        -- change this later to if spellData then... and remove the print
        if not spellData then print(spellName,"Does not exist in spellTable") end
        self:CreateIconToBar(barFrame, spellName, spellData)
    end
    
    self:ArrangeIcons(barFrame, barSettings)
end

function OmniBar:GetIconFromPool(barFrame)
    -- Reuse an icon from the pool if available
    if #self.iconPool > 0 then
        local icon = table.remove(self.iconPool)
        icon:SetParent(barFrame.iconsContainer)
        self:MakeFrameDraggable(icon, barFrame)
        return icon
    end
 --   print("creating new icon")
    -- Otherwise, create a new icon
    local icon = barFrame.CreateOmniBarIcon()
    self:MakeFrameDraggable(icon, barFrame)
    return icon
end

function OmniBar:SortIcons(barFrame, showUnusedIcons)
    if not showUnusedIcons then
        -- Sort icons based on endTime (or default to math.huge)
        table.sort(barFrame.icons, function(a, b)
            local aEndTime = a.endTime or math.huge
            local bEndTime = b.endTime or math.huge 
            return aEndTime < bEndTime
        end) 
    else
        table.sort(barFrame.icons, function (a, b) 
            if a.priority == b.priority then
                return a.spellId < b.spellId
            end

            return a.priority > b.priority  
        end)
    end 
end

local BASE_ICON_SIZE = 36
function OmniBar:ArrangeIcons(barFrame, barSettings, skipSort)
    local maxIconsPerRow = barSettings.maxIconsPerRow
    local maxIconsTotal = barSettings.maxIconsTotal
    local margin = barSettings.margin

    local iconsPerRow, rows = 0, 1
    local growDirection = barSettings.isRowGrowingUpwards and 1 or -1 
    local numActive = #barFrame.icons

    if not skipSort then self:SortIcons(barFrame, barSettings.showUnusedIcons) end

     -- Remove excess icons if necessary
    if numActive > maxIconsTotal then
        local excessIcons = numActive - maxIconsTotal
        for i = 1, excessIcons do
            local icon = barFrame.icons[#barFrame.icons] 
            barFrame.icons[#barFrame.icons] = nil
            self:ReturnIconToPool(icon)
        end
    end 

    numActive = #barFrame.icons
    local columns = maxIconsPerRow < numActive and maxIconsPerRow or numActive

    for i, icon in ipairs(barFrame.icons) do
        icon:ClearAllPoints()
    
        if i > 1 then
            iconsPerRow = iconsPerRow + 1
            if iconsPerRow >= columns then
                icon:SetPoint("CENTER", barFrame.iconsContainer, "CENTER", 
                            (-BASE_ICON_SIZE - margin) * (columns - 1) / 2, 
                            (BASE_ICON_SIZE + margin) * rows * growDirection)
                iconsPerRow = 0
                rows = rows + 1
            else
                icon:SetPoint("TOPLEFT", barFrame.icons[i-1], "TOPRIGHT", margin, 0)
                -- icon:SetPoint("TOPRIGHT", barFrame.icons[i-1], "TOPLEFT", -1 * margin, 0) Aling right, but not working with margin.
            end
        else
            icon:SetPoint("CENTER", barFrame.iconsContainer, "CENTER", 
                            (-BASE_ICON_SIZE - margin) * (columns - 1) / 2, 0)
        end
    end
end

function OmniBar:ReturnIconToPool(icon)
    self:ResetIconState(icon)
    icon:StopNewIconAnimation()
    icon:Hide()
    icon:ClearAllPoints()
    icon:SetParent(nil) -- Remove from parent to avoid layout conflicts
    table.insert(self.iconPool, icon)
end

-- Don't reset spellName, priority, class, or race to avoid affecting showUnusedIcons when the CD countdown ends.
function OmniBar:ResetIconState(icon)
    icon.countdownText:SetText("")
    icon.timerFrame:Hide()
    icon.timerFrame:SetScript("OnUpdate", nil) -- Delete the timer
    icon.cooldown:Hide()
    icon.endTime = nil
    icon.item = nil
    icon.race = nil
end


function OmniBar:ResetIcons(barFrame)
    for _, icon in ipairs(barFrame.icons) do
        self:ReturnIconToPool(icon)
    end

    -- Clear the icons table (reuse pool instead of removing actual icons)
    wipe(barFrame.icons) 
    wipe(barFrame.activeIcons) 
end

function OmniBar:RefreshBarsWithActiveIcons()
    for _, barFrame in pairs(self.barFrames) do
        local showUnusedIcons = self.db.profile.bars[barFrame.key].showUnusedIcons
        
        local shouldRefresh = (showUnusedIcons and next(barFrame.activeIcons)) 
        or (not showUnusedIcons and #barFrame.icons > 0)

        if shouldRefresh then
            self:UpdateBar(barFrame.key, "refreshBarIconsState")
        end 
    end 
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

function OmniBar:ToggleAnchorVisibility(barFrame)
    if #barFrame.icons > 0 or next(barFrame.activeIcons) then
        barFrame.anchor:Hide()
    else
        barFrame.anchor:Show()
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