local mod = {}

script.on_init(function()
  storage.invalid = game.create_inventory(0)
  storage.invalid.destroy()

  storage.structs = {}
  storage.deathrattles = {}

  for _, surface in pairs(game.surfaces) do
    for _, station in ipairs(surface.find_entities_filtered{type = "train-stop"}) do
      mod.on_created_entity({entity = station})
    end
  end
end)

script.on_configuration_changed(function()
  for _, struct in pairs(storage.structs) do
    if struct.entity.valid then
      struct.text.destroy()
      mod.on_station_renamed(struct.entity)
    end
  end
end)

function mod.on_created_entity(event)
  local entity = event.entity or event.destination

  local struct = {
    entity = entity,
    text = storage.invalid,
  }

  storage.structs[entity.unit_number] = struct
  storage.deathrattles[script.register_on_object_destroyed(entity)] = true
  mod.on_station_renamed(entity)
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, mod.on_created_entity, {
    {filter = "type", type = "train-stop"},
  })
end

mod.offset_for_direction = {
  [defines.direction.north] = {-1, -3.0},
  [defines.direction.east]  = { 0, -4.5},
  [defines.direction.south] = { 1, -4.0},
  [defines.direction.west]  = { 0, -2.5},
}

function mod.on_station_renamed(entity)
  local struct = storage.structs[entity.unit_number]

  if struct.text.valid then
    struct.text.text = struct.entity.backer_name
  else
    struct.text = rendering.draw_text{
      text = struct.entity.backer_name,
      target = {entity = struct.entity, offset = mod.offset_for_direction[struct.entity.direction]},
      surface = struct.entity.surface,
      color = {1, 1, 1, 1},
      use_rich_text = true,
      alignment = "center",
    }
  end
end

script.on_event(defines.events.on_entity_renamed, function(event)
  if event.entity.type == "train-stop" then
    mod.on_station_renamed(event.entity)
  end
end)

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    local struct = storage.structs[event.useful_id]
    if struct then storage.structs[event.useful_id] = nil
      -- struct.text.destroy()
    end
  end
end)
