Greetings pione.. ahem engineer,

This mod allows you to get quality items without the random aspect,
simply place down an awesome sink and insert quality modules into the slots,
then each time you insert enough of an item (100 / total module quality of the sink) you get the next tier.
(note: ~~there are no notes~~ quality does not skip a tier, you get exactly one of the next tier of quality)

Your reward items can be withdrawn from the awesome shop, points are shared between all your sinks on the surface.

Legendary items and items that spoil into enemies currently do nothing, but please do not sink, wube does not waste.

The sink is limited to 15 items per second, but you can place multiple sinks and even use belt stacking.

For balance reasons the sink is currently limited to 2 module slots (though arguably it should even be 1),
this mod currently does not nerf quality gained from normal assemblers, so you "could" cheese it to get the most overall.

todo:
- a gui when you open the shop that shows the progress for each tracked item, ideally with a search field and quality dropdown
- better graphics, ideally 3x3 or bigger assembling machine that can be rotated 4 ways (help on both these points will be neat)

Final note: this mod has gone through intensive development/testing over the last few days, 1.0.0 will be deemed stable,
however note that future versions of this mod are likely to exist that are totally different,
therefore keep the "major" version number in mind when picking your ~~poison~~ upgrades.

# Concept
(note: written before typing any code, the above is acurate)

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
