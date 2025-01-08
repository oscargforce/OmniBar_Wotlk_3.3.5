local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local addonName, addon = ...
local specDefiningSpells = addon.specDefiningSpells
local crossSpecSpells = addon.crossSpecSpells
local specAuras = addon.specAuras
local UnitAura = UnitAura

function OmniBar:DetectSpecByAbility(spellName, unit, barFrame)
    if not unit:match("^arena[1-5]$") then return end

    local opponent = self.arenaOpponents[unit]
    if not opponent or opponent.spec then return end

    local definedSpec = specDefiningSpells[spellName]
    if definedSpec then
        opponent.spec = definedSpec
        print("Detected spec for " .. unit .. ": " .. definedSpec .. " via " .. spellName)
        self:OnSpecDetected(unit, definedSpec, barFrame)
    end
end

function OmniBar:DetectSpecByAura(unit, barFrame)
    local opponent = self.arenaOpponents[unit]
    if not opponent or opponent.spec then return end

    local auras = specAuras[opponent.className]

    local unitSpec = nil
    for auraName, spec in pairs(auras) do
        local hasAura = UnitAura(unit, auraName)
        if hasAura then
            print("Detected spec for " .. unit .. ": " .. spec .. " via " .. hasAura)
            unitSpec = spec
            break
        end
    end

    if unitSpec then
        opponent.spec = unitSpec
        self:OnSpecDetected(unit, unitSpec, barFrame)
    end
end

-- This may not work for all enemies, need to check class vs class if so.
local function SpellBelongsToSpec(icon, unitSpec)
    if not icon.spec then 
        return true 
    end

    local crossSpecInfo = crossSpecSpells[icon.spellName]
    if crossSpecInfo and crossSpecInfo[unitSpec] then
        print("Allowing cross-spec spell: " .. icon.spellName)
        return true
    end

    return icon.spec == unitSpec
end

function OmniBar:OnSpecDetected(unit, unitSpec, barFrame)
    -- check if there are icons on the bar, maybe add them we will see when testing.
    if #barFrame.icons == 0 then return end

    local needsRearranging = false

    for i = #barFrame.icons, 1, -1 do
        local icon = barFrame.icons[i]
        if not SpellBelongsToSpec(icon, unitSpec) then
            print("removing icon", icon.spellName)          
            table.remove(barFrame.icons, i)
            self:ReturnIconToPool(icon) 
            needsRearranging = true
        end
    end

    if needsRearranging then
        local barSettings = self.db.profile.bars[barFrame.key]
        self:ArrangeIcons(barFrame, barSettings)
        self:UpdateUnusedAlpha(barFrame, barSettings)
    end
end


