> **STOP!**
>
> This mod does **not** work out of the box, and is **not** intended to be used on multiplayer at all.
> You can use code from this mod to get your own to work with Hurricane's assets, but do not add it as a dependency.
> The mod was made with Hurricane himself in mind, normal players should stay away, modders using his sprites are welcome tho.

This mod contains lua code capable of getting any of his sprites to load as valid assembling machine graphic sets,
in addition there is a php script that generates a lua file based on the image files that contain some important metadata.

Here is one such example file which should exist in the folder of the same name:
```lua
return {
  name = "research-center",
  localised_name = "Research Center",
  size = "9x9",
  frames = 80,

  emissions = 1,
  directory_suffix = "",

  animation = {width = 4720, height = 5120},
  shadow = {width = 1200, height = 700},
}
```

Once you have created such a file either manually or through running the `factorio-sprites.php` script this mod can load them.

Security:
This mod contains arbitrary code, before running the included php script have the contents checked by someone who knows PHP,
whilst the code is not written with malicious intent it is important to understand that it is not safely sandboxed like LUA mods are.
The reason this mod is on the portal at all is for discoverability and noticing when updates are available, it is never usable as-is.

Usage:
- unzip the mod
- download the factorio-sprites folder from his google drive and unzip it in this mod's folder
- run `php factorio-sprites.php` within the mod's directory or type any/all of them out by hand
- start a new singleplayer game

Note:
This mod is not designed to be saved, and breaking changes will just always happen when they're the most convenient option,
taking code from this mod and putting it within your own mod will be stable though, this mod is just a single use debug sandbox.

Common issues:
- oversized shadow? reach out to the artist.
- sprite scrolling vertically? count and confirm the amount of frames in the files by hand.

For support ping `@Quezler` in the `#mod-dev-graphics` channel on the Factorio discord.
- graphics by [Hurricane046](https://mods.factorio.com/user/Hurricane046)

