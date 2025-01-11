local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")

local spellCasts = {}


-- maybe this can be register with ace? I dont think per Bar is needed if we just add spells to our table


-- original omnibar also tracks SPELL_AURA_APPLIED 
function OmniBar:COMBAT_LOG_EVENT_UNFILTERED(barFrame, event, ...)
   print("OnCombatLogUnfiltered")
    -- Implement tracking logic using COMBAT_LOG_EVENT_UNFILTERED
 --[[    local timestamp, subEvent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellId, spellName = ...

    if not subEvent == "SPELL_CAST_SUCCESS" then 
        return 
    end

    local barSettings = self.db.profile.bars[barFrame.key]
    local spellData = barFrame.trackedSpells[spellName]

    if not spellData then 
        return 
    end
    -- add spell to our spellCast table.
    spellCasts[name][spellID] = {
		duration = duration,
		event = event,
		expires = now + duration,
		ownerName = ownerName,
		serverTime = serverTime,
		sourceFlags = sourceFlags,
		sourceGUID = sourceGUID,
		sourceName = sourceName,
		spellID = spellID,
		spellName = spellName,
		timestamp = now,
	}
    self:OnCooldownUsed(barFrame, barSettings, sourceName, spellName, spellData)  ]]
    -- remove from spellCast table after duration
    
end





