local ltn = {}

function ltn.search_area(entity)
  if entity.direction == defines.direction.north then --SN
    return {
      {entity.position.x + 0.001 - 1, entity.position.y + 0.001 - 1},
      {entity.position.x - 0.001 + 1, entity.position.y - 0.001 + 1},
    }
  elseif entity.direction == defines.direction.east then --WE
    return {
      {entity.position.x + 0.001 - 1, entity.position.y + 0.001 - 1},
      {entity.position.x - 0.001 + 1, entity.position.y - 0.001 + 1},
    }
  elseif entity.direction == defines.direction.south then --NS
    return {
      {entity.position.x + 0.001 - 1, entity.position.y + 0.001 - 1},
      {entity.position.x - 0.001 + 1, entity.position.y - 0.001 + 1},
    }
  elseif entity.direction == defines.direction.west then --EW
    return {
      {entity.position.x + 0.001 - 1, entity.position.y + 0.001 - 1},
      {entity.position.x - 0.001 + 1, entity.position.y - 0.001 + 1},
    }
  else
    error('direction: '.. entity.direction)
  end
end

function ltn.pos_for_speaker(entity)
  if entity.direction == defines.direction.north then --SN
    return {entity.position.x - 0, entity.position.y - 0}
  elseif entity.direction == defines.direction.east then --WE
    return {entity.position.x - 1, entity.position.y - 0}
  elseif entity.direction == defines.direction.south then --NS
    return {entity.position.x - 1, entity.position.y - 1}
  elseif entity.direction == defines.direction.west then --EW
    return {entity.position.x - 0, entity.position.y - 1}
  else
    error('direction: '.. entity.direction)
  end
end

return ltn
