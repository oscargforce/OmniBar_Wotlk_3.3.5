local addonName, addon = ...

addon.resetCds = {
    ["Readiness"] = {
        ["Chimera Shot"] = true
    }
}

addon.sharedCds = {
    -- Warrior
    ["Shield Bash"] = {
        ["Pummel"] = 10
    },
    -- Hunter
    ["Freezing Arrow"] = {
        ["Freezing Trap"] = 28,
        ["Frost Trap"] = 28,
    },
    ["Frost Trap"] = {
        ["Freezing Trap"] = 28,
        ["Freezing Arrow"] = 28,
    },
    ["Freezing Trap"] = {
        ["Freezing Arrow"] = 28,
        ["Frost Trap"] = 28,
    },
}


--[[
-- add this in oncooldownused
function OmniBar:ResetCooldownsForSpell(barFrame, spellName)
    local resetSpells = addon.resetCds[spellName]
    if not resetSpells then return end

    for i, icon in ipairs(barFrame.icons) do
        -- Check if this icon's spell should be reset
        if resetSpells[icon.spellName] and barFrame.activeIcons[icon] then
            print("Resetting cooldown for", icon.spellName)
            -- Reset the cooldown
            self:ResetIconState(icon)
            barFrame.activeIcons[icon] = nil
            
            if not self.db.profile.bars[barFrame.key].showUnusedIcons then
                self:ReturnIconToPool(icon)
                table.remove(barFrame.icons, i)
            else
                self:UpdateUnusedAlpha(barFrame, self.db.profile.bars[barFrame.key], icon)
            end
        end
    end
    
    self:ArrangeIcons(barFrame, self.db.profile.bars[barFrame.key])
end


]]