local OmniBar = LibStub("AceAddon-3.0"):GetAddon("OmniBar")
local GetTime = GetTime
local NotifyInspect = NotifyInspect
local CheckInteractDistance = CheckInteractDistance
local ClearInspectPlayer = ClearInspectPlayer

InspectQueue =  {
    queue = {},
    isProcessing = false,
    retryInterval = 1, -- seconds between retry attempts
    maxRetryTime = 15, -- maximum seconds to retry
    timeElapsed = 0,
    currentInspect = nil,
    frame = nil
}

function InspectQueue:New()
    local obj = setmetatable({}, { __index = self })
     -- Create frame for OnUpdate
     obj.frame = CreateFrame("Frame")
     obj.frame.parent = obj
     obj.frame:SetScript("OnUpdate", function(self, elapsed)
         self.parent:OnUpdate(elapsed)
     end)   
     obj.frame:Hide()
    return obj
end

function InspectQueue:AddToQueue(unit, bar)
    for _, item in ipairs(self.queue) do
        if item.unit == unit and item.bar == bar then
            return
        end
    end

    table.insert(self.queue, {
        unit = unit,
        bar = bar,
        timeAdded = GetTime(),
        endTime = GetTime() + self.maxRetryTime,
    })

    if not self.isProcessing then
        self:ProcessQueue()
    end
end

function InspectQueue:IsUnitInRange(unit)
    local distance = CheckInteractDistance(unit, 1)
    print("IsUnitInRange", unit, distance == 1)
    return distance == 1
end

function InspectQueue:FindNextInRangeUnit()
    for i, item in ipairs(self.queue) do
        if self:IsUnitInRange(item.unit) then
            return i
        end
    end
end

function InspectQueue:ProcessQueue()
    print(self.isProcessing, #self.queue)
    if self.isProcessing or #self.queue == 0 then 
        print("ProcessQueue HIDING FRAME")
        self.frame:Hide()
        return 
    end
    
    local inRangeIndex = self:FindNextInRangeUnit()
    if inRangeIndex then
        self.isProcessing = true

        if inRangeIndex > 1 then
            local inRangeItem = table.remove(self.queue, inRangeIndex)
            table.insert(self.queue, 1, inRangeItem)
        end

        local item = self.queue[1]
        print("Processing", item.bar.key)
        self.currentInspect = item
        item.bar:RegisterEvent("INSPECT_TALENT_READY")
        NotifyInspect(item.unit)
    end

    self.frame:Show()
end

function InspectQueue:OnUpdate(elapsed)
    self.timeElapsed = self.timeElapsed + elapsed
    
    if self.timeElapsed >= self.retryInterval then
        self.timeElapsed = 0

        if #self.queue == 0 then
            print("Queue is 0 on Update, hiding frame")
            self.frame:Hide()
            return 
        end

        local timeLeft = self.queue[1].endTime - GetTime()
        print("No current inspect", timeLeft)

        if timeLeft > 0 then
            if not self.currentInspect then
                self:ProcessQueue()
            end
        
        else
            self:PrintOutOfRangeMessage()
            self:ClearQueue()
        end
    end

end

function InspectQueue:InspectComplete()
    ClearInspectPlayer()
    self.currentInspect.bar:UnregisterEvent("INSPECT_TALENT_READY")
    self.currentInspect = nil
    self.isProcessing = false
    table.remove(self.queue, 1)
    self.frame:Show()
    print("InspectComplete")
    self:ProcessQueue()
end 

function InspectQueue:ClearQueue()
    wipe(self.queue)
    self.isProcessing = false
    self.currentInspect = nil
    if self.frame then
        self.frame:Hide()
    end
end

function InspectQueue:RemoveBarFromQueue(bar)
    for i = #self.queue, 1, -1 do
        local item = self.queue[i]
        if item.bar == bar then
            table.remove(self.queue, i)
        end
    end
end

function InspectQueue:PrintOutOfRangeMessage()
    if not OmniBar.db.profile.showOutOfRangeMessages then
        return
    end

    -- Build a string of all units in queue
    local units = ""
    for i, item in ipairs(self.queue) do
        if i > 1 then
            units = units .. ", "
        end
        units = units .. item.unit
    end

    print( "|cFFFF0000[OmniBar]|r: |cFFFFFF00" .. units .. "|r were not in range for inspection. " ..
    "|cFF00FF00The spells may not match the unit's current talents.|r " ..
    "Please |cFF00FFFF/reload|r when you are |cFFFFFF00within range|r to inspect the unit " ..
    "(|cFF00FF00i.e., when you can right-click and inspect their armory in-game|r). " ..
    "This message can be disabled in the options menu |cFF00FFFF'Show Out of Range Messages'|r."
    )
end