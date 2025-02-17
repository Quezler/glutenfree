Sure, editor mode has instant blueprints, but i often test stuff in `/cheat all` mode.

This mod allows players in cheat mode or editor mode to `ALT + scroll` up & down to toggle cheat mode for platforms.

Your hand must be empty, so no item/ghost/tool.

This mod works for existing platforms, and removing this mod again does not delete or damage platforms in any way.

Does your mod require certain items to never be available on platforms?
If so then add this to the on_init and on_configuration_changed events:
`remote.call("creative-space-platform-hub", "blacklist", item.name)`
