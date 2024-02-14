local util = require('__space-exploration__.scripts.util')
local Zone = require('__space-exploration-scripts__.zone')
local Spaceship = require('__space-exploration-scripts__.spaceship')

-- they are assigned with slot++, so in the future if the amount/order changes this will be inaccurate
local output_combinator_id = 1
local output_combinator_speed = 2
local output_combinator_distance = 3
local output_combinator_destination = 4
local output_combinator_density = 5
local output_combinator_anchored = 6

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
    console_output = nil, -- doesn't get created until the first update cycle, so within 60 ticks, tick_struct should always have it since it runs after SE on that tick
  }
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
  })
end

local function tick_struct(struct)
  if struct.console_output == nil then
    struct.console_output = struct.console_input.surface.find_entity(Spaceship.name_spaceship_console_output, util.vectors_add(struct.console_input.position, Spaceship.console_output_offset))
  end
  assert(struct.console_output.valid)

  local output = struct.console_output.get_or_create_control_behavior()

  game.print(serpent.line(output.get_signal(output_combinator_destination)))
end

script.on_event(defines.events.on_tick, function(event)
  for unit_number, struct in pairs(global.structs) do
    if (unit_number + event.tick) % 60 == 0 then
      if struct.console_input.valid == false then
        if struct.slingshot.valid then
          struct.slingshot.destroy()
        end
        global.structs[unit_number] = nil
      else
        tick_struct(struct)
      end
    end
  end
end)
