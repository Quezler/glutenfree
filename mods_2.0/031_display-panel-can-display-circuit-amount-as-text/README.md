This mod will update display panels every tick to match the value of the signal, but there are some optimizations in place:

- only surfaces with connected players on them are updated at all
- "show in chart" ones always update every tick if a player is looking at that surface
- "always show" ones will only update if there's a player looking at that surface with alt mode on
- other than that they only update when you have selected them with your cursor, or have opened their gui
- display panels without wires are checked way less often since it is very unlikely the mod will have to do stuff

So for performance, try to avoid putting too many messages into a single display panel & do not spam map "show in chart"
