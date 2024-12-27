
local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")

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
                func = function(info)
                    self:CreateBar()
                end,
            },
            testButton = {
                order = 3,
                type = "execute",
                name = "Test bars",
                desc = "Tests all bars",
                width = 0.7,
                func = function(info)
                    print("Testing mode enabled...") 
                end,
            },
            general = {
                type = "group",
                name = "General Settings",
                order = 0,
                args = {
                    lockBars = {
                        type = "toggle",
                        name = "Lock Bar Positions",
                        desc = "When enabled, prevents bars from being moved around.",
                        set = function(info, value) self.db.profile.lockBars = value end,
                        get = function(info) return self.db.profile.lockBars end,
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
                    sliderOption = {
                        type = "range",
                        name = "Slider Option",
                        min = 0,
                        max = 100,
                        step = 1,
                        set = function(info, value) self.db.profile.sliderOption = value end,
                        get = function(info) return self.db.profile.sliderOption end,
                        order = 4,
                    },
                },
            },
        },
    }

    LibStub("AceConfig-3.0"):RegisterOptionsTable("OmniBar", self.options)
 
    -- Add the options table to Blizzard's options UI
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("OmniBar", "OmniBar")
 
    -- Register a chat command to open the options UI
    self:RegisterChatCommand("ob", function()
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    end)
 
end