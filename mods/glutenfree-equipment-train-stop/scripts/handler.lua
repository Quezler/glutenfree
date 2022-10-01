local mod_prefix = 'glutenfree-equipment-train-stop-'

--

local handler = {}

function handler.init()
  global.landmines = {}

  global.entries = {}

  global.tripwires_to_replace = {}
end

function handler.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  if entity.name ~= 'train-stop' then return end

  handler.register_train_stop(entity)
end

function handler.register_train_stop(entity)
  -- game.print(serpent.line(entity.position))

  -- entity.connected_rail sometimes nil polyfill
  local connected_rail_position = entity.position
  if entity.direction == defines.direction.north then
    connected_rail_position.x = connected_rail_position.x - 2
  elseif entity.direction == defines.direction.east then
    connected_rail_position.y = connected_rail_position.y - 2
  elseif entity.direction == defines.direction.south then
    connected_rail_position.x = connected_rail_position.x + 2
  elseif entity.direction == defines.direction.west then
    connected_rail_position.y = connected_rail_position.y + 2
  end

  global.entries[entity.unit_number] = {
    train_stop = entity,
    unit_number = entity.unit_number,
    connected_rail_position = connected_rail_position,
  }

  global.tripwires_to_replace[entity.unit_number] = true
end

function handler.replace_tripwire(entity) -- station
  local entry = global.entries[entity.unit_number]

  local landmine = entity.surface.create_entity({
    name = mod_prefix .. 'tripwire',
    force = 'neutral',
    position = entry.connected_rail_position,
  })

  global.landmines[script.register_on_entity_destroyed(landmine)] = entity.unit_number
end

-- handle tripped tripwires
function handler.on_entity_destroyed(event)
  local unit_number = global.landmines[event.registration_number]
  if not unit_number then return end

  global.landmines[event.registration_number] = nil

  local entry = global.entries[unit_number]
  if not entry then return end

  -- search center of tripwire + bounding box (.4) + safety margin (.1) 
  local entities = game.get_surface('nauvis').find_entities_filtered({
    area = {
    {entry.connected_rail_position.x - 0.5, entry.connected_rail_position.y - 0.5},
    {entry.connected_rail_position.x + 0.5, entry.connected_rail_position.y + 0.5},
    },
    type = {'locomotive', 'cargo-wagon', 'fluid-wagon', 'artillery-wagon'} -- all rolling stock
  })

  -- try to update any cairage present
  for _, entity in ipairs(entities) do
    game.print(_ .. ' ' .. entity.name)
  end

  global.tripwires_to_replace[entry.unit_number] = true
end

-- try to replace the tripwire each tick until it is able (aka: the cairage having passed)
function handler.on_tick()
  for unit_number, _ in pairs(global.tripwires_to_replace) do
    global.tripwires_to_replace[unit_number] = nil

    local entry = global.entries[unit_number]
    if entry then

      local can_place_entity = entry.train_stop.surface.can_place_entity({
        name = mod_prefix .. 'tripwire',
        position = entry.connected_rail_position,
        force = 'neutral',
      })

      if can_place_entity then
        handler.replace_tripwire(entry.train_stop)
      else
        global.tripwires_to_replace[unit_number] = true -- try again next tick
      end

    end
  end
end

return handler
