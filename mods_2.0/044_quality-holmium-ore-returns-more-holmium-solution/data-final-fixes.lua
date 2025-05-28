local Shared = require("shared")

-- https://chatgpt.com/share/674af254-ffc4-8007-b2a9-7d003ed5d5e5
function splitStringByLength(input, length)
  local result = {}
  for i = 1, #input, length do
      table.insert(result, input:sub(i, i + length - 1))
  end
  return result
end

local localised_description = {"", "[font=default-bold]"}
data.raw["item"]["holmium-solution-quality-based-productivity"].localised_description = localised_description

local lines = {}
for _, quality in pairs(data.raw["quality"]) do
  if not quality.hidden then
    table.insert(lines, string.format("[img=quality/%s] × %d", quality.name, Shared.get_multiplier_for_quality(quality)))
  end
end
local lines_concat = table.concat(lines, "\n")
for _, substring in ipairs(splitStringByLength(lines_concat, 200)) do -- possibly problematic if it gets split at exactly in between \n?
  if #localised_description >= 20 then break end
  table.insert(localised_description, substring)
end

table.insert(localised_description, "[/font]")


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
recipe.ingredients = {{type = "item", name = "coupon-for-holmium-solution", amount = 1}}
recipe.hide_from_player_crafting = true
recipe.hide_from_signal_gui = true
recipe.hidden = true
recipe.category = crafting_category.name
recipe.enabled = true
recipe.energy_required = 0.1
assert(#recipe.results == 1, serpent.block(recipe.results))

assembler.fixed_recipe = recipe.name
assembler.fixed_quality = "normal"

table.insert(assembler.flags, "no-automated-item-removal")
table.insert(assembler.flags, "no-automated-item-insertion")

data:extend{crafting_category, assembler, recipe}
