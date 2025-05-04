require("shared")

local collision_radius = 0.5
local selection_radius = collision_radius * 1.1 + 0.1

local asteroid = {
  type = "asteroid",
  name = mod_name,

  icon = "__base__/graphics/icons/crash-site-spaceship.png",

  collision_mask = {layers={object=true}, not_colliding_with_itself=true},
  collision_box = {{-collision_radius, -collision_radius}, {collision_radius, collision_radius}},
  selection_box = {{-selection_radius, -selection_radius}, {selection_radius, selection_radius}},

  subgroup = "space-environment",
  flags = {"placeable-neutral", "placeable-off-grid", "not-repairable", "not-on-map"},
}

data:extend{asteroid}
