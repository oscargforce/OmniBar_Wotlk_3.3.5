local addonName, addon = ...

addon.spellTable = { 
    ["General"] = {
        ["Berserking"] = { isTracking = false, duration = 180, spellId = 26297 },
        ["Blood Fury"] = { isTracking = false, duration = 120, spellId = 20572 },
        ["Escape Artist"] = { isTracking = false, duration = 60, spellId = 20589 },
        ["Gift of the Naaru"] = { isTracking = false, duration = 180, spellId = 28880 },
        ["Arcane Torrent"] = { isTracking = false, duration = 120, spellId = 28730 },
        ["Shadowmeld"] = { isTracking = false, duration = 120, spellId = 58984 },
        ["Stoneform"] = { isTracking = false, duration = 120, spellId = 20594 },
        ["War Stomp"] = { isTracking = false, duration = 120, spellId = 20549 },
        ["Bauble of True Blood"] = { isTracking = false, duration = 120, spellId = 50726, item = true },
        ["Sindragosa's Flawless Fang"] = { isTracking = false, duration = 60, spellId = 50364, item = true },
        ["Corroded Skeleton Key"] = { isTracking = false, duration = 120, spellId = 50356, item = true },
        ["PvP Trinket"] = { isTracking = false, duration = 120, spellId = 51377, item = true },
        ["Every Man for Himself"] = { isTracking = false, duration = 120, spellId = 59752 },
    },

    ["Death Knight"] = {
        ["Mind Freeze"] = { isTracking = true, duration = 10, spellId = 47528 },
        ["Icebound Fortitude"] = { isTracking = false, duration = 120, spellId = 48792 },
        ["Anti-magic Shell"] = { isTracking = false, duration = 45, spellId = 48707 },
        ["Death Grip"] = { isTracking = false, duration = 25, spellId = 49576 },
        ["Anti-magic Zone"] = { isTracking = false, duration = 120, spellId = 51052 },
        ["Strangulate"] = { isTracking = false, duration = 100, spellId = 49916 },
        ["Summon Gargoyle"] = { isTracking = false, duration = 180, spellId = 49206 },
        ["Empower Runic Weapon"] = { isTracking = false, duration = 300, spellId = 47568 },
        ["Lichborne"] = { isTracking = false, duration = 120, spellId = 49039 },
        ["Hungering Cold"] = { isTracking = false, duration = 60, spellId = 49203 },
        ["Gnaw"] = { isTracking = false, duration = 60, spellId = 47481 },
        ["Dancing Rune Weapon"] = { isTracking = false, duration = 60, spellId = 49028 },
        ["Mark of Blood"] = { isTracking = false, duration = 180, spellId = 49005 },
        ["Rune Tap"] = { isTracking = false, duration = 30, spellId = 48982 },
        ["Vampiric Blood"] = { isTracking = false, duration = 60, spellId = 55233 },
        ["Deathchill"] = { isTracking = false, duration = 120, spellId = 49796 },
        ["Unbreakable Armor"] = { isTracking = false, duration = 60, spellId = 51271 },
        ["Hysteria"] = { isTracking = false, duration = 180, spellId = 49016 },
    },
    
    ["Druid"] = {
        ["Innervate"] = { isTracking = false, duration = 240, spellId = 29166 },
        ["Barkskin"] = { isTracking = true, duration = 60, spellId = 22812 },
        ["Feral Charge - Bear"] = { isTracking = false, duration = 15, spellId = 16979 },
        ["Nature's Swiftness"] = { isTracking = false, duration = 180, spellId = 17116 },
        ["Typhoon"] = { isTracking = false, duration = 20, spellId = 61384 },
        ["Berserk"] = { isTracking = false, duration = 180, spellId = 50334 },
        ["Survival Instincts"] = { isTracking = false, duration = 180, spellId = 61336 },
        ["Bash"] = { isTracking = false, duration = 30, spellId = 8983 },
        ["Starfall"] = { isTracking = false, duration = 60, spellId = 53201 },
        ["Starfall"] = { isTracking = false, duration = 60, spellId = 53312 },
    },

    ["Hunter"] = {
        ["Scatter Shot"] = { isTracking = true, duration = 30, spellId = 19503 },
        ["Roar of Sacrifice"] = { isTracking = false, duration = 60, spellId = 53480 },
        ["Silencing Shot"] = { isTracking = false, duration = 20, spellId = 34490 },
        ["Deterrence"] = { isTracking = false, duration = 90, spellId = 19263 },
        ["Readiness"] = { isTracking = false, duration = 180, spellId = 23989 },
        ["Master's Call"] = { isTracking = false, duration = 60, spellId = 53271 },
        ["Pet Intervene"] = { isTracking = false, duration = 30, spellId = 53476 },
        ["Aimed Shot"] = { isTracking = false, duration = 8, spellId = 49050 },
        ["Pet Pummel"] = { isTracking = false, duration = 30, spellId = 26090 },
        ["Chimera Shot"] = { isTracking = false, duration = 9, spellId = 53209 },
        ["Feign Death"] = { isTracking = false, duration = 25, spellId = 5384 },
        ["Rapid Fire"] = { isTracking = false, duration = 300, spellId = 3045 },
        ["Frost Trap"] = { isTracking = false, duration = 30, spellId = 13809 },
        ["Freezing Arrow"] = { isTracking = false, duration = 30, spellId = 60192 },
        ["Freezing Trap"] = { isTracking = false, duration = 30, spellId = 14311 },
        ["Snake Trap"] = { isTracking = false, duration = 30, spellId = 34600 },
        ["Intimidation"] = { isTracking = false, duration = 60, spellId = 19577 },
    },

    ["Mage"] = {
        ["Counterspell"] = { isTracking = false, duration = 24, spellId = 2139 },
        ["Evocation"] = { isTracking = false, duration = 240, spellId = 12051 },
        ["Deep Freeze"] = { isTracking = false, duration = 30, spellId = 44572 },
        ["Cold Snap"] = { isTracking = false, duration = 480, spellId = 11958 },
        ["Dragon's Breath"] = { isTracking = false, duration = 20, spellId = 42950 },
        ["Icy Veins"] = { isTracking = false, duration = 144, spellId = 12472 },
        ["Presence of Mind"] = { isTracking = false, duration = 84, spellId = 12043 },
        ["Ice Block"] = { isTracking = false, duration = 240, spellId = 45438 },
        ["Frost Nova"] = { isTracking = false, duration = 20, spellId = 42917 },
        ["Pet Nova (Freeze)"] = { isTracking = false, duration = 25, spellId = 33395 },
        ["Mana gem"] = { isTracking = false, duration = 120, spellId = 42987 },
        ["Invisibility"] = { isTracking = false, duration = 126, spellId = 66 },
        ["Blink"] = { isTracking = false, duration = 24, spellId = 1953 },
    },
    
    ["Paladin"] = {
        ["Divine Plea"] = { isTracking = false, duration = 60, spellId = 54428 },
        ["Hammer of Justice"] = { isTracking = false, duration = 40, spellId = 10308 },
        ["Divine Shield"] = { isTracking = false, duration = 300, spellId = 642 },
        ["Repentance"] = { isTracking = false, duration = 60, spellId = 20066 },
        ["Divine Sacrifice"] = { isTracking = false, duration = 120, spellId = 64205 },
        ["Hand of Sacrifice"] = { isTracking = false, duration = 120, spellId = 6940 },
        ["Hand of Freedom"] = { isTracking = false, duration = 25, spellId = 1044 },
        ["Hand of Protection"] = { isTracking = false, duration = 180, spellId = 10278 },
        ["Avenging Wrath"] = { isTracking = false, duration = 120, spellId = 31884 },
        ["Holy Shock"] = { isTracking = false, duration = 5, spellId = 48825 },
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
        ["Fel Domination"] = { isTracking = false, duration = 180, spellId = 18708 },
        ["Devour Magic"] = { isTracking = false, duration = 8, spellId = 48011 },
        ["Death Coil"] = { isTracking = false, duration = 120, spellId = 47860 },
        ["Howl of Terror"] = { isTracking = false, duration = 32, spellId = 17928 },
        ["Demonic Circle: Teleport"] = { isTracking = false, duration = 26, spellId = 48020 },
        ["Shadowfury"] = { isTracking = false, duration = 20, spellId = 47847 },
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