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

![race & trinket image](https://i.imgur.com/IL87A8F.png)

### 4. Shared Cooldowns
- Displays shared cooldowns to provide better clarity on ability usage and timing.
  
![shared cds giphy](https://media1.giphy.com/media/v1.Y2lkPTc5MGI3NjExZWU0dXZudjRtMHZ5eWxvbWs1eDJta3E5a2NuaWNnMDF0c2E0eTV1eSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/19tIQTG4KwgNVgLgCQ/giphy.gif)  
- Resets cooldowns automatically when abilities like Readiness (Hunter), Preparation (Rogue), or Cold Snap (Mage) are used.

![reset cds giphy](https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExc3ZmYjB6NThocTd1dm9wb2loejR1bDB2M3VidXR1ajdhcGRtNnV2cyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/VjlRmBthHzJKNJUGSb/giphy.gif)

### 5. Dynamic Cooldown Adjustment  
- Automatically modifies cooldown durations based on the enemy's specialization. For example, if the enemy is identified as a Survival Hunter, trap cooldowns adjust from 28 seconds to 22 seconds accordingly.  
- Dynamically updates active cooldowns displayed on the bar to reflect spec-based adjustments. For instance, if a Survival Hunter uses Freezing Trap before their specialization is identified and the timer shows 25 seconds (28-3), the cooldown will automatically adjust to 19 seconds (22-3) once the spec is recognized.

### 6. Custom Icon Ordering/Sorting
- Enables manual ordering/sorting of icons on the bar, when 'Show Unused Icons' is active.
- Use the "Priority" tab to set the sorting order.

### 7. Time-Based Sorting for Hidden Icons
- Allows sorting by time remaining instead of the default 'time added' when icons are hidden.

### 8. New Animation Styles
- Choose from new animation options: OmniCD, OmniBar Classic, or None.

![OmniCD anim](https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExY2ZoOTAwejN0bTRod3pnbGYxY3FqbWN1YWV3MmluZnZmeXc1cTh2cCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/So7HdwbX8BmBmlornP/giphy.gif)

### 9. New Test Mode
- Provides a fresh test mode to simulate and verify settings before entering live gameplay.

### 10. Additional Font Choices
- Introduces new fonts for cooldown timers to enhance readability and customization.

### 11. Reworked 'AllEnemies' Unit Tracking  
- Improved behavior outside of **arena** zones:  
  - Displays only target and focus cooldowns.  
  - Shows cooldowns for non-targeted players only if you were affected by the spell.  
    - *For example:* If a Death Knight uses **Mind Freeze** on you.  
  - When switching target or focus, previously used cooldowns of the old target/focus will persist.
  - This is excellent for tracking enemy cooldowns in battlegrounds while keeping the UI clean and organized.

### 12. Afflicted Style Look
- Choose to add an 'Afflicted' style visual option for a fresh and unique look to the cooldown bar.

![afflicted img](https://i.imgur.com/4l6s5Fl.png)

### 13. Blackrock Dueling Support  
- Automatically resets all cooldowns at the start of a new duel.

### 14. Clutter-Free UI  
- When not in a duel or arena and out of combat for more than 30 seconds, all cooldowns are cleared.  
  - This is especially useful in battlegrounds to maintain a clean and organized UI.


