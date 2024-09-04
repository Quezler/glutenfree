- usage

call the remote interface in both your `on_init` and `on_configuration_changed` handers.

you can look at [Space Exploration - cargo rockets support ion stream as space fuel](https://mods.factorio.com/mod/se-cargo-rockets-support-ion-stream-as-space-fuel) for [an example](https://github.com/Quezler/glutenfree/blob/main/mods/se-cargo-rockets-support-ion-stream-as-space-fuel/control.lua).

- side effects

you will no longer be able to output fuel from the silo (as in, decrease the progress bar),
daisy chaining will continue to work just fine as fluids can still freely flow through it,
also note that removing this mod will delete any fluids still present in the tank itself.

- gas leak

the upstream (pun intended) `window_bounding_box` property currently does not render gasses nicely,
so either set `gas_temperature` to `nil` on your fluid, or help me with making it render fluids and gasses nicely.

- nice to have

imagine if the rocket's flames were tinted in the fuel used, but factorio first has make their secondary draw order lua accessible.

- backstory

made on request of `Cee lo (ceelo0676)` on discord to make it support Krastorio 2's biomethanol,
my original ion stream rocket fuel mod has been lobotimized and hooked into this new library mod.

- thumbnail credits

Science Sparks @ https://nl.pinterest.com/pin/174866398005989799
