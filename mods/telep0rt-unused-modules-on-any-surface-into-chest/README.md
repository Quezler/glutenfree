My own usecase is gathering unused high-but-less-than-tier-9 modules from all the surfaces that have them idly sit in storage.

Getting modules to the planet for construction purposes is handled nicely by my interstellar construction turrets mod,
but only this mod is able to get the items post upgrading/deconstruction back to the surface tasked with upgrading.

Hover over your desired chest and run this command: `/teleport-unused-modules-on-any-surface-into-this-chest`

After that this mod will periodically try to insert up to one stack of every module into that one chest.

Why is there a 0 in the name? well space exploration blocks every mod with `teleport` in it, yay.

(any entity with a `defines.inventory.chest` is supported, i recommend a passive provider)

some sample output of this mod you can check in the log:
```
[player] teleported 50 x speed-module from nauvis to Nauvis Orbit.
[player] teleported 50 x speed-module-2 from nauvis to Nauvis Orbit.
[player] teleported 50 x speed-module-3 from nauvis to Nauvis Orbit.
[player] teleported 50 x speed-module-4 from nauvis to Nauvis Orbit.
[player] teleported 50 x productivity-module from nauvis to Nauvis Orbit.
[player] teleported 50 x productivity-module-2 from nauvis to Nauvis Orbit.
[player] teleported 50 x productivity-module-3 from nauvis to Nauvis Orbit.
[player] teleported 50 x productivity-module-4 from nauvis to Nauvis Orbit.
[player] teleported 50 x productivity-module-5 from nauvis to Nauvis Orbit.
[player] teleported 50 x productivity-module-6 from nauvis to Nauvis Orbit.
[player] teleported 50 x productivity-module-7 from nauvis to Nauvis Orbit.
[player] teleported 2 x effectivity-module from nauvis to Nauvis Orbit.
[player] teleported 50 x effectivity-module-4 from nauvis to Nauvis Orbit.
[player] teleported 48 x effectivity-module from Nauvis Orbit to Nauvis Orbit.
[player] teleported 23 x effectivity-module-5 from Nauvis Orbit to Nauvis Orbit.
[player] teleported 50 x effectivity-module-2 from Hothier to Nauvis Orbit.
[player] teleported 4 x effectivity-module-3 from Ikenga to Nauvis Orbit.
[player] teleported 1 x speed-module-5 from Snek to Nauvis Orbit.
```
