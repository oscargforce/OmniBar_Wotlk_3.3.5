local addonName, addon = ...

local function isEmptyString(s)
    return s:gsub("^%s*(.-)%s*$", "%1") == ""
end

StaticPopupDialogs["OMNIBAR_DELETE"] = {
	text = DELETE.." \"%s\"",
	button1 = YES,
	button2 = NO,
	OnAccept = function(self, data)
		OmniBar:Delete(data)
	end,
	timeout = 0,
	whileDead = true,
}

local tooltip = CreateFrame("GameTooltip", "OmniBarTooltip", UIParent, "GameTooltipTemplate")
local function GetSpellTooltipDescription(spellId, isItem)
    local link = isItem and "item:"..spellId or "spell:"..spellId
	tooltip:SetOwner(UIParent, "ANCHOR_NONE")
	tooltip:SetHyperlink(link)
	local lines = tooltip:NumLines()

	if lines < 1 then 
        return 
    end

	local line = _G["OmniBarTooltipTextLeft"..lines]:GetText()

    if isEmptyString(line) then 
        -- For some items, the description is located at the second-to-last line.
        line = _G["OmniBarTooltipTextLeft"..lines - 1]:GetText()
    end
  
	if isEmptyString(line) then 
        tooltip:Hide()
        return 
    end

	tooltip:Hide()
	return line
end


function OmniBar:AddBarToOptions(barKey) 
 
    self.options.args[barKey] = {
        type = "group",
        name = self.db.profile.bars[barKey].name,
        order = self.barIndex + 1,
        args = {
            delete = {
                type = "execute",
                name = "Delete",
                width = 0.75,
                desc = "Delete the bar",
                func = function()
                    local popup = StaticPopup_Show("OMNIBAR_DELETE", self.db.profile.bars[barKey].name)
                    if popup then popup.data = barKey end
                end,
                arg = barKey,
                order = 0,
            },
            name = {
                name = "Name",
                desc = "Set the name of the bar",
                type = "input",
                width = "double",
                get = function() return self.db.profile.bars[barKey].name end,
                set = function(info, state)
                    self.db.profile.bars[barKey].name = state
                    self.options.args[barKey].name = state
                    self:UpdateBar(barKey, "name")
                end,
                order = 1,
            },
            trackUnit = {
                name = "Track",
                type = "select",
                values = {
                    ["enemy"] = "All Enemies",
                    ["target"] = "Target",
                    ["focus"] = "Focus",
                    ["arena1"] = "Arena1", 
                    ["arena2"] = "Arena2",
                    ["arena3"] = "Arena3",
                    ["party1"] = "Party1",
                    ["party2"] = "Party2",
                    ["party3"] = "Party3",
                },
                get = function() return self.db.profile.bars[barKey].trackUnit end,
                set = function(info, value)
                    self.db.profile.bars[barKey].trackUnit = value
                end,
                order = 2,
            },
            lineBreak1 = {
                name = "",
                type = "description",
                order = 3,
            },
            center = {
                name = "Center Lock",
                desc = "Keep the bar centered horizontally",
                width = "normal",
                type = "toggle",
                order = 4,
            },
            showUnusedIcons = {
                name = "Show Unused Icons",
                desc = "Icons will always remain visible",
                width = "normal",
                type = "toggle",
                get = function() return self.db.profile.bars[barKey].showUnusedIcons end,
                set = function(info, value)
                    self.db.profile.bars[barKey].showUnusedIcons = value
                    self:UpdateBar(barKey, "showUnusedIcons")
                end,
                order = 5,
            },
            adaptive = {
                name = "As Enemies Appear",
                desc = "Only show unused icons for arena opponents or enemies you target while in combat",
                width = "normal",
                type = "toggle",
                order = 6,
                set = function(info, state)
                    print(info)
                end,
            },
            growUpward = {
                name = "Grow Rows Upward",
                desc = "Toggle the grow direction of the icons",
                width = "normal",
                type = "toggle",
                get = function() return self.db.profile.bars[barKey].isRowGrowingUpwards end,
                set = function(info, value)
                    self.db.profile.bars[barKey].isRowGrowingUpwards = value
                    self:UpdateBar(barKey)
                end,
                order = 7,
            },
            cooldownCount = {
                name = "Countdown Count",
                desc = "Allow Blizzard and other addons to display countdown text on the icons",
                width = "normal",
                type = "toggle",
                set = function(info, state)
                    print(info)
                end,
                order = 8,
            },
            border = {
                name = "Show Border",
                desc = "Draw a border around the icons",
                width = "normal",
                type = "toggle",
                order = 9,
                get = function() return self.db.profile.bars[barKey].showBorder end,
                set = function(info, value)
                    self.db.profile.bars[barKey].showBorder = value
                    self:UpdateBar(barKey, "border")
                end
            },
            highlightTarget = {
                name = "Highlight Target",
                desc = "Draw a border around your target",
                width = "normal",
                type = "toggle",
                order = 10,   
                set = function(info, state)
                    print(info)
                end,
            },
            multiple = {
                name = "Track Multiple Players",
                desc = "If another player is detected using the same ability, a duplicate icon will be created and tracked separately",
                width = "normal",
                type = "toggle",
                order = 11,
            },
            glow = {
                name = "Glow Icons",
                desc = "Display a glow animation around an icon when it is activated",
                width = "normal",
                type = "toggle",
                order = 12,
            },
            lineBreak2 = {
                name = "",
                type = "description",
                order = 13,
            },
            align = {
                name = "Alignment",
                desc = "Set the alignment of the icons to the anchor",
                type = "select",
                values = {
                    CENTER = "Center",
                    LEFT = "Left",
                    RIGHT = "Right",
                },
                set = function(info, state)
                    print(info)
                end,
                order = 14,
            },
            lineBreak3 = {
                name = "",
                type = "description",
                order = 15,
            },
            size = {
                name = "Size",
                desc = "Set the size of the icons",
                type = "range",
                min = 0.1,
                max = 2.7,
                step = 0.05,
                width = "double",
                order = 16,
                get = function (info) return self.db.profile.bars[barKey].scale end,
                set = function(info, value) 
                  --  local scaleRatio = value / 36 -- default size
                    self.db.profile.bars[barKey].scale = value 
                    self:UpdateBar(barKey, "scale")
                end,
            },
            sizeDesc = {
                name = "Set the size of the icons" .. "\n",
                type = "description",
                order = 17,
            },
            columns = {
                name = "Columns",
                desc = "Set the maximum icons per row",
                type = "range",
                min = 1,
                max = 100,
                step = 1,
                width = "double",
                get = function() return self.db.profile.bars[barKey].maxIconsPerRow end,
                set = function(info, value)
                    self.db.profile.bars[barKey].maxIconsPerRow = value
                    self:UpdateBar(barKey, "arrangeIcons")
                end,
                order = 18,
            },
            columnsDesc = {
                name = "Set the maximum icons per row" .. "\n",
                type = "description",
                order = 19,
            },
            maxIcons = {
                name = "Icon Limit",
                desc = "Set the maximum number of icons displayed on the bar",
                type = "range",
                min = 1,
                max = 500,
                step = 1,
                width = "double",
                get = function() return self.db.profile.bars[barKey].maxIconsTotal end,
                set = function(info, value)
                    self.db.profile.bars[barKey].maxIconsTotal = value
                    self:UpdateBar(barKey)
                end,
                order = 20,
            },
            maxIconsDesc = {
                name = "Set the maximum number of icons displayed on the bar" .. "\n",
                type = "description",
                order = 21,
            },
            margin = {
                name = "Margin",
                desc = "Set the space between icons",
                type = "range",
                min = 0,
                max = 100,
                step = 1,
                width = "double",
                get = function() return self.db.profile.bars[barKey].margin end,
                set = function(info, value)
                    self.db.profile.bars[barKey].margin = value
                    self:UpdateBar(barKey, "arrangeIcons")
                end,
                order = 22,
            },
            paddingDesc = {
                name = "Set the space between icons" .. "\n",
                type = "description",
                order = 23,
            },
            unusedAlpha = {
                name = "Unused Icon Transparency",
                desc = "Set the transparency of unused icons",
                isPercent = true,
                type = "range",
                min = 0,
                max = 1,
                step = 0.01,
                width = "double",
                order = 24,
            },
            unusedAlphaDesc = {
                name = "Set the transparency of unused icons" .. "\n",
                type = "description",
                order = 25,
            },
            swipeAlpha = {
                name = "Swipe Transparency",
                desc = "Set the transparency of the swipe animation",
                isPercent = true,
                type = "range",
                min = 0,
                max = 1,
                step = 0.01,
                width = "double",
                order = 26,
            },
            swipeAlphaDesc = {
                name = "Set the transparency of the swipe animation" .. "\n",
                type = "description",
                order = 27,
            },
        }
    }

    local trackedCooldowns = self.db.profile.bars[barKey].cooldowns 
    local i = 1;
    for className, cooldowns in pairs(trackedCooldowns) do
        local tcordKey = addon.CLASS_NAME_TO_TCOORDS_KEY[className]
        self.options.args[barKey].args[className] = {
            type="group",
            name = className,
            order = i,
            icon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes",
            iconCoords = CLASS_ICON_TCOORDS[tcordKey],
            args = {}
        }

        if className == "General" then
            self.options.args[barKey].args[className]["icon"] = "Interface\\Icons\\Trade_Engineering"
			self.options.args[barKey].args[className]["iconCoords"] = nil
			self.options.args[barKey].args[className]["order"] = 0
        end

        for cooldownName, cooldownData in pairs(cooldowns) do
            self.options.args[barKey].args[className].args[cooldownName]= {
                type = "toggle",
                width = "normal",
                name = function()
                    return format("|T%s:20|t %s", cooldownData.icon, cooldownName)
                end,
                desc = function(self)
                    local isItem = cooldownData.item or false
                    local spellDescription = GetSpellTooltipDescription(cooldownData.spellId, isItem) or "No description available"
                    local cooldownText = cooldownData.duration > 0 and SecondsToTime(cooldownData.duration) or "Instant"
                    
                    local extra = "\n\n|cffffd700 ".."Cooldown:".."|r "..cooldownText..
                    "\n\n|cffffd700 ".."Spell ID:".."|r "..cooldownData.spellId
                    
                    local tooltip = string.format(
                        "\n|cffffd700Cooldown:|r %s\n\n%s\n\n|cffffd700Spell ID:|r %d",
                        cooldownText,
                        spellDescription,
                        cooldownData.spellId
                    )

                   return tooltip
                  -- return spellDescription..extra
                end,
                get = function() return cooldownData.isTracking end,
                set = function(info, value) 
                    cooldownData.isTracking = value
                    self:UpdateBar(barKey)
                end
            }
        end
        i = i + 1
    end
    -- Refresh the options UI to reflect the changes
    LibStub("AceConfigRegistry-3.0"):NotifyChange("OmniBar")
end




