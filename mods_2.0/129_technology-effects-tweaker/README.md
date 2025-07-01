This mod does not allow you to add/merge/delete technologies or edit their costs (never will),
this mod is only focused on allowing you to make adjustments to which technology unlocks what.

This way mods like https://mods.factorio.com/mod/moves-ghost-rebuild-timeout-to-another-technology do not need to exist.
(and in the last 1-2 weeks someone on the mod portal asked me to make such a 1 off mod, don't remember which effect tho)

Technologies added or modified in `data-final-fixes.lua` might not show up, this mod sees/edits the state at that point in time,
you could add `"(?) mod-name",` to the dependencies of the `info.json` to force compatibility, pull requests will be considered.

This mod is supposed to run after all the other mods, but in the very likely event that it does not it has some debug colors:
- red, technology got removed after this mod had a chance to look at it
- orange, technology got modified after this mod had a chance to look at it, this could just be the costs, effect changes are not guaranteed
- green, technology got added after this mod had a chance to look at it, these technologies cannot be edited for that reason
(keep in mind that this mod uses a snapshot from that point in time of the data stage, it will not reflect effects shown in the technology gui)
