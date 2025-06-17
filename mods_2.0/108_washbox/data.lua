require("shared")

local recipe_category = {
  type = "recipe-category",
  name = "washbox",
}

local furnace = {
  type = "furnace",
  name = "washbox",
  icon = mod_directory .. "/graphics/icons/washbox.png",

  flags = {"placeable-player", "player-creation"},
  max_health = 250,

  selection_box = {{-0.5, -1.0}, {0.5, 1.0}},
  collision_box = {{-0.4, -0.9}, {0.4, 0.9}},

  crafting_speed = 1,
  crafting_categories = {recipe_category.name},

  source_inventory_size = 1,
  result_inventory_size = 1,

  energy_usage = "1kW",
  energy_source = {type = "void"},

  icon_draw_specification = {scale = 0},

  fluid_boxes =
  {
    {
      production_type = "input",
      pipe_covers = pipecoverspictures(),
      volume = 100,
      pipe_connections = {
        {direction = defines.direction.south, position = {0, 0.5}},
        {connection_type = "linked", linked_connection_id = 1},
      },
      secondary_draw_orders = { north = -1 }
    },
    {
      production_type = "output",
      pipe_covers = pipecoverspictures(),
      volume = 100,
      pipe_connections = {
        {direction = defines.direction.north, position = {0, -0.5}},
        {connection_type = "linked", linked_connection_id = 0},
      },
      secondary_draw_orders = { north = -1 }
    },
  },

  graphics_set = {
    animation = {
      north = {
        filename = mod_directory .. "/graphics/entity/washbox/washbox-vertical.png",
        width = 208,
        height = 160,
        scale = 0.5,
        shift = util.by_pixel(-25, -5),
      },
      south = {
        filename = mod_directory .. "/graphics/entity/washbox/washbox-vertical.png",
        width = 208,
        height = 160,
        scale = 0.5,
        shift = util.by_pixel(-25, -5),
      },
      east = {
        filename = mod_directory .. "/graphics/entity/washbox/washbox-horizontal.png",
        width = 158,
        height = 196,
        scale = 0.5,
        shift = util.by_pixel(-1, -19),
      },
      west = {
        filename = mod_directory .. "/graphics/entity/washbox/washbox-horizontal.png",
        width = 158,
        height = 196,
        scale = 0.5,
        shift = util.by_pixel(-1, -19),
      }
    },
    working_visualisations =
    {
      {
        apply_recipe_tint = "primary",
        always_draw = true,

        north_animation =
        {
          filename = mod_directory .. "/graphics/entity/washbox/washbox-vertical-mask.png",
          width = 64,
          height = 74,
          scale = 0.5,
          shift = util.by_pixel(0, -3)
        },
        south_animation =
        {
          filename = mod_directory .. "/graphics/entity/washbox/washbox-vertical-mask.png",
          width = 64,
          height = 74,
          scale = 0.5,
          shift = util.by_pixel(0, -3),
        },
        east_animation =
        {
          filename = mod_directory .. "/graphics/entity/washbox/washbox-horizontal-mask.png",
          width = 74,
          height = 70,
          scale = 0.5,
          shift = util.by_pixel(-1, 1),
        },
        west_animation =
        {
          filename = mod_directory .. "/graphics/entity/washbox/washbox-horizontal-mask.png",
          width = 74,
          height = 70,
          scale = 0.5,
          shift = util.by_pixel(-1, 1),
        },
      }
    },
  }
}

local item = {
  type = "item",
  name = "washbox",
  icon = mod_directory .. "/graphics/icons/washbox.png",

  order = "b[pipe]-d[washbox]",
  subgroup = "energy-pipe-distribution",

  stack_size = 10,
  place_result = furnace.name,
}
furnace.minable = {mining_time = 0.2, result = item.name}

local recipe = {
  type = "recipe",
  name = "washbox",
  enabled = false,
  energy_required = 5,
  ingredients =
  {
    {type = "item", name = "burner-inserter", amount = 1},
    {type = "item", name = "pipe", amount = 2},
    {type = "item", name = "stone-brick", amount = 10},
  },
  results = {{type="item", name=item.name, amount=1}}
}

-- inserts washbox right after the pump in fluid handling
local technology = data.raw["technology"]["fluid-handling"]
for i, effect in ipairs(technology.effects) do
  if effect.type == "unlock-recipe" and effect.recipe == "pump" then
    table.insert(technology.effects, i + 1, {
      type = "unlock-recipe",
      recipe = recipe.name,
    })
    break
  end
end

local valve_in = {
  type = "valve",
  name = mod_prefix .. "valve-in",

  mode = "overflow",
  threshold = 0.8,

  flow_rate = data.raw["pump"]["pump"].pumping_speed, -- 20, times 60 = 1200

  selection_priority = 51,
  -- selection_priority = 49,
  -- selectable_in_game = false,
  selection_box = {{-0.4, -0.4}, {0.4, 0.4}},
  collision_box = {{-0.3, -0.3}, {0.3, 0.3}},
  collision_mask = {layers = {}},

  fluid_box =
  {
    volume = 100,
    pipe_connections = {
      {flow_direction = "input-output", connection_type = "linked", linked_connection_id = 1},
      {flow_direction = "output", connection_type = "linked", linked_connection_id = 0},
    },
  },

  flags = {"not-on-map", "placeable-off-grid"},
  hidden = true,
}

local valve_out = table.deepcopy(valve_in)
valve_out.name = mod_prefix .. "valve-out"
valve_out.mode = "top-up"
valve_out.threshold = 0.75

data:extend{recipe_category, furnace, item, recipe, valve_in, valve_out}
