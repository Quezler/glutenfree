local Handler = {}

function Handler.on_init()
  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = 'se-core-miner-drill'})) do
      Handler.handle_core_miner_drill(entity)
    end
  end
end

function Handler.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  if entity.name ~= 'se-core-miner-drill' then return end
  Handler.handle_core_miner_drill(entity)
end

function Handler.on_player_rotated_entity(event)
  if event.entity.name ~= 'se-core-miner-drill' then return end
  Handler.handle_core_miner_drill(event.entity)
end

function Handler.handle_core_miner_drill(entity)
  local entities = entity.surface.find_entities_filtered{
    position = entity.drop_position,
    force = entity.force,
    type = {'container', 'logistic-container'}
  }

  -- a freshly placed drill doesn't know it's mining_target yet in that tick
  local fragment_name = 'se-core-fragment-omni'
  if entity.mining_target then
    fragment_name = entity.mining_target.prototype.mineable_properties.products[1].name
  end
  local fragment_size = game.item_prototypes[fragment_name].stack_size

  local speaker = entity.surface.find_entity('se-core-miner-drill-speaker', entity.position)
  if not speaker then
    speaker = entity.surface.create_entity{
      name = 'se-core-miner-drill-speaker',
      force = entity.force,
      position = entity.position,
    }

    speaker.get_or_create_control_behavior().circuit_condition = {
      condition = {
        comparator = ">",
        constant = 800, -- todo: dynamic container slot determining, for now assume 40 out of 48 chest rows
        first_signal = {
          name = fragment_name,
          type = "item"
        }
      }    
    }

    speaker.alert_parameters = {
      alert_message = "[item=se-core-miner] [item=".. fragment_name .."] output chest full",
      icon_signal_id = {
        name = "se-core-miner",
        type = "item"
      },
      show_alert = true,
      show_on_map = true
    }
    
  end

  speaker.disconnect_neighbour(defines.wire_type.red)

  -- most often one, unless some mod adds several overlapping gridless containers (just connect them all & combine the signals)
  for _, entity in ipairs(entities) do
    -- game.print(entity.name)
    speaker.connect_neighbour({
      target_entity = entity,
      wire = defines.wire_type.red,
    })
  end
end

--

script.on_init(Handler.on_init)
script.on_event(defines.events.on_player_rotated_entity, Handler.on_player_rotated_entity)

script.on_event(defines.events.on_built_entity, Handler.on_created_entity)
script.on_event(defines.events.on_robot_built_entity, Handler.on_created_entity)
script.on_event(defines.events.script_raised_built, Handler.on_created_entity)
script.on_event(defines.events.script_raised_revive, Handler.on_created_entity)
-- script.on_event(defines.events.on_entity_cloned, Handler.on_created_entity)
