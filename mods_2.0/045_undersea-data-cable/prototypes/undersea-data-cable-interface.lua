local entity = {
  type = "radar",
  name = "undersea-data-cable-interface",
  icon = "__undersea-data-cable__/graphics/icons/undersea-data-cable-interface.png",
  icon_size = 32,

  energy_usage = "1W",
  energy_source = {type = "void"},

  energy_per_sector = "1YJ",
  energy_per_nearby_scan = "1J",

  max_distance_of_sector_revealed = 0,
  max_distance_of_nearby_sector_revealed = 0,

  collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
  selection_box = {{-0.5, -0.5}, {0.5, 0.5}},

  connects_to_other_radars = false,
  selection_priority = 51,

  pictures =
  {
    layers =
    {
      {
        filename = "__undersea-data-cable__/graphics/icons/undersea-data-cable-interface.png",
        priority = "low",
        width = 32,
        height = 32,
        direction_count = 1,
        line_length = 1,
      },
    }
  },

  minable = data.raw["radar"]["radar"].minable,
}

local item = table.deepcopy(data.raw["item"]["heat-pipe"])
item.name = "undersea-data-cable-interface"
item.icon = "__undersea-data-cable__/graphics/icons/undersea-data-cable-interface.png"
item.icon_size = 32
item.place_result = entity.name
entity.minable.result = item.name

local recipe = table.deepcopy(data.raw["recipe"]["radar"])
recipe.name = "undersea-data-cable-interface"
recipe.results[1].name = item.name
recipe.results[1].amount = 1
recipe.enabled = true

data:extend{entity, item, recipe}
