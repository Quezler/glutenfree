### 1.0

A furnace that only crafts whilst fluids are forced to flow through it with a pump,
inspired by Krastorio 2's pollution filter rebalance, this makes cleaning them take no biomass.

Graphics based on a very old mod of mine, the 12th in fact: https://mods.factorio.com/mod/Liquify

Requires fluids to flow through at more than 1000/s, this fluid harmlessly just passes through.

Designed to be placed inline of high flow rate pipes, cannot be chained without a pump in between.

Compound entity breakdown:
- primary furnace, the only thing you see and interact with, does the recipe when it is allowed
- valve in, the washbox requires a high pressure so 80% or more input pressure is required
- pumping speed furnace, crafts a crapton of fluids to measure the speed without capping it
- valve out, outputs only when the destination has less than 75% to avoid a loop without pumps

### 2.0

Now script based, crafting speed now depends on the total pumps pumping into the input fluid segment,
parralel washboxes divide the crafting speed between them, inline ones share the same crafting speed.

0.2 base crafting speed so stale fluid pipes will still see some work done, but that takes some time.
