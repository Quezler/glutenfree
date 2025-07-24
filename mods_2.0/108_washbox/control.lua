require("shared")

local mod = {}

script.on_init(function()
  storage.surfacedata = {}
  mod.refresh_surfacedata()

  for _, surface in pairs(game.surfaces) do
    local surfacedata = storage.surfacedata[surface.index]
    for _, entity in ipairs(surface.find_entities_filtered{{filter = "type", type = {"pump", "offshore-pump"}}}) do
      surfacedata.pumps[entity.unit_number] = entity
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

  if entity.type == "pump" or entity.type == "offshore-pump" then
    surfacedata.pumps[entity.unit_number] = entity
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
    -- id to amount pumped, negative for out
  }
  local surfacedata = storage.surfacedata[surface_index]

  for unit_number, pump in pairs(surfacedata.pumps) do
    if not pump.valid then
      surfacedata.pumps[unit_number] = nil
    else
      local pumped_last_tick = pump.pumped_last_tick
      for _, pipe_connection in ipairs(pump.fluidbox.get_pipe_connections(1)) do
        if pipe_connection.target then

          local fluid_segment_id = pipe_connection.target.get_fluid_segment_id(pipe_connection.target_fluidbox_index)
          if fluid_segment_id then
            if pipe_connection.flow_direction == "output" then
              surface_fluid_segment_map[fluid_segment_id] = (surface_fluid_segment_map[fluid_segment_id] or 0) + pumped_last_tick
            else -- input & input-output
              surface_fluid_segment_map[fluid_segment_id] = (surface_fluid_segment_map[fluid_segment_id] or 0) - pumped_last_tick
            end
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

  -- to only measure the input side we need to split the segments
  for _, struct in pairs(storage.structs) do
    if struct.entity.valid then
      struct.entity.fluidbox.remove_linked_connection(1)
      struct.entity.fluidbox.remove_linked_connection(2)
    end
  end

  for _, struct in pairs(storage.structs) do
    if struct.entity.valid then

      if not fluid_segment_map[struct.entity.surface_index] then
        populate_fluid_segment_map(fluid_segment_map, struct.entity.surface_index)
      end

      local total_pumping_speed = fluid_segment_map[struct.entity.surface_index][struct.entity.fluidbox.get_fluid_segment_id(1)] or 0
      log(total_pumping_speed)
    end
  end

  -- measurements done, now we can merge the fluid segments again
  for _, struct in pairs(storage.structs) do
    if struct.entity.valid then
      struct.entity.fluidbox.add_linked_connection(1, struct.pipe, 1)
      struct.entity.fluidbox.add_linked_connection(2, struct.pipe, 2)
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
      structs = {},
    }
  end
end

script.on_event(defines.events.on_surface_created, mod.refresh_surfacedata)
script.on_event(defines.events.on_surface_deleted, mod.refresh_surfacedata)
