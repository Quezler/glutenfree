The expansion brought a hidden entity called the lane splitter, which is effectively a splitter for just one belt.

Hidden inside the game itself there is only an entity for the yellow splitter, with just a scaled down splitter texture.

This mod adds the entity for the red and blue tiers, as well as for green if you have space age enabled.
(the lane splitter itself is not locked behind an expansion feature flag, so from the 21st anyone can use it)

The recipes are the same as for the splitters but the recipe just crafts two, they're under the same technology too.

- third party belt support: submit a pull request with the **splitter texture** that is a recolor of the vanilla style splitter, and modify the data with your tier.

Since i generate the item icons based on the splitter icons you'll find sprites of other mods embedded in here, these are their licences:
- `kr-advanced-, GNU LGPLv3, Krastorio 2`
- `kr-superior-, GNU LGPLv3, Krastorio 2`
- `extreme-, MIT, AdvancedBeltsSA`
- `ultimate-, MIT, AdvancedBeltsSA`
- `high-speed-, MIT, AdvancedBeltsSA`
- `se-space-, Limited Distribution Only Licence, Space Exploration (with special written permission)`

Note to self, steps to add a new tier:
- check if the other mod's sprite matches the vanilla style
- copy their images into the graphics directory
- modify the imagemagick.sh file and add their prefixes at the top, then run it
- edit the .gitignore in there and whitelist the regular sprites, and then the balancer ones
- head into the data stage to define and gate the new balancers behind a mod check
- add the locale entries
- add their licence notice to the readme
- optional: don't forget to add them to data-updates too for prismatic belt compat
