require("shared")

require("prototypes.surface")

local Hurricane = require("graphics.hurricane")

local a_5x5_entity = data.raw["reactor"]["nuclear-reactor"]

local entity = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-3"])
entity.name = mod_name
entity.max_health = a_5x5_entity.max_health

entity.collision_box = table.deepcopy(a_5x5_entity.collision_box)
entity.selection_box = table.deepcopy(a_5x5_entity.selection_box)

local gravity_assembler = Hurricane.crafter({
  name = "gravity-assembler",
  width = 2560, height = 2560, -- of one of the sheets
  rows = 8, columns = 8,
  total_frames = (8 * 8) + (8 * 4 + 4),
  shadow_width = 520, shadow_height = 500,
})

entity.icon = gravity_assembler.icon
entity.graphics_set = gravity_assembler.graphics_set

entity.icon_draw_specification = {shift = {0, -0.375}, scale = 1.5}
entity.fluid_boxes = nil
entity.circuit_wire_max_distance = nil

entity.corpse = nil
entity.dying_explosion = nil

entity.crafting_speed = 1 -- 0.25 worse than the assembling machine 3
entity.energy_source.buffer_capacity = "10GJ" -- does nothing?

entity.icons_positioning = {
  {inventory_index = defines.inventory.assembling_machine_modules, shift = {0, 1.5}, scale = 0.75},
}

entity.next_upgrade = nil

local item = table.deepcopy(data.raw["item"]["assembling-machine-3"])
item.name = mod_name
item.icon = gravity_assembler.icon
item.order = "d[apprentice-assembler]"
item.stack_size = 10
item.weight = 100*kg

entity.minable.result = item.name
item.place_result = entity.name

local recipe = {
  type = "recipe",
  name = item.name,
  enabled = false,
  ingredients =
  {
    {type = "item", name = "assembling-machine-3", amount = 1},
    {type = "item", name = "beacon", amount = 1},
  },
  results = {{type="item", name=item.name, amount=1}}
}

if mods["space-age"] then
  table.insert(recipe.ingredients, {type = "item", name = "carbon", amount = 50})
else
  table.insert(recipe.ingredients, {type = "item", name = "coal", amount = 100})
end

local technology = {
  type = "technology",
  name = "apprentice-assembler",
  icon = mod_directory .. "/graphics/technology/gravity-assembler.png",
  icon_size = 256,
  effects =
  {
    {
      type = "unlock-recipe",
      recipe = recipe.name
    }
  },
  prerequisites = {"effect-transmission", "automation-3"},
  unit =
  {
    count = 250,
    ingredients =
    {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"chemical-science-pack", 1},
      {"production-science-pack", 1}
    },
    time = 30
  }
}

if mods["space-age"] then
  table.insert(technology.prerequisites, "space-platform")
end

data:extend{entity, item, recipe, technology}

local beacon_interface = table.deepcopy(data.raw["beacon"]["beacon-interface--beacon-tile"])
beacon_interface.name = mod_prefix .. "beacon-interface"
data:extend{beacon_interface}
