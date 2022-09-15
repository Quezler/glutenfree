local ltn = {}

-- function ltn.compass(entity)
--   local stop_offset = 0
--   local pos, posIn, posOut, rotOut, search_area

--   pos = {entity.position.x, entity.position.y}

--   if entity.direction == 0 then --SN
--     game.print('SN')
--     posIn = {entity.position.x, entity.position.y - 1}
--     posOut = {entity.position.x - 1, entity.position.y - 1}
--     rotOut = 0
--     search_area = {
--       {entity.position.x + 0.001 - 1, entity.position.y + 0.001 - 1},
--       {entity.position.x - 0.001 + 1, entity.position.y - 0.001}
--     }

--     pos = {entity.position.x - 0, entity.position.y - 0}
--   elseif entity.direction == 2 then --WE
--     game.print('WE')
--     posIn = {entity.position.x, entity.position.y}
--     posOut = {entity.position.x, entity.position.y - 1}
--     rotOut = 2
--     search_area = {
--       {entity.position.x + 0.001, entity.position.y + 0.001 - 1},
--       {entity.position.x - 0.001 + 1, entity.position.y - 0.001 + 1}
--     }

--     pos = {entity.position.x - 1, entity.position.y - 0}

--   elseif entity.direction == 4 then --NS
--     game.print('NS')
--     posIn = {entity.position.x - 1, entity.position.y}
--     posOut = {entity.position.x, entity.position.y}
--     rotOut = 4
--     search_area = {
--       {entity.position.x + 0.001 - 1, entity.position.y + 0.001},
--       {entity.position.x - 0.001 + 1, entity.position.y - 0.001 + 1}
--     }

--     pos = {entity.position.x - 1, entity.position.y - 1}

--   elseif entity.direction == 6 then --EW
--     game.print('EW')
--     posIn = {entity.position.x - 1, entity.position.y - 1}
--     posOut = {entity.position.x - 1, entity.position.y}
--     rotOut = 6
--     search_area = {
--       {entity.position.x + 0.001 - 1, entity.position.y + 0.001 - 1},
--       {entity.position.x - 0.001, entity.position.y - 0.001 + 1}
--     }

--     pos = {entity.position.x - 0, entity.position.y - 1}
--   else
--     error('direction: '.. entity.direction)
--   end

--   return pos, search_area
--   -- return posIn, posOut, rotOut, search_area
-- end

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
