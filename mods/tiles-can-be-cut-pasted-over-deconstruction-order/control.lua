local function get_key(surface_index, position)
  return 's' .. surface_index .. 'x' .. math.floor(position.x) .. 'y' .. math.floor(position.y)
end

local function on_tile_marked_for_deconstruction(proxy)
  local key = get_key(proxy.surface.index, proxy.position)

  global.deathrattles[script.register_on_entity_destroyed(proxy)] = key
  global.key_to_proxy[key] = proxy
end

script.on_init(function()
  global.deathrattles = {} -- entity pointing to key
  global.key_to_proxy = {} -- key pointing to entity

  global.skip_player_this_tick = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({type = 'deconstructible-tile-proxy'})) do
      on_tile_marked_for_deconstruction(entity)
    end
  end
end)

script.on_event(defines.events.on_marked_for_deconstruction, function(event)
  on_tile_marked_for_deconstruction(event.entity)
end, {
  {filter = 'type', type = 'deconstructible-tile-proxy'},
})

local function on_tick(event)
  global.skip_player_this_tick = {}
  script.on_event(defines.events.on_tick, nil)
end

script.on_event(defines.events.on_built_entity, function(event)
  if global.skip_player_this_tick[event.player_index] then return end
  global.skip_player_this_tick[event.player_index] = true
  script.on_event(defines.events.on_tick, on_tick)

  if event.stack.valid_for_read == false then return end -- stuff like undo

  log(event.stack.name)
  if event.stack.name ~= 'blueprint' then return end
  local tiles = event.stack.get_blueprint_tiles()
  assert(tiles) -- since we're listening for tile ghosts this cannot possibly be nil right?

  local surface = event.created_entity.surface
  local surface_index = surface.index

  for _, tile in ipairs(tiles) do
    if global.key_to_proxy[get_key(surface_index, tile.position)] then
      if tile.name == surface.get_tile(tile.position.x, tile.position.y).name then
        surface.find_entity('deconstructible-tile-proxy', {tile.position.x + 0.5, tile.position.y + 0.5}).destroy()
      end
    end
  end
end, {
  {filter = 'type', type = 'tile-ghost'},
})

script.on_load(function()
  if table_size(global.skip_player_this_tick) > 0 then
    script.on_event(defines.events.on_tick, on_tick)
  end
end)

script.on_event(defines.events.on_entity_destroyed, function(event)
  local deathrattle = global.deathrattles[event.registration_number]
  if deathrattle then global.deathrattles[event.registration_number] = nil
    global.key_to_proxy[deathrattle] = nil
  end
end)

local function on_player_maybe_placed_blueprint(event)
  local player = game.get_player(event.player_index)
  assert(player)

  local blueprint = player.cursor_stack
  if blueprint == nil then return end
  if blueprint.is_blueprint == false then return end

  -- local old_blueprint_snap_to_grid = blueprint.blueprint_snap_to_grid
  -- blueprint.blueprint_snap_to_grid = {0, 0}
  -- log(blueprint.export_stack())
  -- blueprint.blueprint_snap_to_grid = old_blueprint_snap_to_grid

  game.print(serpent.line(event.cursor_position))
  game.print(math.floor(event.cursor_position.x))
  game.print(math.floor(event.cursor_position.y))
end

script.on_event('tcbcpodo-build', on_player_maybe_placed_blueprint)
script.on_event('tcbcpodo-build-ghost', on_player_maybe_placed_blueprint)
