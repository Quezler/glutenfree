local entity = table.deepcopy(data.raw["heat-pipe"]["heat-pipe"])
entity.name = "undersea-cable"
entity.icon = "__undersea-cable__/graphics/icons/undersea-cable.png"
entity.collision_mask = {layers={ground_tile=true, is_lower_object = true}}
entity.heat_buffer.connections = nil
entity.protected_from_tile_building = false
entity.selectable_in_game = false

for _, connection_sprite in pairs(entity.connection_sprites) do
  for j, sheet in pairs(connection_sprite) do
    assert(tonumber(j), serpent.block(connection_sprite)) -- ensure numeric array
    sheet.tint = {0.25, 0.25, 0.25, 0.25}
  end
end

data:extend{entity}

table.insert(data.raw["planet"]["fulgora"].lightning_properties.exemption_rules, {
  type = "id",
  string = entity.name,
})

local offshore_pump = table.deepcopy(data.raw["offshore-pump"]["offshore-pump"])
offshore_pump.name = "undersea-cable-landing-point"
data:extend{offshore_pump}
