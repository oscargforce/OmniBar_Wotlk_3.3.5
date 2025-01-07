local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local addonName, addon = ...
local specSpells = addon.specSpells
local specAuras = addon.specAuras


function OmniBar:DetectSpecByAbility(spellName, unit)
    local opponent = self.arenaOpponents[unit]
    if not opponent or opponent.spec then return end

    local unitSpec = specSpells[spellName]

    if unitSpec then
        opponent.spec = unitSpec
        self:OnSpecDetected(unit, unitSpec)
    end
end

function OmniBar:DetectSpecByAura(auraName, unit)
    local opponent = self.arenaOpponents[unit]
    if not opponent or opponent.spec then return end

    local unitSpec = specAuras[opponent.className][auraName]

    if unitSpec then
        opponent.spec = unitSpec
        self:OnSpecDetected(unit, unitSpec)
    end
end

function OmniBar:OnSpecDetected(unit, spec)
    -- Callback for when spec is detected
    -- Other addons can hook this
end


