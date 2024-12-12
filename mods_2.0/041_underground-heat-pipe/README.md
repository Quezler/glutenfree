This mod took longer than my usual mods since i had to deal with connecting textures, entity build orders & rethink how code structs work.

- yellow, red, blue & green belts are supported (no support for other mods at this time)
- space age is optional, you can use the underground heat pipes anywhere (though the green belts are only loaded with space age present)
- the recipes unlock when you have both the heat pipe and the corresponding underground belt researched
- they can be weaved, not sure why you would, but you can
- the mod uses no on_tick, its all done with hidden entities and listening to just the required events
- ~~in floor heating! tiles between underground are considered warm and toasty~~
- they are bidirectional, the underground direction indicator is not relevant
- the only difference in tiers is the length they can span, since recipes use heat pipes for the full length try to use the lowest tier
- linked heat pipes when? (or linked connections like the fluidbox has, i mean, the heat prototype also has a connections array)
- no sideloading, direct connections only
