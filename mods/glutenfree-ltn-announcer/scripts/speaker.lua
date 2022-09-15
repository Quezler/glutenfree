local ltn = require('scripts.ltn')

local speaker = {}

function speaker.init()
  global.entries = {}
end

function speaker.on_dispatcher_updated(event)
  game.print('owo ' .. event.tick)

  print(serpent.block( event.deliveries ))
end

function speaker.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  if entity.name ~= 'logistic-train-stop' then return end

  local entity = entity.surface.create_entity({
    name = 'logistic-train-stop-announcer',
    position = ltn.pos_for_speaker(entity),
    force = entity.force,
  })

  entity.operable = false
  entity.destructible = false

  local red_signal = entity.surface.create_entity({
    name = 'logistic-train-stop-announcer-red-signal',
    position = entity.position,
    force = entity.force,
  })

  local green_signal = entity.surface.create_entity({
    name = 'logistic-train-stop-announcer-green-signal',
    position = entity.position,
    force = entity.force,
  })

  entity.connect_neighbour({
    target_entity = red_signal,
    wire = defines.wire_type.red,
  })

  entity.connect_neighbour({
    target_entity = green_signal,
    wire = defines.wire_type.green,
  })

  -- here entity is the speaker pole
  global.entries[entity.unit_number] = {
    entity = entity,
    red_signal = red_signal,
    green_signal = green_signal, 
  }

  red_signal.get_control_behavior().parameters = {{index = 1, signal = {type="virtual", name="signal-white"}, count = 1 }}
  green_signal.get_control_behavior().parameters = {{index = 1, signal = {type="virtual", name="signal-black"}, count = 1 }}
  
end

return speaker
