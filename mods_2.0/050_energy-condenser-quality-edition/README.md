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
