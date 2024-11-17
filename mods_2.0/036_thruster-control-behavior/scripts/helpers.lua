function surface_find_entity_or_ghost(surface, position, name)
  local belts = surface.find_entities_filtered{
    position = position,
    name = name,
    limit = 1,
  }
  if belts[1] then return belts[1] end

  local ghosts = surface.find_entities_filtered{
    position = position,
    ghost_name = name,
    limit = 1,
  }
  if ghosts[1] then return ghosts[1] end
end
