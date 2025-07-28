# 1.1

The spiritual successor to my undocumented and deprecated mod that i still used for each run:
https://mods.factorio.com/mod/x-stacks-ltn-combinator-helper

Any item signals get outputed multiplied by their stack size on whichever color of wire.

Fluid and virtual signals are effectively ignored. (as in: does not get outputed at all)

Whilst editing the combinator a "wrong" amount or stray signal might exist for one tick.

This mod has no performance overhead other than when any player has the gui for it open.

# 2.0

The mod now uses 4 combinators on a hidden surface so the overhead is gone.

A change in input signals might take a few ticks to propogate properly to settle.

The output is on the red wire, anything on the green one gets treated as input signal.

Serving suggestion: using it as an LTN combinator to conveniently match the container size.

(note that virtual signals and fluid signals are not affected so you can have them in here as well)
