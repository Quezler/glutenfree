local function on_surface_created(event)
  local surface = game.get_surface(event.surface_index) --[[@as LuaSurface]]
  if surface.platform then return end

  assert(surface.find_entity("rorfc-roboport", {0, 0}) == nil)

  surface.create_entity{
    name = "rorfc-roboport",
    position = {0, 0},
    force = "player",
  }

  assert(surface.find_entity("rorfc-roboport", {0, 0}) ~= nil)
end

script.on_event(defines.events.on_surface_created, on_surface_created)

script.on_init(function(event)
  for _, surface in pairs(game.surfaces) do
    on_surface_created({surface_index = surface.index})
  end
end)
