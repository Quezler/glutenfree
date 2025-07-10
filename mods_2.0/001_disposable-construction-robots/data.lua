local item_sounds = require("__base__.prototypes.item_sounds")

require("namespace")
require("prototypes.planet")

data:extend({
  {
    type = "item",
    name = "disposable-construction-robot",
    icon = mod_directory .. "/graphics/icons/old-engine-unit.png",
    subgroup = "logistic-network",
    order = "a[robot]-b[disposable-construction-robot]",
    inventory_move_sound = item_sounds.robotic_inventory_move,
    pick_sound = item_sounds.robotic_inventory_pickup,
    drop_sound = item_sounds.robotic_inventory_move,
    place_result = "disposable-construction-robot",
    stack_size = 50,
  }
})

local construction_robot = table.deepcopy(data.raw["construction-robot"]["construction-robot"])
construction_robot.name = "disposable-construction-robot"
construction_robot.minable.result = nil
construction_robot.created_effect = {
  type = "direct",
  action_delivery = {
    type = "instant",
    source_effects = {
      {
        type = "script",
        effect_id = "disposable-construction-robot-created",
      },
    }
  }
}
data:extend({construction_robot})

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
      {type = "item", name = "transport-belt", amount = 10},
    },
    results = {{type = "item", name = "disposable-construction-robot", amount = 50}},
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

local roboport_equipment = table.deepcopy(data.raw["roboport-equipment"]["personal-roboport-equipment"])
roboport_equipment.name = "disposable-roboport-equipment"
roboport_equipment.spawn_minimum = "0J"
roboport_equipment.robot_limit = 50
roboport_equipment.charging_offsets = {}
roboport_equipment.charging_station_count = 0
roboport_equipment.hidden = true
data:extend({roboport_equipment})
