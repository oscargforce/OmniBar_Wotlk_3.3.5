local addonName, addon = ...

addon.spellTable = { 
    ["General"] = {
        ["Arcane Torrent"] = { isTracking = false, duration = 120, spellId = 28730, race = "Blood Elf" },
        ["Bauble of True Blood"] = { isTracking = false, duration = 120, spellId = 50726, item = true },
        ["Berserking"] = { isTracking = false, duration = 180, spellId = 26297, race = "Troll" },
        ["Blood Fury"] = { isTracking = false, duration = 120, spellId = 20572, race = "Orc" },
        ["Corroded Skeleton Key"] = { isTracking = false, duration = 120, spellId = 50356, item = true },
        ["Escape Artist"] = { isTracking = false, duration = 60, spellId = 20589, race = "Gnome" },
        ["Every Man for Himself"] = { isTracking = false, duration = 120, spellId = 59752, race = "Human" },
        ["Gift of the Naaru"] = { isTracking = false, duration = 180, spellId = 28880, race = "Draenei" },
        ["PvP Trinket"] = { isTracking = false, duration = 120, spellId = 51377, item = true },
        ["Satrina's Impeding Scarab"] = { isTracking = false, duration = 180, spellId = 47088, item = true },
        ["Shadowmeld"] = { isTracking = false, duration = 120, spellId = 58984, race = "Night Elf" },
        ["Sindragosa's Flawless Fang"] = { isTracking = false, duration = 60, spellId = 50364, item = true },
        ["Stoneform"] = { isTracking = false, duration = 120, spellId = 20594, race = "Dwarf" },
        ["War Stomp"] = { isTracking = false, duration = 120, spellId = 20549, race = "Tauren" },
        ["Will of the Forsaken"] = { isTracking = false, duration = 120, spellId = 7744, race = "Undead" },
    },
    ["Death Knight"] = {
        ["Anti-Magic Zone"] = { isTracking = false, duration = 120, spellId = 51052, spec = "unholy" },
        ["Anti-Magic Shell"] = { isTracking = false, duration = 45, spellId = 48707 },
        ["Army of the Dead"] = { isTracking = false, duration = 360, spellId = 42650 },
        ["Blood Tap"] = { isTracking = false, duration = 60, spellId = 45529 },
        ["Bone Shield"] = { isTracking = false, duration = 60, spellId = 49222, spec = "unholy" },
        ["Dancing Rune Weapon"] = { isTracking = false, duration = 60, spellId = 49028, spec = "blood" },
        ["Death Grip"] = { isTracking = false, duration = 25, spellId = 49576 },
        ["Death Pact"] = { isTracking = false, duration = 120, spellId = 48743 },
        ["Deathchill"] = { isTracking = false, duration = 120, spellId = 49796, spec = "frostDk" },
        ["Empower Rune Weapon"] = { isTracking = false, duration = 300, spellId = 47568 },
        ["Gnaw"] = { isTracking = false, duration = 60, spellId = 47481 },
        ["Howling Blast"] = { isTracking = false, duration = 8, spellId = 51411, spec = "frostDk" },
        ["Hungering Cold"] = { isTracking = false, duration = 60, spellId = 49203, spec = "frostDk" },
        ["Hysteria"] = { isTracking = false, duration = 180, spellId = 49016, spec = "blood" },
        ["Icebound Fortitude"] = { isTracking = false, duration = 120, spellId = 48792 },
        ["Leap"] = { isTracking = false, duration = 20, spellId = 47482, spec = "unholy" },
        ["Lichborne"] = { isTracking = false, duration = 120, spellId = 49039, spec = "frostDk" },
        ["Mark of Blood"] = { isTracking = false, duration = 180, spellId = 49005, spec = "blood" },
        ["Mind Freeze"] = { isTracking = true, duration = 10, spellId = 47528 },
        ["Raise Dead"] = { isTracking = false, duration = 30, spellId = 46584 },
        ["Rune Tap"] = { isTracking = false, duration = 30, spellId = 48982, spec = "blood" },
        ["Strangulate"] = { isTracking = false, duration = 120, spellId = 49916 },
        ["Summon Gargoyle"] = { isTracking = false, duration = 180, spellId = 49206, spec = "unholy" },
        ["Unbreakable Armor"] = { isTracking = false, duration = 60, spellId = 51271, spec = "frostDk" },
        ["Vampiric Blood"] = { isTracking = false, duration = 60, spellId = 55233, spec = "blood" },
    },
    ["Druid"] = {
        ["Barkskin"] = { isTracking = true, duration = 60, spellId = 22812 },
        ["Bash"] = { isTracking = false, duration = 30, spellId = 8983, adjust = { feral = 30 } },
        ["Berserk"] = { isTracking = false, duration = 180, spellId = 50334, spec = "feral" },
        ["Challenging Roar"] = { isTracking = false, duration = 180, spellId = 5209 },
        ["Dash"] = { isTracking = false, duration = 144, spellId = 33357 },
        ["Enrage"] = { isTracking = false, duration = 60, spellId = 5229 },
        ["Feral Charge - Bear"] = { isTracking = false, duration = 15, spellId = 16979, spec = "feral" },
        ["Feral Charge - Cat"] = { isTracking = false, duration = 15, spellId = 49376, spec = "feral" },
        ["Force of Nature"] = { isTracking = false, duration = 180, spellId = 33831, spec = "balance" },
        ["Frenzied Regeneration"] = { isTracking = false, duration = 180, spellId = 22842 },
        ["Growl"] = { isTracking = false, duration = 8, spellId = 6795, spec = "balance" },
        ["Innervate"] = { isTracking = false, duration = 180, spellId = 29166 },
        ["Nature's Swiftness"] = { isTracking = false, duration = 180, spellId = 17116, spec = "restoDruid" },
        ["Nature's Grasp"] = { isTracking = false, duration = 60, spellId = 53312 },
        ["Maim"] = { isTracking = false, duration = 10, spellId = 49802 },
        ["Rebirth"] = { isTracking = false, duration = 600, spellId = 48477 },
        ["Starfall"] = { isTracking = false, duration = 60, spellId = 53201, spec = "balance" },
        ["Survival Instincts"] = { isTracking = false, duration = 180, spellId = 61336, spec = "feral" },
        ["Swiftmend"] = { isTracking = false, duration = 13, spellId = 18562, spec = "restoDruid" },
        ["Tiger's Fury"] = { isTracking = false, duration = 30, spellId = 50213 },
        ["Tranquility"] = { isTracking = false, duration = 480, spellId = 48447 },
        ["Typhoon"] = { isTracking = false, duration = 20, spellId = 61384, spec = "balance" },
    },
    ["Hunter"] = {
        ["Aimed Shot"] = { isTracking = false, duration = 8, spellId = 49050 },
        ["Bestial Wrath"] = { isTracking = false, duration = 120, spellId = 19574, spec = "bm" },
        ["Black Arrow"] = { isTracking = false, duration = 22, spellId = 63672, spec = "survival" },
        ["Chimera Shot"] = { isTracking = false, duration = 10, spellId = 53209, spec = "mm" },
        ["Deterrence"] = { isTracking = false, duration = 90, spellId = 19263 },
        ["Explosive Trap"] = { isTracking = false, duration = 28, spellId = 49067, adjust = { survival = 22 } },
        ["Feign Death"] = { isTracking = false, duration = 25, spellId = 5384 },
        ["Freezing Arrow"] = { isTracking = false, duration = 28, spellId = 60192, adjust = { survival = 22 } },
        ["Freezing Trap"] = { isTracking = false, duration = 28, spellId = 14311, adjust = { survival = 22 } },
        ["Frost Trap"] = { isTracking = false, duration = 28, spellId = 13809, adjust = { survival = 22 } },
        ["Immolation Trap"] = { isTracking = false, duration = 28, spellId = 49055, adjust = { survival = 22 } },
        ["Intimidation"] = { isTracking = false, duration = 60, spellId = 19577, spec = "bm" },
        ["Master's Call"] = { isTracking = false, duration = 60, spellId = 53271 },
        ["Pet Intervene"] = { isTracking = false, duration = 30, spellId = 53476 },
        ["Pet Pummel"] = { isTracking = false, duration = 30, spellId = 26090 },
        ["Rapid Fire"] = { isTracking = false, duration = 300, spellId = 3045 },
        ["Readiness"] = { isTracking = false, duration = 180, spellId = 23989, spec = "mm" },
        ["Roar of Sacrifice"] = { isTracking = false, duration = 60, spellId = 53480 },
        ["Scatter Shot"] = { isTracking = true, duration = 30, spellId = 19503, spec = "survival" },
        ["Silencing Shot"] = { isTracking = false, duration = 20, spellId = 34490, spec = "mm" },
        ["Snake Trap"] = { isTracking = false, duration = 28, spellId = 34600, adjust = { survival = 22 } },
        ["Wyvern Sting"] = { isTracking = false, duration = 60, spellId = 49012, spec = "survival" },
    },
    ["Mage"] = {
        ["Arcane Power"] = { isTracking = false, duration = 84, spellId = 12042, spec = "arcane" },
        ["Blast Wave"] = { isTracking = false, duration = 30, spellId = 42945, spec = "fire" },
        ["Blink"] = { isTracking = false, duration = 15, spellId = 1953 },
        ["Cold Snap"] = { isTracking = false, duration = 384, spellId = 11958, spec = "frost" },
        ["Combustion"] = { isTracking = false, duration = 120, spellId = 29977, spec = "fire" },
        ["Counterspell"] = { isTracking = false, duration = 24, spellId = 2139 },
        ["Deep Freeze"] = { isTracking = false, duration = 30, spellId = 44572, spec = "frost" },
        ["Dragon's Breath"] = { isTracking = false, duration = 20, spellId = 42950, spec = "fire" },
        ["Evocation"] = { isTracking = false, duration = 240, spellId = 12051, adjust = { arcane = 120 } },
        ["Fire Ward"] = { isTracking = false, duration = 30, spellId = 43010 },
        ["Frost Nova"] = { isTracking = false, duration = 20, spellId = 42917 },
        ["Frost Ward"] = { isTracking = false, duration = 30, spellId = 43012 },
        ["Ice Barrier"] = { isTracking = false, duration = 24, spellId = 43039, spec = "frost" },
        ["Ice Block"] = { isTracking = false, duration = 240, spellId = 45438 },
        ["Icy Veins"] = { isTracking = false, duration = 144, spellId = 12472, spec = "frost" },
        ["Invisibility"] = { isTracking = false, duration = 180, spellId = 66, adjust = { arcane = 126 } },
        ["Mana gem"] = { isTracking = false, duration = 120, spellId = 42987 },
        ["Mirror Image"] = { isTracking = false, duration = 180, spellId = 55342 },
        ["Pet Nova (Freeze)"] = { isTracking = false, duration = 25, spellId = 33395 },
        ["Presence of Mind"] = { isTracking = false, duration = 84, spellId = 12043, spec = "arcane" },
        ["Summon Water Elemental"] = { isTracking = false, duration = 144, spellId = 31687, spec = "frost" },
    },
    ["Paladin"] = {
        ["Aura Mastery"] = { isTracking = false, duration = 120, spellId = 31821, spec = "holy" },
        ["Avenger's Shield"] = { isTracking = false, duration = 30, spellId = 48827, spec = "protPala" },
        ["Avenging Wrath"] = { isTracking = false, duration = 180, spellId = 31884, adjust = { retri = 120 } },
        ["Crusader Strike"] = { isTracking = false, duration = 4, spellId = 35395, spec = "retri" },
        ["Consecration"] = { isTracking = false, duration = 8, spellId = 48819 },
        ["Divine Favor"] = { isTracking = false, duration = 120, spellId = 20216, spec = "holy" },
        ["Divine Illumination"] = { isTracking = false, duration = 180, spellId = 31842, spec = "holy" },
        ["Divine Plea"] = { isTracking = false, duration = 60, spellId = 54428 },
        ["Divine Protection"] = { isTracking = false, duration = 180, spellId = 498, adjust = { protPala = 120 } },
        ["Divine Sacrifice"] = { isTracking = false, duration = 120, spellId = 64205, spec = "protPala" },
        ["Divine Shield"] = { isTracking = false, duration = 300, spellId = 642, adjust = { protPala = 240 } },
        ["Divine Storm"] = { isTracking = false, duration = 10, spellId = 53385, spec = "retri" },
        ["Hammer of Justice"] = { isTracking = false, duration = 40, spellId = 10308, adjust = { protPala = 30 } },
        ["Hammer of the Righteous"] = { isTracking = false, duration = 6, spellId = 53595, spec = "protPala" },
        ["Hand of Freedom"] = { isTracking = false, duration = 25, spellId = 1044 },
        ["Hand of Protection"] = { isTracking = false, duration = 180, spellId = 10278 },
        ["Hand of Reckoning"] = { isTracking = false, duration = 8, spellId = 62124 },
        ["Hand of Sacrifice"] = { isTracking = false, duration = 120, spellId = 6940 },
        ["Hand of Salvation"] = { isTracking = false, duration = 120, spellId = 1038 },
        ["Holy Shield"] = { isTracking = false, duration = 8, spellId = 48952, spec = "protPala" },
        ["Holy Shock"] = { isTracking = false, duration = 5, spellId = 48825, spec = "holy" },
        ["Holy Wrath"] = { isTracking = false, duration = 30, spellId = 48817 },
        ["Lay on Hands"] = { isTracking = false, duration = 1200, spellId = 48788 },
        ["Repentance"] = { isTracking = false, duration = 60, spellId = 20066, spec = "retri" },
        ["Righteous Defense"] = { isTracking = false, duration = 8, spellId = 31789 },
    },
    ["Priest"] = {
        ["Desperate Prayer"] = { isTracking = false, duration = 120, spellId = 48173, spec = "holyPriest" },
        ["Dispersion"] = { isTracking = false, duration = 75, spellId = 47585, spec = "shadow" },
        ["Divine Hymn"] = { isTracking = false, duration = 480, spellId = 64843 },
        ["Fade"] = { isTracking = false, duration = 30, spellId = 586, adjust = { shadow = 15 } },
        ["Fear Ward"] = { isTracking = false, duration = 180, spellId = 6346 },
        ["Guardian Spirit"] = { isTracking = false, duration = 180, spellId = 47788, spec = "holyPriest" },
        ["Hymn of Hope]"] = { isTracking = false, duration = 360, spellId = 64901 },
        ["Inner Focus"] = { isTracking = false, duration = 144, spellId = 14751, spec = "disc" },
        ["Lightwell"] = { isTracking = false, duration = 180, spellId = 48086, spec = "holyPriest" },
        ["Penance"] = { isTracking = false, duration = 8, spellId = 53007, spec = "disc" },
        ["Power Infusion"] = { isTracking = false, duration = 96, spellId = 10060, spec = "disc" },
        ["Psychic Scream"] = { isTracking = false, duration = 27, spellId = 10890, adjust = { shadow = 23 } },
        ["Psychic Horror"] = { isTracking = false, duration = 120, spellId = 64044, spec = "shadow" },
        ["Pain Suppression"] = { isTracking = false, duration = 144, spellId = 33206, spec = "disc" },
        ["Shadowfiend"] = { isTracking = false, duration = 300, spellId = 34433, adjust = { shadow = 180 } },
        ["Shadow Word: Death"] = { isTracking = false, duration = 12, spellId = 48158 },
        ["Silence"] = { isTracking = false, duration = 45, spellId = 15487, spec = "shadow" },
    },
    ["Rogue"] = {
        ["Adrenaline Rush"] = { isTracking = false, duration = 180, spellId = 13750, spec = "combat" },
        ["Blade Flurry"] = { isTracking = false, duration = 120, spellId = 13877, spec = "combat" },
        ["Blind"] = { isTracking = false, duration = 120, spellId = 2094 },
        ["Cloak of Shadows"] = { isTracking = false, duration = 60, spellId = 31224 },
        ["Cold Blood"] = { isTracking = false, duration = 180, spellId = 14177, spec = "assa" },
        ["Dismantle"] = { isTracking = false, duration = 60, spellId = 51722 },
        ["Evasion"] = { isTracking = false, duration = 180, spellId = 5277, adjust = { combat = 120 } },
        ["Feint"] = { isTracking = false, duration = 10, spellId = 48659 },
        ["Ghostly Strike"] = { isTracking = false, duration = 20, spellId = 14278, spec = "sub" },
        ["Gouge"] = { isTracking = false, duration = 10, spellId = 1776 },
        ["Kick"] = { isTracking = false, duration = 10, spellId = 1766 },
        ["Kidney Shot"] = { isTracking = false, duration = 20, spellId = 8643 },
        ["Killing Spree"] = { isTracking = false, duration = 75, spellId = 51690, spec = "combat" },
        ["Preparation"] = { isTracking = false, duration = 300, spellId = 14185, spec = "sub" },
        ["Shadow Dance"] = { isTracking = false, duration = 60, spellId = 51713, spec = "sub" },
        ["Shadowstep"] = { isTracking = false, duration = 20, spellId = 36554, spec = "sub" },
        ["Sprint"] = { isTracking = false, duration = 180, spellId = 11305, adjust = { combat = 120 } },
        ["Tricks of the Trade"] = { isTracking = false, duration = 30, spellId = 57934, adjust = { sub = 20 } },
        ["Vanish"] = { isTracking = false, duration = 120, spellId = 1856 },
    },
    ["Shaman"] = { 
        ["Bloodlust"] = { isTracking = false, duration = 300, spellId = 2825 },
        ["Chain Lightning "] = { isTracking = false, duration = 6, spellId = 49271, adjust = { ele = 3.5 } },
        ["Earthbind Totem"] = { isTracking = false, duration = 10.5, spellId = 2484 },
        ["Elemental Mastery"] = { isTracking = false, duration = 180, spellId = 16166, spec = "ele" },
        ["Feral Spirit"] = { isTracking = false, duration = 180, spellId = 51533, spec = "enhancement" },
        ["Fire Nova"] = { isTracking = false, duration = 10, spellId = 61657 },
        ["Grounding Totem"] = { isTracking = false, duration = 13.5, spellId = 8177 },
        ["Hex"] = { isTracking = true, duration = 45, spellId = 51514 },
        ["Heroism"] = { isTracking = true, duration = 300, spellId = 32182 },
        ["Lava Burst"] = { isTracking = false, duration = 8, spellId = 60043 },
        ["Lava Lash"] = { isTracking = false, duration = 6, spellId = 60103, spec = "enhancement" },
        ["Mana Tide Totem"] = { isTracking = false, duration = 300, spellId = 16190, spec = "restoSham" },
        ["Nature's Swiftness"] = { isTracking = false, duration = 120, spellId = 16188, spec = "restoSham" },
        ["Reincarnation"] = { isTracking = false, duration = 1800, spellId = 20608 },
        ["Riptide"] = { isTracking = false, duration = 6, spellId = 61301, spec = "restoSham" },
        ["Shamanistic Rage"] = { isTracking = false, duration = 60, spellId = 30823, spec = "enhancement" },
        ["Stoneclaw Totem"] = { isTracking = false, duration = 21, spellId = 58582 },
        ["Stormstrike"] = { isTracking = false, duration = 8, spellId = 17364, spec = "enhancement" },
        ["Tidal Force"] = { isTracking = false, duration = 180, spellId = 55198, spec = "restoSham" },
        ["Thunderstorm"] = { isTracking = false, duration = 35, spellId = 59159, spec = "ele" },
        ["Wind Shear"] = { isTracking = false, duration = 5, spellId = 57994 },
    },
    ["Warlock"] = { 
        ["Chaos Bolt"] = { isTracking = false, duration = 12, spellId = 59172, spec = "destro" },
        ["Conflagrate"] = { isTracking = false, duration = 10, spellId = 17962, spec = "destro" },
        ["Death Coil"] = { isTracking = false, duration = 120, spellId = 47860 },
        ["Demonic Circle: Teleport"] = { isTracking = false, duration = 30, spellId = 48020 },
        ["Demonic Empowerment"] = { isTracking = false, duration = 60, spellId = 47193, spec = "demo" },
        ["Devour Magic"] = { isTracking = false, duration = 8, spellId = 48011 },
        ["Fel Domination"] = { isTracking = false, duration = 180, spellId = 18708, spec = "demo", adjust = { demo = 126 } },
        ["Haunt"] = { isTracking = false, duration = 8, spellId = 59164, spec = "affli" },
        ["Howl of Terror"] = { isTracking = false, duration = 32, spellId = 17928 },
        ["Metamorphosis"] = { isTracking = false, duration = 126, spellId = 47241, spec = "demo" },
        ["Shadow Ward"] = { isTracking = false, duration = 30, spellId = 47891 },
        ["Shadowburn"] = { isTracking = false, duration = 15, spellId = 47827, spec = "destro" },
        ["Shadowflame"] = { isTracking = false, duration = 15, spellId = 61290 },
        ["Shadowfury"] = { isTracking = false, duration = 20, spellId = 47847, spec = "destro" },
        ["Spell Lock"] = { isTracking = true, duration = 24, spellId = 19647 },
    },
    ["Warrior"] = {
        ["Berserker Rage"] = { isTracking = false, duration = 30, spellId = 18499, adjust = { fury = 20 } },
        ["Bladestorm"] = { isTracking = false, duration = 90, spellId = 46924, spec = "arms" },
        ["Bloodthirst"] = { isTracking = false, duration = 4, spellId = 30335, spec = "fury" },
        ["Charge"] = { isTracking = false, duration = 20, spellId = 11578, adjust = { protWar = 15 } },
        ["Concussion Blow"] = { isTracking = false, duration = 30, spellId = 12809, spec = "protWar" },
        ["Death Wish"] = { isTracking = false, duration = 120, spellId = 12292, spec = "fury" },
        ["Disarm"] = { isTracking = false, duration = 60, spellId = 676, adjust = { protWar = 40 } },
        ["Enraged Regeneration"] = { isTracking = false, duration = 180, spellId = 55694 },
        ["Heroic Fury"] = { isTracking = false, duration = 45, spellId = 60970, spec = "fury" },
        ["Heroic Throw"] = { isTracking = false, duration = 60, spellId = 57755 },
        ["Intercept"] = { isTracking = false, duration = 25, spellId = 20252 },
        ["Intervene"] = { isTracking = false, duration = 30, spellId = 3411 },
        ["Intimidating Shout"] = { isTracking = false, duration = 120, spellId = 5246 },
        ["Last Stand"] = { isTracking = false, duration = 180, spellId = 12975, spec = "protWar" },
        ["Mortal Strike"] = { isTracking = false, duration = 5, spellId = 47486, spec = "arms" },
        ["Pummel"] = { isTracking = false, duration = 10, spellId = 6552 },
        ["Recklessness"] = { isTracking = false, duration = 300, spellId = 1719, adjust = { protWar = 240, fury = 201 } },
        ["Retaliation"] = { isTracking = false, duration = 300, spellId = 65932, adjust = { protWar = 240 } },
        ["Shattering Throw"] = { isTracking = false, duration = 300, spellId = 64382 },
        ["Shield Bash"] = { isTracking = false, duration = 12, spellId = 72 },
        ["Shield Block"] = { isTracking = false, duration = 60, spellId = 2565, adjust = { protWar = 40 } },
        ["Shield Wall"] = { isTracking = false, duration = 300, spellId = 871, adjust = { protWar = 240 } },
        ["Shockwave"] = { isTracking = false, duration = 17, spellId = 46968, spec = "protWar" },
        ["Spell Reflection"] = { isTracking = false, duration = 10, spellId = 23920 },
        ["Sweeping Strikes"] = { isTracking = false, duration = 30, spellId = 12328, spec = "arms" },
        ["Whirlwind"] = { isTracking = false, duration = 10, spellId = 1680 },
    },
}
