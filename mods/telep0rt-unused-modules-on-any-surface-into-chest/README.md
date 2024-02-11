My own usecase is gathering unused high-but-less-than-tier-9 modules from all the surfaces that have them idly sit in storage.

Getting modules to the planet for construction purposes is handled nicely by my interstellar construction turrets mod,
but only this mod is able to get the items post upgrading/deconstruction back to the surface tasked with upgrading.

Hover over your desired chest and run this command: `/teleport-unused-modules-on-any-surface-into-this-chest`

After that this mod will periodically try to insert up to one stack of every module into that one chest.

Why is there a 0 in the name? well space exploration blocks every mod with `teleport` in it, yay.

(any entity with a `defines.inventory.chest` is supported, i recommend a passive provider)
