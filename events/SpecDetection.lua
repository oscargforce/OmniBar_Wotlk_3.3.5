local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")

OmniBar.specDetection = {
    arena1 = "arms",
    arena2 = "arms",
    arena3 = "arms",
}


function OmniBar:DetectSpecByAbility(spellName)
    return addon.specSpellTableSimple[spellName] or false
end

function OmniBar:DetectSpecByAura(auraName)
    return addon.buffSpecTable[auraName] or false
end



local buffSpecTable = {
    ["Warrior"] = {
        ["Taste for Blood"] = "arms",
        ["Juggernaut"] = "arms",
        ["Rampage"] = "fury",
        ["Sword and Board"] = "protWar"
    },
    ["Paladin"] = {
        ["Seal of Command"] = "retri",
        ["Light's Grace"] = "holy"
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
        ["Imp. Icy Talons"] = "frost"
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


addon.specSpellTableSimple = {
    -- Death Knight
    ["Anti-Magic Zone"] = "Unholy",
    ["Bone Shield"] = "Unholy",
    ["Dancing Rune Weapon"] = "Blood",
    ["Deathchill"] = "Frost",
    ["Howling Blast"] = "Frost",
    ["Hungering Cold"] = "Frost",
    ["Hysteria"] = "Blood",
    ["Lichborne"] = "Frost",
    ["Mark of Blood"] = "Blood",
    ["Rune Tap"] = "Blood",
    ["Summon Gargoyle"] = "Unholy",
    ["Unbreakable Armor"] = "Frost",
    ["Vampiric Blood"] = "Blood",

    -- Druid
    ["Berserk"] = "Feral",
    ["Feral Charge - Bear"] = "Feral",
    ["Force of Nature"] = "Balance",
    ["Nature's Swiftness"] = "Restoration",
    ["Starfall"] = "Balance",
    ["Survival Instincts"] = "Feral",
    ["Swiftmend"] = "Restoration",
    ["Typhoon"] = "Balance",

    -- Hunter
    ["Aimed Shot"] = "Marksmanship",
    ["Bestial Wrath"] = "Beast Mastery",
    ["Black Arrow"] = "Survival",
    ["Chimera Shot"] = "Marksmanship",
    ["Intimidation"] = "Beast Mastery",
    ["Readiness"] = "Marksmanship",
    ["Scatter Shot"] = "Survival",
    ["Silencing Shot"] = "Marksmanship",
    ["Wyvern Sting"] = "Survival",

    -- Mage
    ["Arcane Power"] = "Arcane",
    ["Blast Wave"] = "Fire",
    ["Cold Snap"] = "Frost",
    ["Combustion"] = "Fire",
    ["Deep Freeze"] = "Frost",
    ["Dragon's Breath"] = "Fire",
    ["Ice Barrier"] = "Frost",
    ["Icy Veins"] = "Frost",
    ["Presence of Mind"] = "Arcane",
    ["Summon Water Elemental"] = "Frost",

    -- Paladin
    ["Aura Mastery"] = "Holy",
    ["Avenger's Shield"] = "Protection",
    ["Crusader Strike"] = "Retribution",
    ["Divine Favor"] = "Holy",
    ["Divine Illumination"] = "Holy",
    ["Divine Sacrifice"] = "Protection",
    ["Divine Storm"] = "Retribution",
    ["Hammer of the Righteous"] = "Protection",
    ["Holy Shield"] = "Protection",
    ["Holy Shock"] = "Holy",
    ["Repentance"] = "Retribution",

    -- Priest
    ["Dispersion"] = "Shadow",
    ["Desperate Prayer"] = "Holy",
    ["Guardian Spirit"] = "Holy",
    ["Inner Focus"] = "Discipline",
    ["Lightwell"] = "Holy",
    ["Pain Suppression"] = "Discipline",
    ["Penance"] = "Discipline",
    ["Power Infusion"] = "Discipline",
    ["Psychic Horror"] = "Shadow",
    ["Silence"] = "Shadow",

    -- Rogue
    ["Adrenaline Rush"] = "Combat",
    ["Blade Flurry"] = "Combat",
    ["Cold Blood"] = "Assassination",
    ["Ghostly Strike"] = "Subtlety",
    ["Killing Spree"] = "Combat",
    ["Preparation"] = "Subtlety",
    ["Shadow Dance"] = "Subtlety",
    ["Shadowstep"] = "Subtlety",

    -- Shaman
    ["Elemental Mastery"] = "Elemental",
    ["Feral Spirit"] = "Enhancement",
    ["Lava Lash"] = "Enhancement",
    ["Mana Tide Totem"] = "Restoration",
    ["Nature's Swiftness"] = "Restoration",
    ["Riptide"] = "Restoration",
    ["Shamanistic Rage"] = "Enhancement",
    ["Stormstrike"] = "Enhancement",
    ["Tidal Force"] = "Restoration",
    ["Thunderstorm"] = "Elemental",

    -- Warlock
    ["Chaos Bolt"] = "Destruction",
    ["Conflagrate"] = "Destruction",
    ["Demonic Empowerment"] = "Demonology",
    ["Fel Domination"] = "Demonology",
    ["Metamorphosis"] = "Demonology",
    ["Shadowburn"] = "Destruction",
    ["Shadowfury"] = "Destruction",

    -- Warrior
    ["Bladestorm"] = "Arms",
    ["Bloodthirst"] = "Fury",
    ["Concussion Blow"] = "Protection",
    ["Death Wish"] = "Fury",
    ["Heroic Fury"] = "Fury",
    ["Last Stand"] = "Protection",
    ["Mortal Strike"] = "Arms",
    ["Shockwave"] = "Protection",
    ["Sweeping Strikes"] = "Arms",
}