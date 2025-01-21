local addonName, addon = ...

addon.resetCds = {
    ["Readiness"] = {
        ["Chimera Shot"] = true
    }
}

-- showWhenHidden is used to display shared cooldowns for bars that have showUnusedIcons disabled.
-- It is unnecessary to show all shared cooldowns if icons are hidden, as it would only clutter your UI.
-- Therefore, only the most important shared cooldowns are shown when icons are hidden.
addon.sharedCds = {
    -- PvP Trinkets
    ["PvP Trinket"] = {
        ["Will of the Forsaken"] = { duration = 45, showWhenHidden = true },
    }, 
    ["Will of the Forsaken"] = {
        ["PvP Trinket"] = { duration = 45, showWhenHidden = true },
    }, 

    -- Druid
    ["Feral Charge - Bear"] = {
        ["Feral Charge - Cat"] = { duration = 45 }
    }, 
    ["Feral Charge - Cat"] = {
        ["Feral Charge - Bear"] = { duration = 45 }
    }, 

    -- Hunter
    ["Freezing Arrow"] = {
        ["Freezing Trap"] = { duration = 28 },
        ["Frost Trap"] = { duration = 28 },
    },
    ["Frost Trap"] = {
        ["Freezing Trap"] = { duration = 28 },
        ["Freezing Arrow"] = { duration = 28 },
    },
    ["Freezing Trap"] = {
        ["Freezing Arrow"] = { duration = 28 },
        ["Frost Trap"] = { duration = 28 },
    },
    ["Immolation Trap"] = {
        ["Explosive Trap"] = { duration = 28 },
    },
    ["Explosive Trap"] = {
        ["Immolation Trap"] = { duration = 28 },
    },

    -- Paladin
    ["Avenging Wrath"] = {
        ["Divine Protection"] = { duration = 30 },
        ["Divine Shield"] = { duration = 30, showWhenHidden = true },
        ["Lay on Hands"] = { duration = 30 },
    },
    ["Divine Protection"] = {
        ["Avenging Wrath"] = { duration = 30 },
    },
    ["Divine Shield"] = {
        ["Avenging Wrath"] = { duration = 30 },
    },
    ["Lay on Hands"] = {
        ["Avenging Wrath"] = { duration = 30 },
    },
    
    -- Warrior
    ["Shield Bash"] = {
        ["Pummel"] = { duration = 10 }
    },
    ["Pummel"] = {
        ["Shield Bash"] = { duration = 10 }
    },
    ["Recklessness"] = {
        ["Shield Wall"] = { duration = 10, showWhenHidden = true },
        ["Retaliation"] = { duration = 10 },
    },
    ["Shield Wall"] = {
        ["Recklessness"] = { duration = 10 },
        ["Retaliation"] = { duration = 10 },
    },
    ["Retaliation"] = {
        ["Shield Wall"] = { duration = 10, showWhenHidden = true },
        ["Recklessness"] = { duration = 10 },
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