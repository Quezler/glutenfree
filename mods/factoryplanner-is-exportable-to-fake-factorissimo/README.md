# welcome

more user friendly introduction @ https://www.reddit.com/r/factorio/comments/1azqm1w/new_mod_factory_planner_x_factorissimo/

# concept

[this mod but control stage and more powerful](https://github.com/Quezler/glutenfree/tree/main/mods/se-catalogues-can-be-crafted-from-their-breakdown)

# difference

Unlike Factorissimo 2 belts/pipes/chests up to the wall aren't a thing, interact with items via loaders or inserters, and fluids will need barrels.

# beacons

Currently not supported, there would need to be an algorithm that checks how many beacons are needed to fit the machine sizes at that row,
as well as perhaps trying to combine it with machines from other rows in need of the same coverage, let alone mixed coverage and god knows what.

Consider it "balance" for now, making "fake" productivity setups would require more modules and machines, even though the latter is hardly expensive.

# subfactories

Currently not supported, when the button is pressed my mod looks at what you can currently see to determine the buildings & modules you need,
since subfactories are on their own page i cannot view the entire planned factory as one, so you'll just need to have a long list unfortunately.

# changes/updates to the modlist

Currently not supported, well, supported as in it will work, but once a fake factorissimo building is generated it's locked to those input & outputs,
mods that change recipes, or updates to mods that have tweaked some recipes in that version or basically anything else will not affect built factories.

# performance

It could be argued that this mod improves performance since it simulates the factories based on power, input & output alone.
It falls to the player to use common sense, and to not simulate an entire SPM factory in here and just feed it what it wants.

# why depend on factory planner?

Well as you can see my data stage mod failed due to complexity reasons, easier to let another mod do the work, i just read the finished result from the gui.

# sizes

Factorissimo has 3 building sizes, i currently only support the small one whilst i figure out how to "balance" them out,
e.g. slots in terms of buildings & materials it can fit, amount of text that can fit over it and thus limit, and other stuff.

1.1.0 update: you can get the 2nd and 3rd tier by middle & right clicking the button respectively 

# credits

- `./graphics/factory/*` and their prototype defintions are MIT licenced to MagmaMcFry (original author) and notnotmelon (fork maintainer)
- `./graphics/icon/*` and their prototype defintions are MIT licenced to MagmaMcFry (original author) and notnotmelon (fork maintainer)
- parts of the control script (e.g. the `ingredients_to_factorissimo` button style/construction) come from Therenas's MIT licenced Factory Planner mod
- the thumbnail is part of a frame from a rick and morty episode about the car battery
- the power panel above the factory archways is a sprite from among us
- the `-space` graphic files originate from Crazy_Editor's MIT licenced `space-factorissimo-lizard` mod

# 1.0.0 release

I am not yet fully satisfied, the code is still a bit of a mess but i've been working on this mod for days at this point, and i want to play again.

Note that this mod is currently unrestricted in terms of which recipes/steps are allowed, as well as no block for "surface specific" recipes like waterless/space.

Factories currently have 40 slots, this is shared between buildings, modules, inputs & outputs, factories that "do too much" quickly can become impractical to wield.

# potato

Oh nice you've read it all? Then here is some useful information: the circuit network of the factory tells you what it is missing with negative signals.
