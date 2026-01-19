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
    isRowGrowingUpwards = false,
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
    showInWorld = true,
    showInBgs = true,
    showInArenas = true,
    cooldowns = {},
}
 
local function AddIconsToSpellTable()
    for className, spells in pairs(spellTable) do
        for spellName, spellData in pairs(spells) do
            if not spellData.item then 
                local _, _, spellIcon = GetSpellInfo(spellData.spellId)  
                spellData.icon = spellIcon 
            end
            -- items should have their icons hardcoded in spellData.icon already
        end
    end
end

-- Register options and initialize the addon
function OmniBar:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("OmniBarDatabase", DEFAULT_PROFILE_SETTINGS)
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
    self.localPlayerGUID = UnitGUID("player")
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
    wipe(self.iconPool)
    
    -- Step 1: Clean up existing bars, 
    for barKey, barFrame in pairs(self.barFrames) do
        self:DeleteBar(barKey, barFrame, true)
    end

    -- Step 2: Create a default bar if none exist
    if next(self.db.profile.bars) == nil then
        local defaultKey = self:GenerateUniqueKey()
        self:InitializeBar(defaultKey)
    else
        -- Else initialize existing bars from the database
        for barKey, barSettings in pairs(self.db.profile.bars) do
            self:InitializeBar(barKey, barSettings)
        end

    end

    -- Step 3: Add all bars to the options menu
    for barKey, _ in pairs(self.db.profile.bars) do
        self:AddBarToOptions(barKey)
    end
end

function OmniBar:DeleteBar(barKey, barFrame, keepProfile)
    local targetFrame  = barFrame or self.barFrames[barKey]

    targetFrame:Hide()
    self:UnregisterAllBarEvents(targetFrame)
    
    if not keepProfile then
        self.db.profile.bars[barKey] = nil 
    end

    self.options.args[barKey] = nil
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
    
    return key
end

function OmniBar:InitializeBar(barKey, settings)
    if (not self.db.profile.bars[barKey]) then
        self.db.profile.bars[barKey] = {}

        local defaultBarSettings = self:DeepCopyTable(DEFAULT_BAR_SETTINGS)

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
        if #self.iconPool < 200 then
            self:CreateIconsToPool(barFrame)
        end
       
        -- Trigger the event "party members changed" to detect the party members specs after a reload
        if barSettings.trackedUnit:match("^party[1-4]$") then
            self:SetupBarIcons(barFrame, barSettings)
        end
    end  

    self:ToggleAnchorVisibility(barFrame)
end

function OmniBar:DeepCopyTable(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = self:DeepCopyTable(v)  -- Recursively copy tables
        else
            copy[k] = v
        end
    end
    return copy
end

function OmniBar:ExportProfile()
    local LibDeflate = LibStub:GetLibrary("LibDeflate")
    local AceSerializer = LibStub:GetLibrary("AceSerializer-3.0")
    
    local data = {
        addon = "OscarsOmniBar",
        profile = self.db.profile,
        version = 10
    }
    
    local serialized = AceSerializer:Serialize(data)
    if not serialized then return end
    
    local compressed = LibDeflate:CompressZlib(serialized)
    if not compressed then return end
    
    return LibDeflate:EncodeForPrint(compressed)
end

function OmniBar:DecodeProfile(encoded)
    local LibDeflate = LibStub:GetLibrary("LibDeflate")
    local AceSerializer = LibStub:GetLibrary("AceSerializer-3.0")
    
    local decoded = LibDeflate:DecodeForPrint(encoded)
    if not decoded then return nil, "DecodeForPrint failed" end
    
    local decompressed = LibDeflate:DecompressZlib(decoded)
    if not decompressed then return nil, "DecompressZlib failed" end
    
    local success, deserialized = AceSerializer:Deserialize(decompressed)
    if not success then return nil, "Deserialize failed" end
    
    return deserialized, nil
end

function OmniBar:ImportProfile(data)
    if data.addon ~= "OscarsOmniBar" then
        return false, "Profile from a different OmniBar addon. Only profiles from this backported OmniBar are supported. https://github.com/oscargforce/OmniBar_Wotlk_3.3.5"
    end
    
    if data.version ~= 10 then 
        return false, "Invalid version" 
    end
    
    -- Create a new profile with timestamp
    local profileName = string.format("Imported (%s)", date("%Y-%m-%d %H:%M:%S"))
    
    -- Save the imported data to a new profile
    self.db.profiles[profileName] = data.profile
    
    -- Switch to the new profile
    self.db:SetProfile(profileName)
    
    -- Reinitialize the addon with the new profile
    self:OnEnable()
    
    -- Notify the config system to refresh
    LibStub("AceConfigRegistry-3.0"):NotifyChange("OmniBar")
    
    return true, profileName
end