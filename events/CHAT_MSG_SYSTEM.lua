function OmniBar:CHAT_MSG_SYSTEM(event, chatMsg)
    if self.zone == "arena" then return end
    if not chatMsg:match("Duel starting: 3") then return end

    self:RefreshBarsWithActiveIcons()
end
