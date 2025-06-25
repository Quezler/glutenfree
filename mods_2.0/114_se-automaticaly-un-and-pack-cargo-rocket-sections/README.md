Checks all your logistic networks & every 10 seconds...

...if above 105, pack sections until 100 is reached
...if below 100, unpack sections until 100 is reached

Currently does not keep more unpacked in stock based on the amount of silos on a surface,
more advanced logic is planned in future versions, first lets see how well this one works.

(2 buffer chests with 48 slots set to cargo rocket sections next to each silo should prevent any/most alerts)

Note: this mod only checks logistic storage chests, (un)packed cargo sections in passive providers & buffer chests are ignored.

This mod logs to the console what it has done:

```
1352.986 Script @__se-automaticaly-un-and-pack-cargo-rocket-sections__/control.lua:50: 303 unpacked cargo rocket sections, so re-packed 40 on nauvis
1352.994 Script @__se-automaticaly-un-and-pack-cargo-rocket-sections__/control.lua:50: 5704 unpacked cargo rocket sections, so re-packed 1120 on Nauvis Orbit
1352.994 Script @__se-automaticaly-un-and-pack-cargo-rocket-sections__/control.lua:50: 240 unpacked cargo rocket sections, so re-packed 28 on Aine
1352.995 Script @__se-automaticaly-un-and-pack-cargo-rocket-sections__/control.lua:50: 702 unpacked cargo rocket sections, so re-packed 120 on Mossgarden
1352.995 Script @__se-automaticaly-un-and-pack-cargo-rocket-sections__/control.lua:50: 381 unpacked cargo rocket sections, so re-packed 56 on Akerty
1352.995 Script @__se-automaticaly-un-and-pack-cargo-rocket-sections__/control.lua:75: 070 unpacked cargo rocket sections, so un-packed 06 on Calidus Asteroid Belt 2
1352.996 Script @__se-automaticaly-un-and-pack-cargo-rocket-sections__/control.lua:50: 527 unpacked cargo rocket sections, so re-packed 85 on Borroum
1352.996 Script @__se-automaticaly-un-and-pack-cargo-rocket-sections__/control.lua:50: 392 unpacked cargo rocket sections, so re-packed 41 on Calidus Asteroid Belt 1
1352.996 Script @__se-automaticaly-un-and-pack-cargo-rocket-sections__/control.lua:75: 094 unpacked cargo rocket sections, so un-packed 02 on Ikenga
1352.996 Script @__se-automaticaly-un-and-pack-cargo-rocket-sections__/control.lua:50: 254 unpacked cargo rocket sections, so re-packed 30 on Juliette
...
1362.986 Script @__se-automaticaly-un-and-pack-cargo-rocket-sections__/control.lua:75: 097 unpacked cargo rocket sections, so un-packed 01 on nauvis
1362.986 Script @__se-automaticaly-un-and-pack-cargo-rocket-sections__/control.lua:50: 187 unpacked cargo rocket sections, so re-packed 17 on Calidus Asteroid Belt 1
...
1372.985 Script @__se-automaticaly-un-and-pack-cargo-rocket-sections__/control.lua:75: 098 unpacked cargo rocket sections, so un-packed 01 on nauvis
```
