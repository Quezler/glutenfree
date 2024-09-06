Tile deconstruction orders only vanish when a new tile gets placed in that location,
pasting the same tile over the same kind of tile that is marked for deconstruction does nothing,
since all the blueprint sees is "this tile is already there, lets move on",
whilst in reality it should be clearing that tile deconstruction order.

This mod checks your held blueprint for tiles and cancels the appropriate deconstuction requests.

Does not work for blueprints in your library, place those in your inventory first,
but honestly you'll likely be using cut paste anyways or you wouldn't really need this mod.

This mod also cancels tile ghosts if you paste the already existing tile there over it. (just 2 more lines of code)

And in addition to that and a few more lines of code, copy pasting tile ghosts over others override those too,
but strangely if your blueprint is all red you'll have to click twice for that behavior to trigger, weird right?
