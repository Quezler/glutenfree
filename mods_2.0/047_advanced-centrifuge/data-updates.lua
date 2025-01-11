if mods["Cerys-Moon-of-Fulgora"] then
  local fluid_boxes = data.raw["assembling-machine"]["k11-advanced-centrifuge"].fluid_boxes
  if fluid_boxes then
    fluid_boxes[1].pipe_connections[1].position[2] = -3.0
    fluid_boxes[2].pipe_connections[1].position[2] =  3.0
  end
end
