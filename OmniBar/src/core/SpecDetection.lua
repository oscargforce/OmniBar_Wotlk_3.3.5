local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local addonName, addon = ...
local specDefiningSpells = addon.specDefiningSpells
local crossSpecSpells = addon.crossSpecSpells
local specDefiningAuras = addon.specDefiningAuras
local UnitAura = UnitAura
local GetUnitName = GetUnitName
local UnitClass = UnitClass

local processedBars = {}

local validArenaUnits = {
    ["arena1"] = true,
    ["arena2"] = true,
    ["arena3"] = true,
    ["arena4"] = true,
    ["arena5"] = true,
}

local validWorldUnits = {
    ["target"] = true,
    ["focus"] = true,
}


local function MarkBarAsProcessed(barKey, unit)
    if not processedBars[barKey] then
        processedBars[barKey] = {}
    end
    processedBars[barKey][unit] = true
end

local function HasBarProcessedUnit(barKey, unit)
    return processedBars[barKey] and processedBars[barKey][unit]
end

function OmniBar:GetSpecFromSpellTable(spellName)
    return specDefiningSpells[spellName]
end

function OmniBar:ClearSpecProcessedData(unit)
    for barKey, units in pairs(processedBars) do
        units[unit] = nil
    end
end

function OmniBar:DetectSpecByAbility(spellName, unit, barFrame, barSettings, unitGUID)
    if self.zone ~= "arena" then 
        self:DetectSpecByAbilityInWorldZones(spellName, unit, barFrame, barSettings, unitGUID)
        return 
    end

    if not validArenaUnits[unit] then return end

    local barKey = barFrame.key
    if HasBarProcessedUnit(barKey, unit) then
        return
    end

    local opponent = self.arenaOpponents[unit]
    if not opponent then return end

    if not opponent.spec then
        local definedSpec = specDefiningSpells[spellName]
        if definedSpec then
            opponent.spec = definedSpec
        end
    end
    
    if opponent.spec then
        self:OnSpecDetected(unit, opponent, barFrame, barSettings)
        MarkBarAsProcessed(barKey, unit)
    end
end

function OmniBar:DetectSpecByAbilityInWorldZones(spellName, unit, barFrame, barSettings, unitGUID)
    if not validWorldUnits[unit] then return end
    -- if barSettings.trackedUnit == "allEnemies" then return end --- Why did I have this check ??? 

    local barKey = barFrame.key
    if HasBarProcessedUnit(barKey, unit) then return end

    local unitName = GetUnitName(unit)
    local cachedData = self.combatLogCache[unitName]

    if cachedData and cachedData.spec then return end

    local definedSpec = specDefiningSpells[spellName]
    if definedSpec then
        local className = UnitClass(unit)
        local opponent = { unitGUID = unitGUID, className = className, spec = definedSpec }
        self:OnSpecDetected(unit, opponent, barFrame, barSettings)
        MarkBarAsProcessed(barKey, unit)
    end
end

function OmniBar:DetectSpecByAura(unit, barFrame, barSettings)
    local barKey = barFrame.key
    if HasBarProcessedUnit(barKey, unit) then return end

    local opponent = self.arenaOpponents[unit]
    if not opponent then return end

    local auras = specDefiningAuras[opponent.className]
    if not auras then return end
    
    local unitSpec = opponent.spec or false
    
    -- Detect spec if not already detected
    if not unitSpec then
        for auraName, spec in pairs(auras) do
            local hasAura = UnitAura(unit, auraName)
            if hasAura then
                unitSpec = spec
                opponent.spec = spec
                break
            end
        end
    end

    -- If spec is detected, process it
    if unitSpec then
        self:OnSpecDetected(unit, opponent, barFrame, barSettings)
        MarkBarAsProcessed(barKey, unit)    
    end
end

local function SpellBelongsToSpec(spellData, opponent, spellName)
    if not spellData.spec then 
        return false 
    end

    if spellData.partySpecOnly then
        return false
    end

    if spellData.className ~= opponent.className then
        return false
    end

    local crossSpecInfo = crossSpecSpells[spellName]
    if crossSpecInfo and crossSpecInfo[opponent.spec] then
        return true
    end

    return spellData.spec == opponent.spec
end

-- Spec application
function OmniBar:OnSpecDetected(unit, opponent, barFrame, barSettings)
    local needsAlphaUpdate = false

    if barSettings.showUnusedIcons then
        for spellName, spellData in pairs(barFrame.trackedSpells) do
            if SpellBelongsToSpec(spellData, opponent, spellName) then
                local icon = self:CreateIconToBar(barFrame, barSettings.showBorder, spellName, spellData, opponent.unitGUID, unit)
                needsAlphaUpdate = true

                if self.zone ~= "arena" then
                    local playerName = GetUnitName(unit)
                    local cachedData = self.combatLogCache[playerName]
                    local hasCachedSpell = cachedData and cachedData[spellName]
                    if hasCachedSpell then
                        self:ActivateIcon(barFrame, barSettings, icon, cachedData[spellName])
                    end
                end
            end
        end
    end
    
    self:AdjustUnusedIconsCooldownForSpec(barFrame, opponent.unitGUID, opponent.spec, barSettings)
    self:ArrangeIcons(barFrame, barSettings)
    
    if needsAlphaUpdate then
        self:UpdateUnusedAlpha(barFrame, barSettings)
    end
end

function OmniBar:AdjustUnusedIconsCooldownForSpec(barFrame, unitGUID, spec, barSettings)
    for i, icon in ipairs(barFrame.icons) do 
        if icon.unitGUID == unitGUID then
            local spellData = barFrame.trackedSpells[icon.spellName]
            if spellData.adjust and spellData.adjust[spec] then
               icon.duration = spellData.adjust[spec]
               -- Update the cooldown timer for active icons when spec detection changes the cooldown duration.
               if barFrame.activeIcons[icon] then
                   self:ActivateIcon(barFrame, barSettings, icon, {
                       expires = icon.startTime + icon.duration,
                       timestamp = icon.startTime,
                       duration = icon.duration
                   })
               end
           end
        end
   end
end

function OmniBar:AdjustCooldownForSpec(icon, spellData, unit, barFrame, barSettings, cachedSpell)
    if cachedSpell then return end
    if not spellData.adjust then return end
   
    -- Arena spec handling
    if self.zone == "arena" then
        local spec = self.arenaOpponents[unit] and self.arenaOpponents[unit].spec or self.partyMemberSpecs[unit]

        if not spellData.adjust[spec] then return end
        icon.duration = spellData.adjust[spec]
        return
    end 

    -- World PvP spec handling
    if unit:match("^party[1-4]$") then
        local spec = self.partyMemberSpecs[unit]

        -- If party spec detection failed, use combatLogCache as last resort
        if spec and spec ~= "" then 
            if not spellData.adjust[spec] then return end
    
            icon.duration = spellData.adjust[spec]
            return
        end
    end

    local playerName = GetUnitName(unit)
    local cachedData = self.combatLogCache[playerName]
    local hasCachedSpec = cachedData and cachedData.spec

    if hasCachedSpec and spellData.adjust[cachedData.spec] then
        icon.duration = spellData.adjust[cachedData.spec]
    end
end