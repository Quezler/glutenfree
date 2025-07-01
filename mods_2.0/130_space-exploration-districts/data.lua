-- at least 2 planets (nauvis & this) need to exist before the "buildable on:" shows any planets or surfaces at all
data:extend{
  {
    type = "planet",
    name = "planet-unknown",

    icon = "__core__/graphics/icons/unknown.png",
    hidden = true,

    distance = 0,
    orientation = 0,
  }
}

data.raw["roboport"]["roboport"].surface_conditions = {
  {
    property = "pressure",
    min = 100
  }
}

if not data.raw.tile["empty-space"] then
  local empty_space = table.deepcopy(data.raw.tile["out-of-map"])
  empty_space.name = "empty-space"
  data:extend{empty_space}
end

data:extend{
  {
    type = "surface",
    name = "se-planet-or-moon",

    order = "space-exploration-districts--a",
    icon = "__base__/graphics/icons/landfill.png",
  },
  {
    type = "surface",
    name = "se-orbit-or-space",

    order = "space-exploration-districts--b",
    icon = "__space-exploration-graphics__/graphics/icons/space-platform-plating.png",
  },
  {
    type = "surface",
    name = "se-spaceship-only",

    order = "space-exploration-districts--c",
    icon = "__space-exploration-graphics__/graphics/icons/spaceship-floor.png",
  },
}
