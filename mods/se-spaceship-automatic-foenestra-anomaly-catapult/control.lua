local mod = {}

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

-- traveling to and from foenestra supposedly is 10k distance,
-- but it seems to only start counting once you leave the solar system,
-- so when traveling to a neighbouring star it might take longer if the reported distance is above 20k whilst you're still close to the center.
local distance_cutoff = 10000 * 2

local function on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination

  if string.find(event.destination.surface.name, 'spaceship-') == nil then
    return -- ship anchored, we only want to detect when a ship lifts off.
  end

  local from_zone = Zone.from_surface_index(event.source.surface.index)
  if from_zone.type == 'anomaly' then
    return -- ships lifting off from the anomaly will not be needing slingshotting.
  end

  local known_zones = remote.call("space-exploration", "get_known_zones", {force_name = event.source.force.name})
  if known_zones[1] == nil then return end -- this force has not discovered foenestra yet

  local slingshot = entity.surface.find_entity('se-spaceship-slingshot', entity.position)
  if slingshot == nil then
    slingshot = entity.surface.create_entity{
      name = 'se-spaceship-slingshot',
      force = entity.force,
      position = entity.position,
    }

    slingshot.destructible = false

    -- i use red for output and green for input myself, so picking red here prevents it from leaking into how i design my own ships.
    entity.connect_neighbour({target_entity = slingshot, wire = defines.wire_type.red})
    -- entity.connect_neighbour({target_entity = slingshot, wire = defines.wire_type.green})
  end

  local struct = {
    unit_number = entity.unit_number,

    slingshot = slingshot,
    console_input = entity,
    console_output = entity.surface.find_entity(Spaceship.name_spaceship_console_output, util.vectors_add(entity.position, Spaceship.console_output_offset)),

    destination_zone_signal = nil,
    destination_zone_index = nil,

    destination_foenestra_confirmed = false,
  }
  
  assert(struct.console_output.valid)

  do
    local output_combinator = struct.console_output.get_control_behavior()
    local spaceship_id = output_combinator.get_signal(output_combinator_id).count

    local distance = output_combinator.get_signal(output_combinator_distance).count
    if distance_cutoff >= distance then return end -- destination is too close by

    local destination = output_combinator.get_signal(output_combinator_destination)
    -- game.print(destination.signal.name .. ' ' .. destination.count)
    struct.destination_zone_signal = destination.signal.name
    struct.destination_zone_index = destination.count

    log(string.format('spaceship #%d departed for %s %s %d distance away, slingshotting.', spaceship_id, struct.destination_zone_signal, struct.destination_zone_index, distance))
    slingshot.get_control_behavior().set_signal(1, {signal = {type = 'virtual', name = 'se-anomaly'}, count = 1})

    struct.console_input.surface.create_entity{
      name = 'tutorial-flying-text',
      position = struct.console_input.position,
      text = 'slingshot enabled'
    }

    local to_zone = remote.call("space-exploration", "get_zone_from_zone_index", {zone_index = destination.count})
    if to_zone == nil then error('are you traveling to another spaceship?') end
    rendering.draw_text{
      text = Zone._get_rich_text_name(to_zone),
      use_rich_text = true,
      alignment = 'center',
      color = {1,1,1},
      surface = slingshot.surface,
      target = slingshot,
      target_offset = {0, -1.5},
      scale = 0.5,
    }
  end

  global.structs[entity.unit_number] = struct
  global.structs_count = global.structs_count + 1
  script.on_event(defines.events.on_tick, mod.on_tick)
end

script.on_init(function(event)
  global.structs = {}
  global.structs_count = 0
end)

for _, event in ipairs({
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, on_created_entity, {
    {filter = 'name', name = 'se-spaceship-console'},
  })
end

local function tick_struct(struct)
  local output_combinator = struct.console_output.get_or_create_control_behavior()
  local slingshot_combinator = struct.slingshot.get_control_behavior()

  local destination = output_combinator.get_signal(output_combinator_destination)

  if destination.signal.name ~= 'se-anomaly' then
    if struct.destination_foenestra_confirmed then
      -- we have arrived at foenestra and the last tick_struct entered the new destination, or a player/circuit picked another destination.
      struct.slingshot.destroy()
      global.structs[struct.unit_number] = nil
      global.structs_count = global.structs_count - 1
      struct.console_input.surface.create_entity{
        name = 'tutorial-flying-text',
        position = struct.console_input.position,
        text = 'slingshot disabled'
      }
      return
    else
      assert('a spaceship was still receiving a destination signal.')
    end
  end

  if struct.destination_foenestra_confirmed == false then
    if destination.signal.name == 'se-anomaly' then
      struct.destination_foenestra_confirmed = true
      slingshot_combinator.set_signal(1, nil)
    end
  end

  -- we have arrived at foenestra, input the original stored destination.
  if output_combinator.get_signal(output_combinator_distance).count == -1 then
    slingshot_combinator.set_signal(1, {signal = {type = 'virtual', name = struct.destination_zone_signal}, count = struct.destination_zone_index})
  end

  -- a: cancel out only the active destination
  -- b: get the merged signals of all the inputs and negate each possible destination
end

function mod.on_tick(event)
  for unit_number, struct in pairs(global.structs) do
    if (unit_number + event.tick) % 60 == 0 then
      if struct.console_input.valid == false then
        if struct.slingshot.valid then
          struct.slingshot.destroy()
        end
        global.structs[unit_number] = nil
        global.structs_count = global.structs_count - 1
      else
        tick_struct(struct)
      end
    end
  end

  if global.structs_count == 0 then
    script.on_event(defines.events.on_tick, nil)
  end
end

script.on_load(function(event)
  if global.structs_count > 0 then
    script.on_event(defines.events.on_tick, mod.on_tick)
  end
end)

commands.add_command('foenestra-catapult-integrity', nil, function(command)
  local player = game.get_player(command.player_index)
  player.print(serpent.block({
    actual_structs = table_size(global.structs),
    expected_structs = global.structs_count,
    on_tick_active = script.get_event_handler(defines.events.on_tick) ~= nil,
  }))
end)
