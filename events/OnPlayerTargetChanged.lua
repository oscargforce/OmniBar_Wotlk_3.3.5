local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local UnitIsPlayer = UnitIsPlayer
local UnitIsHostile = UnitIsHostile
local UnitClass = UnitClass
local UnitRace = UnitRace

function OmniBar:OnPlayerTargetChanged(barFrame, event)
    local barSettings = self.db.profile.bars[barFrame.key]

    if not barSettings.showUnusedIcons then 
        return 
    end

    if not UnitIsPlayer("target") and not UnitIsHostile("target") then
        return
    end

    local unitClass = UnitClass("target")
    local unitRace = UnitRace("target")

    -- Filter icons spells on class and race

    -- Add spec detection?


--[[
    events to listen to.
      - PLAYER_TARGET_CHANGED
      - PLAYER_FOCUS_CHANGED
    
    
]]
end