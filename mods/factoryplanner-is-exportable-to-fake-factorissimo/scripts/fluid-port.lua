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

  for _, slot in ipairs(slots) do
    local position = {entity.position.x + slot.offset[1], entity.position.y + slot.offset[2]}

    entity.surface.create_entity{
      name = string.format(mod_prefix .. 'storage-tank-%s', 'water'),
      force = entity.force,
      position = position,
      direction = slot.direction,
    }
  end
end)

return FluidPort
