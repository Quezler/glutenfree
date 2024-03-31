local mod_prefix = 'fietff-'

local FluidPort = {}

FluidPort.tiers = require('scripts.fluid-port-tiers')

commands.add_command(mod_prefix .. "fluidport", nil, function(command)
  local player = game.get_player(command.player_index)
  assert(player)
  if player.selected == nil then return end
  if player.selected.unit_number == nil then return end

  local struct = global.structs[player.selected.unit_number]
  if struct == nil then return end

  local entity = struct.container
  local slots = FluidPort.tiers[1]
  -- local slots = FluidPort.tiers[2]
  -- local slots = FluidPort.tiers[3]

  -- for _, slot in ipairs(slots) do
  --   local position = {entity.position.x + slot.offset[1], entity.position.y + slot.offset[2]}

  --   entity.surface.create_entity{
  --     name = string.format(mod_prefix .. 'storage-tank-%s', 'water'),
  --     force = entity.force,
  --     position = position,
  --     direction = slot.direction,
  --   }
  -- end

  FluidPort.add_fluid_port(struct, 'water')
  FluidPort.add_fluid_port(struct, 'lubricant')
  FluidPort.add_fluid_port(struct, 'steam')
end)

function FluidPort.get_occupied_slots(struct, ignore_entity)
  local tier = struct.tier
  local fluid_port_slots = #FluidPort.tiers[tier]
  local occupied_slots = {}

  for _, fluid_port in ipairs(struct.fluid_ports) do
    if fluid_port.entity ~= ignore_entity then
      occupied_slots[fluid_port.index] = true

      -- fluid port slots can have a corner property, if its present the current slot's index + the offset in the `corners` is reserved as well.
      if fluid_port.entity ~= ignore_entity and FluidPort.tiers[tier][fluid_port.index].corners ~= nil then
        occupied_slots[FluidPort.clockwise_array_index(fluid_port.index, fluid_port_slots, FluidPort.tiers[tier][fluid_port.index].corners)] = true
      end
    end
  end

  return occupied_slots
end

function FluidPort.get_random_unoccupied_index(struct)
  local occupied_slots = FluidPort.get_occupied_slots(struct)

  local array_size = #FluidPort.tiers[struct.tier]
  assert(array_size > table_size(occupied_slots))

  ::again::
  local random_index = math.random(1, array_size)
  if occupied_slots[random_index] then goto again end

  return random_index
end

function FluidPort.add_fluid_port(struct, fluid_name, index)
  local entity = struct.container
  if index == nil then index = FluidPort.get_random_unoccupied_index(struct) end

  local slots = FluidPort.tiers[struct.tier]
  local slot = slots[index]
  local position = {entity.position.x + slot.offset[1], entity.position.y + slot.offset[2]}
  local fluid_port = entity.surface.create_entity{
    name = string.format(mod_prefix .. 'storage-tank-%s', fluid_name),
    force = entity.force,
    position = position,
    direction = slot.direction,
  }

  table.insert(struct.fluid_ports, {index = index, entity = fluid_port, fluid = fluid_name})

  global.fluid_port_data[fluid_port.unit_number] = {
    unit_number = fluid_port.unit_number,
    entity = fluid_port,

    struct_id = struct.unit_number,
  }

  global.fluid_port_data_deathrattles[script.register_on_entity_destroyed(fluid_port)] = fluid_port.unit_number

  -- add the fluid port to the list of entities to kill when the container gets destroyed
  table.insert(global.deathrattles[script.register_on_entity_destroyed(struct.container)], fluid_port)
end

function FluidPort.direction_changed_clockwise(old_direction, new_direction)
  if old_direction == defines.direction.north and new_direction == defines.direction.east then return true end
  if old_direction == defines.direction.east and new_direction == defines.direction.south then return true end
  if old_direction == defines.direction.south and new_direction == defines.direction.west then return true end
  if old_direction == defines.direction.west and new_direction == defines.direction.north then return true end

  return false
end

function FluidPort.get_fluid_port_index(struct, entity)
  for i, fluid_port in ipairs(struct.fluid_ports) do
    if entity == fluid_port.entity then
      return i
    end
  end

  error()
end

-- returns values in the 1-30 range, assuming array_length was 30 :)
function FluidPort.clockwise_array_index(index, array_length, shift)
  local next_index = (index + shift) % array_length
  if 0 >= next_index then next_index = array_length + next_index end
  return next_index
end

assert(FluidPort.clockwise_array_index(1, 30, 10) == 11)
assert(FluidPort.clockwise_array_index(29, 30, 1) == 30)
assert(FluidPort.clockwise_array_index(29, 30, 2) ==  1)
assert(FluidPort.clockwise_array_index(1, 30, -9) == 22)
assert(FluidPort.clockwise_array_index(1, 30, -1) == 30)

function FluidPort.update_fluid_port_position(struct, fluid_port_index)
  local fluid_port = struct.fluid_ports[fluid_port_index]
  local slot = FluidPort.tiers[struct.tier][fluid_port.index]

  fluid_port.entity.teleport({struct.container.position.x + slot.offset[1], struct.container.position.y + slot.offset[2]})
  fluid_port.entity.direction = slot.direction
end

function FluidPort.on_player_rotated_entity(event)
  local entity = event.entity
  if global.fluid_port_names[entity.name] then
    local fluid_port_data = global.fluid_port_data[entity.unit_number]
    if fluid_port_data then
      local struct = global.structs[fluid_port_data.struct_id]
      assert(struct)

      local fluid_port_slots = #FluidPort.tiers[struct.tier]
      local occupied_slots = FluidPort.get_occupied_slots(struct, entity)

      local fluid_port_index = FluidPort.get_fluid_port_index(struct, entity)
      local next_index = struct.fluid_ports[fluid_port_index].index -- not yet the next! (wait till the repeat until)

      if event.sign == nil then
        event.sign = FluidPort.direction_changed_clockwise(event.previous_direction, entity.direction) and 1 or -1
      end

      repeat
        next_index = FluidPort.clockwise_array_index(next_index, fluid_port_slots, event.sign)
      until occupied_slots[next_index] == nil

      struct.fluid_ports[fluid_port_index].index = next_index
      FluidPort.update_fluid_port_position(struct, fluid_port_index)
    end
  end
end

function FluidPort.on_selected_entity_changed(event)
  local entity = game.get_player(event.player_index).selected
  if entity then
    if global.fluid_port_names[entity.name] then
      -- game.print('selected a fluid port')
      global.selected_fluid_port[event.player_index] = entity
    end
  elseif global.selected_fluid_port[event.player_index] then
    -- game.print('selected nothing')
    global.selected_fluid_port[event.player_index] = nil
  end
end

function FluidPort.on_player_pressed_rotate(event, sign)
  local player = game.get_player(event.player_index)
  assert(player)
  local selected_fluid_port = global.selected_fluid_port[player.index]
  if player.selected and selected_fluid_port and selected_fluid_port.valid and player.selected ~= selected_fluid_port then
    FluidPort.on_player_rotated_entity({entity = selected_fluid_port, sign = sign})
  end
end

function FluidPort.on_player_pressed_rotate_key(event)
  FluidPort.on_player_pressed_rotate(event,  1)
end

function FluidPort.on_player_pressed_reverse_rotate_key(event)
  FluidPort.on_player_pressed_rotate(event, -1)
end

function FluidPort.try_to_output_from_fluid_output_buffer(struct)
  local outputted = false

  for fluid_name, fluid_amount in pairs(struct.fluid_output_buffer) do
    if fluid_amount > 0 then
      for _, fluid_port in ipairs(struct.fluid_ports) do
        if fluid_port.fluid == fluid_name and fluid_amount > 0 then
          local inserted = fluid_port.entity.insert_fluid{name = fluid_port.fluid, amount = fluid_amount}
          if inserted > 0 then outputted = true end
          struct.fluid_output_buffer[fluid_name] = fluid_amount - inserted
          fluid_amount = struct.fluid_output_buffer[fluid_name]
        end
      end
    end
  end

  if outputted then FluidPort.update_fluid_combinator(struct) end
end

function FluidPort.get_fluid_ports_required(clipboard)
  local port_count = 0

  for _, pbi in ipairs({clipboard.products, clipboard.byproducts, clipboard.ingredients}) do
    for _, thing in ipairs(pbi) do
      if is_item_or_else_fluid(thing) then
        -- ignored
      else
        port_count = port_count + math.ceil(thing.amount / 5000) -- each fluid port is rated for 5000 per minute (technically 6000, if its full every 10 secs)
      end
    end
  end

  return port_count
end

function FluidPort.update_fluid_combinator(struct)
  local parameters = {}

  for fluid_name, fluid_amount in pairs(struct.fluid_input_buffer) do
    table.insert(parameters, {signal = {type = 'fluid', name = fluid_name}, count = fluid_amount, index = #parameters + 1})
  end

  for fluid_name, fluid_amount in pairs(struct.fluid_output_buffer) do
    table.insert(parameters, {signal = {type = 'fluid', name = fluid_name}, count = fluid_amount, index = #parameters + 1})
  end

  struct.fluid_combinator.get_control_behavior().parameters = parameters
end

script.on_event(defines.events.on_selected_entity_changed, FluidPort.on_selected_entity_changed)

script.on_event(mod_prefix .. 'rotate', FluidPort.on_player_pressed_rotate_key)
script.on_event(mod_prefix .. 'reverse-rotate', FluidPort.on_player_pressed_reverse_rotate_key)

return FluidPort
