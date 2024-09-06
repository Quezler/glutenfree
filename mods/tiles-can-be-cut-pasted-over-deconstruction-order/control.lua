local ignore_player_this_tick = {}

script.on_event(defines.events.on_built_entity, function(event)
  local entity = event.created_entity
  assert(entity.tags.tile_name)

  local surface = entity.surface
  local tile = surface.get_tile(entity.position.x - 0.5, entity.position.y - 0.5)

  local ghost = surface.find_entity('tile-ghost', entity.position)
  if tile.name == entity.tags.tile_name then
    local proxy = surface.find_entity('deconstructible-tile-proxy', entity.position)
    if proxy then proxy.destroy() end
    if ghost then ghost.destroy() end
  elseif ghost then
    ghost.destroy()
    surface.create_entity{
      name = 'tile-ghost',
      force = entity.force,
      position = entity.position,
      inner_name = entity.tags.tile_name,
    }
  end

  entity.destroy()

  -- this should remove the mayflies without desyncing even though its not stored in global, since it all happens in the same tick
  if ignore_player_this_tick[event.player_index] and ignore_player_this_tick[event.player_index] == event.tick then return end
  ignore_player_this_tick[event.player_index] = event.tick

  local blueprint = event.stack
  local blueprint_entities = assert(blueprint.get_blueprint_entities())
  for i = #blueprint_entities, 1, -1 do
    if blueprint_entities[i].name == 'tcbcpodo-mayfly' then
      table.remove(blueprint_entities, i)
    end
  end
  blueprint.set_blueprint_entities(blueprint_entities)
end, {
  {filter = 'ghost_name', name = 'tcbcpodo-mayfly'},
})

local function on_player_maybe_placed_blueprint(event)
  local player = game.get_player(event.player_index)
  assert(player)

  local blueprint = player.cursor_stack
  if blueprint == nil then return end
  if blueprint.is_blueprint == false then return end

  local tiles = blueprint.get_blueprint_tiles()
  if tiles == nil then return end

  local blueprint_entities = blueprint.get_blueprint_entities() or {}

  for _, blueprint_entity in ipairs(blueprint_entities) do
    if blueprint_entity.name == 'tcbcpodo-mayfly' then
      return -- already has mayflies
    end
  end

  for _, tile in ipairs(tiles) do
    table.insert(blueprint_entities, {
      entity_number = #blueprint_entities + 1,
      name = 'tcbcpodo-mayfly',
      position = {tile.position.x + 0.5, tile.position.y + 0.5},
      tags = {tile_name = tile.name},
    })
  end

  blueprint.set_blueprint_entities(blueprint_entities)
end

-- for some reason blueprints from the library do not trigger
script.on_event('tcbcpodo-build', on_player_maybe_placed_blueprint)
script.on_event('tcbcpodo-build-ghost', on_player_maybe_placed_blueprint)
