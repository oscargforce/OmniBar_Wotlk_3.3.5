--[[ 


 function OmniBar:StartCooldownShading(icon, duration, barSettings, barFrame, cachedSpell)
    local now = GetTime()
    local remainingDuration = duration

    if cachedSpell then
        remainingDuration = cachedSpell.expires - now
        duration = remainingDuration 
    end

    local endTime = now + remainingDuration
    print("End time:", endTime, "Duration:", duration, "Remaining duration:", remainingDuration)
    icon:SetAlpha(1)
    if not cachedSpell then
        icon:PlayNewIconAnimation()
    end

    icon.cooldown:SetCooldown(now, remainingDuration)
    icon.cooldown:SetAlpha(barSettings.swipeAlpha)

    print("Icons pool OnUpdate", #self.iconPool)
    local lastUpdate = 0
    icon.timerFrame:Show() 
    icon.timerFrame:SetScript("OnUpdate", function(self, elapsed)
        lastUpdate = lastUpdate + elapsed
        if lastUpdate >= 0.2 then
            local timeLeft = endTime - GetTime()
            print("Time left:", timeLeft)
            if timeLeft > 0 then
                -- need to add condition here, if barSettings.noCountdownText, return early
                icon.countdownText:SetText(formatTimeText(timeLeft))
            else
                print("Cooldown ended")
                OmniBar:OnCooldownEnd(icon, barFrame, barSettings)
               -- print("BarFrame icons num:", #barFrame.icons)
            end
            lastUpdate = 0
        end
    end) 
end 







local spellCasts = {}

-- original omnibar also tracks SPELL_AURA_APPLIED 
function OmniBar:OnCombatLogUnfiltered(barFrame, event, ...)
    -- Implement tracking logic using COMBAT_LOG_EVENT_UNFILTERED
    local timestamp, subEvent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, destFlags, _, spellId, spellName = ...

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
    self:OnCooldownUsed(barFrame, barSettings, sourceName, spellName, spellData)
    -- remove from spellCast table after duration
    
end

function OmniBar:OnPlayerTargetChange(barFrame, event, ...)
    -- if zone is arena should we still do combat log event?

    -- Gather Basic info, OBS should create a cache for this.
    local targetName = UnitName("target")
    local targetClass = UnitClass("target")
    local targetRace = UnitRace("target")
    local targetCds = spellCasts[targetName]

    -- Populate the bar
    self:CreateIconToBar()
end


function OmniBar:OnEventHandler(barFrame, event, ...)
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        self:OnUnitSpellCastSucceeded(barFrame, event, ...)
    elseif event == "PARTY_MEMBERS_CHANGED" then
        self:OnPartyMembersChanged(barFrame, event, ...)
    elseif event == "UNIT_INVENTORY_CHANGED" then
        self:OnUnitInventoryChanged(barFrame, event, ...)
    elseif event == "INSPECT_TALENT_READY" then
        self:OnInspectTalentReady(barFrame, event, ...)
    elseif event == "ARENA_OPPONENT_UPDATE" then
        self:OnArenaOpponentUpdate(barFrame, event, ...)
    elseif event == "UNIT_AURA" then
        self:OnUnitAura(barFrame, event, ...)
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        self:OnCombatLogUnfiltered(barFrame, event, ...)
    end
end

local function IsValidWorldUnit(trackedUnit)
    return trackedUnit == "allEnemies" or trackedUnit == "target" or trackedUnit == "focus"
end

function OmniBar:ToggleSpellTrackingEvents(barFrame)
    if IsValidWorldUnit(self.db.profile.bars[barFrame.key].trackedUnit) then
        local registerEvent = self.zone == "arena" and "UNIT_SPELLCAST_SUCCEEDED" or "COMBAT_LOG_EVENT_UNFILTERED"
        local unregisterEvent = self.zone == "arena" and "COMBAT_LOG_EVENT_UNFILTERED" or "UNIT_SPELLCAST_SUCCEEDED"
        barFrame:UnregisterEvent(unregisterEvent)
        barFrame:RegisterEvent(registerEvent)
    else
        barFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        barFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    end
end

function OmniBar:ToggleWorldEnemiesEvents(barFrame)
    for barKey, barFrame in pairs(self.barFrames) do
        self:ToggleSpellTrackingEvents(barFrame)
    end
end

function OmniBar:PLAYER_ENTERING_WORLD()
    local _, zone = IsInInstance()
 
    -- Prevent unnecessary refresh on login or reload if the zone hasn't changed.
    if self.zone and self.zone ~= zone then
        self:RefreshBarsWithActiveIcons()
        self:ClearPartyGUIDCache()
        self:ToggleWorldEnemiesEvents()
        print("PLAYER_ENTERING_WORLD: RefreshBarsWithActiveIcons")

    end
    
    self.zone = zone

    if self.zone == "arena" then
        self:HandleMidGameReloadsForArenaUpdate()
    end
end

function OmniBar:UpdateUnitEventTracking(barFrame, barSettings)
    local trackedUnit = barSettings.trackedUnit
    -- Unregister previous events
    barFrame:UnregisterEvent("ARENA_OPPONENT_UPDATE")
    barFrame:UnregisterEvent("PARTY_MEMBERS_CHANGED")
    barFrame:UnregisterEvent("UNIT_INVENTORY_CHANGED")
    barFrame:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    barFrame:UnregisterEvent("INSPECT_TALENT_READY")
    barFrame:UnregisterEvent("UNIT_AURA")
    barFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    
    if trackedUnit:match("^arena[1-5]$") or trackedUnit == "allEnemies" then
        barFrame:RegisterEvent("ARENA_OPPONENT_UPDATE")
        barFrame:RegisterEvent("UNIT_AURA")
    elseif trackedUnit:match("^party[1-4]$") then
        barFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
        barFrame:RegisterEvent("UNIT_INVENTORY_CHANGED")
    elseif trackedUnit == "target" then
        -- barFrame:RegisterEvent("")
    elseif trackedUnit == "focus" then
        -- barFrame:RegisterEvent("")
    end

    -- factory: Register combat log event or unit spellcast depending on current zone
    --barFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    self:ToggleSpellTrackingEvents(barFrame)
end 

]]