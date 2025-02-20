OmniBar = LibStub("AceAddon-3.0"):NewAddon("OmniBar", "AceConsole-3.0", "AceEvent-3.0")
local addonName, addon = ...
local spellTable = addon.spellTable
local GetSpellInfo = GetSpellInfo
local GetItemInfo = GetItemInfo
local wipe = wipe

local DEFAULT_PROFILE_SETTINGS = {
    profile = {
        bars = {},
        isBarsLocked = false,
        showOutOfRangeMessages = true,
        fontStyle = "Fonts\\FRIZQT__.TTF",
        fontColorExpire = { r = 1, g = 0, b = 0, a = 1 },
        fontSizeExpire = 22,
        fontColorSeconds = { r = 1, g = 1, b = 0, a = 1 },
        fontSizeSeconds = 18,
        fontColorMinutes = { r = 1, g = 1, b = 1, a = 1 },
        fontSizeMinutes = 18,
    }
}

local DEFAULT_BAR_SETTINGS = {
    name = "OmniBar",
    iconAlignment = "CENTER",
    iconSortingMethod = "remainingTime",
    customCountdownText = false,
    countdownTextXOffset = 0,
    anchorWidth = 80,
    scale = 1,
    glowSetting = "default",
    position = { point = "CENTER", relativePoint = "CENTER", x = 0, y = 0 },
    showBorder = true,
    isRowGrowingUpwards = true,
    highlightTarget = false,
    targetHighlightColor = { r = 0.639, g = 0.207, b = 0.933, a = 1 }, 
    focusHighlightColor = { r = 1, g = 0.843, b = 0, a = 1 }, 
    highlightFocus = false,
    maxIconsPerRow = 15,
    maxIconsTotal = 30,
    margin = 4,
    showUnusedIcons = true,
    unusedAlpha = 0.45,
    swipeAlpha = 0.65,
    trackedUnit = "allEnemies",
    showNames = false,
    cooldowns = {},
}
 
local function AddIconsToSpellTable()
    for className, spells in pairs(spellTable) do
        for spellName, spellData in pairs(spells) do
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
    self.db = LibStub("AceDB-3.0"):New("OMNIBAR_TEST", DEFAULT_PROFILE_SETTINGS)
    self.barFrames = {}
    self.barIndex = 1
    self.iconPool = {}
    self.isArenaMatchInProgress = false -- maybe use later for onInventoryChanged
    self.arenaOpponents = {}
    self.partyMemberGUIDs = {}
    self.partyMemberSpecs = {}
    self.combatLogCache = {}
    self.currentRealm = GetRealmName()
    self.isDuelInProgress = false
    self.testModeEnabled = false 
    self.localPlayerName = GetUnitName("player")
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
        self:DeleteBar(barKey, barFrame, true)
    end

    -- Step 2: Create a default bar if none exist
    if next(self.db.profile.bars) == nil then
        print("Creating default bar")
        local defaultKey = self:GenerateUniqueKey()
        self:InitializeBar(defaultKey)
    else
        -- Else initialize existing bars from the database
        for barKey, barSettings in pairs(self.db.profile.bars) do
            print("Adding existing bars")
            self:InitializeBar(barKey, barSettings)
        end

    end

    -- Step 3: Add all bars to the options menu
    for barKey, _ in pairs(self.db.profile.bars) do
        self:AddBarToOptions(barKey)
    end
    print("OnEnabled: Icons left in pool:", #self.iconPool)
end

function OmniBar:DeleteBar(barKey, barFrame, keepProfile)
    local targetFrame  = barFrame or self.barFrames[barKey]

    targetFrame:Hide()
    self:UnregisterAllBarEvents(targetFrame)

    if not keepProfile then
        self.db.profile.bars[barKey] = nil 
        self.options.args[barKey] = nil
    end

    targetFrame.anchor:Hide()
    wipe(targetFrame.icons)
    wipe(targetFrame.activeIcons)
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

local function DeepCopyTable(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = DeepCopyTable(v)  -- Recursively copy tables
        else
            copy[k] = v
        end
    end
    return copy
end

function OmniBar:InitializeBar(barKey, settings)
    if (not self.db.profile.bars[barKey]) then
        self.db.profile.bars[barKey] = {}

        local defaultBarSettings = DeepCopyTable(DEFAULT_BAR_SETTINGS)

		for k, v in pairs(defaultBarSettings) do
			self.db.profile.bars[barKey][k] = v
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
    self:BuildTrackedSpells(barFrame, barSettings)
    self:InitializeEventsTracking(barFrame, barSettings)

     -- Hide/show icons
    if barSettings.showUnusedIcons then
        self:SetupBarIcons(barFrame, barSettings)
    else
        self:CreateIconsToPool(barFrame)

        -- Trigger the event "party members changed" to detect the party members specs after a reload
        if barSettings.trackedUnit:match("^party[1-4]$") then
            self:SetupBarIcons(barFrame, barSettings)
        end
    end  

    self:ToggleAnchorVisibility(barFrame)
end
