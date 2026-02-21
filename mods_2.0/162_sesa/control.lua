mod_prefix = "se-"
Util = require("__space-exploration__/scripts/util")
Shared = require("__space-exploration__/shared")
Event = {addListener = function() end}
SpaceshipObstacles = require('__space-exploration__/scripts/spaceship-obstacles')
MapView = require("__space-exploration__/scripts/map-view")

local SESA = {}

script.on_init(function()
  SESA.try_hide_surfaces()
end)

script.on_configuration_changed(function()
  SESA.try_hide_surfaces()
end)

script.on_event(defines.events.on_surface_created, function(event)
  SESA.try_hide_surface(game.get_surface(event.surface_index))
end)

SESA.try_hide_surface = function(surface)
  if surface.name == "nauvis" then return end

  local surface_type = remote.call("space-exploration", "get_surface_type", {surface_index = surface.index})
  if surface_type or MapView.is_surface_starmap(surface) then
    game.forces.player.set_surface_hidden(surface, true)
  end
end

SESA.try_hide_surfaces = function()
  for _, surface in pairs(game.surfaces) do
    SESA.try_hide_surface(surface)
  end
end
