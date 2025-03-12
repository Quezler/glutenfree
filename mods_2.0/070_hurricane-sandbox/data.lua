require("shared")

-- local Hurricane = require("graphics/hurricane")
-- local skin = Hurricane.crafter({
--   directory = mod_directory .. "factorio-sprites",
--   name = "radio-station",
--   width = 1280, height = 870,
--   total_frames = 20, rows = 3, -- custom
--   shadow_width = 400, shadow_height = 350,
--   shift = {0, 0.25}, -- custom
-- })

local recipe_category = {
  type = "recipe-category",
  name = mod_name,
}

local active_recipe = {
  type = "recipe",
  name = mod_prefix .. "animation-loop",

  icon = "__core__/graphics/icons/parametrise.png",

  energy_required = 1,

  ingredients = {},
  results = {},

  category = recipe_category.name,
  hidden = true,
}
data:extend{recipe_category, active_recipe}

local Hurricane = require("hurricane")

local function create_assembling_machine_prototypes(directory, name)
  local skin = Hurricane.assembling_machine(directory, name)

  local order = string.format("hurricane[%s]", skin.name)

  local entity = {
    type = "assembling-machine",
    name = mod_prefix .. skin.name,
    localised_name = skin.name,

    icon = skin.icon,
    order = order,

    selection_box = skin.selection_box,
    collision_box = skin.collision_box,

    crafting_categories = {recipe_category.name},
    graphics_set = skin.graphics_set,

    crafting_speed = 1,
    energy_usage = "1GW",
    energy_source = {type = "void"},
    minable = {mining_time = 0.2},

    flags = {"player-creation"},
  }

  entity.icon_draw_specification = {scale = 0}
  entity.fixed_recipe = active_recipe.name
  entity.fixed_quality = "normal"

  local item = {
    type = "item",
    name = entity.name,

    icon = skin.icon,
    order = order,

    stack_size = 10,
    weight = 100*kg,
    place_result = entity.name,
  }
  entity.minable.result = item.name

  local recipe = {
    type = "recipe",
    name = item.name,

    icon = item.icon,
    energy_required = 0.1,

    ingredients = {},
    results = {
      {type = "item", name = item.name, amount = 1},
    },
  }

  data:extend{entity, item, recipe}
end

create_assembling_machine_prototypes(mod_directory .. "/factorio-sprites", "alloy-forge")
create_assembling_machine_prototypes(mod_directory .. "/factorio-sprites", "arc-furnace")
create_assembling_machine_prototypes(mod_directory .. "/factorio-sprites", "atom-forge")
create_assembling_machine_prototypes(mod_directory .. "/factorio-sprites", "chemical-stager")
create_assembling_machine_prototypes(mod_directory .. "/factorio-sprites", "conduit")
create_assembling_machine_prototypes(mod_directory .. "/factorio-sprites", "core-extractor")
create_assembling_machine_prototypes(mod_directory .. "/factorio-sprites", "electricity-extractor")
create_assembling_machine_prototypes(mod_directory .. "/factorio-sprites", "fluid-extractor")
create_assembling_machine_prototypes(mod_directory .. "/factorio-sprites", "fusion-reactor")
create_assembling_machine_prototypes(mod_directory .. "/factorio-sprites", "glass-furnace")
create_assembling_machine_prototypes(mod_directory .. "/factorio-sprites", "gravity-assembler")
create_assembling_machine_prototypes(mod_directory .. "/factorio-sprites", "greenhouse")
create_assembling_machine_prototypes(mod_directory .. "/factorio-sprites", "item-extractor")
create_assembling_machine_prototypes(mod_directory .. "/factorio-sprites", "lumber-mill")
create_assembling_machine_prototypes(mod_directory .. "/factorio-sprites", "manufacturer")
create_assembling_machine_prototypes(mod_directory .. "/factorio-sprites", "oxidizer")
create_assembling_machine_prototypes(mod_directory .. "/factorio-sprites", "pathogen-lab")
create_assembling_machine_prototypes(mod_directory .. "/factorio-sprites", "photometric-lab")
create_assembling_machine_prototypes(mod_directory .. "/factorio-sprites", "quantum-stabilizer")
create_assembling_machine_prototypes(mod_directory .. "/factorio-sprites", "radio-station")
create_assembling_machine_prototypes(mod_directory .. "/factorio-sprites", "research-center")
create_assembling_machine_prototypes(mod_directory .. "/factorio-sprites", "scrubber")
create_assembling_machine_prototypes(mod_directory .. "/factorio-sprites", "thermal-plant")
