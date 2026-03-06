local Shared = require("shared")

for _, resource in ipairs(Shared.resources) do
  resource.product = resource.product or resource.name

  -- prevent zones from having space age ores as their primary resource or as ore
  data.raw["mod-data"]["se-universe-resource-word-rules"].data[resource.name] = {
    forbid_space = true,
    forbid_orbit = true,
    forbid_belt = true,
    forbid_field = true,
    forbid_planet = true,
    forbid_homeworld = true,
  }

  se_core_fragment_resources = se_core_fragment_resources or {}
  se_core_fragment_resources[resource.product] = se_core_fragment_resources[resource.product] or {
    multiplier = 0, -- do not create a pulverizer recipe for this resource/fragment
    omni_multiplier = 0, -- do not output this resource when crushing omni fragments
  }
end

-- https://github.com/wube/Factorio/commit/7226d95f9a3a8656e37d739d7d5bb100dab7b432
-- Fixed base game space science getting throughput limited due to limited hatches. (https://forums.factorio.com/118064)
local cargo_station_parameters = data.raw["cargo-landing-pad"]["cargo-landing-pad"].cargo_station_parameters
local hatch_definitions = {}
local covered_hatches = {}
cargo_station_parameters.giga_hatch_definitions[1].covered_hatches = covered_hatches
for i = 1, 10 do
  for _, hatch_definition in ipairs(cargo_station_parameters.hatch_definitions) do
    table.insert(hatch_definitions, hatch_definition)
    table.insert(covered_hatches, #covered_hatches)
  end
end
cargo_station_parameters.hatch_definitions = hatch_definitions

-- generally all/only resources are allowed in the delivery cannon, but this curated list relieves some pain.
se_delivery_cannon_recipes["agricultural-science-pack"] = {name = "agricultural-science-pack", type = "tool"}

local function add_recipe_category(recipe, category)
  recipe.additional_categories = recipe.additional_categories or {}
  table.insert(recipe.additional_categories, category)
end

add_recipe_category(data.raw.recipe["rocket-control-unit"], "electromagnetics")

-- in a really akward spot with vanilla only science packs and inability to be placed in space
data.raw["lab"]["biolab"].hidden = true
data.raw["item"]["biolab"].hidden = true
data.raw["recipe"]["biolab"].hidden = true
data.raw["technology"]["biolab"].hidden = true
