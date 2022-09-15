local ltn = {}

function ltn.search_area(entity)
  if entity.direction == 0 then --SN
    return {
      {entity.position.x + 0.001 - 1, entity.position.y + 0.001 - 1},
      {entity.position.x - 0.001 + 1, entity.position.y - 0.001}
    }
  elseif entity.direction == 2 then --WE
    return {
      {entity.position.x + 0.001, entity.position.y + 0.001 - 1},
      {entity.position.x - 0.001 + 1, entity.position.y - 0.001 + 1}
    }
  elseif entity.direction == 4 then --NS
    return {
      {entity.position.x + 0.001 - 1, entity.position.y + 0.001},
      {entity.position.x - 0.001 + 1, entity.position.y - 0.001 + 1}
    }
  elseif entity.direction == 6 then --EW
    return {
      {entity.position.x + 0.001 - 1, entity.position.y + 0.001 - 1},
      {entity.position.x - 0.001, entity.position.y - 0.001 + 1}
    }
  else
    error('direction: '.. entity.direction)
  end
end

function ltn.pos_for_speaker(entity)
  if entity.direction == 0 then --SN
    return {entity.position.x - 0, entity.position.y - 0}
  elseif entity.direction == 2 then --WE
    return {entity.position.x - 1, entity.position.y - 0}
  elseif entity.direction == 4 then --NS
    return {entity.position.x - 1, entity.position.y - 1}
  elseif entity.direction == 6 then --EW
    return {entity.position.x - 0, entity.position.y - 1}
  else
    error('direction: '.. entity.direction)
  end
end

return ltn
