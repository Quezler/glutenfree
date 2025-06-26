local item_sounds = require("__base__.prototypes.item_sounds")

data:extend({
  {
    type = "item",
    name = "disposable-construction-robot",
    icon = "__disposable-construction-robots__/graphics/icons/old-engine-unit.png",
    subgroup = "logistic-network",
    order = "a[robot]-b[disposable-construction-robot]",
    inventory_move_sound = item_sounds.robotic_inventory_move,
    pick_sound = item_sounds.robotic_inventory_pickup,
    drop_sound = item_sounds.robotic_inventory_move,
    place_result = "disposable-construction-robot",
    stack_size = 50,
    spoil_ticks = 60 * 60,
    spoil_to_trigger_result = {
      items_per_trigger = 1,
      trigger = {
        type = "direct",
        action_delivery =
        {
          type = "instant",
          source_effects =
          {
            {
              type = "script",
              effect_id = "disposable-construction-robot-spoiled",
            }
          }
        }
      }
    }
  }
})

local dcr = table.deepcopy(data.raw["construction-robot"]["construction-robot"])
dcr.name = "disposable-construction-robot"
dcr.minable = {mining_time = 0.1}
dcr.min_to_charge = 0
dcr.max_to_charge = 0
dcr.speed_multiplier_when_out_of_energy = 0 -- crashes: if you kept it flying for that long, that's on you.
data:extend({dcr})

data:extend({
  {
    type = "recipe-category",
    name = "handcrafting",
  },
  {
    type = "recipe",
    name = "disposable-construction-robot",
    category = "handcrafting",
    energy_required = 2.5,
    ingredients =
    {
      {type = "item", name = "iron-gear-wheel", amount = 2},
      {type = "item", name = "transport-belt" , amount = 10},
    },
    results = {{type = "item", name = "disposable-construction-robot", amount = 1}},
    enabled = true,
  },
})

table.insert(data.raw["character"]["character"].crafting_categories, "handcrafting")

data:extend({
  {
    type = "equipment-grid",
    name = "disposable-equipment-grid",
    width = 2,
    height = 2,
    equipment_categories = {"armor"},
    locked = true,
  },
  {
    type = "armor",
    name = "empty-ish-armor-slot",
    icons = {
      {
        icon = "__core__/graphics/icons/mip/empty-armor-slot.png",
        tint = {0.25, 0.25, 0.25, 0.25},
      },
    },
    subgroup = "armor",
    order = "a[empty-ish-armor-slot]",
    inventory_move_sound = item_sounds.armor_small_inventory_move,
    pick_sound = item_sounds.armor_small_inventory_pickup,
    drop_sound = item_sounds.armor_small_inventory_move,
    stack_size = 1,
    infinite = true,
    flags = {"only-in-cursor"}, -- i guess it can only end up in the inventory whilst picking up a corpse?
    equipment_grid = "disposable-equipment-grid",
    hidden = true,
  },
})

local dre = table.deepcopy(data.raw["roboport-equipment"]["personal-roboport-equipment"])
dre.name = "disposable-roboport-equipment"
dre.spawn_minimum = "0J"
dre.robot_limit = 50
dre.charging_station_count = 50 -- if its zero bots cannot land despite not needing to charge.
dre.hidden = true
data:extend({dre})
