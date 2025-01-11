require("util")

local Handler = {}

local function refresh_surfacedata()
  -- deleted old
  for surface_index, surfacedata in pairs(storage.surfacedata) do
    if surfacedata.surface.valid == false then
      storage.surfacedata[surface_index] = nil
    end
  end

  -- created new
  for _, surface in pairs(game.surfaces) do
    storage.surfacedata[surface.index] = storage.surfacedata[surface.index] or {
      surface = surface,
      tiles = {},
      interfaces = {},
      tile_to_network = {},
      next_network_id = 0,
    }
  end
end

script.on_init(function()
  storage.surface = game.planets["undersea-data-cable"].create_surface()
  storage.surface.generate_with_lab_tiles = true

  storage.surfacedata = {}
  refresh_surfacedata()

  storage.active_surface_index = 1 -- nauvis 

  storage.deathrattles = {}

  storage.refresh_next_on_tick = {}
end)

script.on_configuration_changed(function()
  refresh_surfacedata()
end)

script.on_event(defines.events.on_surface_created, refresh_surfacedata)
script.on_event(defines.events.on_surface_deleted, refresh_surfacedata)

local function disconnect_from_other_interfaces(interface)
  for _, color in ipairs({"red", "green"}) do
    local wire_connector = interface[color]
    for _, connection in ipairs(wire_connector.real_connections) do
      if connection.target.owner.name == "undersea-data-cable-interface" then
        wire_connector.disconnect_from(connection.target, connection.origin)
      end
    end
  end
end

function Handler.set_backer_name_to(entity, network_id)
  entity.backer_name = string.format("[font=default-tiny-bold]network %s[/font]", tostring(network_id))
end

-- i suppose if the surface got deleted within 0-1 ticks this could crash,
-- but i am kinda curious to see if i'll ever get any crash reports for that.
function Handler.recalculate_networks_now(surfacedata)
  surfacedata.tile_to_network = {}
  surfacedata.next_network_id = 0

  local network_id_to_interface = {}

  for _, interface in pairs(surfacedata.interfaces) do
    disconnect_from_other_interfaces(interface)
    local network_here = surfacedata.tile_to_network[interface.position_str]
    if network_here then
      Handler.set_backer_name_to(interface.entity, network_here)
      interface.red.connect_to(network_id_to_interface[network_here].red, false, defines.wire_origin.script)
      interface.green.connect_to(network_id_to_interface[network_here].green, false, defines.wire_origin.script)
    else
      surfacedata.next_network_id = surfacedata.next_network_id + 1
      local tile_positions = storage.surface.get_connected_tiles(interface.entity.position, {"concrete"}, false)
      for _, tile_position in ipairs(tile_positions) do
        surfacedata.tile_to_network[util.positiontostr(tile_position)] = surfacedata.next_network_id
      end
      Handler.set_backer_name_to(interface.entity, surfacedata.next_network_id)
      network_id_to_interface[surfacedata.next_network_id] = interface
    end
  end
end

function Handler.recalculate_networks(surfacedata)
  if not next(storage.refresh_next_on_tick) then
    script.on_event(defines.events.on_tick, Handler.on_tick)
  end

  storage.refresh_next_on_tick[surfacedata.surface.index] = true
end

function Handler.get_lab_tile_name(position)
  return (position.x + position.y) % 2 == 0 and "lab-dark-1" or "lab-dark-2"
end

function Handler.get_set_tiles_tiles(surfacedata, to_concrete)
  local tiles = {}

  for _, position in pairs(surfacedata.tiles) do
    table.insert(tiles, {position = position, name = to_concrete and "concrete" or Handler.get_lab_tile_name(position)})
  end

  return tiles
end

function Handler.undo_tiles(surfacedata)
  assert(storage.active_surface_index ~= nil, "storage.active_surface_index is already nil.")
  storage.active_surface_index = nil

  storage.surface.set_tiles(Handler.get_set_tiles_tiles(surfacedata, false), false, false, false)
end

function Handler.redo_tiles(surfacedata)
  storage.active_surface_index = surfacedata.surface.index

  storage.surface.set_tiles(Handler.get_set_tiles_tiles(surfacedata, true), false, false, false)
end

local function new_struct(table, struct)
  assert(struct.id, serpent.block(struct))
  assert(table[struct.id] == nil)
  table[struct.id] = struct
  return struct
end

function Handler.surfacedata_add_tile(surfacedata, tile_position)
  surfacedata.tiles[util.positiontostr(tile_position)] = tile_position

  if surfacedata.surface.index == storage.active_surface_index then
    storage.surface.set_tiles({{position = tile_position, name = "concrete"}}, false, false, false)
  end
end

function Handler.surfacedata_sub_tile(surfacedata, tile_position)
  surfacedata.tiles[util.positiontostr(tile_position)] = nil

  if surfacedata.surface.index == storage.active_surface_index then
    storage.surface.set_tiles({{position = tile_position, name = Handler.get_lab_tile_name(tile_position)}}, false, false, false)
  end
end

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  local position = {x = math.floor(entity.position.x), y = math.floor(entity.position.y)}
  local position_str = util.positiontostr(position)

  local surfacedata = storage.surfacedata[entity.surface_index]

  if entity.surface_index ~= storage.active_surface_index then
    -- game.print(string.format("[undersea-data-cable] switching active surface from %d to %d.", storage.active_surface_index, entity.surface_index))
    Handler.undo_tiles(storage.surfacedata[storage.active_surface_index]) -- todo: what if the active surface got deleted?
    Handler.redo_tiles(surfacedata)
  end

  -- if a player visits the hidden surface then the chunks start actually generating, and overriding any already set tiles,
  -- so we request that chunk to generate and then force the game or the current set tile is very likely to get overwritten.
  storage.surface.request_to_generate_chunks(position, 0)
  storage.surface.force_generate_chunk_requests()

  Handler.surfacedata_add_tile(surfacedata, position)

  -- storage.surface.set_tiles{
  --   tiles = {
  --     {position = entity.position, name = "concrete"},
  --   },
  --   correct_tiles = false,
  --   remove_colliding_entities = false,
  --   remove_colliding_decoratives = false,
  -- }

  if entity.name == "undersea-data-cable-interface" then
    local heat_pipe = entity.surface.create_entity{
      name = "undersea-data-cable",
      force = entity.force,
      position = entity.position,
      quality = entity.quality, -- why would you even build a quality interface?
    }
    heat_pipe.destructible = false -- the pipe under the interface we control by script

    Handler.set_backer_name_to(entity, "?")
    surfacedata.interfaces[entity.unit_number] = {
      entity = entity,
      red = entity.get_wire_connector(defines.wire_connector_id.circuit_red, true),
      green = entity.get_wire_connector(defines.wire_connector_id.circuit_green, true),
      position_str = position_str,
    }
  end

  new_struct(storage.deathrattles, {
    id = script.register_on_object_destroyed(entity),
    type = entity.name,
    surface_index = entity.surface.index,
    position = entity.position,
  })

  Handler.recalculate_networks(surfacedata)
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = "name", name = "undersea-data-cable"},
    {filter = "name", name = "undersea-data-cable-interface"},
  })
end

script.on_event(defines.events.on_player_setup_blueprint, function(event)
  if event.stack == nil then return end

  local blueprint_entities = event.stack.get_blueprint_entities()
  if blueprint_entities == nil then return end

  local remove_this_heat_pipe = {}

  for _, blueprint_entity in ipairs(blueprint_entities) do
    if blueprint_entity.name == "undersea-data-cable-interface" then
      remove_this_heat_pipe[util.positiontostr(blueprint_entity.position)] = true
    end
  end

  for i, blueprint_entity in ipairs(blueprint_entities) do
    if blueprint_entity.name == "undersea-data-cable" then
      if remove_this_heat_pipe[util.positiontostr(blueprint_entity.position)] then
        blueprint_entities[i] = nil
      end
    end
  end

  event.stack.set_blueprint_entities(blueprint_entities)
end)

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil

    if deathrattle.type == "undersea-data-cable" then
      local surfacedata = storage.surfacedata[deathrattle.surface_index]
      if surfacedata == nil then return end
      Handler.surfacedata_sub_tile(surfacedata, deathrattle.position)
      Handler.recalculate_networks(surfacedata)
    elseif deathrattle.type == "undersea-data-cable-interface" then
      local surfacedata = storage.surfacedata[deathrattle.surface_index]
      if surfacedata == nil then return end
      surfacedata.interfaces[event.useful_id] = nil
      local immortal_snail = surfacedata.surface.find_entity("undersea-data-cable", deathrattle.position)
      if immortal_snail then immortal_snail.destroy() end
      Handler.surfacedata_sub_tile(surfacedata, deathrattle.position)
      Handler.recalculate_networks(surfacedata)
    else
      error(serpent.block(deathrattle))
    end

  end
end)

function Handler.on_tick(event)
  for surface_index, _ in pairs(storage.refresh_next_on_tick) do
    Handler.recalculate_networks_now(storage.surfacedata[surface_index])
  end

  storage.refresh_next_on_tick = {}
  script.on_event(defines.events.on_tick, nil)
end

script.on_load(function()
  if next(storage.refresh_next_on_tick) then
    script.on_event(defines.events.on_tick, Handler.on_tick)
  end
end)
