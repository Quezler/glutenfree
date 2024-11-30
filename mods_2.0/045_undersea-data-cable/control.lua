require("util")

local mod_surface_name = "undersea-data-cable"

local Handler = {}

local function refresh_surfacedata()
  -- deleted old
  for surface_index, surfacedata in pairs(storage.surfacedata) do
    if surfacedata.surface.valid == false then
      storage.surfacedata[surface_index] = nil
    end
  end

  -- created new
  for _, surface in pairs(game.surfaces) do
    storage.surfacedata[surface.index] = storage.surfacedata[surface.index] or {
      surface = surface,
    }
  end
end

script.on_init(function()
  storage.surfacedata = {}
  refresh_surfacedata()

  local mod_surface = game.planets[mod_surface_name].create_surface()
  mod_surface.generate_with_lab_tiles = true
end)

script.on_configuration_changed(function()
  refresh_surfacedata()
end)

script.on_event(defines.events.on_surface_created, refresh_surfacedata)
script.on_event(defines.events.on_surface_deleted, refresh_surfacedata)

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
