This mod does not allow you to add/merge/delete technologies or edit their costs (never will),
this mod is only focused on allowing you to make adjustments to which technology unlocks what.

This way mods like https://mods.factorio.com/mod/moves-ghost-rebuild-timeout-to-another-technology do not need to exist.
(and in the last 1-2 weeks someone on the mod portal asked me to make such a 1 off mod, don't remember which effect tho)

Technologies added or modified in `data-final-fixes.lua` might not show up, this mod sees/edits the state at that point in time,
you could add `"(?) mod-name",` to the dependencies of the `info.json` to force compatibility, pull requests will be considered.
