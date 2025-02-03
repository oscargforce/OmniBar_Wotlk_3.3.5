local addonName, addon = ...

addon.resetCds = {
    ["Readiness"] = {
        ["Chimera Shot"] = true,
        ["Aimed Shot"] = true,
        ["Frost Trap"] = true,
        ["Freezing Trap"] = true,
        ["Freezing Arrow"] = true,
        ["Concussive Shot"] = true,
        ["Kill Command"] = true,
        ["Master's Call"] = true,
        ["Scare Beast"] = true,
        ["Arcane Shot"] = true,
        ["Distracting Shot"] = true,
        ["Flare"] = true,
        ["Kill Shot"] = true,
        ["Multi-Shot"] = true,
        ["Rapid Fire"] = true,
        ["Tranquilizing Shot"] = true,
        ["Viper Sting"] = true,
        ["Deterrence"] = true,
        ["Disengage"] = true,
        ["Explosive Trap"] = true,
        ["Feign Death"] = true,
        ["Immolation Trap"] = true,
        ["Misdirection"] = true,
        ["Mongoose Bite"] = true,
        ["Raptor Strike"] = true,
        ["Snake Trap"] = true,
        ["Silencing Shot"] = true,
        ["Scatter Shot"] = true,
    },
   ["Preparation"] = { 
        ["Evasion"] = true,
        ["Sprint"] = true,
        ["Vanish"] = true,
        ["Cold Blood"] = true,
        ["Shadowstep"] = true,
        ["Blade Flurry"] = true,
        ["Kick"] = true,
        ["Dismantle"] = true,
    },
    ["Summon Felhunter"] = {
        ["Spell Lock"] = true,
    },
    ["Cold Snap"] = {
        ["Ice Barrier"] = true,
        ["Frost Ward"] = true,
        ["Frost Nova"] = true,
        ["Ice Block"] = true,
        ["Icy Veins"] = true,
        ["Summon Water Elemental"] = true,
        ["Deep Freeze"] = true,
        ["Cone of Cold"] = true,
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
