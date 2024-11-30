require("util")

local mod_surface_name = "undersea-data-cable"

local Handler = {}

script.on_init(function()
  local mod_surface = game.planets[mod_surface_name].create_surface()
  mod_surface.generate_with_lab_tiles = true
end)

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  game.print(event.tick)
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = "name", name = "undersea-data-cable"},
  })
end
