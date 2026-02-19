mod_prefix = "se-"
Util = require("__space-exploration__/scripts/util")
Shared = require("__space-exploration__/shared")
Event = {addListener = function() end}
SpaceshipObstacles = require('__space-exploration__/scripts/spaceship-obstacles')
MapView = require("__space-exploration__/scripts/map-view")

local SESA = {}

script.on_init(function()
  SESA.hide_starmap_surfaces()
end)

script.on_configuration_changed(function()
  SESA.hide_starmap_surfaces()
end)

SESA.hide_starmap_surfaces = function()
  for _, surface in pairs(game.surfaces) do
    if MapView.is_surface_starmap(surface) then
      game.forces.player.set_surface_hidden(surface, true)
    end
  end
end

script.on_event(defines.events.on_surface_created, function(event)
  local surface = game.get_surface(event.surface_index) --[[@as LuaSurface]]
  if MapView.is_surface_starmap(surface) then
    game.forces.player.set_surface_hidden(surface, true)
  end
end)
