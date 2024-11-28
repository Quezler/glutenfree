local Shared = require("shared")

local lines = {}
for _, quality in pairs(data.raw["quality"]) do
  if not quality.hidden then
    table.insert(lines, string.format("[img=quality/%s] × %d", quality.name, Shared.get_multiplier_for_quality(quality)))
  end
end
data.raw["item"]["holmium-solution-quality-based-productivity"].localised_description = {"", "[font=default-bold]", table.concat(lines, "\n"), "[/font]"}

local crafting_category = {
  type = "recipe-category",
  name = "holmium-chemical-plant-assembling-machine"
}

local assembler = {
  type = "assembling-machine",
  name = "holmium-chemical-plant-assembling-machine",
  collision_mask = {layers = {}},
  collision_box = {{-0.25, -0.25}, {0.25, 0.25}},
  selection_box = {{-0.25, -0.25}, {0.25, 0.25}},
  fluid_boxes =
  {
    {
      production_type = "output",
      volume = 1,
      pipe_connections = {{ flow_direction = "output", connection_type = "linked", linked_connection_id = 1 }},
    },
    {
      production_type = "output",
      volume = 1,
      pipe_connections = {{ flow_direction = "output", connection_type = "linked", linked_connection_id = 2 }},
    },
  },
  energy_usage = "1W",
  energy_source = {type = "void"},
  crafting_speed = 10,
  hidden = true,
  selection_priority = 51,
  selectable_in_game = false,
  crafting_categories = {crafting_category.name},
  flags = {"not-on-map", "hide-alt-info"},
}

local recipe = table.deepcopy(data.raw["recipe"]["holmium-solution"])
recipe.name = "holmium-chemical-plant-assembling-machine"
recipe.ingredients = {{type = "item", name = "coupon-for-holmium-solution", amount = 1, ignored_by_stats = 1}}
recipe.hide_from_player_crafting = true
recipe.hide_from_signal_gui = true
recipe.category = crafting_category.name
recipe.enabled = true
recipe.energy_required = 0.1
assert(#recipe.results == 1)

assembler.fixed_recipe = recipe.name
assembler.fixed_quality = "normal"

table.insert(assembler.flags, "no-automated-item-removal")
table.insert(assembler.flags, "no-automated-item-insertion")

data:extend{crafting_category, assembler, recipe}
