[below: coherent summary]
Ehmm sorry for the incomplete and messy readme, the mod is finally done and i lack energy to write a coherent one,
but suffice it to say this mod includes the functionality of the two mods before it along with a bunch of options.

Those that know the energy condenser from the minecraft days might recognize the mechanic,
just put the items you wish to upgrade inside of the machine, power it and wait for a bit.

You can limit the upper quality to which it upgrades by setting the quality of the recipe,
the normal quality means that the machine will just keep going and going.

If there are not enough items to upgrade (item count * percentage = below 100) the machine does nothing,
if there is a remainder that 1-99 percentage will be turned into a chance for one more item.

The mod is quite performant in that it does bulk and triggers machine states by circuits instead of polling the entities,
if you manage to get a machine stuck then fear not, every 60 seconds any stuck machine (changed quality or researched more) becomes unstuck.

Quality quality condensers are faster and have more inventory space.

[below: failed attempt at rewriting below]

Both of the mods that came before this had some shortcomings and there were a bunch of feature requests for both since,
it would have been tricky to retcon those features in those two mods, so here's a new one that should cover a whole lot.

- module slots: 

Configuration options:
- appearance: pick between two of the awesome textures made by [Hurricane046](https://mods.factorio.com/user/Hurricane046)
- base quality: 0-100
- module slots: 0-6
- technology effects: comma seperated technology names with their values

[below: technical summary]

Attempts to deal with the shortcomings of both mods that came before it, like bulk items without sacrificing performance.

Just put items inside the building and when full/idle it will condense the items to the their next unlocked quality tier.


| Feature                     | Awesome sink | Upcycler | Energy condenser |
|-----------------------------|--------------|----------|------------------|
| modules                     | ✔            | ✗        | ✔                |
| configurable                | ✗            | ✔        | ✔                |
| configurable per quality    | ✗            | ✗        | ✔                |
| bulk items                  | ✗            | ✗        | ✔                |
| upgradable with technology  | ✗            | ✗        | ✔                |
| kidnaps unupgradable items  | ✔            | ✔        | ✗                |
| downgrade items somehow     | ✗            | ✗        | ✗                |
| directional insertions only | ✔            | ✔        | ✗                |
| problematic data final fixes| ✗            | ✔        | ✗                |
| updates totally at random   | ✗            | ✔        | ✗                |
| respects spoil percentages  | ✗            | ✗        | ✔                |

Base quality:
- `0` (no base quality)
- `10 * (quality.level)` (no base quality, then 10% per quality)
- `10 * (quality.level + 1)` (10% base quality, then 10% per quality)
- `math.pow(2, quality.level) * 2` (2, 4, 8, 16, 64)

Technology effects:
- `` (no additional base quality)
- `planet-discovery-fulgora=10,planet-discovery-gleba=10,planet-discovery-vulcanus=10,planet-discovery-aquilo=20` (extra quality per known planet)
- `speed-module=-1,speed-module-2=-1.5,speed-module-3=-2.5` (want to punish some technology choices? you can)

- graphics by [Hurricane046](https://mods.factorio.com/user/Hurricane046) (originally named disruptor, later revision is called laboratory)
- "how to use his graphics" observed from [Xorimuth](https://github.com/tburrows13/LunarLandings/blob/master/prototypes/core-extractor.lua)
