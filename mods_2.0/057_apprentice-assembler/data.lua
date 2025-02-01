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
  table.insert(recipe.ingredients, {type = "item", name = "coal", amount = 50})
end

table.insert(data.raw["technology"]["automation-3"].effects, {
  type = "unlock-recipe",
  recipe = recipe.name,
})

data:extend{entity, item, recipe}
