script.on_init(function()
  global.deathrattles = {} -- entity pointing to key
  global.key_to_proxy = {} -- key pointing to entity
end)

local function get_key(surface_index, position)
  return 's' .. surface_index .. 'x' .. math.floor(position.x) .. 'y' .. math.floor(position.y)
end

script.on_event(defines.events.on_marked_for_deconstruction, function(event)
  log('sen')
  local entity = event.entity
  local key = get_key(entity.surface.index, entity.position)

  global.deathrattles[script.register_on_entity_destroyed(entity)] = key
  global.key_to_proxy[key] = entity
  log(key)
end, {
  {filter = 'type', type = 'deconstructible-tile-proxy'},
})

script.on_event(defines.events.on_player_mined_tile, function(event)
  log('foo')
  for _, tile in ipairs(event.tiles) do
    local key = get_key(event.surface_index, tile.position)
    log(key)
    local proxy = global.key_to_proxy[key]
    if proxy then proxy.destroy() end
  end
end)

script.on_event(defines.events.on_entity_destroyed, function(event)
  log('pai')
  local deathrattle = global.deathrattles[event.registration_number]
  if deathrattle then global.deathrattles[event.registration_number] = nil
    log('bai')
    global.key_to_proxy[deathrattle] = nil
  end
end)
