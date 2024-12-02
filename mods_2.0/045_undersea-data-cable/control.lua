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
    }
  end
end

script.on_init(function()
  storage.surfacedata = {}
  refresh_surfacedata()

  storage.surface = game.planets["undersea-data-cable"].create_surface()
  storage.surface.generate_with_lab_tiles = true

  storage.active_surface_index = 1 -- nauvis 
end)

script.on_configuration_changed(function()
  refresh_surfacedata()
end)

script.on_event(defines.events.on_surface_created, refresh_surfacedata)
script.on_event(defines.events.on_surface_deleted, refresh_surfacedata)

-- technically an ungenerated world only has "out-of-map" tiles, lab tiles only start existing when a player visits
-- function Handler.get_lab_tile_name(position)
--   return (position.x + position.y) % 2 == 0 and "lab-dark-1" or "lab-dark-2"
-- end

function Handler.get_set_tiles_tiles(surfacedata, to_concrete)
  local tiles = {}

  for _, position in pairs(surfacedata.tiles) do
    table.insert(tiles, {position = position, name = to_concrete and "concrete" or "out-of-map"})
  end

  return tiles
end

function Handler.undo_tiles(surfacedata)
  assert(storage.active_surface_index ~= nil, "storage.active_surface_index is already nil.")
  storage.active_surface_index = nil

  storage.surface.set_tiles(
    Handler.get_set_tiles_tiles(surfacedata, false),
    false,
    false,
    false
  )
end

function Handler.redo_tiles(surfacedata)
  storage.active_surface_index = surfacedata.surface.index

  storage.surface.set_tiles(
    Handler.get_set_tiles_tiles(surfacedata, true),
    false,
    false,
    false
  )
end

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  local position = {x = math.floor(entity.position.x), y = math.floor(entity.position.y)}
  local position_str = util.positiontostr(position)

  local surfacedata = storage.surfacedata[entity.surface_index]
  surfacedata.tiles[position_str] = position

  if entity.surface_index ~= storage.active_surface_index then
    game.print(string.format("[undersea-data-cable] switching active surface from %d to %d.", storage.active_surface_index, entity.surface_index))
    Handler.undo_tiles(storage.surfacedata[storage.active_surface_index]) -- todo: what if the active surface got deleted?
    Handler.redo_tiles(surfacedata)
  end

  -- if a player visits the hidden surface then the chunks start actually generating, and overriding any already set tiles,
  -- so we request that chunk to generate and then force the game or the current set tile is very likely to get overwritten.
  -- storage.surface.request_to_generate_chunks(position, 0)
  -- storage.surface.force_generate_chunk_requests()

  -- game.print(event.tick)

  -- storage.surface.set_tiles{
  --   tiles = {
  --     {position = entity.position, name = "concrete"},
  --   },
  --   correct_tiles = false,
  --   remove_colliding_entities = false,
  --   remove_colliding_decoratives = false,
  -- }

  -- game.print(storage.surface.get_tile(position).name)
  storage.surface.set_tiles(
    {
      {position = position, name = "concrete"},
    },
    false,
    false,
    false
  )
  -- game.print(storage.surface.get_tile(position).name)
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
  })
end


script.on_event(defines.events.on_player_changed_surface, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  if player.surface.index == storage.surface.index then
    game.print("[undersea-data-cable] you just broke the mod by visiting the hidden surface, load an autosave.")
  end
end)

if debug_mode then
  commands.add_command("undersea-undo", nil, function(command)
    local player = game.get_player(command.player_index) --[[@as LuaPlayer]]
    Handler.undo_tiles(storage.surfacedata[player.surface.index])
  end)

  commands.add_command("undersea-redo", nil, function(command)
    local player = game.get_player(command.player_index) --[[@as LuaPlayer]]
    if player.surface.index == storage.surface.index then
      Handler.redo_tiles(storage.surfacedata[storage.active_surface_index])
    end
  end)
end
