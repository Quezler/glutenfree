local mod_prefix = 'fietff-'

local FluidPort = {}

-- i should generate these via code, but for the prototyping stage this was quicker.
FluidPort.tiers = {
  {
    -- top left to top right
    {offset = {-3.5, -3.5}, direction = defines.direction.north, counter_clockwise_skip = 2},
    {offset = {-2.5, -3.5}, direction = defines.direction.north},
    {offset = {-1.5, -3.5}, direction = defines.direction.north},
    {offset = {-0.5, -3.5}, direction = defines.direction.north},
    {offset = { 0.5, -3.5}, direction = defines.direction.north},
    {offset = { 1.5, -3.5}, direction = defines.direction.north},
    {offset = { 2.5, -3.5}, direction = defines.direction.north},
    {offset = { 3.5, -3.5}, direction = defines.direction.north, clockwise_skip = 2},

    -- top right to bottom right
    {offset = { 3.5, -3.5}, direction = defines.direction.east, counter_clockwise_skip = 2},
    {offset = { 3.5, -2.5}, direction = defines.direction.east},
    {offset = { 3.5, -1.5}, direction = defines.direction.east},
    {offset = { 3.5, -0.5}, direction = defines.direction.east},
    {offset = { 3.5,  0.5}, direction = defines.direction.east},
    {offset = { 3.5,  1.5}, direction = defines.direction.east},
    {offset = { 3.5,  2.5}, direction = defines.direction.east},
    {offset = { 3.5,  3.5}, direction = defines.direction.east, clockwise_skip = 2},

    -- bottom right to bottom left
    {offset = { 3.5,  3.5}, direction = defines.direction.south, counter_clockwise_skip = 2},
    {offset = { 2.5,  3.5}, direction = defines.direction.south},
    {offset = { 1.5,  3.5}, direction = defines.direction.south},
    -- {offset = { 0.5,  3.5}, direction = defines.direction.south},
    -- {offset = {-0.5,  3.5}, direction = defines.direction.south},
    {offset = {-1.5,  3.5}, direction = defines.direction.south},
    {offset = {-2.5,  3.5}, direction = defines.direction.south},
    {offset = {-3.5,  3.5}, direction = defines.direction.south, clockwise_skip = 2},

    -- bottom left to top left
    {offset = {-3.5,  3.5}, direction = defines.direction.west, counter_clockwise_skip = 2},
    {offset = {-3.5,  2.5}, direction = defines.direction.west},
    {offset = {-3.5,  1.5}, direction = defines.direction.west},
    {offset = {-3.5,  0.5}, direction = defines.direction.west},
    {offset = {-3.5, -0.5}, direction = defines.direction.west},
    {offset = {-3.5, -1.5}, direction = defines.direction.west},
    {offset = {-3.5, -2.5}, direction = defines.direction.west},
    {offset = {-3.5, -3.5}, direction = defines.direction.west, clockwise_skip = 2},
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

  local slot = slots[1]
  local position = {entity.position.x + slot.offset[1], entity.position.y + slot.offset[2]}
  local fluid_port = entity.surface.create_entity{
    name = string.format(mod_prefix .. 'storage-tank-%s', 'water'),
    force = entity.force,
    position = position,
    direction = slot.direction,
  }

  struct.fluid_ports = {
    {index = 1, entity = fluid_port, fluid = 'water'},
  }

  global.fluid_port_data[fluid_port.unit_number] = {
    unit_number = fluid_port.unit_number,
    entity = fluid_port,

    struct_id = struct.unit_number,
  }
end)

function FluidPort.direction_changed_clockwise(old_direction, new_direction)
  if old_direction == defines.direction.north and new_direction == defines.direction.east then return true end
  if old_direction == defines.direction.east and new_direction == defines.direction.south then return true end
  if old_direction == defines.direction.south and new_direction == defines.direction.west then return true end
  if old_direction == defines.direction.west and new_direction == defines.direction.north then return true end

  return false
end

function FluidPort.on_player_rotated_entity(event)
  local entity = event.entity
  if string.find(entity.name, 'fietff%-storage%-tank%-') then
    local fluid_port_data = global.fluid_port_data[entity.unit_number]
    if fluid_port_data then
      local struct = global.structs[fluid_port_data.struct_id]
      assert(struct)

      local fluid_port_slots = #FluidPort.tiers[1]
      
      local sign = FluidPort.direction_changed_clockwise(event.previous_direction, entity.direction) and 1 or -1
      local next_index = (struct.fluid_ports[1].index % fluid_port_slots) + sign
      if 0 >= next_index then next_index = fluid_port_slots + next_index end

      local next_slot = FluidPort.tiers[1][next_index]
      local next_position = {struct.container.position.x + next_slot.offset[1], struct.container.position.y + next_slot.offset[2]}
      entity.teleport(next_position)
      entity.direction = next_slot.direction
      struct.fluid_ports[1].index = next_index
    end
  end
end

return FluidPort
