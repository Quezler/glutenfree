Don't you wish inserters could grab some items ahead of time? (like when fetching from sushi belts, they don't exactly buffer)

Due to optimizations reasons the "read hand contents" MUST be on "hold", and you MUST NOT send it signals on the red wire, green is fine.
(reading from the red wires is fine, beware that if you read from several greedy inserters at the time that you do not daisy chain wires)
(why the red wire? eh just personal preference, i tend to use red for inventory/read signals and green for control/filter signals myself)

Note that a side effect (or feature) is that in addition to the inserter grabbing what it can it'll force feed machines just as loaders do.
Also, when greedy inserters are idle they don't use any scripting, each 180 degree swing however triggers some lua, so use these sparingly. 

(though honestly when i upgrade planered my nauvis the time usage of this mod was like 0.05, but some setups broke so take it with a grain of salt)
And on that note, for single item belts leaving the inserter unfiltered is fine, but for mixed belts/sushi you MUST set a filter or risk deadlocks.

Version 1.0.0 works, but there are still things planned like even better optimization, possibly supporting bulk & stack ones too, stack size, etc.

But for now, this works well enough, and any bugs caught in this state will be easier to keep in mind before a future optimization pass.
