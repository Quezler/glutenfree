require("shared")

for space_location_type, _ in pairs(defines.prototypes["space-location"]) do
  for _, space_location in pairs(data.raw[space_location_type]) do
    if space_location.asteroid_spawn_definitions then
      table.insert(space_location.asteroid_spawn_definitions, {
        type = "entity",
        asteroid = mod_name,
        probability = 0.01,
        speed = 0.05,
        angle_when_stopped = 1,
      })
    end
  end
end
