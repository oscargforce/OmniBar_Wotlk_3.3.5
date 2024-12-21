local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")

--[[    
Example tables        

barFrame.trackedCooldowns = {
    ["Mind Freeze"] = {
        duration = 120,
        icon = path,
    },
    ["Kick"] = {
        duration = 15,
        icon = path,
    },
}

barFrame.activeCooldowns = {
        ["Mind Freeze"] = { endTime = 140, icon = frameRef }
        ["Berserking"] = { endTime = 140, icon = frameRef }
} 

]]


-- fix later
function OmniBar:OnUnitSpellCastSucceded(barFrame, event, unitId, spellName, spellRank)
    -- Quick fails
  --  if not unitId:match("arena%d") then return end
    if not unitId:match("party%d") then return end
   
    local cooldownData = barFrame.trackedCooldowns[spellName]
    if not cooldownData then return end

    local now = GetTime()

    -- Get or create icon for this spell
    local icon = self:GetIconFromPool(barFrame)
    icon.spellName = spellName -- maybe not need???
    icon.icon:SetTexture(cooldownData.icon)
    icon.cooldown:SetCooldown(now, cooldownData.duration)
    icon:Show()
    -- need to sort on bar based on time left, we prob need a new function
    
    table.insert(barFrame.icons, icon)
     -- Update or create spell tracking

     barFrame.activeCooldowns[spellName] = {
        endTime = now + cooldownData.duration,
        icon = icon
    }
    local barKey = barFrame.key
    viewTable(self.db.profile.bars[barKey])
    self:ArrangeIcons(barFrame, self.db.profile.bars[barKey])
end

--[[

local units = {
    target = "",
    arena1 = "",
    arena2 = "",
    arena3 = ""
}

local function ClearUnitClasses()
    for arenaUnit in pairs(unitClasses) do
        unitClasses[arenaUnit] = ""
    end
end

local function GetUnitClass(unitId)
    if unitClasses[unitId] ~= "" then
        return unitClasses[unitId]
    end
    local unitClass = UnitClass(unitId)
    unitClasses[unitId] = unitClass
    return unitClass
end

function OmniBar:UNIT_SPELLCAST_SUCCEEDED(event, unitId, spellName, spellRank)
    for barKey, barSettings in paris(self.db.profile.bars) do
        if barSettings.trackUnit == unitId then
            local unitClass = GetUnitClass(unitId)
            local spellData = self.db.profile.bars[barKey].cooldowns[unitClass][spellName]

            if not spellData or not spellData.isTracking then 
                return 
            end

            local icon = self:GetIconFromPool(barFrame)
            icon.icon:SetTexture(cooldownData.icon)
            icon:Show()

            self:ArrangeIcons(self.barFrames[barKey], barSettings)
        end
    end
end

]]

