local mod_prefix = 'glutenfree-circuit-network-events-'

--

script.on_init(function()
  global.school = {} -- of fish

  global.deathrattles = {}

  global.spiral_index = 0
  global.spiral_empty = {}
end)

--

local surface_name = 'glutenfree-circuit-network-events-v1'
function surface()
  if game.surfaces[surface_name] then
    return game.surfaces[surface_name]
  end

  local surface = game.create_surface(surface_name)
  surface.generate_with_lab_tiles = true

  return surface
end

local on_circuit_condition_fulfilled_event = script.generate_event_name()
remote.add_interface("glutenfree-circuit-network-events", {
  on_circuit_condition_fulfilled_event = function() return on_circuit_condition_fulfilled_event end,
  register_on_circuit_condition_fulfilled = function(event)

    local inserter = surface().create_entity({
      name = mod_prefix .. 'inserter',
      position = event.target_entity.position,
      force = event.target_entity.force, -- i wonder what would happen with the *spoiler alert* spaceship in the asteroid belt, it is initially of a claimable force
    })

    inserter.connect_neighbour(event)
    inserter.get_or_create_control_behavior().circuit_condition = {condition = event.condition}

    local item = surface().create_entity({
      name = 'item-on-ground',
      stack = {name = 'raw-fish'},
      position = {inserter.position.x, inserter.position.y - 1},
    })

    local registration_number = script.register_on_entity_destroyed(item)
    global.school[registration_number] = {
      inserter = inserter,
    }

    -- in case the linked entity decides to cease existing
    global.deathrattles[script.register_on_entity_destroyed(event.target_entity)] = {
      inserter = inserter,
      item = item,
      item_registration_number = registration_number,
    }

    return registration_number
  end,
})

script.on_event(defines.events.on_entity_destroyed, function(event)
  local fish = global.school[event.registration_number]
  if fish then global.school[event.registration_number] = nil

    fish.inserter.destroy() -- takes out the inserter & the fish holding it

    -- tbh the other mod could just listen for on_entity_destroyed directly as well
    script.raise_event(on_circuit_condition_fulfilled_event, {
      registration_number = event.registration_number,
    })
  end

  -- on_circuit_condition_fulfilled's entity_target vanished somehow
  local deathrattle = global.deathrattles[event.registration_number]
  if deathrattle then global.deathrattles[event.registration_number] = nil
    deathrattle.inserter.destroy()

    -- unregister the success trigger before destroying the item
    global.school[deathrattle.item_registration_number] = nil
    deathrattle.item.destroy()
  end
end)

local Miner = require('scripts.miner')
script.on_event(defines.events.on_player_rotated_entity, function(event)

  local position = Miner.next_empty_position()
  game.print(serpent.line(position))

  surface().create_entity({
    name = 'wooden-chest',
    position = position,
    force = 'neutral',
  })
end)
