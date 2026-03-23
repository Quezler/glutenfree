-- table.insert(data.raw["character"]["character"].mining_categories, "basic-fluid")

data.raw["mining-drill"]["burner-mining-drill"].module_slots = 2
data.raw["mining-drill"]["burner-mining-drill"].allowed_module_categories = {"resource"}
data.raw["mining-drill"]["burner-mining-drill"].allowed_effects = {"consumption"}

data.raw["assembling-machine"]["assembling-machine-1"].module_slots = 1
data.raw["assembling-machine"]["assembling-machine-1"].allowed_module_categories = {"resource"}

data.raw["furnace"]["stone-furnace"].module_slots = 2
data.raw["furnace"]["stone-furnace"].allowed_module_categories = {"resource"}

data.raw["furnace"]["steel-furnace"].module_slots = 2
data.raw["furnace"]["steel-furnace"].allowed_module_categories = {"resource"}

data.raw["assembling-machine"]["centrifuge"].allowed_module_categories = {"resource"}

-- local boiler = data.raw["boiler"]["boiler"] --[[@as data.AssemblingMachinePrototype]]
-- data.raw[boiler.type][boiler.name] = nil
-- boiler.type = "assembling-machine"
-- data.raw[boiler.type][boiler.name] = boiler
-- boiler.energy_usage = "1.8MW"
-- boiler.crafting_speed = 1
-- boiler.crafting_categories = {"water-boiling"}
-- boiler.fixed_recipe = "water-boiling"
-- boiler.fluid_boxes = {
--   boiler.fluid_box,
--   boiler.output_fluid_box,
-- }
-- boiler.graphics_set = "complicated"

-- data:extend{
--   {
--     type = "recipe-category",
--     name = "water-boiling",
--   },
--   {
--     type = "recipe",
--     name = "water-boiling",
--     enabled = true,
--     ingredients = {{type = "fluid", name = "water", amount = 6}},
--     results = {{type = "fluid", name = "steam", amount = 60}},
--     energy_required = 1,
--     category = "water-boiling",
--   }
-- }

local mod_prefix = "mr-"

data:extend{
  {
    type = "item-subgroup",
    name = "nodes",
    group = "other",
    order = "d"
  },
  {
    type = "custom-input", key_sequence = "",
    name = mod_prefix .. "drop-cursor",
    linked_game_control = "drop-cursor",
  },
}

data.raw["resource"]["uranium-ore"].minable.fluid_amount = nil
data.raw["resource"]["uranium-ore"].minable.required_fluid = nil
