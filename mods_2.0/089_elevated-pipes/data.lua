local item_sounds = require("__base__.prototypes.item_sounds")
local item_tints = require("__base__.prototypes.item-tints")

require("shared")

elevated_pipes = {}

require("prototypes.entity")
require("prototypes.sprite")
require("prototypes.mod-data")

elevated_pipes.new_elevated_pipe = function(config)
  data.raw["mod-data"]["elevated-pipes"].data[config.name] = {}

  data:extend{
    elevated_pipes.new_furnace(config),
    elevated_pipes.new_storage_tank(config),
    elevated_pipes.new_corpse(config),
    elevated_pipes.new_sprites(config),
  }
end

local config = {
  name = "elevated-pipe",
  icon = mod_directory .. "/graphics/icons/elevated-pipe.png",
  graphics = mod_directory .. "/graphics/entity/elevated-pipe/elevated-pipe", -- .png / -something.png
  max_underground_distance = settings.startup[mod_prefix .. "max-underground-distance"].value,
}

elevated_pipes.new_elevated_pipe(config)

-- these prototypes are not complicated enough for other mods to mimic to warant a generator function:
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
      {type = "item", name = "pipe", amount = 5},
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
      {
        type = "unlock-recipe",
        recipe = "iron-stick"
      }
    },
    prerequisites = {"steam-power", "steel-processing"},
    unit =
    {
      count = 100,
      ingredients = {{"automation-science-pack", 1}},
      time = 10
    }
  }
}
