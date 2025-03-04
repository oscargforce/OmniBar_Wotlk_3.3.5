

TODOS: 

    2) Update unit aura detection in world if I want to have that there. If so need to update OnPlayerTargetChanged, OnUnitAura, SpecDetection

1. Add all spells to spell table
2. Add disable/enable depending on zone "show in bg/arenas/world"
3. Add export/import profile
4. Add Copy from another bar settings
5. Add Spells
6. test Nature's Swiftness from shamans and resto druids, what icon is shown if both are tracked?
7. test Heroism and bloodlust, we only wantto show 1 icon depending on faction.

1 = {
    "Death Knight", -- DONE
    "Druid", -- DONE
    "Hunter", -- DONE
    "Mage", -- DONE ( need to fix pet freeze i think)
    "Paladin", -- DONE
    "Priest", -- DONE
    "Rogue", -- DONE
    "Shaman", -- DONE
    "Warlock", -- DONE
    "Warrior" -- DONE
}

--- Features I have implemented
-- Spec detection
-- filter by race
-- trinket filtering for party members
-- shared cds
-- Dynamically adjust cooldown duration if its affected by spec.
-- Dynamically adjust active cooldowns shown on the bar if its duration is affected by spec.
-- Set the order of the icons on the bar as you wish (only for show unused icons)
-- if hidden icons, you can sort by time remaining instead of time added (default of omnibar)
-- New animations (OmniCD, OmniBar Classic, None)
-- New test mode
-- Custom cooldown options for omniCC look alike
-- New fonts for cooldown timers
-- Rework on trackedUnit "AllEnemies" if zone is not "arena". Now only shows target+focus and non targeted players if destSource is equal to the local player.