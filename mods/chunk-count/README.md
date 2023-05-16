The most obvious way of tracking chunks per surface is inaccurate, this mod does the heavy lifting.

note: due to the lack of an `on_chunk_created` event the count can lag behind `table_size(surface.get_chunks())`.

```lua
/c game.print(serpent.block( remote.call("chunk-count", "get", {surface_index = game.player.surface.index}) ))
/c game.print(serpent.block( remote.call("chunk-count", "get")                                              ))
```

Debugged and developed on the factorio discord with the help of: (in order of reacting)
- [justarandomgeek](https://mods.factorio.com/user/justarandomgeek)
- [JanSharp](https://mods.factorio.com/user/JanSharp)
- [_CodeGreen](https://mods.factorio.com/user/_CodeGreen)
