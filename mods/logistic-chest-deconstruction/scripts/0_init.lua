function Handler.on_init()
  global.surfaces = {}
  for _, surface in pairs(game.surfaces) do
    Handler.on_surface_created({surface_index = surface.index})
  end

  global.construction_robots = {}
  global.robots_to_check_at_tick = {}

  Handler.on_configuration_changed()

  global.deathrattles = {}
end

function Handler.on_configuration_changed()
  global.storage_chest_names = {}
  global.aimation_offset_for = {}

  -- {"", {"logistic-chest-storage", "7"}} -- vanilla
  -- {"", {"logistic-chest-storage", "8"}, {"aai-strongbox-storage", "8"}, {"aai-storehouse-storage", "8"}, {"aai-warehouse-storage", "8"}} -- aai containers
  for _, pair in pairs(game.equipment_grid_prototypes["logistic-chest-deconstruction-equipment-grid"].localised_description) do
    if type(pair) == "table" then
      global.storage_chest_names[pair[1]] = pair[1]
      global.aimation_offset_for[pair[1]] = tonumber(pair[2])
    end
  end

  global.robot_prototype_for = {}
  for _, robot in pairs(game.get_filtered_entity_prototypes{{filter="type", type = "construction-robot"}}) do
    global.robot_prototype_for[robot.name] = {
      max_speed = robot.max_speed,
      speed = robot.speed,
      speed_multiplier_when_out_of_energy = robot.speed_multiplier_when_out_of_energy,
    }
  end
end
