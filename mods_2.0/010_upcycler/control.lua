local Handler = {}

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  entity.custom_status = {
    diode = defines.entity_status_diode.green,
    label = {"upcycler.status"},
  }

  local inserted = entity.get_inventory(defines.inventory.furnace_source).insert({name = "upcycle-any-quality", count = 1})
  assert(inserted > 0)

  Handler.get_or_create_linkedchest_then_move(entity)
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = "name", name = "upcycler"},
  })
end

function Handler.get_or_create_linkedchest_then_move(entity)
  local linked_chest = entity.surface.find_entities_filtered{
    name = "linked-chest",
    area = entity.bounding_box,
    limit = 1,
  }

  linked_chest = #linked_chest and linked_chest[1] or nil

  if linked_chest == nil then
    linked_chest = entity.surface.create_entity{
      name = "linked-chest",
      force = "neutral",
      position = entity.position,
    }
  end
  if entity.mirroring then
    if entity.direction == defines.direction.north then
      linked_chest.teleport({entity.position.x - 1, entity.position.y + 1})
    elseif entity.direction == defines.direction.east then
      linked_chest.teleport({entity.position.x - 2, entity.position.y - 1})
    elseif entity.direction == defines.direction.south then
      linked_chest.teleport({entity.position.x, entity.position.y - 2})
    elseif entity.direction == defines.direction.west then
      linked_chest.teleport({entity.position.x + 1, entity.position.y})
    end
  else
    if entity.direction == defines.direction.north then
      linked_chest.teleport({entity.position.x, entity.position.y + 1})
    elseif entity.direction == defines.direction.east then
      linked_chest.teleport({entity.position.x - 2, entity.position.y})
    elseif entity.direction == defines.direction.south then
      linked_chest.teleport({entity.position.x - 1, entity.position.y - 2})
    elseif entity.direction == defines.direction.west then
      linked_chest.teleport({entity.position.x + 1, entity.position.y - 1})
    end
  end
end

script.on_event(defines.events.on_player_rotated_entity, function(event)
  if event.entity.name == "upcycler" then
    Handler.get_or_create_linkedchest_then_move(event.entity)
  end
end)

script.on_event(defines.events.on_player_flipped_entity, function(event)
  if event.entity.name == "upcycler" then
    Handler.get_or_create_linkedchest_then_move(event.entity)
  end
end)
