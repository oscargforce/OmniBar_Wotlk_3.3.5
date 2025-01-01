local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local UnitClass = UnitClass
local UnitRace = UnitRace

--[[ 

    TODO:
      1) Need to add in equipment check for trinkets if tracked.
      2) Fix the create icons function, so it works with updating, or maybe just remove it completley. 
      3) Maybe reset the priority and spellName, className, race when returning to pool?  
      4) If we set UpdateUnusedAlpha here we need to remove that operation from the operationOrder in the updateBar function
      5) Fix bug, when the cooldown is used it changes places and changes places again once the cd is over
]]

function OmniBar:OnPartyMembersChanged(barFrame)
    local barSettings = self.db.profile.bars[barFrame.key]

    if not barSettings.showUnusedIcons then return end

    local trackedUnit = barSettings.trackedUnit

    -- make api request to fetch class and race
    local className = UnitClass(trackedUnit)

    -- No longer in a party, return the icons to the pool, if icons exists
    if not className then 
        self:ResetIcons(barFrame)
        return 
    end
    local race = UnitRace(trackedUnit)

    -- filter the tracked cooldowns based on class and race.
    -- populate the icons to the bar
    for spellName, spellData in pairs(barFrame.trackedSpells) do
        if className == spellData.className then
            self:CreateIconToBar(barFrame, spellName, spellData)
        end

        if spellData.race and spellData.race == race then
            self:CreateIconToBar(barFrame, spellName, spellData)
        end
    end

    -- arrange the icons by priority

    self:ArrangeIcons(barFrame, barSettings)
    self:UpdateUnusedAlpha(barFrame, barSettings)
end