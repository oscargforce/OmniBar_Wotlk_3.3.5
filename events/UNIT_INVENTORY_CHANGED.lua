local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local _, addon = ...
local GetTrinketNameFromBuff = addon.GetTrinketNameFromBuff
local IsActiveBattlefieldArena = IsActiveBattlefieldArena
local CheckInteractDistance = CheckInteractDistance
local NotifyInspect = NotifyInspect
local ClearInspectPlayer = ClearInspectPlayer

--[[
So pros for keeping it all in party members changed:
 if unit changes gear, we update talent incase they switched [not reliable though] however one does often change gear when switching talents.

 cons:
  Might risk resetting cds earlier then expected.
  

 general:
 the event sucks, it gives wrong talents sometimes... Might have to delay a second before making a request.
]]

function OmniBar:OnUnitInventoryChanged(barFrame, event, unit)
    print("OnUnitInventoryChanged")
    local barSettings = self.db.profile.bars[barFrame.key]

    if not barSettings.showUnusedIcons then return end

    local trackedUnit = barSettings.trackedUnit

    if trackedUnit ~= unit then return end

    if select(1, IsActiveBattlefieldArena()) then return end

    local unitTrinkets = {}
    local didInspect = false
    local needsRearranging = false

    if CheckInteractDistance(trackedUnit, 1) then 
        NotifyInspect(trackedUnit)
        print("tracking", trackedUnit)
        unitTrinkets = self:GetPartyUnitsTrinkets(trackedUnit) 
        didInspect = true
    end

    if not didInspect then return end

    for i = #barFrame.icons, 1, -1 do
        local icon = barFrame.icons[i]
        if icon.item then  
            local trinketName = GetTrinketNameFromBuff(icon.spellName)
            if not unitTrinkets[trinketName] then
                table.remove(barFrame.icons, i)
                self:ReturnIconToPool(icon) 
                needsRearranging = true
            end
        end
    end

    for trinketName, _ in pairs(unitTrinkets) do
        local isTrinketOnBar = false
        local buffName = addon.GetBuffNameFromTrinket(trinketName)
        local spellData = barFrame.trackedSpells[buffName] 
        if spellData then
            self:CreateIconToBar(barFrame, buffName, spellData)
            needsRearranging = true
        end
    end

    ClearInspectPlayer()

    if needsRearranging then
        self:ArrangeIcons(barFrame, barSettings)
        self:UpdateUnusedAlpha(barFrame, barSettings)
    end
end