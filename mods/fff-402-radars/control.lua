local mod_prefix = 'fff-402-radars-'

local function is_radar_supported(entity)
  local selection_box = entity.prototype.selection_box

  -- only support 3x3 radars, those are likely recolors of the original radar and thus the circuit connector sprite is assumed to fit them
  return selection_box.left_top.x == -1.5 and selection_box.left_top.y == -1.5 and selection_box.right_bottom.x == 1.5 and selection_box.right_bottom.y == 1.5 
end

local function on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  local surface = entity.surface

  if not is_radar_supported(entity) then return end

  local surfacedata = global.surfacedata[surface.index]
  if surfacedata.relay ~= nil and surfacedata.relay.valid == false then
    error("the surface's radar circuit relay got invalidated, what happened?")
  end

  if surfacedata.relay == nil or surfacedata.relay.valid == false then
    surfacedata.relay = surface.create_entity{
      name = mod_prefix .. 'circuit-relay',
      force = entity.force,
      position = surface.find_non_colliding_position(mod_prefix .. 'circuit-relay', {0, 0}, 0, 1, true),
    }
  end

  local circuit_connector = surface.find_entity(mod_prefix .. 'circuit-connector', entity.position)
  if circuit_connector == nil then
    local entity_ghosts = surface.find_entities_filtered{
      ghost_name = mod_prefix .. 'circuit-connector',
      position = entity.position,
      limit = 1
    }

    if entity_ghosts[1] then
      local _, entity = entity_ghosts[1].revive({})
      if entity then circuit_connector = entity end
    end
  end
  if circuit_connector == nil then
    circuit_connector = surface.create_entity{
      name = mod_prefix .. 'circuit-connector',
      force = entity.force,
      position = entity.position,
    }

    circuit_connector.destructible = false

    circuit_connector.connect_neighbour({
      target_entity = surfacedata.relay,
      wire = defines.wire_type.red,
    })
    circuit_connector.connect_neighbour({
      target_entity = surfacedata.relay,
      wire = defines.wire_type.green,
    })
  end

  local registration_number = script.register_on_entity_destroyed(entity)

  global.surfacedata[surface.index].structs[entity.unit_number] = {
    unit_number = entity.unit_number,
    entity = entity,

    circuit_connector = circuit_connector,
  }

  global.deathrattles[registration_number] = {circuit_connector}
  global.owned_by_deathrattle[circuit_connector.unit_number] = registration_number
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, on_created_entity, {
    {filter = 'type', type = 'radar'},
  })
end

local function on_surface_created(event)
  assert(global.surfacedata[event.surface_index] == nil)
  global.surfacedata[event.surface_index] = {
    structs = {},
  }
end

local function on_surface_deleted(event)
  assert(global.surfacedata[event.surface_index] ~= nil)
  global.surfacedata[event.surface_index] = nil
end

script.on_event(defines.events.on_surface_created, on_surface_created)
script.on_event(defines.events.on_surface_deleted, on_surface_deleted)

local function on_dolly_moved_entity(event)
  local struct = global.surfacedata[event.moved_entity.surface.index].structs[event.moved_entity.unit_number]
  if struct == nil then return end

  struct.circuit_connector.teleport(event.moved_entity.position)
end

local function register_events()
  if remote.interfaces["PickerDollies"] and remote.interfaces["PickerDollies"]["dolly_moved_entity_id"] then
    script.on_event(remote.call("PickerDollies", "dolly_moved_entity_id"), on_dolly_moved_entity)
  end

  if remote.interfaces["PickerDollies"] and remote.interfaces["PickerDollies"]["add_blacklist_name"] then
    remote.call("PickerDollies", "add_blacklist_name", mod_prefix .. 'circuit-connector')
  end
end

local function on_init(event)
  global.surfacedata = {}
  global.deathrattles = {}
  global.owned_by_deathrattle = {}

  for _, surface in pairs(game.surfaces) do
    on_surface_created({surface_index = surface.index})
    for _, entity in pairs(surface.find_entities_filtered{type = 'radar'}) do
      on_created_entity({entity = entity})
    end
  end

  register_events()
end

script.on_init(on_init)
script.on_load(register_events)

script.on_event(defines.events.on_entity_destroyed, function(event)
  local deathrattle = global.deathrattles[event.registration_number]
  if deathrattle then global.deathrattles[event.registration_number] = nil
    for _, entity in ipairs(deathrattle) do
      if global.owned_by_deathrattle[entity.unit_number] == event.registration_number then
        entity.destroy()
      end
    end
  end
end)

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
  local player = game.get_player(event.player_index)
  -- game.print(event.tick)

  if player.cursor_stack and player.cursor_stack.valid_for_read and player.cursor_stack.name == mod_prefix .. 'circuit-connector' then
    if player.selected and player.selected.name == mod_prefix .. 'circuit-connector' then
      local radars = player.surface.find_entities_filtered{type = 'radar', position = player.selected.position}
      for _, radar in ipairs(radars) do
        if is_radar_supported(radar) then
          player.pipette_entity(radar)
          return
        end
      end
    end
    
    player.cursor_stack.clear()
  end

  if player.cursor_ghost and player.cursor_ghost.name == mod_prefix .. 'circuit-connector' then
    if player.selected and player.selected.name == mod_prefix .. 'circuit-connector' then
      local radars = player.surface.find_entities_filtered{type = 'radar', position = player.selected.position}
      for _, radar in ipairs(radars) do
        if is_radar_supported(radar) then
          player.cursor_ghost = radar.name
          return
        end
      end
    end

    player.cursor_ghost = nil
  end
end)
