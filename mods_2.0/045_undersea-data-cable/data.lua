local entity = table.deepcopy(data.raw["heat-pipe"]["heat-pipe"])
entity.name = "undersea-data-cable"
entity.icon = "__undersea-data-cable__/graphics/icons/undersea-data-cable.png"
entity.collision_mask = {layers={ground_tile=true, is_lower_object=true}}
entity.heat_buffer.connections = nil -- still visually connects, but we do not want it to transmit heat
entity.quality_indicator_scale = 0

for _, connection_sprite in pairs(entity.connection_sprites) do
  for j, sheet in pairs(connection_sprite) do
    assert(tonumber(j), serpent.block(connection_sprite)) -- ensure numeric array
    sheet.tint = {0.25, 0.25, 0.25, 0.25}
  end
end

local item = table.deepcopy(data.raw["item"]["heat-pipe"])
item.name = "undersea-data-cable"
item.icon = "__undersea-data-cable__/graphics/icons/undersea-data-cable.png"
item.place_result = entity.name
entity.minable.result = item.name

local recipe = table.deepcopy(data.raw["recipe"]["heat-pipe"])
recipe.name = "undersea-data-cable"
recipe.results[1].name = item.name
recipe.results[1].amount = 10
recipe.enabled = true

data:extend{entity, item, recipe}

table.insert(data.raw["planet"]["fulgora"].lightning_properties.exemption_rules, {
  type = "id",
  string = entity.name,
})

data:extend{{
  type = "planet",
  name = "undersea-data-cable",
  icon = "__undersea-data-cable__/graphics/icons/undersea-data-cable.png",

  distance = 0,
  orientation = 0,

  hidden = true,
}}

data:extend{{
  type = "radar",
  name = "undersea-data-cable-connector",
  icon = "__undersea-data-cable__/graphics/icons/undersea-data-cable-connector.png",
  icon_size = 32,

  energy_usage = "1W",
  energy_source = {type = "void"},

  energy_per_sector = "1J",
  energy_per_nearby_scan = "1J",

  max_distance_of_sector_revealed = 0,
  max_distance_of_nearby_sector_revealed = 0,

  collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
  selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
}}
