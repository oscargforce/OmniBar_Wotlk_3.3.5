local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local _, addon = ...
local UnitAffectingCombat = UnitAffectingCombat
local CheckInteractDistance = CheckInteractDistance
local NotifyInspect = NotifyInspect
local ClearInspectPlayer = ClearInspectPlayer

--[[
      NOTE: WoW's 3.3.5 Inventory API can be unreliable, especially when trinkets are swapped quickly. 
        It may not keep up with rapid changes and could return outdated trinket data. 
        In some cases, it may provide information about the trinkets that were equipped a moment ago,
        rather than the current state.
]]

function OmniBar:OnUnitInventoryChanged(barFrame, event, unit)
    print("OnUnitInventoryChanged")
    local barSettings = self.db.profile.bars[barFrame.key]

    if not barSettings.showUnusedIcons then return end

    local trackedUnit = barSettings.trackedUnit

    if trackedUnit ~= unit then return end

    if UnitAffectingCombat(trackedUnit) then return end

    local unitTrinkets = {}
    local didInspect = false
    local needsRearranging = false

    if CheckInteractDistance(trackedUnit, 1) then 
        NotifyInspect(trackedUnit)
        print("NotifyInspect", trackedUnit)
        unitTrinkets = self:GetPartyUnitsTrinkets(trackedUnit) 
        didInspect = true
    end

    if not didInspect then return end

    -- existing icon trinkets on the omnibar.
    local iconTrinketsOnBar = {}

    for i = #barFrame.icons, 1, -1 do
        local icon = barFrame.icons[i]
        if icon.item then          
            if not unitTrinkets[icon.spellName] then -- Remove trinket icon form bar since it no longer is equipped.
                table.remove(barFrame.icons, i)
                self:ReturnIconToPool(icon) 
                needsRearranging = true

            else 
                iconTrinketsOnBar[icon.spellName] = true -- cache equipped trinket
            end
        end
    end

    for trinketName, _ in pairs(unitTrinkets) do
        local spellData = barFrame.trackedSpells[trinketName] 
        if spellData and not iconTrinketsOnBar[trinketName] then
            self:CreateIconToBar(barFrame, trinketName, spellData)
            needsRearranging = true
        end
    end

    ClearInspectPlayer()

    if needsRearranging then
        self:ArrangeIcons(barFrame, barSettings)
        self:UpdateUnusedAlpha(barFrame, barSettings)
    end
    print("OnUnitInventoryChanged DONE")
end