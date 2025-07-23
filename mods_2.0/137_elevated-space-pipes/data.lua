local item_sounds = require("__base__.prototypes.item_sounds")
local item_tints = require("__base__.prototypes.item-tints")

require("namespace")

if mods["space-age"] then
  require("prototypes.planet")
end

local config = {
  name = "elevated-space-pipe",
  icon = mod_directory .. "/graphics/icons/elevated-pipe.png",
  graphics = mod_directory .. "/graphics/entity/elevated-pipe/elevated-pipe", -- .png / -something.png
  max_underground_distance = settings.startup[mod_prefix .. "max-underground-distance"].value,
}

elevated_pipes.new_elevated_pipe(config)

data:extend{
  {
    type = "item",
    name = config.name,
    icon = config.icon,
    subgroup = "energy-pipe-distribution",
    order = "a[pipe]-b[" .. config.name .. "]",
    inventory_move_sound = item_sounds.metal_small_inventory_move,
    pick_sound = item_sounds.metal_small_inventory_pickup,
    drop_sound = item_sounds.metal_small_inventory_move,
    place_result = config.name,
    stack_size = 100 / 5,
    weight = 5 * kg * 5,
    random_tint_color = item_tints.iron_rust,
  },
  {
    type = "recipe",
    name = config.name,
    energy_required = 1,
    ingredients = {
      {type = "item", name = data.raw["item"]["se-space-pipe"] and "se-space-pipe" or "pipe", amount = 5},
      {type = "item", name = "steel-plate", amount = 4},
      {type = "item", name = "iron-stick", amount = 20},
    },
    results = {{type="item", name=config.name, amount=1}},
    enabled = false,
  },
  {
    type = "technology",
    name = config.name,
    icon = mod_directory .. "/graphics/technology/elevated-pipe.png",
    icon_size = 256,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = config.name,
      },
    },
    prerequisites = {"elevated-pipe"},
    unit =
    {
      count = 100,
      ingredients = {{"automation-science-pack", 1}},
      time = 10
    }
  }
}

if mods["space-age"] then
  table.insert(data.raw["technology"][config.name].prerequisites, "space-science-pack")
  data.raw["technology"][config.name].unit.ingredients = {{"space-science-pack", 1}}

  data.raw["furnace"][config.name].surface_conditions =
  {
    {
      property = "gravity",
      max = 0,
    }
  }
  data.raw["furnace"]["elevated-pipe"].surface_conditions =
  {
    {
      property = "gravity",
      min = 1,
    }
  }
end

if mods["space-exploration"] then
  table.insert(data.raw["technology"][config.name].prerequisites, "se-space-pipe")
  data.raw["technology"][config.name].unit.ingredients = table.deepcopy(data.raw["technology"]["se-space-pipe"].unit.ingredients)

  data.raw["furnace"][config.name].se_allow_in_space = true
end
