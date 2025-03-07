local addonName, addon = ...
local spellTable = addon.spellTable

local function isEmptyString(s)
    return s:gsub("^%s*(.-)%s*$", "%1") == ""
end

StaticPopupDialogs["OMNIBAR_DELETE"] = {
	text = DELETE.." \"%s\"",
	button1 = YES,
	button2 = NO,
	OnAccept = function(self, data)
		OmniBar:DeleteBar(data)
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
            copyFrom = {
                name = "Copy From:",
                type = "select",
                desc = "Copies all settings/spells from the selected OmniBar",
                values = function()
                    local barKeys = {}
                    local currentBarKey = barKey
                
                    for key, barSettings in pairs(self.db.profile.bars) do
                        if key ~= currentBarKey then
                            barKeys[key] = barSettings.name
                        end
                    end

                    return barKeys
                end,
                get = function() return "" end,
                set = function(info, selectedBarKey)
                    local bars = self.db.profile.bars
                    local selectedBar = bars[selectedBarKey]
                    local targetBar = bars[barKey]
                    local barFrame = self.barFrames[barKey]

                    local copiedSettings = self:DeepCopyTable(selectedBar)
                    copiedSettings.name = targetBar.name
                    copiedSettings.position = {
                        point = targetBar.position.point,
                        relativePoint = targetBar.position.relativePoint,
                        x = targetBar.position.x,
                        y = targetBar.position.y,
                    }

                    bars[barKey] = copiedSettings
                    self:BuildTrackedSpells(barFrame, copiedSettings)
                    self:InitializeEventsTracking(barFrame, copiedSettings)
                    print(string.format("|cff00ff00OmniBar copied settings from |cffffd700%s |cff00ff00to |cffffd700%s|r", selectedBar.name, targetBar.name))
                end,
                order = 1,
            },
            name = {
                name = "Name",
                desc = "Set the name of the bar",
                type = "input",
                width = "double",
                get = function() return self.db.profile.bars[barKey].name end,
                set = function(info, value)
                    self.db.profile.bars[barKey].name = value
                    self.options.args[barKey].name = value
                    self:UpdateBarName(barKey)
                end,
                order = 2,
            },
            trackedUnit = {
                name = "Track",
                type = "select",
                desc = "Choose the unit to track cooldowns for",
                values = {
                    ["allEnemies"] = "All Enemies",
                    ["target"] = "Target",
                    ["focus"] = "Focus",
                    ["arena1"] = "Arena1", 
                    ["arena2"] = "Arena2",
                    ["arena3"] = "Arena3",
                    ["arena4"] = "Arena4",
                    ["arena5"] = "Arena5",
                    ["party1"] = "Party1",
                    ["party2"] = "Party2",
                    ["party3"] = "Party3",
                    ["party4"] = "Party4",
                },
                get = function() return self.db.profile.bars[barKey].trackedUnit end,
                set = function(info, value)
                    self.db.profile.bars[barKey].trackedUnit = value
                    self:UpdateTrackedUnit(barKey)
                end,
                order = 2,
            },
            iconSortingMethod = {
                name = "Sort Icons By",
                type = "select",
                desc = "Sort icons by remaining time or the time they were added to the bar.\n\n|cFFFFFF00Note:|r This feature is only available when |cFFFF0000'Show Unused Icons'|r is disabled. Otherwise, icons are sorted by priority.",
                values = {
                    ["remainingTime"] = "Remaining time",
                    ["timeAdded"] = "Time added",
                },
                get = function() return self.db.profile.bars[barKey].iconSortingMethod end,
                set = function(info, value)
                    local barSettings = self.db.profile.bars[barKey]
                    barSettings.iconSortingMethod = value
                    self:ArrangeIcons(self.barFrames[barKey], barSettings)
                end,
                disabled = function() return self.db.profile.bars[barKey].showUnusedIcons end,
                order = 3,
            },
            glowSetting = {
                name = "Glow Animation for Icons",
                desc = "Choose whether to display a glow animation around an icon when it is activated.",
                type = "select",
                width = "normal",
                values = {
                    ["none"] = "None",
                    ["omnicd"] = "OmniCD",
                    ["default"] = "Default",
                },
                get = function() return self.db.profile.bars[barKey].glowSetting end,
                set = function(info, value)
                    self.db.profile.bars[barKey].glowSetting = value
                end,
                order = 4,
            },
            iconAlignment = {
                name = "Icon Alignment",
                desc = "Choose how icons align within the bar:\n\n" ..
                        "1) |cFFFFFF00Center|r – The default OmniBar layout. Icons grow from the middle.\n\n" ..
                        "2) |cFFFFFF00Left|r – Icons grow from the left side of the anchor.\n\n" ..
                        "3) |cFFFFFF00Right|r – Icons grow from the right side of the anchor.\n\n" ..
                        "|cFF00FF00Recommended for party units: Left or Right alignment|r",
                type = "select",
                values = {
                    CENTER = "Center",
                    LEFT = "Left",
                    RIGHT = "Right",
                },
                get = function() return self.db.profile.bars[barKey].iconAlignment end,
                set = function(info, value)
                    local barSettings = self.db.profile.bars[barKey]
                    local barFrame = self.barFrames[barKey]

                    barSettings.iconAlignment = value
                    self:ArrangeIcons(barFrame, barSettings)
                end,
                order = 5,
            },
            lineBreak3 = {
                name = "",
                type = "description",
                order = 6,
            },
            showUnusedIcons = {
                name = "Show Unused Icons",
                desc = "Icons will always remain visible",
                width = "normal",
                type = "toggle",
                get = function() return self.db.profile.bars[barKey].showUnusedIcons end,
                set = function(info, value)
                    local barSettings = self.db.profile.bars[barKey]
                    barSettings.showUnusedIcons = value
                    self:StopTestMode()
                    self:RefreshIconVisibility(self.barFrames[barKey], barSettings)
                end,
                order = 7,
            },
            growUpward = {
                name = "Grow Rows Upward",
                desc = "Toggle the grow direction of the icons",
                width = "normal",
                type = "toggle",
                get = function() return self.db.profile.bars[barKey].isRowGrowingUpwards end,
                set = function(info, value)
                    self.db.profile.bars[barKey].isRowGrowingUpwards = value
                    local barFrame, barSettings = self:GetBarData(barKey)
                    self:ArrangeIcons(barFrame, barSettings, true)
                end,
                order = 8,
            },
            customCountdownText = {
                name = "Custom Countdown Text",
                desc = "Enable custom countdown text positioning and styling.\n\n" ..
                       "Example: Offset the countdown text horizontally for an |cFFFF0000Afflicted|r addon-style appearance.\n\n" ..
                       "|cFFFFD100Note:|r This will disable OmniCC for this bar to prevent duplicate timers.\n\n" ..
                       "Use the added dropdown to adjust text position and appearance.",
                width = "normal",
                type = "toggle",
                get = function() return self.db.profile.bars[barKey].customCountdownText end,
                set = function(info, value)
                    self.db.profile.bars[barKey].customCountdownText = value
                end,
                order = 9,
            },
            countdownTextXOffset = {
                name = "Countdown Text Position",
                desc = "Offset the countdown text horizontally for an |cFFFF0000Afflicted|r addon-style appearance.\n\n|cFFFFD100Note:|r Adjust the 'margin' slider to control vertical spacing between icons.",
                type = "select",
                width = "normal",
                values = {
                    [0] = "Center",
                    [34] = "Right",
                    [-34] = "Left",
                },
                get = function() return self.db.profile.bars[barKey].countdownTextXOffset end,
                set = function(info, value)
                    self.db.profile.bars[barKey].countdownTextXOffset = value
                    local barFrame = self.barFrames[barKey]

                    for _, icon in ipairs(barFrame.icons) do
                        icon.countdownText:SetPoint("CENTER", icon.countdownFrame, "CENTER", value, 0)
                    end

                    self:ArrangeIcons(barFrame, self.db.profile.bars[barKey])
                end,
                order = 10,
                hidden = function() return not self.db.profile.bars[barKey].customCountdownText end,
            },
            border = {
                name = "Show Border",
                desc = "Draw a border around the icons",
                width = "normal",
                type = "toggle",
                order = 11,
                get = function() return self.db.profile.bars[barKey].showBorder end,
                set = function(info, value)
                    self.db.profile.bars[barKey].showBorder = value
                    self:UpdateBorders(barKey)
                end
            },
            highlightTarget = {
                name = "Highlight Target",
                desc = "Draw a border around your target icon cooldowns",
                width = "normal",
                type = "toggle",
                order = 12,  
                get = function() return self.db.profile.bars[barKey].highlightTarget end, 
                set = function(info, value)
                    self.db.profile.bars[barKey].highlightTarget = value
                    self:UpdateHighlightVisibility(self.barFrames[barKey], value, "target")
                end,
                disabled = function() return self.db.profile.bars[barKey].trackedUnit ~= "allEnemies" end,
            },
            targetHighlightColor = {
                name = "Highlight Target Color",
                desc = "Pick a color for the target highlight, defaults to purple",
                width = "normal",
                type = "color",
                order = 13,  
                get = function()  
                    local color = self.db.profile.bars[barKey].targetHighlightColor
                    return color.r, color.g, color.b, color.a
                end, 
                set = function(info, r, g, b, a)
                    self.db.profile.bars[barKey].targetHighlightColor = { r = r, g = g, b = b, a = a }
                    self:UpdateTargetHighlightColor(self.barFrames[barKey], r, g, b, a)
                end,
                hidden = function() return not self.db.profile.bars[barKey].highlightTarget or self.db.profile.bars[barKey].trackedUnit ~= "allEnemies"  end,
            },
            highlightFocus = {
                name = "Highlight Focus",
                desc = "Draw a border around your focus icon cooldowns",
                width = "normal",
                type = "toggle",
                order = 14,
                get = function() return self.db.profile.bars[barKey].highlightFocus end,   
                set = function(info, value)
                    self.db.profile.bars[barKey].highlightFocus = value
                    self:UpdateHighlightVisibility(self.barFrames[barKey], value, "focus")
                end,
                disabled = function() return self.db.profile.bars[barKey].trackedUnit ~= "allEnemies" end,
            },
            focusHighlightColor = {
                name = "Highlight Focus Color",
                desc = "Pick a color for the focuys highlight, defaults to yellow",
                width = "normal",
                type = "color",
                order = 15,  
                get = function() 
                    local color = self.db.profile.bars[barKey].focusHighlightColor 
                    return color.r, color.g, color.b, color.a
                end, 
                set = function(info, r, g, b, a)
                    self.db.profile.bars[barKey].focusHighlightColor = { r = r, g = g, b = b, a = a }
                    self:UpdateFocusHighlightColor(self.barFrames[barKey], r, g, b, a)
                end,
                hidden = function() return not self.db.profile.bars[barKey].highlightFocus or self.db.profile.bars[barKey].trackedUnit ~= "allEnemies" end,
            },
            showNames = {
                name = "Show Names",
                desc = "Show the player name of the spell",
                width = "normal",
                type = "toggle",
                order = 15.5,  
                get = function() return self.db.profile.bars[barKey].showNames end, 
                set = function(info, value)
                    self.db.profile.bars[barKey].showNames = value
                end,
                disabled = function() return self.db.profile.bars[barKey].trackedUnit ~= "allEnemies" end,
            },
            showInWorld = {
                name = "Show in World",
                desc = "Enable/disable the bar in the world",
                width = "normal",
                type = "toggle",
                order = 15.6,  
                get = function() return self.db.profile.bars[barKey].showInWorld end, 
                set = function(info, value)
                    self.db.profile.bars[barKey].showInWorld = value
                    self:SetBarVisibilityForZone()
                end,
            },
            showInArenas = {
                name = "Show in Arenas",
                desc = "Enable/disable the bar in arenas",
                width = "normal",
                type = "toggle",
                order = 15.7,  
                get = function() return self.db.profile.bars[barKey].showInArenas end, 
                set = function(info, value)
                    self.db.profile.bars[barKey].showInArenas = value
                    self:SetBarVisibilityForZone()
                end,
            },
            showInBgs = {
                name = "Show in Battlegrounds",
                desc = "Enable/disable the bar in battlegrounds",
                width = "normal",
                type = "toggle",
                order = 15.8,  
                get = function() return self.db.profile.bars[barKey].showInBgs end, 
                set = function(info, value)
                    self.db.profile.bars[barKey].showInBgs = value
                    self:SetBarVisibilityForZone()
                end,
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
                    self.db.profile.bars[barKey].scale = value 
                    self:UpdateScale(barKey, value)
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
                    self:UpdateColumns(barKey)
                end,
                order = 18,
            },
            columnsDesc = {
                name = "Set the maximum icons per row" .. "\n",
                type = "description",
                order = 19,
            },
            maxIconsTotal = {
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
                    self:UpdateMaxIcons(barKey)
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
                    local barSettings = self.db.profile.bars[barKey]
                    barSettings.margin = value
                    self:ArrangeIcons(self.barFrames[barKey], barSettings, true)
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
                get = function() return self.db.profile.bars[barKey].unusedAlpha end,
                set = function(info, value)
                    self.db.profile.bars[barKey].unusedAlpha = value
                    local barFrame, barSettings = self:GetBarData(barKey)
                    self:UpdateUnusedAlpha(barFrame, barSettings)
                end,
                disabled = function() return not self.db.profile.bars[barKey].showUnusedIcons end,  -- Disable if classicons is false
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
                get = function() return self.db.profile.bars[barKey].swipeAlpha end,
                set = function(info, value)
                    self.db.profile.bars[barKey].swipeAlpha = value
                    local barFrame, barSettings = self:GetBarData(barKey)
                    self:UpdateSwipeAlpha(barFrame, barSettings)
                end,
            },
            swipeAlphaDesc = {
                name = "Set the transparency of the swipe animation" .. "\n",
                type = "description",
                order = 27,
            },
        }
    }

    local i = 1;
    for className, spells in pairs(spellTable) do
        local tcordKey = addon.CLASS_NAME_TO_TCOORDS_KEY[className]
        self.options.args[barKey].args[className] = {
            type="group",
            name = className,
            order = i,
            icon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes",
            iconCoords = CLASS_ICON_TCOORDS[tcordKey],
            childGroups = "tab",
            args = {
                spellsTab = {
                    type = "group",
                    name = "Spells", 
                    order = 1,
                    args = {} 
                },
                priorityTab = {
                    type = "group",
                    name = "Priority",
                    desc = "Adjust icon positions on the bar.",
                    order = 2,
                    args = {
                        desc = {
                            type = "description",
                            order = 0,
                            name = "|cFFFFD100Enable|r |cFFFF0000'Show Unused Icons'|r and track spells for this class to configure their priority order.\n\n|cFF00FF00Higher priority|r items are positioned closer to the first icon on the bar.",
                        },
                    } 
                },
            }
        }

        if className == "General" then
            self.options.args[barKey].args[className]["icon"] = "Interface\\Icons\\Trade_Engineering"
			self.options.args[barKey].args[className]["iconCoords"] = nil
			self.options.args[barKey].args[className]["order"] = 0
        end

        for spellName, spellData in pairs(spells) do
            self.options.args[barKey].args[className].args.spellsTab.args[spellName] = {
                type = "toggle",
                width = "normal",
                name = function()
                    return format("|T%s:20|t %s", spellData.icon, spellName)
                end,
                desc = function(self)
                    local isItem = spellData.item or false
                    local spellDescription = GetSpellTooltipDescription(spellData.spellId, isItem) or "No description available"
                    local cooldownText = spellData.duration > 0 and SecondsToTime(spellData.duration) or "Instant"
                    
                    local extra = "\n\n|cffffd700 ".."Cooldown:".."|r "..cooldownText..
                    "\n\n|cffffd700 ".."Spell ID:".."|r "..spellData.spellId
                    
                    local tooltip = string.format(
                        "\n|cffffd700Cooldown:|r %s\n\n%s\n\n|cffffd700Spell ID:|r %d",
                        cooldownText,
                        spellDescription,
                        spellData.spellId
                    )

                   return tooltip
                  -- return spellDescription..extra
                end,
                get = function()  
                    local bar = self.db.profile.bars[barKey]
    
                    -- If the class table doesn't exist yet, just return the default value without creating any structures
                    if not bar.cooldowns[className] then
                        return false
                    end
                    
                    -- If the specific cooldown doesn't exist yet, return the default value without creating it
                    if bar.cooldowns[className][spellName] == nil then
                        return false
                    end
                
                    -- Return the saved value if it exists
                    return bar.cooldowns[className][spellName].isTracking
                end,
                set = function(info, isChecked) 
                    local bar = self.db.profile.bars[barKey]
                    if not bar.cooldowns[className] then
                        bar.cooldowns[className] = {}
                    end

                    if not bar.cooldowns[className][spellName] then
                        bar.cooldowns[className][spellName] = {}
                    end
                    -- Set the value for this spellName
                    local spellConfig = bar.cooldowns[className][spellName]
                    spellConfig.isTracking = isChecked
                    self:UpdateSpellTracking(barKey, isChecked, spellName, className, spellConfig)
                end
            }
        
            self.options.args[barKey].args[className].args.priorityTab.args[spellName] = {
                name = spellName,
                desc = "Set the position for the spell on the bar",
                type = "range",
                min = 1,
                max = 100,
                step = 1,
                width = "double",
                get = function() 
                    local bar = self.db.profile.bars[barKey]
                    if not bar.cooldowns[className] then
                        return false
                    end
                    if bar.cooldowns[className][spellName] == nil then
                        return false
                    end
                    return bar.cooldowns[className][spellName].priority
                end,
                set = function(info, value)
                    self.db.profile.bars[barKey].cooldowns[className][spellName].priority = value
                    self:UpdatePriority(barKey)
                    
                end,
                disabled = function ()
                    local bar = self.db.profile.bars[barKey]
                    if not bar.cooldowns[className] or not bar.cooldowns[className][spellName] then
                        return true
                    end
                    return not bar.cooldowns[className][spellName].isTracking or not bar.showUnusedIcons
                end,
                order = i,
            }

        end

        i = i + 1
    end
    -- Refresh the options UI to reflect the changes
    LibStub("AceConfigRegistry-3.0"):NotifyChange("OmniBar")
end