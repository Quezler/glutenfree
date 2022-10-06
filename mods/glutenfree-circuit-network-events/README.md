Space Exploration has this thing where spaceships and cargo rockets need a sustained signal before acting on it, this is because those kind of mods tend to check all inputs every second or so on a loop, any faster would be bad for performance.

This proof-of-concept library is an attempt at solving that polling problem by firing an event when a circuit condition is met, without requiring polling from either mod.

===

Version 1.0.0 is just the concept, it does not yet make sure there is a non-colliding position on the hidden surface or anything yet.

I'll be waiting for some reactions on this before i build it out further in whatever direction i currently do not yet know.

And i could fully understand if some modders would like to implement this mechanic into their mods so a dependancy on this is not required.

Well anyways this is MIT licenced, though if you decide (or plan) to implement it directly into your own mod, please comment which. ^-^

===

Maybe todo list:

- make sure there are no colissions on the other surface
- allow an entity to have multiple unresolved events (different color of wires and/or different conditions entirely)
- allow nested/combined conditions, instead of just 1 condition set directly on the inserter
- measure the tick delay (if any) between the pulse and the event, currently the mod is just guaranteed to detect it

`/c game.player.teleport({0,0},"glutenfree-circuit-network-events-v1")`
