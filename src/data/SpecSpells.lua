local addonName, addon = ...

addon.specDefiningAuras = {
    ["Warrior"] = {
        ["Taste for Blood"] = "arms",
        ["Juggernaut"] = "arms",
        ["Rampage"] = "fury",
        ["Sword and Board"] = "protWar"
    },
    ["Paladin"] = {
        ["Seal of Command"] = "retri",
        ["Light's Grace"] = "holyPala"
    },
    ["Rogue"] = {
        ["Shadowstep"] = "sub",
        ["Master of Subtlety"] = "sub"
    },
    ["Priest"] = {
        ["Guardian Spirit"] = "holyPriest",
        ["Borrowed Time"] = "disc",
        ["Shadowform"] = "shadow",
        ["Vampiric Embrace"] = "shadow"
    },
    ["Death Knight"] = {
        ["Bone Shield"] = "unholy",
        ["Hysteria"] = "blood",
        ["Abomination's Might"] = "blood",
        ["Imp. Icy Talons"] = "frostDk"
    },
    ["Mage"] = {
        ["Ice Barrier"] = "frost",
        ["Combustion"] = "fire",
        ["Arcane Empowerment"] = "arcane"
    },
    ["Warlock"] = {
        ["Nether Protection"] = "destro"
    },
    ["Shaman"] = {
        ["Totem of Wrath"] = "ele",
        ["Earth Shield"] = "restoSham",
        ["Elemental Oath"] = "ele",
        ["Unleashed Rage"] = "enhancement"
    },
    ["Hunter"] = {
        ["Spirit Bond"] = "bm",
        ["Trueshot Aura"] = "mm"
    },
    ["Druid"] = {
        ["Leader of the Pack"] = "feral",
        ["Tree of Life"] = "restoDruid",
        ["Moonkin Aura"] = "balance",
        ["Wild Growth"] = "restoDruid"
    }
}

addon.crossSpecSpells = {
    ["Aimed Shot"] = { mm = true, survival = true, bm = true },
    ["Readiness"] = { mm = true, bm = true },
    ["Scatter Shot"] =  { mm = true, survival = true },
    ["Lichborne"] =  { frostDk = true, blood = true, unholy = true },
    ["Bone Shield"] =  { frostDk = true, blood = true, unholy = true },
}

addon.specDefiningSpells = {
    -- Death Knight
    ["Anti-Magic Zone"] = "unholy",
    ["Dancing Rune Weapon"] = "blood",
    ["Deathchill"] = "frostDk",
    ["Howling Blast"] = "frostDk",
    ["Hungering Cold"] = "frostDk",
    ["Hysteria"] = "blood",
    ["Mark of Blood"] = "blood",
    ["Rune Tap"] = "blood",
    ["Summon Gargoyle"] = "Unholy",
    ["Unbreakable Armor"] = "frostDk",
    ["Vampiric Blood"] = "blood",

    -- Druid
    ["Berserk"] = "feral",
    ["Feral Charge - Bear"] = "feral",
    ["Force of Nature"] = "balance",
    ["Nature's Swiftness"] = "restoDruid",
    ["Starfall"] = "balance",
    ["Survival Instincts"] = "feral",
    ["Swiftmend"] = "restoDruid",
    ["Typhoon"] = "balance",

    -- Hunter
    ["Bestial Wrath"] = "bm",
    ["Black Arrow"] = "survival",
    ["Chimera Shot"] = "mm",
    ["Intimidation"] = "bm",
    ["Silencing Shot"] = "mm",
    ["Wyvern Sting"] = "survival",
    ["Explosive Shot"] = "survival",

    -- Mage
    ["Arcane Power"] = "arcane",
    ["Blast Wave"] = "fire",
    ["Cold Snap"] = "frost",
    ["Combustion"] = "fire",
    ["Deep Freeze"] = "frost",
    ["Dragon's Breath"] = "fire",
    ["Ice Barrier"] = "frost",
    ["Icy Veins"] = "frost",
    ["Presence of Mind"] = "arcane",
    ["Summon Water Elemental"] = "frost",

    -- Paladin
    ["Aura Mastery"] = "holy",
    ["Avenger's Shield"] = "protPala",
    ["Crusader Strike"] = "retri",
    ["Divine Favor"] = "holy",
    ["Divine Illumination"] = "holy",
    ["Divine Sacrifice"] = "protPala",
    ["Divine Storm"] = "retri",
    ["Hammer of the Righteous"] = "protPala",
    ["Holy Shield"] = "protPala",
    ["Holy Shock"] = "holy",
    ["Repentance"] = "retri",

    -- Priest
    ["Dispersion"] = "shadow",
    ["Desperate Prayer"] = "holyPriest",
    ["Guardian Spirit"] = "holyPriest",
    ["Inner Focus"] = "disc",
    ["Lightwell"] = "holyPriest",
    ["Pain Suppression"] = "disc",
    ["Penance"] = "disc",
    ["Power Infusion"] = "disc",
    ["Psychic Horror"] = "shadow",
    ["Silence"] = "shadow",

    -- Rogue
    ["Adrenaline Rush"] = "combat",
    ["Blade Flurry"] = "combat",
    ["Cold Blood"] = "assa",
    ["Ghostly Strike"] = "sub",
    ["Killing Spree"] = "combat",
    ["Preparation"] = "sub",
    ["Shadow Dance"] = "sub",
    ["Shadowstep"] = "sub",

    -- Shaman
    ["Elemental Mastery"] = "ele",
    ["Feral Spirit"] = "enhancement",
    ["Lava Lash"] = "enhancement",
    ["Mana Tide Totem"] = "restoSham",
    ["Nature's Swiftness"] = "restoSham",
    ["Riptide"] = "restoSham",
    ["Shamanistic Rage"] = "enhancement",
    ["Stormstrike"] = "enhancement",
    ["Tidal Force"] = "restoSham",
    ["Thunderstorm"] = "ele",

    -- Warlock
    ["Chaos Bolt"] = "destro",
    ["Conflagrate"] = "destro",
    ["Demonic Empowerment"] = "demo",
    ["Fel Domination"] = "demo",
    ["Metamorphosis"] = "demo",
    ["Shadowburn"] = "destro",
    ["Shadowfury"] = "destro",

    -- Warrior
    ["Bladestorm"] = "arms",
    ["Bloodthirst"] = "fury",
    ["Concussion Blow"] = "protWar",
    ["Death Wish"] = "fury",
    ["Heroic Fury"] = "fury",
    ["Last Stand"] = "protWar",
    ["Mortal Strike"] = "arms",
    ["Shockwave"] = "protWar",
    ["Sweeping Strikes"] = "arms",
}