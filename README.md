# CenterMarker by Hubbs

### Feature Overview
- **Always-visible anchor**: Places a crisp “+” at screen center; adjust size (8–256 px) and opacity (0–1).
- **Color control**: Pick any color via swatch; changes apply instantly and persist.
- **Visibility modes**: Show always, only in combat, or only out of combat.
- **Marker style choice**: Select +, x, dot (•), or asterisk (*).
- **Vertical offset**: Shift the marker up/down from center with a numeric Y-offset (supports negatives).
- **Quick toggle**: Enable/disable the marker without reloading UI.
- **Slash commands**: `/cm` opens the panel; `/cm size <px>`, `/cm alpha <0-1>`, `/cm toggle`.
- **Auto combat logging**: Toggle under **Cool Stuff** to start/stop `/combatlog` automatically in raids and Mythic+.

### How to Install
1) Copy the `CenterMarker` folder into `World of Warcraft/_retail_/Interface/AddOns/`.
2) In-game, enable **CenterMarker**, then `/reload` if needed.

### How to Use
- Open settings: `/cm`
- Set size via slider or number box.
- Set alpha via slider or number box.
- Pick a color from the swatch.
- Choose marker style (plus, x, dot •, asterisk *).
- Choose when to show the marker: Always, In Combat, or Not in Combat.
- Adjust feet Y-offset to nudge the marker vertically from center.
- Enable auto combat logging from the **Cool Stuff** tab if you want `/combatlog` handled automatically in group content.

### Notes
- Settings persist between sessions (`CenterMarkerDB`).
- If the marker doesn't appear in combat, ensure "Show when: In Combat" is selected and the addon is enabled.
- Auto combat logging defaults to on for raids and Mythic+, and can be toggled off in the config. Announces when it switches states.

