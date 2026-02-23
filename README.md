# Anti-Cheat

Made by chickEZ & lil lukewarm (aka TeeZ0)

## Scope
- Strafe hack
- Fast run / speedhack
- Bhop (FOG1-3)
- Gstrafe (FOG1-3)
- Bhop ratio
- Gstrafe ratio
- Knifebot heuristics

## Configuration
The plugin now supports runtime punishment configuration through cvars.

### Cvars
- `ac_punishment`
  - `0` = do nothing
  - `1` = alert only
  - `2` = kick user
  - `3` = kick user using `amx_ban`
- `ac_alert_non_admins`
  - `0` = alerts are shown only to admins (players with `ADMIN_KICK`)
  - `1` = alerts are shown to all players

### Config file
On startup, the plugin ensures a config file exists at:

`addons/amxmodx/configs/anticheat.cfg`

If the file is missing, it is created with defaults and then executed.

A template is also included in this repository at `anticheat.cfg`.

## Notes
- Alert messages include player name, SteamID and detection type.
- A short anti-spam cooldown is applied per-player to prevent repeated frame-level alerts.

![Cheaters page](https://i.imgur.com/uXkrzwz.jpg)
