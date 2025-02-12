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
                name = "Test bars",
                desc = "Tests all bars",
                width = 0.7,
                func = function()
                    self:OpenTestPanel()
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
                    lockBars = {
                        type = "toggle",
                        name = "Lock Bar Positions",
                        desc = "When enabled, prevents bars from being moved around.",
                        set = function(info, value) self.db.profile.lockBars = value end,
                        get = function(info) return self.db.profile.lockBars end,
                        order = 2,
                    },
                    showInArena = {
                        type = "toggle",
                        name = "Show Bars in Arena",
                        desc = "Enable this option to show the cooldown bars in arena matches.",
                        set = function(info, value) self.db.profile.showInArena = value end,
                        get = function(info) return self.db.profile.showInArena end,
                        order = 3,
                    },
                    showInWorld = {
                        type = "toggle",
                        name = "Show in World and Battlegrounds",
                        desc = "Enable this option to show the cooldown bars in the world and battlegrounds.",
                        set = function(info, value) self.db.profile.showInWorld = value end,
                        get = function(info) return self.db.profile.showInWorld end,
                        order = 4,
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
        else
            -- Default behavior - open options
            InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
        end

    end)
 
end

