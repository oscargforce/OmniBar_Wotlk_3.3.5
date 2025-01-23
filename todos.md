

TODOS: 

    PRIO:
        - test in arena with shared cds, both enemy and party
        - add spec property to TalentTreeCoordinates.lua

    2) Update unit aura detection in world if I want to have that there. If so need to update OnPlayerTargetChanged, OnUnitAura, SpecDetection
    3) Remove showing items for hostile players, keep party members as is. Since its impossible to know what trinkets is equpped, better to hide until used.
    4) Add shared cds and reset cds logic, WIP



Folder Structure:
OmniBar/
├── arts/                    # Art assets and textures
│   └── *.blp               # Blizzard texture files
├── libs/                    # Third-party libraries
│   ├── AceAddon-3.0/       # Ace3 addon framework
│   ├── AceConfig-3.0/      # Configuration library
│   ├── AceGUI-3.0/        # GUI framework
│   ├── AceDB-3.0/         # Database library
│   └── ...                # Other Ace3 modules
├── src/                    # Source code
│   ├── core/              # Core functionality
│   ├── data/              # Game data and constants
│   ├── options/           # Options UI and settings
│   └── widgets/           # Custom UI widgets
│   └── Main.lua           # Main entry point of the addon
├── embeds.xml             # Library embedding
├── load.xml               # Addon load order
├── OmniBar.toc           # Addon manifest
└── ViewTable.lua          # Debug utility




