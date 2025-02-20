local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local wipe = wipe

function OmniBar:SetupOptions()
    self.options = {
        type = "group",
        name = "OmniBar Options",
        args = {
            Desc = {
                type = "description",
                order = 1,
                name = "OmniBar is a simple cooldown tracking addon for World of Warcraft. Originally created by Jordan, it has been completely rewritten by Oscargforce for 3.3.5. https://github.com/oscargforce for questions or feedback.",
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
                func = function(info, v)
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
                        get = function(info) return self.db.profile.showOutOfRangeMessages end,
                        set = function(info, value) self.db.profile.showOutOfRangeMessages = value end,
                        order = 1,
                    },
                    showInArena = {
                        type = "toggle",
                        name = "Show Bars in Arena",
                        desc = "Enable this option to show the cooldown bars in arena matches.",
                        set = function(info, value) self.db.profile.showInArena = value end,
                        get = function(info) return self.db.profile.showInArena end,
                        order = 2,
                    },
                    showInWorld = {
                        type = "toggle",
                        name = "Show in World and Battlegrounds",
                        desc = "Enable this option to show the cooldown bars in the world and battlegrounds.",
                        set = function(info, value) self.db.profile.showInWorld = value end,
                        get = function(info) return self.db.profile.showInWorld end,
                        order = 3,
                    },
                    fontHeader = {
                        order = 4,
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
                        set = function(info, value) 
                            self.db.profile.fontStyle = value
                            self:UpdateCountdownFont() 
                        end,
                        get = function(info) return self.db.profile.fontStyle end,
                        order = 5,
                    },
                    fontSize = {
                        type = "range",
                        name = "Set Font Size",
                        desc = "Set the font size for the cooldown text.",
                        min = 10,
                        max = 20,
                        step = 1,
                        set = function(info, value) 
                            self.db.profile.fontSize = value
                            self:UpdateCountdownFont() 
                        end,
                        get = function(info) return self.db.profile.fontSize end,
                        order = 5,
                    },
                },
            },
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

