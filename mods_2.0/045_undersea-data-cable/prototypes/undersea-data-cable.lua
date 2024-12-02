local entity = table.deepcopy(data.raw["heat-pipe"]["heat-pipe"])
entity.name = "undersea-data-cable"
entity.icon = "__undersea-data-cable__/graphics/icons/undersea-data-cable.png"
entity.collision_mask = {layers={ground_tile=true, is_lower_object=true}}
entity.heat_buffer.connections = nil -- still visually connects, but we do not want it to transmit heat
entity.quality_indicator_scale = 0
-- entity.selection_box = {{-0.25, -0.25}, {0.25, 0.25}}

for _, connection_sprite in pairs(entity.connection_sprites) do
  for j, sheet in pairs(connection_sprite) do
    assert(tonumber(j), serpent.block(connection_sprite)) -- ensure numeric array
    sheet.tint = {0.25, 0.25, 0.25, 0.25}
  end
end

local item = table.deepcopy(data.raw["item"]["heat-pipe"])
item.name = "undersea-data-cable"
item.icon = "__undersea-data-cable__/graphics/icons/undersea-data-cable.png"
item.subgroup = "environmental-protection"
item.order = "z-e[undersea-data-cable]"
item.place_result = entity.name
entity.minable.result = item.name

local recipe = {
  type = "recipe",
  name = "undersea-data-cable",
  energy_required = 1,
  enabled = false,
  ingredients = {
    {type = "item", name = "steel-plate", amount = 1},
    {type = "item", name = "copper-plate", amount = 2},
  },
  results = {{type="item", name="undersea-data-cable", amount=1}}
}

data:extend{entity, item, recipe}

table.insert(data.raw["planet"]["fulgora"].lightning_properties.exemption_rules, {
  type = "id",
  string = entity.name,
})
