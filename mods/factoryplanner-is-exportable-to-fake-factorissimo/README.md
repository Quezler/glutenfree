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

# credits

- `./graphics/factory/*` and their prototype defintions are MIT licenced to MagmaMcFry (original author) and notnotmelon (fork maintainer)
- `./graphics/icon/*` and their prototype defintions are MIT licenced to MagmaMcFry (original author) and notnotmelon (fork maintainer)
- parts of the control script (e.g. the `ingredients_to_factorissimo` button style/construction) come from Therenas's MIT licenced Factory Planner mod
- the thumbnail is part of a frame from a rick and morty episode about the car battery
- the power panel above the factory archways is a sprite from among us
