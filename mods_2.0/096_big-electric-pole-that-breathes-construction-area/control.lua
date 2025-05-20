local Handler = {}

function on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination

  if entity.name == "big-electric-pole-roboport" then
    entity.destroy() -- other mods are not allowed to create instances
    return
  end

  if storage.deactivated then return end

  -- saninty check to make sure there is not already a roboport here
  assert(entity.surface.find_entity("big-electric-pole-roboport", entity.position) == nil)

  local roboport = entity.surface.create_entity{
    name = "big-electric-pole-roboport",
    force = entity.force,
    position = {entity.position.x, entity.position.y + 0.01}
  }

  roboport.destructible = false

  storage.deathrattles[script.register_on_object_destroyed(entity)] = roboport
end

function Handler.activate()
  assert(storage.deactivated == true)
  storage.deactivated = false

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = {"big-electric-pole"}})) do
      on_created_entity({entity = entity})
    end
  end
end

-- function Handler.deactivate()
-- assert(storage.deactivated == false)
--   storage.deactivated = true

--   for _, surface in pairs(game.surfaces) do
--     for _, entity in pairs(surface.find_entities_filtered({name = {"big-electric-pole-roboport"}})) do
--       entity.destroy()
--     end
--   end
-- end

function Handler.check_technology_for_roboport(technology)
  for _, effect in ipairs(technology.prototype.effects) do
    if effect.type == "unlock-recipe" and effect.recipe == "roboport" then
      Handler.activate()
      return true
    end
  end
end

script.on_event(defines.events.on_research_finished, function (event)
  if not storage.deactivated then return end
  Handler.check_technology_for_roboport(event.research)
end)

script.on_init(function(event)
  storage.deactivated = true
  storage.deathrattles = {}

  -- Handler.activate()
  for _, technology in pairs(game.forces["player"].technologies) do
    if technology.researched then
      if Handler.check_technology_for_roboport(technology) then
        return
      end
    end
  end
end)

script.on_configuration_changed(function(event)
  storage.version = (storage.version or 0)

  if storage.version == 0 then
    for unit_number, roboport in pairs(storage.deathrattles) do
      if roboport.valid then
        roboport.destructible = false
      end
    end
    storage.version = 1
  end
end)

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, on_created_entity, {
    {filter = "name", name = "big-electric-pole"},
    {filter = "name", name = "big-electric-pole-roboport"},
  })
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    deathrattle.destroy()
  end
end)
