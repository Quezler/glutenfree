local entity = table.deepcopy(data.raw["heat-pipe"]["heat-pipe"])
entity.name = "undersea-cable"
entity.icon = "__undersea-cable__/graphics/icons/undersea-cable.png"
entity.collision_mask = {layers = {}}
entity.heat_buffer.connections = nil

for _, connection_sprite in pairs(entity.connection_sprites) do
  for j, sheet in pairs(connection_sprite) do
    assert(tonumber(j), serpent.block(connection_sprite)) -- sheet array and not just one
    sheet.tint = {0.25, 0.25, 0.25, 0.25}
  end
end

data:extend{entity}

table.insert(data.raw["planet"]["fulgora"].lightning_properties.exemption_rules, {
  type = "id",
  string = entity.name,
})
