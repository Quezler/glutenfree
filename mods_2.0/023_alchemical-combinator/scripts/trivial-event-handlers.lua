local direction_to_sprite = {
  [defines.direction.north] = "alchemical-combinator-active-north",
  [defines.direction.east ] = "alchemical-combinator-active-east" ,
  [defines.direction.south] = "alchemical-combinator-active-south",
  [defines.direction.west ] = "alchemical-combinator-active-west" ,
}

local function on_changed_orientation(entity)
  local struct_id = storage.alchemical_combinator_active_to_struct_id[entity.unit_number]
  local struct = storage.structs[struct_id]

  struct.sprite_render_object.sprite = direction_to_sprite[entity.direction]
  struct.alchemical_combinator.direction = entity.direction
end

script.on_event(defines.events.on_player_rotated_entity, function(event)
  -- game.print("rotated")
  if event.entity.name == "alchemical-combinator-active" then
    on_changed_orientation(event.entity)
  end
end)

script.on_event(defines.events.on_player_flipped_entity, function(event)
  -- game.print("flipped")
  if event.entity.name == "alchemical-combinator-active" then
    on_changed_orientation(event.entity)
  end
end)
