local mod_prefix = "csrsbsy-"

local proxy = table.deepcopy(data.raw["item-request-proxy"]["item-request-proxy"])
proxy.name = mod_prefix .. proxy.name

local character = data.raw["character"]["character"]
proxy.selection_box = character.selection_box
proxy.collision_box = character.collision_box
proxy.selection_priority = (character.selection_priority or 50) - 1
proxy.minable.mining_time = 1000000

data:extend{proxy}

data:extend{{
  type = "electric-pole",
  name = mod_prefix .. "electric-pole",

  supply_area_distance = 0,
  connection_points = {},

  selection_box = {
    {character.selection_box[1][1] - 0.5, character.selection_box[1][2] - 0.5},
    {character.selection_box[2][1] + 0.5, character.selection_box[2][2] + 0.5},
  },
  collision_box = character.collision_box,
  selection_priority = (character.selection_priority or 50) + 1,

  flags = {"placeable-off-grid", "not-on-map"},
  collision_mask = {layers = {}},
}}

-- error(serpent.block( character.selection_box ))
