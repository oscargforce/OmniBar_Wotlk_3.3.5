local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")

function OmniBar:RemoveExpiredSpellsFromCombatLogCache()
    local currentTime = GetTime()

    for playerName, spells in pairs(self.combatLogCache) do
        for spellName, spellData in pairs(spells) do
            if spellData.expires then
                if currentTime >= spellData.expires then
                    self.combatLogCache[playerName][spellName] = nil
                end
            end
        end
    end
end
