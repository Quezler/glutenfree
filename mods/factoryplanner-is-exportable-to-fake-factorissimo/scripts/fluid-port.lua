local mod_prefix = 'fietff-'

local FluidPort = {}

-- i should generate these via code, but for the prototyping stage this was quicker.
FluidPort.tiers = {
  {
    -- top left to top right
    {offset = {-3.5, -3.5}, direction = defines.direction.north, occupy = -1},
    {offset = {-2.5, -3.5}, direction = defines.direction.north},
    {offset = {-1.5, -3.5}, direction = defines.direction.north},
    {offset = {-0.5, -3.5}, direction = defines.direction.north},
    {offset = { 0.5, -3.5}, direction = defines.direction.north},
    {offset = { 1.5, -3.5}, direction = defines.direction.north},
    {offset = { 2.5, -3.5}, direction = defines.direction.north},
    {offset = { 3.5, -3.5}, direction = defines.direction.north, occupy =  1},

    -- top right to bottom right
    {offset = { 3.5, -3.5}, direction = defines.direction.east, occupy = -1},
    {offset = { 3.5, -2.5}, direction = defines.direction.east},
    {offset = { 3.5, -1.5}, direction = defines.direction.east},
    {offset = { 3.5, -0.5}, direction = defines.direction.east},
    {offset = { 3.5,  0.5}, direction = defines.direction.east},
    {offset = { 3.5,  1.5}, direction = defines.direction.east},
    {offset = { 3.5,  2.5}, direction = defines.direction.east},
    {offset = { 3.5,  3.5}, direction = defines.direction.east, occupy =  1},

    -- bottom right to bottom left
    {offset = { 3.5,  3.5}, direction = defines.direction.south, occupy = -1},
    {offset = { 2.5,  3.5}, direction = defines.direction.south},
    {offset = { 1.5,  3.5}, direction = defines.direction.south},
    -- {offset = { 0.5,  3.5}, direction = defines.direction.south},
    -- {offset = {-0.5,  3.5}, direction = defines.direction.south},
    {offset = {-1.5,  3.5}, direction = defines.direction.south},
    {offset = {-2.5,  3.5}, direction = defines.direction.south},
    {offset = {-3.5,  3.5}, direction = defines.direction.south, occupy =  1},

    -- bottom left to top left
    {offset = {-3.5,  3.5}, direction = defines.direction.west, occupy = -1},
    {offset = {-3.5,  2.5}, direction = defines.direction.west},
    {offset = {-3.5,  1.5}, direction = defines.direction.west},
    {offset = {-3.5,  0.5}, direction = defines.direction.west},
    {offset = {-3.5, -0.5}, direction = defines.direction.west},
    {offset = {-3.5, -1.5}, direction = defines.direction.west},
    {offset = {-3.5, -2.5}, direction = defines.direction.west},
    {offset = {-3.5, -3.5}, direction = defines.direction.west, occupy =  1},
  }
}

commands.add_command(mod_prefix .. "fluidport", nil, function(command)
  local player = game.get_player(command.player_index)
  if player.selected == nil then return end
  if player.selected.unit_number == nil then return end

  local struct = global.structs[player.selected.unit_number]
  if struct == nil then return end

  local entity = struct.container
  local slots = FluidPort.tiers[1]

  -- for _, slot in ipairs(slots) do
  --   local position = {entity.position.x + slot.offset[1], entity.position.y + slot.offset[2]}

    -- entity.surface.create_entity{
    --   name = string.format(mod_prefix .. 'storage-tank-%s', 'water'),
    --   force = entity.force,
    --   position = position,
    --   direction = slot.direction,
    -- }
  -- end

  local seeds = {{4, 'water'}, {6, 'lubricant'}, {8, 'steam'}}
  for _, seed in ipairs(seeds) do
    local slot = slots[seed[1]]
    local position = {entity.position.x + slot.offset[1], entity.position.y + slot.offset[2]}
    local fluid_port = entity.surface.create_entity{
      name = string.format(mod_prefix .. 'storage-tank-%s', seed[2]),
      force = entity.force,
      position = position,
      direction = slot.direction,
    }
  
    table.insert(struct.fluid_ports, {index = seed[1], entity = fluid_port, fluid = seed[2]})
  
    global.fluid_port_data[fluid_port.unit_number] = {
      unit_number = fluid_port.unit_number,
      entity = fluid_port,
  
      struct_id = struct.unit_number,
    }
  end
end)

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

function FluidPort.on_player_rotated_entity(event)
  local entity = event.entity
  if string.find(entity.name, 'fietff%-storage%-tank%-') then
    local fluid_port_data = global.fluid_port_data[entity.unit_number]
    if fluid_port_data then
      local struct = global.structs[fluid_port_data.struct_id]
      assert(struct)

      local fluid_port_slots = #FluidPort.tiers[1]

      local occupied_slots = {}
      for _, fluid_port in ipairs(struct.fluid_ports) do
        if fluid_port.entity ~= entity then
          occupied_slots[fluid_port.index] = true

          -- allow current entity to bypass corner reservations of itself
          if fluid_port.entity ~= entity and FluidPort.tiers[1][fluid_port.index].occupy ~= nil then
            occupied_slots[FluidPort.clockwise_array_index(fluid_port.index, fluid_port_slots, FluidPort.tiers[1][fluid_port.index].occupy)] = true
          end
        end
      end

      local fluid_port_index = FluidPort.get_fluid_port_index(struct, entity)
      local next_index = struct.fluid_ports[fluid_port_index].index -- not yet the next! (wait till the repeat until)

      repeat
        local sign = FluidPort.direction_changed_clockwise(event.previous_direction, entity.direction) and 1 or -1
        next_index = FluidPort.clockwise_array_index(next_index, fluid_port_slots, sign)
      until occupied_slots[next_index] == nil

      local next_slot = FluidPort.tiers[1][next_index]
      local next_position = {struct.container.position.x + next_slot.offset[1], struct.container.position.y + next_slot.offset[2]}

      entity.teleport(next_position)
      entity.direction = next_slot.direction
      struct.fluid_ports[fluid_port_index].index = next_index
    end
  end
end

return FluidPort
