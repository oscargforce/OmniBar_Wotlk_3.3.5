local addonName, addon = ...

addon.resetCds = {
    ["Readiness"] = {
        ["Chimera Shot"] = true
    }
}


--[[
    The `showWhenHidden` flag is used to display shared cooldowns for bars where `showUnusedIcons` is disabled.
    It helps to avoid cluttering the UI by only showing the most important shared cooldowns when icons are hidden.

    Note: Only set `sharedDuration` if it differs from the default or talent-specific duration of the spell.
    For example, "Will of the Forsaken" shares a 45-second cooldown with the PvP trinket, while its default cooldown is 2 minutes.
]]
addon.sharedCds = {
    -- PvP Trinkets
    ["PvP Trinket"] = {
        ["Will of the Forsaken"] = { sharedDuration = 45, showWhenHidden = true },
    }, 
    ["Will of the Forsaken"] = {
        ["PvP Trinket"] = { sharedDuration = 45, showWhenHidden = true },
    }, 

    -- Druid
    ["Feral Charge - Bear"] = {
        ["Feral Charge - Cat"] = {},
    }, 
    ["Feral Charge - Cat"] = {
        ["Feral Charge - Bear"] = {},
    }, 

    -- Hunter
    ["Freezing Arrow"] = {
        ["Freezing Trap"] = {},
        ["Frost Trap"] = {},
    },
    ["Frost Trap"] = {
        ["Freezing Trap"] = {},
        ["Freezing Arrow"] = {},
    },
    ["Freezing Trap"] = {
        ["Freezing Arrow"] = {},
        ["Frost Trap"] = {},
    },
    ["Immolation Trap"] = {
        ["Explosive Trap"] = {},
    },
    ["Explosive Trap"] = {
        ["Immolation Trap"] = {},
    },

    -- Paladin
    ["Avenging Wrath"] = {
        ["Divine Protection"] = { sharedDuration = 30 },
        ["Divine Shield"] = { sharedDuration = 30, showWhenHidden = true },
        ["Lay on Hands"] = { sharedDuration = 30 },
    },
    ["Divine Protection"] = {
        ["Avenging Wrath"] = { sharedDuration = 30 },
    },
    ["Divine Shield"] = {
        ["Avenging Wrath"] = { sharedDuration = 30 },
    },
    ["Lay on Hands"] = {
        ["Avenging Wrath"] = { sharedDuration = 30 },
    },
    
    -- Warrior
    ["Shield Bash"] = {
        ["Pummel"] = { sharedDuration = 12 }
    },
    ["Pummel"] = {
        ["Shield Bash"] = { sharedDuration = 10 }
    },
    ["Recklessness"] = {
        ["Shield Wall"] = { sharedDuration = 12, showWhenHidden = true },
        ["Retaliation"] = { sharedDuration = 12 },
    },
    ["Shield Wall"] = {
        ["Recklessness"] = { sharedDuration = 12 },
        ["Retaliation"] = { sharedDuration = 12 },
    },
    ["Retaliation"] = {
        ["Shield Wall"] = { sharedDuration = 12, showWhenHidden = true },
        ["Recklessness"] = { sharedDuration = 12 },
    },
}

--[[
-- add this in oncooldownused
function OmniBar:ResetCooldownsForSpell(barFrame, spellName)
    local resetSpells = addon.resetCds[spellName]
    if not resetSpells then return end

    for i, icon in ipairs(barFrame.icons) do
        -- Check if this icon's spell should be reset
        if resetSpells[icon.spellName] and barFrame.activeIcons[icon] then
            print("Resetting cooldown for", icon.spellName)
            -- Reset the cooldown
            self:ResetIconState(icon)
            barFrame.activeIcons[icon] = nil
            
            if not self.db.profile.bars[barFrame.key].showUnusedIcons then
                self:ReturnIconToPool(icon)
                table.remove(barFrame.icons, i)
            else
                self:UpdateUnusedAlpha(barFrame, self.db.profile.bars[barFrame.key], icon)
            end
        end
    end
    
    self:ArrangeIcons(barFrame, self.db.profile.bars[barFrame.key])
end


]]