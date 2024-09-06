Tile deconstruction orders only vanish when a new tile gets placed in that location,
pasting the same tile over the same kind of tile that is marked for deconstruction does nothing,
since all the blueprint sees is "this tile is already there, lets move on",
whilst in reality it should be clearing that tile deconstruction order.

This mod checks your held blueprint for tiles and cancels the appropriate deconstuction requests.

Note that if you place it back in exactly the same spot before any of the tiles had been deconstructed this mod does nothing.
