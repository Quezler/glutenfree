Space Exploration has some util functions and a bunch of constants that cannot be used from another mod without some workarounds.

This mod currently allows me to access those without creating temporary variables directly within each of my own mods that need em.

There are currently only a few files supported (since the stuff i needed myself were in those), expect breaking changes if you use it.

- `old require("__space-exploration__.scripts.util")`
- `new require("__space-exploration-scripts__.util")`
