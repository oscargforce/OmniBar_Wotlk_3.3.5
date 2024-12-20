local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local addonName, addon = ...

--[[    
Example tables        

self.trackedCooldowns = {
    ["Mind Freeze"] = {
        duration = 120,
        icon = path,
        bars = {
            ["OmniBar1"] = true,
            ["OmniBar2"] = true
        },
    },
    ["Kick"] = {
        duration = 15,
        icon = path,
        bars = {
            ["OmniBar1"] = true,
            ["OmniBar2"] = false
        },
    },
}

self.activeCooldowns = {
        ["Mind Freeze"] = { endTime = 140, icon = frameRef }
        ["Berserking"] = { endTime = 140, icon = frameRef }
} 

]]



function OmniBar:BuildSpellTracking()
    wipe(self.trackedCooldowns)
    
    local cooldownsTable = addon.cooldownsTable
    
    for barKey, barSettings in pairs(self.db.profile.bars) do
        local barCooldowns = barSettings.cooldowns
        
        for className, cooldowns in pairs(barCooldowns) do
            for spellName, isTracking in pairs(cooldowns) do
                if isTracking then
                    local cooldownData = cooldownsTable[className][spellName]
                    
                    if not self.trackedCooldowns[spellName] then
                        self.trackedCooldowns[spellName] = {
                            duration = cooldownData.duration,
                            icon = cooldownData.icon,
                            bars = {}
                        }
                    end
                    self.trackedCooldowns[spellName].bars[barKey] = true
                end
            end
        end
    end
end


function OmniBar:UNIT_SPELLCAST_SUCCEEDED(event, unitId, spellName, spellRank)
    -- Quick fails
    if not unitId:match("arena%d") then return end
    local spellData = self.trackedCooldowns[spellName]
    if not spellData then return end

    local now = GetTime()
    
    -- Update or create spell tracking
    self.activeCooldowns[spellName] = {
        endTime = now + spellData.duration
    }

    -- Update each bar tracking this spell
    for barKey in pairs(spellData.bars) do
        local barFrame = self.barFrames[barKey]
        if barFrame then
            -- Get or create icon for this spell
            local icon = self:GetIconFromPool(barFrame)
            icon.spellId = spellName -- maybe not need???
            icon.icon:SetTexture(spellData.icon)
            icon.cooldown:SetCooldown(now, spellData.duration)
            icon:Show()
            
            table.insert(barFrame.icons, icon)
            self:ArrangeIcons(barFrame, self.db.profile.bars[barKey])
        end
    end
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

