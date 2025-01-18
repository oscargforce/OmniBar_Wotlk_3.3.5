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

function OmniBar:ClearSpecProcessedData(unit)
    for barKey, units in pairs(processedBars) do
        units[unit] = nil
    end
end

function OmniBar:DetectSpecByCombatLogCache(spellName)
    return specDefiningSpells[spellName]
end

function OmniBar:DetectSpecByAbility(spellName, unit, barFrame, barSettings)
    if self.zone ~= "arena" then 
        self:DetectSpecByAbilityInWorldZones(spellName, unit, barFrame, barSettings)
        return 
    end

    if not validArenaUnits[unit] then return end

    local barKey = barFrame.key
    if HasBarProcessedUnit(barKey, unit) then
        print(barSettings.name, "returns because HasBarProcessedUnit")
        return
    end

    local opponent = self.arenaOpponents[unit]
    if not opponent then return end

    if not opponent.spec then
        local definedSpec = specDefiningSpells[spellName]
        if definedSpec then
            opponent.spec = definedSpec
            print(barSettings.name, "Detected spec for " .. unit .. ": " .. definedSpec .. " via " .. spellName)
        end
    end
    
    if opponent.spec then
        self:OnSpecDetected(unit, opponent, barFrame, barSettings)
        MarkBarAsProcessed(barKey, unit)
    end
end

function OmniBar:DetectSpecByAbilityInWorldZones(spellName, unit, barFrame, barSettings)
    if not validWorldUnits[unit] then return end
    if barSettings.trackedUnit == "allEnemies" then return end

    local barKey = barFrame.key
    if HasBarProcessedUnit(barKey, unit) then
        print(barSettings.name, "returns because HasBarProcessedUnit")
        return
    end

    local unitName = GetUnitName(unit)
    local cachedData = self.combatLogCache[unitName]

    if cachedData and cachedData.spec then 
        print(barSettings.name, "Detected spec for " .. unit .. ": " .. cachedData.spec .. " via combat log cache")
        return 
    end

    local definedSpec = specDefiningSpells[spellName]
    
    if definedSpec then
        local className = UnitClass(unit)
        local opponent = { className = className, spec = definedSpec }
        self:OnSpecDetected(unit, opponent, barFrame, barSettings)
        MarkBarAsProcessed(barKey, unit)
    end
end

function OmniBar:DetectSpecByAura(unit, barFrame, barSettings)
    local barKey = barFrame.key
    if HasBarProcessedUnit(barKey, unit) then print(barSettings.name, "returns cuz HasBarProcessedUnit"); return end

    local opponent = self.arenaOpponents[unit]
    if not opponent then print(barSettings.name, "returns cuz no opponent"); return end

    local auras = specDefiningAuras[opponent.className]
    local unitSpec = opponent.spec or false
    
    -- Detect spec if not already detected
    if not unitSpec then
        for auraName, spec in pairs(auras) do
            local hasAura = UnitAura(unit, auraName)
            if hasAura then
                print(barSettings.name,"Detected spec for " .. unit .. ": " .. spec .. " via " .. hasAura)
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
        print(barSettings.name,"MarkBarAsProcessed")
    end
end

local function SpellBelongsToSpec(spellData, opponent, spellName)
    if not spellData.spec then 
        return false 
    end

    if spellData.className ~= opponent.className then
        return false
    end

    local crossSpecInfo = crossSpecSpells[spellName]
    if crossSpecInfo and crossSpecInfo[opponent.spec] then
        print("Allowing cross-spec spell: " .. spellName)
        return true
    end

    return spellData.spec == opponent.spec
end

function OmniBar:OnSpecDetected(unit, opponent, barFrame, barSettings)
    if #barFrame.icons == 0 then return end -- unsure why I have this check hehehe :P

    local needsRearranging = false

    for spellName, spellData in pairs(barFrame.trackedSpells) do
        if SpellBelongsToSpec(spellData, opponent, spellName) then
            print("OnSpecDetected:", spellName)
            self:CreateIconToBar(barFrame, spellName, spellData)
            needsRearranging = true
        end
    end

    if needsRearranging then
        self:ArrangeIcons(barFrame, barSettings)
        self:UpdateUnusedAlpha(barFrame, barSettings)
    end
end