local ltn = {}

local multiblock_offset = {}
multiblock_offset["combinator"] = {
  [0 * 2] = {-1, -1},
  [2 * 2] = { 0, -1},
  [4 * 2] = { 0,  0},
  [6 * 2] = {-1,  0},
}
multiblock_offset["lamp"] = {
  [0 * 2] = { 0, -1},
  [2 * 2] = { 0,  0},
  [4 * 2] = {-1,  0},
  [6 * 2] = {-1, -1},
}
multiblock_offset["speakerpole"] = {
  [0 * 2] = { 0,  0},
  [2 * 2] = {-1,  0},
  [4 * 2] = {-1, -1},
  [6 * 2] = { 0, -1},
}
multiblock_offset["unused"] = {
  [0 * 2] = {-1,  0},
  [2 * 2] = {-1, -1},
  [4 * 2] = {-1,  0},
  [6 * 2] = { 0,  0},
}

function ltn.multiblock_position_for(entity, offset)
  offset = multiblock_offset[offset][entity.direction]

  return {entity.position.x + offset[1], entity.position.y + offset[2]}
end

return ltn
