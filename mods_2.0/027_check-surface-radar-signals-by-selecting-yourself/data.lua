local mod_prefix = "csrsbsy-"

local proxy = table.deepcopy(data.raw["item-request-proxy"]["item-request-proxy"])
proxy.name = mod_prefix .. proxy.name

local character = data.raw["character"]["character"]
proxy.selection_box = character.selection_box
proxy.collision_box = character.collision_box
proxy.selection_priority = (character.selection_priority or 50) - 2
proxy.minable.mining_time = 1000000

data:extend{proxy}

data:extend{{
  type = "electric-pole",
  name = mod_prefix .. "electric-pole",

  supply_area_distance = 0,
  connection_points = {},

  selection_box = character.selection_box,
  collision_box = character.collision_box,
  selection_priority = (character.selection_priority or 50) - 1,

  flags = {"placeable-off-grid", "not-on-map"},
  collision_mask = {layers = {}},
}}
