local function on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination

  -- game.print("foo")
  if storage.non_default_mode_to_default_mode[entity.ghost_name] == nil then return end
  -- game.print("bar")

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {
    default_name = storage.non_default_mode_to_default_mode[entity.ghost_name],
    mode_name = entity.ghost_name,

    force = entity.force,
    surface = entity.surface,
    position = entity.position,
  }
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, on_created_entity, {
    {filter = "ghost_type", type = "roboport"},
  })
end

local function on_configuration_changed(event)
  storage.deathrattles = {}
  storage.deathrattles_out = {}
  storage.deathrattles_out_count = 0

  storage.non_default_mode_to_default_mode = {}
  for _, prototype in pairs(prototypes.get_entity_filtered({{ filter = "type", type = "roboport" }})) do

    if prototypes.entity[prototype.name .. "-logistic-mode"] and prototypes.entity[prototype.name .. "-construction-mode"] then
      storage.non_default_mode_to_default_mode[prototype.name .. "-logistic-mode"] = prototype.name
      storage.non_default_mode_to_default_mode[prototype.name .. "-construction-mode"] = prototype.name
    end
  end
  -- log(serpent.block(storage.non_default_mode_to_default_mode))

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({ghost_type = {"roboport"}})) do
      on_created_entity({entity = entity})
    end
  end
end

script.on_init(on_configuration_changed)
script.on_configuration_changed(on_configuration_changed)

local function on_tick(event)
  for registration_number, deathrattle in pairs(storage.deathrattles_out) do
    if deathrattle.surface.valid then
      -- i suppose i could also have just checked the deathrattles after only the player placed event,
      -- but hey this is bound to work too and i use structures like this in my other mods, so force of habit.
      local placed_roboport = deathrattle.surface.find_entity(deathrattle.default_name, deathrattle.position)
      if placed_roboport then
        placed_roboport.destroy()
        deathrattle.surface.create_entity{
          name = deathrattle.mode_name,
          force = deathrattle.force,
          position = deathrattle.position,
          raise_built = true,
        }
      end
    end
    storage.deathrattles_out[registration_number] = nil
    storage.deathrattles_out_count = storage.deathrattles_out_count - 1
  end

  if storage.deathrattles_out_count == 0 then
    script.on_event(defines.events.on_tick, nil)
  end
end

script.on_load(function(event)
  if storage.deathrattles_out_count ~= 0 then
    script.on_event(defines.events.on_tick, on_tick)
  end
end)

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    storage.deathrattles_out[event.registration_number] = deathrattle
    storage.deathrattles_out_count = storage.deathrattles_out_count + 1
    script.on_event(defines.events.on_tick, on_tick)
  end
end)
