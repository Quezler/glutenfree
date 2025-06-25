
for _, storage_tank in pairs(data.raw["storage-tank"]) do
  if string.starts(storage_tank.name, "se-space-pipe-long") then

    circuit_connector_definition = circuit_connector_definitions.create_vector
    (
      universal_connector_template,
      {
        { variation = 1, main_offset = util.by_pixel(3, -12), shadow_offset = util.by_pixel(-2, -16), show_shadow = false },
        { variation = 1, main_offset = util.by_pixel(3, -12), shadow_offset = util.by_pixel(-2, -16), show_shadow = false },
        { variation = 1, main_offset = util.by_pixel(3, -12), shadow_offset = util.by_pixel(-2, -16), show_shadow = false },
        { variation = 1, main_offset = util.by_pixel(3, -12), shadow_offset = util.by_pixel(-2, -16), show_shadow = false },
      }
    )

    storage_tank.circuit_connector = circuit_connector_definition
    storage_tank.circuit_wire_max_distance = default_circuit_wire_max_distance
  end
end
