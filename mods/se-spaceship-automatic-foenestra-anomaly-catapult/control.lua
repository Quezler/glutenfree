local util = require('__space-exploration__.scripts.util')
local Zone = require('__space-exploration-scripts__.zone')
local Spaceship = require('__space-exploration-scripts__.spaceship')

function on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination

  local slingshot = entity.surface.find_entity('se-spaceship-slingshot', entity.position)
  if slingshot == nil then
    slingshot = entity.surface.create_entity{
      name = 'se-spaceship-slingshot',
      force = entity.force,
      position = entity.position,
    }

    slingshot.destructible = false

    entity.connect_neighbour({target_entity = slingshot, wire = defines.wire_type.red})
    entity.connect_neighbour({target_entity = slingshot, wire = defines.wire_type.green})
  end

  local combinator = slingshot.get_control_behavior()
  combinator.parameters = {{index = 1, signal = {type = 'virtual', name = 'se-anomaly'}, count = 1}}

  global.structs[entity.unit_number] = {
    unit_number = entity,

    slingshot = slingshot,
    console_input = entity,
    -- console_output = entity.surface.find_entity(Spaceship.name_spaceship_console_output, util.vectors_add(entity.position, Spaceship.console_output_offset))
  }

  -- assert(global.structs[entity.unit_number].console_output.valid)
end

script.on_init(function(event)
  global.structs = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = {'se-spaceship-console'}})) do
      on_created_entity({entity = entity})
    end
  end
end)

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, on_created_entity, {
    {filter = 'name', name = 'se-spaceship-console'},
    -- {filter = 'name', name = 'aai-signal-receiver'},
  })
end

-- for _, event in ipairs({
--   defines.events.on_built_entity,
--   defines.events.on_robot_built_entity,
--   defines.events.script_raised_built,
--   defines.events.script_raised_revive,
--   defines.events.on_entity_cloned,
-- }) do
--   script.on_event(event, on_created_entity, {
--     {filter = 'name', name = 'se-spaceship-console'},
--     {filter = 'name', name = 'aai-signal-receiver'},
--   })
-- end
