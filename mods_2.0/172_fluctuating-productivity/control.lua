-- local util = require("util")

local all_recipe_names = {}
local all_recipe_count = 0

local function skip_recipe(recipe)
  if recipe.hidden then return true end
  if recipe.is_parameter then return true end
  if recipe.hide_from_bonus_gui then return true end
  if recipe.category == "recycling" then return true end
  if recipe.subgroup == "fill-barrel" then return true end
  if recipe.subgroup == "empty-barrel" then return true end
  if recipe.name == "fluoroketone-cooling" then return true end

  -- local allowed_effects = util.list_to_map(recipe.allowed_effects or {"consumption", "speed", "productivity", "pollution", "quality"})
  -- if not allowed_effects["productivity"] then
  --   return true
  -- end
end

for recipe_name, recipe in pairs(prototypes.recipe) do
  if not skip_recipe(recipe) then
    all_recipe_count = all_recipe_count + 1
    all_recipe_names[all_recipe_count] = recipe_name
  end
end

-- all_recipe_names = {"iron-gear-wheel"}
-- all_recipe_count = #all_recipe_names

min = 0
max = 3

min_step = -0.1
max_step =  0.1

function math.clamp(number, min, max)
	return math.min(math.max(number, min), max)
end

local mod = {}

script.on_init(function()
  storage.forcedata = {}

  mod.add_force("player")
end)

script.on_configuration_changed(function()
  for _, forcedata in pairs(storage.forcedata) do
    mod.refresh_forcedata(forcedata)
  end
end)

mod.add_force = function(force_name)
  local force = game.forces[force_name]
  -- assert(force)

  storage.forcedata[force_name] = {
    force = force,
    recipes = {},
  }

  mod.refresh_forcedata(storage.forcedata[force_name])
end

mod.refresh_forcedata = function(forcedata)
  forcedata.recipes = {}
  for recipe_name, recipe in pairs(forcedata.force.recipes) do
    forcedata.recipes[recipe_name] = recipe
  end
end

script.on_event(defines.events.on_tick, function()
  for _, forcedata in pairs(storage.forcedata) do
    local recipe_name = all_recipe_names[math.random(1, all_recipe_count)]
    local recipe = forcedata.recipes[recipe_name]
    -- assert(recipe, recipe_name)
    local productivity_bonus = recipe.productivity_bonus

    local step = min_step + (max_step - min_step) * math.random()
    local next = math.clamp(productivity_bonus + step, min, max)
    recipe.productivity_bonus = next
  end
end)
