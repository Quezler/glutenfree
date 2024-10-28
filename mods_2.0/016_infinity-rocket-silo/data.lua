local silo = table.deepcopy(data.raw["rocket-silo"]["rocket-silo"])
local silo_item = table.deepcopy(data.raw["item"]["rocket-silo"])


silo.name = "infinity-rocket-silo"
silo.heating_energy = nil -- frozen sprites missing (gimp, hue saturation, -60)

silo.base_day_sprite.filename = "__infinity-rocket-silo__/graphics/entity/infinity-rocket-silo/06-infinity-rocket-silo.png"
silo.base_front_sprite.filename = "__infinity-rocket-silo__/graphics/entity/infinity-rocket-silo/14-infinity-rocket-silo-front.png"

silo_item.name = silo.name
silo_item.icon = "__infinity-rocket-silo__/graphics/icons/infinity-rocket-silo.png"

silo.hidden_in_factoriopedia = true
silo_item.hidden_in_factoriopedia = true

silo_item.place_result = silo.name
silo.minable.result = silo_item.name

silo.energy_source = {type = "void"}
silo.module_slots = 0
silo.rocket_parts_required = 1
silo.fixed_recipe = "infinity-rocket-part"

local infinity_rocket_part_item = {
  type = "item",
  name = "infinity-rocket-part",
  icon = "__infinity-rocket-silo__/graphics/icons/infinity-rocket-part.png",
  hidden = true,
  subgroup = "intermediate-product",
  order = "d[rocket-parts]-e[infinity-rocket-part]",
  inventory_move_sound = item_sounds.mechanical_inventory_move,
  pick_sound = item_sounds.mechanical_inventory_pickup,
  drop_sound = item_sounds.mechanical_inventory_move,
  stack_size = 5,
  hidden_in_factoriopedia = true,
}

local infinity_rocket_part_recipe = {
  type = "recipe",
  name = "infinity-rocket-part",
  energy_required = 0.01,
  enabled = true,
  hide_from_player_crafting = true,
  category = "rocket-building",
  ingredients =
  {
    --
  },
  results = {{type="item", name="infinity-rocket-part", amount=1}},
  auto_recycle = false, -- doesn't work?
  hidden_in_factoriopedia = true,
}

data:extend{silo, silo_item}
data:extend{infinity_rocket_part_item, infinity_rocket_part_recipe}
