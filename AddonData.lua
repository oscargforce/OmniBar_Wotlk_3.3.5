local addonName, addon = ...

addon.spellTable = { 
    ["General"] = {
        ["Berserking"] = { isTracking = false, duration = 180, spellId = 26297, race = "Troll" },
        ["Blood Fury"] = { isTracking = false, duration = 120, spellId = 20572, race = "Orc" },
        ["Escape Artist"] = { isTracking = false, duration = 60, spellId = 20589, race = "Gnome" },
        ["Gift of the Naaru"] = { isTracking = false, duration = 180, spellId = 28880, race = "Draenei" },
        ["Arcane Torrent"] = { isTracking = false, duration = 120, spellId = 28730, race = "Blood Elf" },
        ["Shadowmeld"] = { isTracking = false, duration = 120, spellId = 58984, race = "Night Elf" },
        ["Stoneform"] = { isTracking = false, duration = 120, spellId = 20594, race = "Dwarf" },
        ["War Stomp"] = { isTracking = false, duration = 120, spellId = 20549, race = "Tauren" },
        ["Bauble of True Blood"] = { isTracking = false, duration = 120, spellId = 50726, item = true },
        ["Sindragosa's Flawless Fang"] = { isTracking = false, duration = 60, spellId = 50364, item = true },
        ["Corroded Skeleton Key"] = { isTracking = false, duration = 120, spellId = 50356, item = true },
        ["PvP Trinket"] = { isTracking = false, duration = 120, spellId = 51377, item = true },
        ["Every Man for Himself"] = { isTracking = false, duration = 120, spellId = 59752, race = "Human" },
        ["Satrina's Impeding Scarab"] = { isTracking = false, duration = 180, spellId = 47088, item = true },
    },

    ["Death Knight"] = {
        ["Mind Freeze"] = { isTracking = true, duration = 10, spellId = 47528 },
        ["Icebound Fortitude"] = { isTracking = false, duration = 120, spellId = 48792 },
        ["Anti-magic Shell"] = { isTracking = false, duration = 45, spellId = 48707 },
        ["Death Grip"] = { isTracking = false, duration = 25, spellId = 49576 },
        ["Anti-Magic Zone"] = { isTracking = false, duration = 120, spellId = 51052, spec = true },
        ["Strangulate"] = { isTracking = false, duration = 100, spellId = 49916 },
        ["Summon Gargoyle"] = { isTracking = false, duration = 180, spellId = 49206, spec = true },
        ["Empower Runic Weapon"] = { isTracking = false, duration = 300, spellId = 47568 },
        ["Lichborne"] = { isTracking = false, duration = 120, spellId = 49039, spec = true },
        ["Hungering Cold"] = { isTracking = false, duration = 60, spellId = 49203, spec = true },
        ["Gnaw"] = { isTracking = false, duration = 60, spellId = 47481 },
        ["Dancing Rune Weapon"] = { isTracking = false, duration = 60, spellId = 49028, spec = true },
        ["Mark of Blood"] = { isTracking = false, duration = 180, spellId = 49005, spec = true },
        ["Rune Tap"] = { isTracking = false, duration = 30, spellId = 48982, spec = true },
        ["Vampiric Blood"] = { isTracking = false, duration = 60, spellId = 55233, spec = true },
        ["Deathchill"] = { isTracking = false, duration = 120, spellId = 49796, spec = true },
        ["Unbreakable Armor"] = { isTracking = false, duration = 60, spellId = 51271, spec = true },
        ["Hysteria"] = { isTracking = false, duration = 180, spellId = 49016, spec = true },
        ["Howling Blast"] = { isTracking = false, duration = 8, spellId = 51411, spec = true },
        ["Bone Shield"] = { isTracking = false, duration = 60, spellId = 49222, spec = true },
    },
    
    ["Druid"] = {
        ["Innervate"] = { isTracking = false, duration = 240, spellId = 29166 },
        ["Barkskin"] = { isTracking = true, duration = 60, spellId = 22812 },
        ["Feral Charge - Bear"] = { isTracking = false, duration = 15, spellId = 16979, spec = true },
        ["Nature's Swiftness"] = { isTracking = false, duration = 180, spellId = 17116, spec = true },
        ["Berserk"] = { isTracking = false, duration = 180, spellId = 50334, spec = true },
        ["Survival Instincts"] = { isTracking = false, duration = 180, spellId = 61336, spec = true },
        ["Bash"] = { isTracking = false, duration = 30, spellId = 8983 },
        ["Starfall"] = { isTracking = false, duration = 60, spellId = 53201, spec = true },
        ["Typhoon"] = { isTracking = false, duration = 20, spellId = 61384, spec = true },
        ["Force of Nature"] = { isTracking = false, duration = 180, spellId = 33831, spec = true },
        ["Swiftmend"] = { isTracking = false, duration = 13, spellId = 18562, spec = true },
    },

    ["Hunter"] = {
        ["Scatter Shot"] = { isTracking = true, duration = 30, spellId = 19503, spec = true },
        ["Roar of Sacrifice"] = { isTracking = false, duration = 60, spellId = 53480 },
        ["Silencing Shot"] = { isTracking = false, duration = 20, spellId = 34490, spec = true },
        ["Deterrence"] = { isTracking = false, duration = 90, spellId = 19263 },
        ["Readiness"] = { isTracking = false, duration = 180, spellId = 23989, spec = true },
        ["Master's Call"] = { isTracking = false, duration = 60, spellId = 53271 },
        ["Pet Intervene"] = { isTracking = false, duration = 30, spellId = 53476 },
        ["Aimed Shot"] = { isTracking = false, duration = 8, spellId = 49050, spec = true },
        ["Bestial Wrath"] = { isTracking = false, duration = 120, spellId = 19574, spec = true },
        ["Black Arrow"] = { isTracking = false, duration = 28, spellId = 63672, spec = true },
        ["Intimidation"] = { isTracking = false, duration = 60, spellId = 19577, spec = true },
        ["Wyvern Sting"] = { isTracking = false, duration = 60, spellId = 49012, spec = true },
        ["Pet Pummel"] = { isTracking = false, duration = 30, spellId = 26090 },
        ["Chimera Shot"] = { isTracking = false, duration = 10, spellId = 53209, spec = true },
        ["Feign Death"] = { isTracking = false, duration = 25, spellId = 5384 },
        ["Rapid Fire"] = { isTracking = false, duration = 300, spellId = 3045 },
        ["Frost Trap"] = { isTracking = false, duration = 30, spellId = 13809 },
        ["Freezing Arrow"] = { isTracking = false, duration = 30, spellId = 60192 },
        ["Freezing Trap"] = { isTracking = false, duration = 30, spellId = 14311 },
        ["Snake Trap"] = { isTracking = false, duration = 30, spellId = 34600 },
    },

    ["Mage"] = {
        ["Counterspell"] = { isTracking = false, duration = 24, spellId = 2139 },
        ["Evocation"] = { isTracking = false, duration = 240, spellId = 12051 },
        ["Deep Freeze"] = { isTracking = false, duration = 30, spellId = 44572, spec = true },
        ["Cold Snap"] = { isTracking = false, duration = 384, spellId = 11958, spec = true },
        ["Dragon's Breath"] = { isTracking = false, duration = 20, spellId = 42950, spec = true },
        ["Icy Veins"] = { isTracking = false, duration = 144, spellId = 12472, spec = true },
        ["Presence of Mind"] = { isTracking = false, duration = 84, spellId = 12043, spec = true },
        ["Ice Block"] = { isTracking = false, duration = 240, spellId = 45438 },
        ["Frost Nova"] = { isTracking = false, duration = 20, spellId = 42917 },
        ["Pet Nova (Freeze)"] = { isTracking = false, duration = 25, spellId = 33395 },
        ["Mana gem"] = { isTracking = false, duration = 120, spellId = 42987 },
        ["Invisibility"] = { isTracking = false, duration = 126, spellId = 66 },
        ["Blink"] = { isTracking = false, duration = 24, spellId = 1953 },
        ["Arcane Power"] = { isTracking = false, duration = 84, spellId = 12042, spec = true },
        ["Blast Wave"] = { isTracking = false, duration = 30, spellId = 42945, spec = true },
        ["Combustion"] = { isTracking = false, duration = 120, spellId = 29977, spec = true },
        ["Ice Barrier"] = { isTracking = false, duration = 24, spellId = 43039, spec = true },
        ["Summon Water Elemental"] = { isTracking = false, duration = 144, spellId = 31687, spec = true },
    },
    
    ["Paladin"] = {
        ["Divine Plea"] = { isTracking = false, duration = 60, spellId = 54428 },
        ["Hammer of Justice"] = { isTracking = false, duration = 40, spellId = 10308 },
        ["Divine Shield"] = { isTracking = false, duration = 300, spellId = 642 },
        ["Repentance"] = { isTracking = false, duration = 60, spellId = 20066, spec = true },
        ["Divine Sacrifice"] = { isTracking = false, duration = 120, spellId = 64205, spec = true },
        ["Hand of Sacrifice"] = { isTracking = false, duration = 120, spellId = 6940 },
        ["Hand of Freedom"] = { isTracking = false, duration = 25, spellId = 1044 },
        ["Hand of Protection"] = { isTracking = false, duration = 180, spellId = 10278 },
        ["Avenging Wrath"] = { isTracking = false, duration = 120, spellId = 31884 },
        ["Holy Shock"] = { isTracking = false, duration = 5, spellId = 48825, spec = true },
        ["Aura Mastery"] = { isTracking = false, duration = 120, spellId = 31821, spec = true },
        ["Avenger's Shield"] = { isTracking = false, duration = 30, spellId = 48827, spec = true },
        ["Crusader Strike"] = { isTracking = false, duration = 4, spellId = 35395, spec = true },
        ["Divine Favor"] = { isTracking = false, duration = 120, spellId = 20216, spec = true },
        ["Divine Illumination"] = { isTracking = false, duration = 180, spellId = 31842, spec = true },
        ["Divine Storm"] = { isTracking = false, duration = 10, spellId = 53385, spec = true },
        ["Hammer of the Righteous"] = { isTracking = false, duration = 6, spellId = 53595, spec = true },
        ["Holy Shield"] = { isTracking = false, duration = 8, spellId = 48952, spec = true },
    },

    ["Priest"] = {
        ["Psychic Scream"] = { isTracking = false, duration = 23, spellId = 10890 },
        ["Dispersion"] = { isTracking = false, duration = 75, spellId = 47585 },
        ["Psychic Horror"] = { isTracking = false, duration = 120, spellId = 64044 },
        ["Pain Suppression"] = { isTracking = false, duration = 160, spellId = 33206 },
        ["Shadowfiend"] = { isTracking = false, duration = 300, spellId = 34433 },
        ["Fear Ward"] = { isTracking = false, duration = 180, spellId = 6346 },
        ["Silence"] = { isTracking = false, duration = 45, spellId = 15487 },
        ["Power Infusion"] = { isTracking = false, duration = 96, spellId = 10060 },
        ["Shadow Word: Death"] = { isTracking = false, duration = 12, spellId = 48158 },
        ["Desperate Prayer"] = { isTracking = false, duration = 12, spellId = 48173 },
    },

    ["Rogue"] = {
        ["Kick"] = { isTracking = false, duration = 10, spellId = 1766 },
        ["Cloak of Shadows"] = { isTracking = false, duration = 60, spellId = 31224 },
        ["Kidney Shot"] = { isTracking = false, duration = 20, spellId = 8643 },
        ["Shadow Dance"] = { isTracking = false, duration = 60, spellId = 51713 },
        ["Shadow Step"] = { isTracking = false, duration = 20, spellId = 36554 },
        ["Vanish"] = { isTracking = false, duration = 120, spellId = 1856 },
        ["Evasion"] = { isTracking = false, duration = 180, spellId = 5277 },
        ["Preparation"] = { isTracking = false, duration = 300, spellId = 14185 },
        ["Blind"] = { isTracking = false, duration = 120, spellId = 2094 },
        ["Sprint"] = { isTracking = false, duration = 120, spellId = 11305 },
        ["Dismantle"] = { isTracking = false, duration = 60, spellId = 51722 },
        ["Cold Blood"] = { isTracking = false, duration = 180, spellId = 14177 },
    },

    
    ["Shaman"] = {
        ["Nature's Swiftness"] = { isTracking = false, duration = 120, spellId = 16188 },
        ["Elemental Mastery"] = { isTracking = false, duration = 150, spellId = 16166 },
        ["Wind Shear"] = { isTracking = false, duration = 5, spellId = 57994 },
        ["Thunderstorm"] = { isTracking = false, duration = 35, spellId = 59159 },
        ["Grounding Totem"] = { isTracking = false, duration = 13.5, spellId = 8177 },
        ["Hex"] = { isTracking = true, duration = 45, spellId = 51514 },
        ["Mana Tide"] = { isTracking = false, duration = 300, spellId = 16190 },
        ["Stoneclaw Totem"] = { isTracking = false, duration = 21, spellId = 58582 },
    },
    
    ["Warlock"] = {
        ["Spell Lock"] = { isTracking = true, duration = 24, spellId = 19647 },
        ["Fel Domination"] = { isTracking = false, duration = 180, spellId = 18708, spec = true },
        ["Devour Magic"] = { isTracking = false, duration = 8, spellId = 48011 },
        ["Death Coil"] = { isTracking = false, duration = 120, spellId = 47860 },
        ["Howl of Terror"] = { isTracking = false, duration = 32, spellId = 17928 },
        ["Demonic Circle: Teleport"] = { isTracking = false, duration = 26, spellId = 48020 },
        ["Shadowfury"] = { isTracking = false, duration = 20, spellId = 47847, spec = true },
    },

    ["Warrior"] = {
        ["Spell Reflection"] = { isTracking = false, duration = 10, spellId = 23920 },
        ["Pummel"] = { isTracking = false, duration = 10, spellId = 6552 },
        ["Bladestorm"] = { isTracking = false, duration = 90, spellId = 46924 },
        ["Shield Bash"] = { isTracking = false, duration = 12, spellId = 72 },
        ["Berserker Rage"] = { isTracking = false, duration = 30, spellId = 18499 },
        ["Charge"] = { isTracking = false, duration = 20, spellId = 11578 },
        ["Intercept"] = { isTracking = false, duration = 20, spellId = 20252 },
        ["Intervene"] = { isTracking = false, duration = 30, spellId = 3411 },
        ["Shield Wall"] = { isTracking = false, duration = 300, spellId = 871 },
        ["Shockwave"] = { isTracking = false, duration = 17, spellId = 46968 },
        ["Concussive Blow"] = { isTracking = false, duration = 30, spellId = 12809 },
        ["Recklessness"] = { isTracking = false, duration = 300, spellId = 1719 },
        ["Intimidating Shout"] = { isTracking = false, duration = 120, spellId = 5246 },
    },
}


addon.CLASS_NAME_TO_TCOORDS_KEY = {
    ["Death Knight"] = "DEATHKNIGHT",
    ["Druid"] = "DRUID",
    ["Hunter"] = "HUNTER",
    ["Mage"] = "MAGE",
    ["Paladin"] = "PALADIN",
    ["Priest"] = "PRIEST",
    ["Rogue"] = "ROGUE",
    ["Shaman"] = "SHAMAN",
    ["Warlock"] = "WARLOCK",
    ["Warrior"] = "WARRIOR",
}

function addon.DeepCopyTable(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = addon.DeepCopyTable(v)  -- Recursively copy tables
        else
            copy[k] = v
        end
    end
    return copy
end

function addon.GetBuffNameFromTrinket(trinketName)
    local nameMapping = {
        ["Bauble of True Blood"] = "Release of Light",
        ["Corroded Skeleton Key"] = "Hardened Skin",
        ["Medallion of the Alliance"] = "PvP Trinket",
        ["Medallion of the Horde"] = "PvP Trinket",
        ["Satrina's Impeding Scarab"] = "Fortitude",
        ["Sindragosa's Flawless Fang"] = "Aegis of Dalaran",
    }
    
    return nameMapping[trinketName] or trinketName
end

-- Hunter, paladin, druid, dk, mage are done.
-- Copy the specAbilities from PAB addon
addon.specSpellTable = {
    ["Druid"] = { 
        ["Berserk"] = {
            talentGroup = 2,
            index = 30,
        },
        ["Feral Charge - Bear"] = {
            talentGroup = 2,
            index = 14,
        },
        ["Force of Nature"] = {
            talentGroup = 1,
            index = 25,
        },
        ["Nature's Swiftness"] = {
            talentGroup = 3,
            index = 12,
        },
        ["Starfall"] = {
            talentGroup = 1,
            index = 28,
        },
        ["Survival Instincts"] = {
            talentGroup = 2,
            index = 7,
        },
        ["Swiftmend"] = {
            talentGroup = 3,
            index = 18,
        },
        ["Typhoon"] = {
            talentGroup = 1,
            index = 24,
        },
    },
    ["Death Knight"] = {
        ["Anti-Magic Zone"] = { 
            talentGroup = 3,
            index = 22,
        },
        ["Bone Shield"] = { 
            talentGroup = 3,
            index = 26,
        },
        ["Dancing Rune Weapon"] = { 
            talentGroup = 1,
            index = 28,
        },
        ["Deathchill"] = { 
            talentGroup = 2,
            index = 15,
        },
        ["Howling Blast"] = {
            talentGroup = 2,
            index = 29,
        },
        ["Hungering Cold"] = {
            talentGroup = 2,
            index = 20,
        },
        ["Hysteria"] = {
            talentGroup = 1,
            index = 19,
        },
        ["Lichborne"] = {
            talentGroup = 2,
            index = 8,
        },
        ["Mark of Blood"] = {
            talentGroup = 1,
            index = 15,
        },
        ["Rune Tap"] = {
            talentGroup = 1,
            index = 7,
        },
        ["Summon Gargoyle"] = {
            talentGroup = 3,
            index = 31,
        },
        ["Unbreakable Armor"] = {
            talentGroup = 2,
            index = 24,
        },
        ["Vampiric Blood"] = {
            talentGroup = 1,
            index = 23,
        },
    },
    ["Hunter"] = {
        ["Aimed Shot"] = {
            talentGroup = 2,
            index = 9,
        },
        ["Bestial Wrath"] = {
            talentGroup = 1,
            index = 18,
        },
        ["Black Arrow"] = {
            talentGroup = 3,
            index = 25,
        },
        ["Chimera Shot"] = {
            talentGroup = 2,
            index = 27,
        },
        ["Intimidation"] = {
            talentGroup = 1,
            index = 13,
        },
        ["Readiness"] = {
            talentGroup = 2,
            index = 14,
        },
        ["Silencing Shot"] = {
            talentGroup = 2,
            index = 24,
        },
        ["Wyvern Sting"] = {
            talentGroup = 3,
            index = 20,
        },
        ["Scatter Shot"] = {
            talentGroup = 3,
            index = 9,
        },
    },
    ["Mage"] = {
        ["Arcane Power"] = {
            talentGroup = 1,
            index = 22,
        },
        ["Blast Wave"] = { 
            talentGroup = 2,
            index = 16,
        },
        ["Cold Snap"] = {
            talentGroup = 3,
            index = 14,
        },
        ["Combustion"] = {
            talentGroup = 2,
            index = 20,
        },
        ["Deep Freeze"] = {
            talentGroup = 3,
            index = 28,
        },
        ["Dragon's Breath"] = {
            talentGroup = 2,
            index = 25,
        },
        ["Ice Barrier"] = {
            talentGroup = 3,
            index = 20,
        },
        ["Icy Veins"] = {
            talentGroup = 3,
            index = 9,
        },
        ["Presence of Mind"] = {
            talentGroup = 1,
            index = 16,
        },
        ["Summon Water Elemental"] = {
            talentGroup = 3,
            index = 25,
        },
    }, 
    ["Paladin"] = {
        ["Aura Mastery"] = {
            talentGroup = 1,
            index = 6,
        },
        ["Avenger's Shield"] = {
            talentGroup = 2,
            index = 22,
        },
        ["Crusader Strike"] = {
            talentGroup = 3,
            index = 23,
        },
        ["Divine Favor"] = {
            talentGroup = 1,
            index = 13,
        },
        ["Divine Illumination"] = {
            talentGroup = 1,
            index = 22,
        },
        ["Divine Sacrifice"] = {
            talentGroup = 2,
            index = 6,
        },
        ["Divine Storm"] = {
            talentGroup = 3,
            index = 26,
        },
        ["Hammer of the Righteous"] = {
            talentGroup = 2,
            index = 26,
        },
        ["Holy Shield"] = {
            talentGroup = 2,
            index = 17,
        },
        ["Holy Shock"] = {
            talentGroup = 1,
            index = 18,
        },
        ["Repentance"] = {
            talentGroup = 3,
            index = 18,
        },
    },
    ["Priest"] = {
        ["Dispersion"] = {
            talentGroup = 3,
            index = 27,
        },
        ["Pain Suppression"] = {
            talentGroup = 1,
            index = 25,
        },
        ["Psychic Horror"] = {
            talentGroup = 3,
            index = 23,
        },
        ["Silence"] = {
            talentGroup = 3,
            index = 13,
        },
    },
    ["Rogue"] = {
        ["Cold Blood"] = {
            talentGroup = 1,
            index = 13,
        },
        ["Killing Spree"] = {
            talentGroup = 2,
            index = 28,
        },
        ["Preparation"] = {
            talentGroup = 3,
            index = 14,
        },
        ["Shadow Dance"] = {
            talentGroup = 3,
            index = 28,
        },
        ["Shadow Step"] = {
            talentGroup = 3,
            index = 25,
        },
    },
    ["Shaman"] = {
        ["Elemental Mastery"] = {
            talentGroup = 1,
            index = 16,
        },
        ["Nature's Swiftness"] = {
            talentGroup = 3,
            index = 13,
        },
        ["Shamanistic Rage"] = {
            talentGroup = 2,
            index = 26,
        },
        ["Thunderstorm"] = {
            talentGroup = 1,
            index = 25,
        },
    },
    ["Warlock"] = {
        ["Fel Domination"] = {
            talentGroup = 2,
            index = 10,
        },
        ["Shadowfury"] = {
            talentGroup = 3,
            index = 23,
        },
    },
    ["Warrior"] = {
        ["Bladestorm"] = {
            talentGroup = 1,
            index = 31,
        },
        ["Concussion Blow"] = {
            talentGroup = 3,
            index = 14,
        },
        ["Shockwave"] = {
            talentGroup = 3,
            index = 27,
        },
    },
}



