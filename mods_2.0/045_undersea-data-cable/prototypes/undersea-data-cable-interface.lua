local icons = {
  {icon = "__undersea-data-cable__/graphics/icons/undersea-data-cable-interface.png", icon_size = 32},
  {icon = "__undersea-data-cable__/graphics/icons/undersea-data-cable.png", scale = 0.3},
}

local entity = {
  type = "radar",
  name = "undersea-data-cable-interface",
  icons = icons,
  icon_size = 32,

  energy_usage = "1W",
  energy_source = {type = "void"},

  energy_per_sector = "1YJ",
  energy_per_nearby_scan = "1J",

  max_distance_of_sector_revealed = 0,
  max_distance_of_nearby_sector_revealed = 0,

  collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
  selection_box = {{-0.5, -0.5}, {0.5, 0.5}},

  circuit_wire_max_distance = data.raw["radar"]["radar"].circuit_wire_max_distance,
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
      {
        filename = "__undersea-data-cable__/graphics/icons/undersea-data-cable.png",
        priority = "low",
        width = 64,
        height = 64,
        direction_count = 1,
        line_length = 1,
        scale = 0.2,
      },
    }
  },

  minable = table.deepcopy(data.raw["radar"]["radar"].minable),
  flags = {"player-creation"},
}

local item = table.deepcopy(data.raw["item"]["heat-pipe"])
item.name = "undersea-data-cable-interface"
item.icons = icons
item.order = "z-d[undersea-data-cable-interface]"
item.stack_size = 10
item.place_result = entity.name
entity.minable.result = item.name

local recipe = {
  type = "recipe",
  name = "undersea-data-cable-interface",
  ingredients =
  {
    {type = "item", name = "electronic-circuit", amount = 1},
    {type = "item", name = "iron-gear-wheel", amount = 1},
    {type = "item", name = "iron-plate", amount = 2}
  },
  results = {{type="item", name="undersea-data-cable-interface", amount=1}},
  enabled = false
}

data:extend{entity, item, recipe}

entity.circuit_connector = circuit_connector_definitions.create_single
(
  universal_connector_template,
  { variation = 7, main_offset = util.by_pixel(4, 2), shadow_offset = util.by_pixel(4, 2), show_shadow = true }
)

if data.raw["planet"]["fulgora"] then
  table.insert(data.raw["planet"]["fulgora"].lightning_properties.exemption_rules, {
    type = "id",
    string = entity.name,
  })
end
