# Rewritten Omnibar Addon for WOTLK 3.3.5: New Features Presentation

## Introduction
The Omnibar Addon has been **REWRITTEN** with several new features, bringing improved functionality, customization, and usability to your gaming experience. Below is an overview of the latest features added to the addon.

---
## How to install the addon
[Read the guide here](https://github.com/oscargforce/OmniBar_Wotlk_3.3.5/wiki/How-to-install-the-addon)

## 🛠️ **Set Up Your OmniBar Configuration**  

For a detailed step-by-step guide on configuring your **OmniBar**, visit:  
[📖 **Read More Here**](https://github.com/oscargforce/OmniBar_Wotlk_3.3.5/wiki) 

## Commands
| Command              | Description                              |
|----------------------|------------------------------------------|
| `/ob`                | Opens the options menu                   |
| `/ob test`           | Opens the test panel                     |
| `/ob test stop`      | Stops the test mode                      |
| `/ob reset`          | Resets any active cooldowns on the bar   |


## Implemented Features

### 1. Spec Detection
- Automatically detects the specialization of players and adjusts settings accordingly.

### 2. Filter by Race
- Allows filtering of cooldowns and abilities based on the race of players.

### 3. Trinket Filtering for Party Members
- The addon first checks which trinkets are equipped and then adds the corresponding icons.

### 4. Shared Cooldowns
- Displays shared cooldowns to provide better clarity on ability usage and timing.

### 5. Dynamic Cooldown Adjustment
- Automatically adjusts cooldown durations if they are affected by player specialization.
- Dynamically alters active cooldowns displayed on the bar based on spec-influenced durations.

### 6. Custom Icon Ordering/Sorting
- Enables manual ordering/sorting of icons on the bar, when 'Show Unused Icons' is active.
- Use the "Priority" tab to set the sorting order.

### 7. Time-Based Sorting for Hidden Icons
- Allows sorting by time remaining instead of the default 'time added' when icons are hidden.

### 8. New Animation Styles
- Choose from new animation options: OmniCD, OmniBar Classic, or None.

### 9. New Test Mode
- Provides a fresh test mode to simulate and verify settings before entering live gameplay.

### 10. Custom Cooldown Appearance
- Adds options to make cooldown displays look similar to OmniCC, providing a familiar and clear interface.

### 11. Additional Font Choices
- Introduces new fonts for cooldown timers to enhance readability and customization.

### 12. Reworked 'AllEnemies' Unit Tracking  
- Improved behavior outside of **arena** zones:  
  - Displays only target and focus cooldowns.  
  - Shows cooldowns for non-targeted players only if you were affected by the spell.  
    - *For example:* If a Death Knight uses **Mind Freeze** on you.  
  - When switching target or focus, previously used cooldowns of the old target/focus will persist.
  - This is excellent for tracking enemy cooldowns in battlegrounds while keeping the UI clean and organized.

### 13. Afflicted Style Look
- Choose to add an 'Afflicted' style visual option for a fresh and unique look to the cooldown bar.

### 14. Blackrock Dueling Support  
- Automatically resets all cooldowns at the start of a new duel.

### 15. Clutter-Free UI  
- When not in a duel or arena and out of combat for more than 30 seconds, all cooldowns are cleared.  
  - This is especially useful in battlegrounds to maintain a clean and organized UI.


