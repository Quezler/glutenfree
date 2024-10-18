# Concept

Items are inserted either via belts or inserters into a loader or linked chest,
on a hidden surface it'll pulse count and void the items into lava or something.

The counted items should be multiplied by like 100 or something,
and then with some math equal the quality of the modules in **that** awesome sink.
(i.e. no modules = items are effectively voided, 0.2% quality = 500 items needed for 100%)

All item sinks will contribute to that surface's "awesome shop",
which is effectively just a linked chest holding all of the output results.

There should be a `* >= 100` combinator or something hooked up to lua,
for every 100 items it should dispense one of the higher quality and subtract the value from the circuit counter,
note that we are not gonna upgrade jump, each item will only upgrade once when it gets put into the awesome sink.

Whilst a "pickup item with circuit inserter to trigger on_object_destroyed" could be used for performance,
checking the circuits every 1-2 seconds should be perfectly acceptable too, the player will get the output eventually.

Since we won't be tracking spoilage, any time one of those will be returned it'll always be its spoil result.

Legendary items have no next tier and should thus also be voided? or some goofy "fixcit doesn't waste" and just output it again?
