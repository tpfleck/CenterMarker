# Changelog

## 0.6.4
- Trying this again to fix the auto combat logging spam when someone else starts the key—hopefully the fourth try sticks (listening to the keystone countdown `START_TIMER` type 4).

## 0.6.3
- Lowered minimum marker size to 1px so you can scale anywhere between 1 and 256.
- Dot marker now renders with a circular mask so it stays perfectly round when scaled up (no more oval at large sizes). Thanks for reporting the bug!
- Fixed marker style dropdown so it correctly shows your last selected marker after a UI reload instead of "Custom."

## 0.6.2
- Added `/cm cdm` slash command to open the Cooldown Manager settings window.
- Added `/cm kb` slash command to open the quick keybind menu (falls back to the classic binding frame if needed).
- Add a short hold after keystone start so auto combat logging stays on without spamming during the Mythic+ countdown.

## 0.6.1
- Fix combat log chat spam during Mythic+ countdown (keeps logging steady through keystone start).
- Marked compatibility for Retail 11.2.7.

## 0.6.0
- Added instance-based visibility options (In/Not in Instance) with hover info for instance types.
- Updated "Show when" labels for clarity and widened the config frame so the tooltip fits.
- Kept combat visibility options and other settings intact; existing encounter settings migrate to instance automatically.
