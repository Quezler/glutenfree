local function on_created_entity(event)
  local entity = event.entity or event.destination

  entity.direction = defines.direction.north
end

local function update_force(force)
  local recipes = force.recipes
  recipes["wooden-sign-post"].enabled = not recipes["display-panel"].enabled
end

local function update_forces()
  for _, force in pairs(game.forces) do
    update_force(force)
  end
end

script.on_init(function()
  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = {'display-panel'}})) do
      on_created_entity({entity = entity})
    end
  end

  update_forces()
end)

script.on_configuration_changed(function()
  update_forces()
end)

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, on_created_entity, {
    {filter = 'name', name = 'display-panel'},
  })
end

local function on_research_toggled(event)
  update_force(event.research.force)
end

script.on_event(defines.events.on_research_finished, on_research_toggled)
script.on_event(defines.events.on_research_reversed, on_research_toggled)
