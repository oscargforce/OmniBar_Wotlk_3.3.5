local addonName, addon = ...

local trinketToBuffMap = {
    ["Bauble of True Blood"] = "Release of Light",
    ["Corroded Skeleton Key"] = "Hardened Skin",
    ["Medallion of the Alliance"] = "PvP Trinket",
    ["Medallion of the Horde"] = "PvP Trinket",
    ["Satrina's Impeding Scarab"] = "Fortitude",
    ["Sindragosa's Flawless Fang"] = "Aegis of Dalaran",
}

function addon.MapTrinketNameToBuffName(trinketName)
    return trinketToBuffMap[trinketName] or trinketName
end

local petToPlayerMap = {
    ["arenapet1"] = "arena1",
    ["arenapet2"] = "arena2",
    ["arenapet3"] = "arena3",
    ["arenapet4"] = "arena4",
    ["arenapet5"] = "arena5",
    ["partypet1"] = "party1",
    ["partypet2"] = "party2",
    ["partypet3"] = "party3",
    ["partypet4"] = "party4",
}

function addon.MapPetToPlayerUnit(unit)
    return petToPlayerMap[unit] or unit
end

local warlockDeathCoilSpells = { 
    [6789] = true, -- Death Coil (Rank 1)
    [17925] = true, -- Death Coil (Rank 2)
    [17926] = true, -- Death Coil (Rank 3)
    [27223] = true, -- Death Coil (Rank 4)
    [47859] = true, -- Death Coil (Rank 5)
    [47860] = true, -- Death Coil (Rank 6)
}

function addon.IsWarlockDeathCoilSpell(spellId)
    return warlockDeathCoilSpells[spellId]
end