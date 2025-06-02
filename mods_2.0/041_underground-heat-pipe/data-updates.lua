local heating_radius = data.raw["heat-pipe"]["heat-pipe"].heating_radius

for heat_pipe_name, _ in pairs(underground_heat_pipe_directional_heat_pipe_names) do
  data.raw["heat-pipe"][heat_pipe_name].heating_radius = heating_radius
end
