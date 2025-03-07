# DO NOT DOWNLOAD THIS PROJECT 
### Its a work in progress, and the addon is not fully developed.
Expecting it to be done in February 2025




Folder Structure:
```
OmniBar/
├── arts/                   # Art assets and textures
│   └── *.blp               # Blizzard texture files
├── libs/                   # Third-party libraries
│   ├── AceAddon-3.0/       # Ace3 addon framework
│   ├── AceConfig-3.0/      # Configuration library
│   ├── AceGUI-3.0/         # GUI framework
│   ├── AceDB-3.0/          # Database library
│   └── ...                 # Other Ace3 modules
├── src/                    # Source code
│   ├── core/               # Core functionality
│   ├── data/               # Tables for spells and talents
│   ├── options/            # Options UI and settings
│   └── widgets/            # Custom UI widgets
│   └── Main.lua            # Main entry point of the addon
├── embeds.xml              # Library load order
├── load.xml                # Addon load order
├── OmniBar.toc             # Addon manifest
└── ViewTable.lua           # Debug utility and the file will be deleted once the addon is developed
```

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