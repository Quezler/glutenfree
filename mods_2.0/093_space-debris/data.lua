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

  -- based on small
  max_health = 100 / 2,
  mass = 200000 / 2,

  subgroup = "space-environment",
  flags = {"placeable-neutral", "placeable-off-grid", "not-repairable", "not-on-map"},

  created_effect = {
    type = "direct",
    action_delivery = {
      type = "instant",
      source_effects = {
        {
          type = "script",
          effect_id = mod_name .. "-created",
        },
      }
    }
  },

  dying_trigger_effect = {
    {
      type = "create-explosion",
      entity_name = "carbonic-asteroid-explosion-1", -- a grey "generic" explosion
    }
  }
}

data:extend{asteroid}
