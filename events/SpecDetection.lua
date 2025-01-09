local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local addonName, addon = ...
local specDefiningSpells = addon.specDefiningSpells
local crossSpecSpells = addon.crossSpecSpells
local specDefiningAuras = addon.specDefiningAuras
local UnitAura = UnitAura
local processedBars = {}

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

function OmniBar:DetectSpecByAbility(spellName, unit, barFrame, barSettings)
    if not unit:match("^arena[1-5]$") then return end

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

local function SpellBelongsToSpec(icon, opponent)
    if not icon.spec then 
        return true 
    end

    -- Dont remove icons for other classes.
    if icon.className ~= opponent.className then
        return true
    end

    local crossSpecInfo = crossSpecSpells[icon.spellName]
    if crossSpecInfo and crossSpecInfo[opponent.spec] then
        print("Allowing cross-spec spell: " .. icon.spellName)
        return true
    end

    return icon.spec == opponent.spec
end

function OmniBar:OnSpecDetected(unit, opponent, barFrame, barSettings)
    -- check if there are icons on the bar, maybe add them we will see when testing.
    if #barFrame.icons == 0 then return end

    local needsRearranging = false

    for i = #barFrame.icons, 1, -1 do
        local icon = barFrame.icons[i]
        if not SpellBelongsToSpec(icon, opponent) then
            print(barSettings.name,"removing icon", icon.spellName)          
            table.remove(barFrame.icons, i)
            self:ReturnIconToPool(icon) 
            needsRearranging = true
        end
    end

    if needsRearranging then
        self:ArrangeIcons(barFrame, barSettings)
        self:UpdateUnusedAlpha(barFrame, barSettings)
    end
end


