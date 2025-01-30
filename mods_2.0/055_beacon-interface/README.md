This mod adds a beacon where you can manually set the strengths of each effect from -32768 to 32767
(note that the slider does not go so high, but you can manually enter numbers in the textarea too.)

The beacon has a distribution efficiency of 1 so the strength of the sliders will always match,
regardless of which quality the beacon itself is, it increasing due to quality is disabled,
note that the profile is left unaltered so if you have several you'll see lower values.

If the quality feature flag is missing the quality slider & modules will still be present, but will not function.

This beacon is not craftable, it is intended for use in editor mode, and can also be obtained through the `/cheat all` command.

In addition to the visible/configurable beacon this mod also has a remote interface in which mods can add 1x1 tile beacons,
that way you can modify the speed/productivity/consumption/pollution/quality of buildings on the fly should your mod need that.

Modding instructions:

Create the `beacon-interface--beacon` or `beacon-interface--beacon-tile` yourself, be sure to trigger any of the build events,
afterwards you can get/set the effects by passing the unit number, it is your own responsibility to delete it when no longer needed.

You are encouraged to use `table.deepcopy()` instead of using the above two by name, so they get removed if your mod leaves the save.
Any beacon with the `beacon-interface--module-category` category will get recognized, beacons that allow all categores via `nil` are skipped.
(pay special attention to the minable result, ensure you also set a sensible item to place the beacon, or `nil` both minable and place_result)

(note that the `-tile` beacon does have a profile of `{1}`, so any other beacons will not interfere with the transmission strength)

(you can examine a live example here, but it might already be a tad complex: https://mods.factorio.com/mod/circuit-controlled-beacon-interface)

```lua
/c remote.call("beacon-interface", "set_effect", game.player.selected.unit_number, "productivity", 10)
...
local effects = remote.call("beacon-interface", "get_effects", unit_number)
effects["speed"] = 25
remote.call("beacon-interface", "set_effects", unit_number, effects)
...
remote.call("beacon-interface", "set_effect", unit_number, "efficiency", 25)
...
local quality = remote.call("beacon-interface", "get_effect", unit_number, "quality")
remote.call("beacon-interface", "set_effect", unit_number, "quality", speed + 25)
```
