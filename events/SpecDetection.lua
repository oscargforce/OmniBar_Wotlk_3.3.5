local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local addonName, addon = ...
local specSpells = addon.specSpells
local specAuras = addon.specAuras

-- How to handle spells such as aim shot, which can be used by multiple specs?

function OmniBar:DetectSpecByAbility(spellName, unit, barFrame)
    if not unit:match("^arena[1-5]$") then return end

    local opponent = self.arenaOpponents[unit]
    if not opponent or opponent.spec then return end

    local unitSpec = specSpells[spellName]
    print("unitSpec", unitSpec)
    if unitSpec then
        opponent.spec = unitSpec
        self:OnSpecDetected(unit, unitSpec, barFrame)
    end
end

function OmniBar:DetectSpecByAura(auraName, unit, barFrame)
    local opponent = self.arenaOpponents[unit]
    if not opponent or opponent.spec then return end

    local unitSpec = specAuras[opponent.className][auraName]

    if unitSpec then
        opponent.spec = unitSpec
        self:OnSpecDetected(unit, unitSpec, barFrame)
    end
end

function OmniBar:OnSpecDetected(unit, spec, barFrame)
    -- check if there are icons on the bar, maybe add them we will see when testing.
    if #barFrame.icons == 0 then return end

    local needsRearranging = false

    for i = #barFrame.icons, 1, -1 do
        local icon = barFrame.icons[i]
        if icon.spec and icon.spec ~= spec then          
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


