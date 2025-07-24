require("shared")

local mod = {}

script.on_init(function()
  storage.surfacedata = {}
  mod.refresh_surfacedata()

  for _, surface in pairs(game.surfaces) do
    local surfacedata = storage.surfacedata[surface.index]
    for _, entity in ipairs(surface.find_entities_filtered{{filter = "type", type = "pump"}}) do
      surfacedata.pumps[entity.unit_number] = entity
    end
    for _, entity in ipairs(surface.find_entities_filtered{{filter = "type", type = "offshore-pump"}}) do
      surfacedata.offshore_pumps[entity.unit_number] = entity
    end
  end

  storage.structs = {}
  storage.deathrattles = {}
end)

script.on_configuration_changed(function()
  assert(storage.surfacedata == nil, "not compatible with washbox <= 2.0.0, remove the previous version first.")

  mod.refresh_surfacedata()
end)

mod.on_created_entity = function(event)
  local entity = event.entity or event.destination
  local surfacedata = storage.surfacedata[entity.surface.index]

  if entity.type == "pump" then
    surfacedata.pumps[entity.unit_number] = entity
    return
  elseif entity.type == "offshore-pump" then
    surfacedata.offshore_pumps[entity.unit_number] = entity
    return
  end

  local pipe = entity.surface.create_entity{
    name = mod_prefix .. "pipe",
    position = entity.position,
    force = entity.force,
  }
  pipe.destructible = false

  entity.fluidbox.add_linked_connection(1, pipe, 1)
  entity.fluidbox.add_linked_connection(2, pipe, 2)

  local beacon = entity.surface.create_entity{
    name = mod_prefix .. "beacon-interface",
    force = entity.force,
    position = entity.position,
    raise_built = true,
  }
  beacon.destructible = false

  remote.call("beacon-interface", "set_effects", beacon.unit_number, {
    speed = -50,
    productivity = 0,
    consumption = 0,
    pollution = 0,
    quality = 0,
  })

  local beacon_overload = entity.surface.create_entity{
    name = mod_prefix .. "beacon-interface-overload",
    force = entity.force,
    position = entity.position,
    raise_built = true,
  }

  beacon_overload.destructible = false
  remote.call("beacon-interface", "set_effects", beacon_overload.unit_number, {
    speed = -10000,
    productivity = 0,
    consumption = 0,
    pollution = 0,
    quality = 0,
  })

  -- surfacedata.structs[entity.unit_number] = {
  storage.structs[entity.unit_number] = {
    entity = entity,
    pipe = pipe,
    beacon = beacon,
    beacon_overload = beacon_overload,
  }

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {surface_index = surfacedata.index}
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, mod.on_created_entity, {
    {filter = "name", name = "washbox"},
    {filter = "type", type = "pump"},
    {filter = "type", type = "offshore-pump"},
  })
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    -- local surfacedata = storage.surfacedata[deathrattle.surface_index]
    -- if surfacedata then
    --   local struct = surfacedata.structs[event.useful_id]
    --   if struct then surfacedata.structs[event.useful_id] = nil
      local struct = storage.structs[event.useful_id]
      if struct then storage.structs[event.useful_id] = nil
        if struct.pipe then struct.pipe.destroy() end
        if struct.beacon then struct.beacon.destroy() end
        if struct.beacon_overload then struct.beacon_overload.destroy() end
      end
    -- end
  end
end)

local function populate_fluid_segment_map(fluid_segment_map, surface_index)
  surface_fluid_segment_map = {
    ["input-output"] = {}, -- unused
    output = {}, -- outputs into
    input = {},
  }
  local surfacedata = storage.surfacedata[surface_index]

  for unit_number, pump in pairs(surfacedata.pumps) do
    if not pump.valid then
      surfacedata.pumps[unit_number] = nil
    else
      for _, pipe_connection in ipairs(pump.fluidbox.get_pipe_connections(1)) do
        if pipe_connection.target then

          local fluid_segment_id = pipe_connection.target.get_fluid_segment_id(pipe_connection.target_fluidbox_index)
          if fluid_segment_id then
            local flow_direction_map = surface_fluid_segment_map[pipe_connection.flow_direction]
            flow_direction_map[fluid_segment_id] = flow_direction_map[fluid_segment_id] or {}
            table.insert(flow_direction_map[fluid_segment_id], pump)
          end

          -- log(pipe_connection.target.get_fluid_segment_id(pipe_connection.target_fluidbox_index))
          -- log(serpent.line(pipe_connection))
        end

        -- if pipe_connection.flow_direction == "output" then

        -- end
      end
    end
  end

  for unit_number, offshore_pump in pairs(surfacedata.offshore_pumps) do
    if not offshore_pump.valid then
      surfacedata.pumps[unit_number] = nil
    else
      for _, pipe_connection in ipairs(offshore_pump.fluidbox.get_pipe_connections(1)) do
        if pipe_connection.target then

          local fluid_segment_id = pipe_connection.target.get_fluid_segment_id(pipe_connection.target_fluidbox_index)
          if fluid_segment_id then
            local flow_direction_map = surface_fluid_segment_map[pipe_connection.flow_direction]
            flow_direction_map[fluid_segment_id] = flow_direction_map[fluid_segment_id] or {}
            table.insert(flow_direction_map[fluid_segment_id], offshore_pump)
          end

        end
      end
    end
  end

  log(serpent.line(surface_fluid_segment_map))
  fluid_segment_map[surface_index] = surface_fluid_segment_map
end

script.on_nth_tick(60 * 2.5, function()
  local fluid_segment_map = {}
  for _, struct in pairs(storage.structs) do
    if struct.entity.valid then

      if not fluid_segment_map[struct.entity.surface_index] then
        populate_fluid_segment_map(fluid_segment_map, struct.entity.surface_index)
      end

      local total_pumping_speed = 0
      -- log(serpent.line(fluid_segment_map[struct.entity.surface_index].output))
      for _, a_pump in ipairs(fluid_segment_map[struct.entity.surface_index].output[struct.pipe.fluidbox.get_fluid_segment_id(1)] or {}) do
        total_pumping_speed = total_pumping_speed + a_pump.pumped_last_tick
      end
      log(total_pumping_speed)
    end
  end
end)

function mod.refresh_surfacedata()
  -- deleted old
  for surface_index, surfacedata in pairs(storage.surfacedata) do
    if not surfacedata.surface.valid then
      storage.surfacedata[surface_index] = nil
    end
  end

  -- created new
  for _, surface in pairs(game.surfaces) do
    storage.surfacedata[surface.index] = storage.surfacedata[surface.index] or {
      index = surface.index,
      surface = surface,

      pumps = {},
      offshore_pumps = {},

      structs = {},
    }
  end
end

script.on_event(defines.events.on_surface_created, mod.refresh_surfacedata)
script.on_event(defines.events.on_surface_deleted, mod.refresh_surfacedata)
