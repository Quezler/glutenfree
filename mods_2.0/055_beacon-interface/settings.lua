if mods["UnlimitedProductivityFork"] then
  -- that mod can go through all modded beacons and force override their effects,
  -- whilst i can remedy it slightly in data-final-fixes it's simply too much to ask for modders cloning my prototypes in the data.lua stage,
  -- therefore instead of just marking it incompatible the best i can do is force that mod to not touch the effects of modded beacons at all.
  data.raw["bool-setting"]["up-allow-all-beacons"].hidden = true
  data.raw["bool-setting"]["up-allow-all-beacons"].forced_value = false

  -- and since this setting only does something when the above setting is enabled, we'll be hiding it from the user too.
  data.raw["bool-setting"]["allow-quality-in-all-beacons"].hidden = true
  data.raw["bool-setting"]["allow-quality-in-all-beacons"].forced_value = false
end
