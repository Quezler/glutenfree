Aimed at modpacks and the people working on compatibility code for them.

With this you can scroll through the list to visibly confirm if the recycle recipes look good or not.

(like good luck checking each recycle result in factoriopedia to see if it picked the right recipe and was not updated later)

Usage: `/recycle-recipes-inspector`
(this mod assumes recycling recipes are named `<item name>-recycling`)

Legend:
- light grey: hidden item
- dark grey: probably a self recycle recipe
- green: item it recycles into is (still) present in the recipe it generated from
- red: item it recycles into is not present in the recipe it generated from
- orange: item present in the recipe it generated from but does not recycle into
- ~~yellow: amount doesn't appear to be 1/4th of the recipe it generated from~~

Note: the detection of some self recycle recipes might erroneously show up as that they were created from a recipe,
this is due to the insane way i am detecting them (check data.lua if you dare) so viewer discretion is advised here.
