

TODOS: 

    PRIO:
        - test in arena with shared cds, same class meaning 2x...
        - add spec property to TalentTreeCoordinates.lua

    2) Update unit aura detection in world if I want to have that there. If so need to update OnPlayerTargetChanged, OnUnitAura, SpecDetection
    3) Remove showing items for hostile players, keep party members as is. Since its impossible to know what trinkets is equpped, better to hide until used.
    4) Add shared cds and reset cds logic, WIP


--- Features I have implemented
-- Spec detection
-- filter by race
-- trinket filtering for party members
-- shared cds
-- Dynamically adjust cooldown duration if its affected by spec.
-- Dynamically adjust active cooldowns shown on the bar if its duration is affected by spec.
-- Set the order of the icons on the bar as you wish (only for show unused icons)
-- if hidden icons, you can sort by time remaining instead of time added (default of omnibar)





