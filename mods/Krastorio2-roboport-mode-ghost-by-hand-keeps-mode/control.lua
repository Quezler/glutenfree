local function on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination

  -- game.print('foo')
  if global.non_default_mode_to_default_mode[entity.ghost_name] == nil then return end
  -- game.print('bar')

  global.deathrattles[script.register_on_entity_destroyed(entity)] = {
    default_name = global.non_default_mode_to_default_mode[entity.ghost_name],
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
    {filter = 'ghost_type', type = 'roboport'},
  })
end

local function on_configuration_changed(event)
  global.deathrattles = {}
  global.deathrattles_out = {}
  global.deathrattles_out_count = 0

  global.non_default_mode_to_default_mode = {}
  for _, prototype in pairs(game.get_filtered_entity_prototypes({{ filter = 'type', type = 'roboport' }})) do
    
    if game.entity_prototypes[prototype.name .. '-logistic-mode'] and game.entity_prototypes[prototype.name .. '-construction-mode'] then
      global.non_default_mode_to_default_mode[prototype.name .. '-logistic-mode'] = prototype.name
      global.non_default_mode_to_default_mode[prototype.name .. '-construction-mode'] = prototype.name
    end

    -- log(serpent.block(global.non_default_mode_to_default_mode))
  end

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({ghost_type = {'roboport'}})) do
      on_created_entity({entity = entity})
    end
  end
end

script.on_init(on_configuration_changed)
script.on_configuration_changed(on_configuration_changed)

local function on_tick(event)
  for registration_number, deathrattle in pairs(global.deathrattles_out) do
    -- i suppose i could also have just checked the deathrattles after only the player placed event,
    -- but hey this is bound to work too and i use structures like this in my other mods, so force of habit.
    local placed_roboport = deathrattle.surface.find_entity(deathrattle.default_name, deathrattle.position)
    if placed_roboport and deathrattle.surface.valid then
      placed_roboport.destroy()
      deathrattle.surface.create_entity{
        name = deathrattle.mode_name,
        force = deathrattle.force,
        position = deathrattle.position,
        raise_built = true,
      }
    end
    global.deathrattles_out[registration_number] = nil
    global.deathrattles_out_count = global.deathrattles_out_count - 1
  end

  if global.deathrattles_out_count == 0 then
    script.on_event(defines.events.on_tick, nil)
  end
end

script.on_load(function(event)
  if global.deathrattles_out_count ~= 0 then
    script.on_event(defines.events.on_tick, on_tick)
  end
end)

script.on_event(defines.events.on_entity_destroyed, function(event)
  local deathrattle = global.deathrattles[event.registration_number]
  if deathrattle then global.deathrattles[event.registration_number] = nil
    global.deathrattles_out[event.registration_number] = deathrattle
    global.deathrattles_out_count = global.deathrattles_out_count + 1
    script.on_event(defines.events.on_tick, on_tick)
  end
end)
