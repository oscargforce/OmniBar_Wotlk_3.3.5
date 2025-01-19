OmniBar/
├── core/
│   ├── init.lua              # Core initialization, addon setup
│   ├── cooldowns.lua         # Cooldown tracking logic
│   ├── icons.lua            # Icon creation and management
│   ├── bars.lua             # Bar creation and management
│   ├── cache.lua            # Combat log and unit caching
│   └── constants.lua        # Shared constants/enums
├── events/
│   ├── combat.lua           # Combat log event handling
│   ├── unit.lua             # Unit-related events (target, focus etc)
│   ├── party.lua            # Party/raid events
│   └── arena.lua            # Arena-specific events
├── data/
│   ├── spells               # Spell data
│   └── specs.lua            # Spec detection data
├── options/
│   ├── panel.lua            # Main options panel
│   └── bars.lua             # Bar-specific options
└── utils/
    ├── debug.lua            # Debug utilities
    └── helpers.lua          # Shared helper functions

