
for _, storage_tank in pairs(data.raw['storage-tank']) do
  if string.starts(storage_tank.name, "se-space-pipe-long") then

    circuit_connector_definition = circuit_connector_definitions.create
    (
      universal_connector_template, -- didn't touch the shadow pixels since they are disabled anyways
      {
        { variation = 1, main_offset = util.by_pixel(3, -12), shadow_offset = util.by_pixel(27, 29), show_shadow = false },
        { variation = 1, main_offset = util.by_pixel(3, -12), shadow_offset = util.by_pixel(27, 29), show_shadow = false },
        { variation = 1, main_offset = util.by_pixel(3, -12), shadow_offset = util.by_pixel(27, 29), show_shadow = false },
        { variation = 1, main_offset = util.by_pixel(3, -12), shadow_offset = util.by_pixel(27, 29), show_shadow = false },
      }
    )

    storage_tank.circuit_wire_connection_points = circuit_connector_definition.points
    storage_tank.circuit_connector_sprites = circuit_connector_definition.sprites
    storage_tank.circuit_wire_max_distance = 9 -- same as the storage tank
  end
end
