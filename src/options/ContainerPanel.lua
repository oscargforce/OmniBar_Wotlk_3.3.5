local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local wipe = wipe
local LibStub = LibStub

function OmniBar:SetupOptions()
    self.options = {
        type = "group",
        name = "OmniBar Options",
        args = {
            Desc = {
                type = "description",
                order = 1,
                name = "Rewritten OmniBar for 3.3.5 by Oscargforce. https://github.com/oscargforce for questions or feedback.",
            },
            header = {
                order = 2,
                type = "header",
                name = "OmniBar v1.0.0",
            }, 
            createBarButton = {
                order = 3,
                type = "execute",
                name = "Create Bar",
                desc = "Create a new bar",
                width = 0.7,
                func = function()
                    self:CreateBar()
                end,
            },
            testButton = {
                order = 3,
                type = "execute",
                name = function() 
                    return self.testModeEnabled and "Stop Testing" or "Test Bars"
                end,
                desc = "Tests all bars",
                width = 0.7,
                func = function()
                    if not self.testModeEnabled then
                        self:OpenTestPanel()
                    else
                        self:StopTestMode()
                    end
                end,
            },
            lockBarsButton = {
                order = 4,
                type = "execute",
                name = function()
                    return self.db.profile.isBarsLocked and "Unlock Bars" or "Lock Bars" 
                end,
                desc = "Lock all bars positions",
                width = 0.65,
                func = function()
                    self.db.profile.isBarsLocked = not self.db.profile.isBarsLocked
                    local isBarsLocked = self.db.profile.isBarsLocked

                    for barKey, barFrame in pairs(self.barFrames) do
                        barFrame.anchor:SetMovable(not isBarsLocked)
                        barFrame.anchor:EnableMouse(not isBarsLocked)
                        self:ToggleAnchorVisibility(barFrame)      
                        self:ToggleIconLock(barFrame, isBarsLocked)        
                    end
                end,
            },
            general = {
                type = "group",
                name = "General Settings",
                order = 0,
                args = {
                    showOutOfRangeMessages = {
                        type = "toggle",
                        name = "Show Out of Range Messages",
                        desc = "When enabled, a message will be displayed when OmniBar is out of range to inspect a unit.",
                        get = function() return self.db.profile.showOutOfRangeMessages end,
                        set = function(info, value) self.db.profile.showOutOfRangeMessages = value end,
                        order = 1,
                    },
                    fontHeader = {
                        order = 2,
                        type = "header",
                        name = "Font Settings",
                    }, 
                    fontStyle = {
                        type = "select",
                        name = "Set Font Style",
                        desc = "Select the font style for the cooldown text.",
                        values = {
                            ["Fonts\\FRIZQT__.TTF"] = "Friz Quadrata TT",
                            ["Fonts\\ARIALN.TTF"] = "Arial Narrow",
                            ["Fonts\\MORPHEUS.TT"] = "Morpheus",
                            ["Fonts\\SKURRI.TTF"] = "Skurri", 
                        },
                        get = function() return self.db.profile.fontStyle end,
                        set = function(info, value) self.db.profile.fontStyle = value end,
                        order = 3,
                    },
                    lineBreak1 = {
                        name = " ",
                        type = "description",
                        order = 4,
                    },
                    descColor = {
                        name = "Color and Font Size Settings",
                        type = "description",
                        order = 5,
                    },
                    lineBreak2 = {
                        name = " ",
                        type = "description",
                        order = 6,
                    },
                    fontColorExpire = {
                        type = "color",
                        name = "Soon to Expire",
                        desc = "Set the font color for cooldowns equal to or under 5 seconds.",
                        get = function() 
                            local color = self.db.profile.fontColorExpire
                            return color.r, color.g, color.b, color.a
                        end,
                        set = function(info, r, g, b, a) 
                            self.db.profile.fontColorExpire = { r = r, g = g, b = b, a = a } 
                        end,
                        order = 7,
                    },
                    fontSizeExpire = {
                        type = "range",
                        name = "Soon to Expire Font Size",
                        desc = "Set the font size for cooldown text when the timer is 5 seconds or less.",
                        width = "double",
                        min = 10,
                        max = 30,
                        step = 1,
                        get = function() return self.db.profile.fontSizeExpire end,
                        set = function(info, value) 
                            self.db.profile.fontSizeExpire = value end,
                        order = 8,
                    },
                    fontColorSeconds = {
                        type = "color",
                        name = "Under a Minute",
                        desc = "Set the font color for cooldowns under 60 seconds.",
                        get = function() 
                            local color = self.db.profile.fontColorSeconds
                            return color.r, color.g, color.b, color.a
                        end,
                        set = function(info, r, g, b, a)
                            self.db.profile.fontColorSeconds = { r = r, g = g, b = b, a = a } 
                        end,
                        order = 9,
                    },
                    fontSizeSeconds = {
                        type = "range",
                        name = "Under a Minute Font Size",
                        desc = "Set the font size for cooldown text under 60 seconds.",
                        width = "double",
                        min = 10,
                        max = 20,
                        step = 1,
                        get = function() return self.db.profile.fontSizeSeconds end,
                        set = function(info, value) self.db.profile.fontSizeSeconds = value end,
                        order = 10,
                    },
                    fontColorMinutes = {
                        type = "color",
                        name = "Minutes",
                        desc = "Set the font color for cooldowns displayed in minutes.",
                        get = function()
                            local color = self.db.profile.fontColorMinutes 
                            return color.r, color.g, color.b, color.a
                        end,
                        set = function(info, r, g, b, a) 
                            self.db.profile.fontColorMinutes = { r = r, g = g, b = b, a = a } 
                        end,
                        order = 11,
                    },
                    fontSizeMinutes = {
                        type = "range",
                        name = "Minutes Font Size",
                        desc = "Set the font size for cooldown text displayed in minutes.",
                        width = "double",
                        min = 10,
                        max = 20,
                        step = 1,
                        get = function() return self.db.profile.fontSizeMinutes end,
                        set = function(info, value) self.db.profile.fontSizeMinutes = value end,
                        order = 12,
                    },                    
                },
            },
            profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db) 
        },
    }

    LibStub("AceConfig-3.0"):RegisterOptionsTable("OmniBar", self.options)
 
    -- Add the options table to Blizzard's options UI
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("OmniBar", "OmniBar")
 
    -- Register slash commands
    self:RegisterChatCommand("ob", function(input)
        local command = input and input:trim():lower() or ""
        if command == "reset" then
            wipe(self.combatLogCache)
            self:RefreshBarsWithActiveIcons()
        elseif command == "test" then
            self:OpenTestPanel()
        elseif command == "test stop" then
            self:StopTestMode()
        else
            -- Default behavior - open options
            InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
        end

    end)
 
end

