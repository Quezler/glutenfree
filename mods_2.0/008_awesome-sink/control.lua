local mod_surface_name = "awesome-sink"

script.on_init(function ()
  storage.version = 0

  local surface = game.surfaces[mod_surface_name]
  assert(surface == nil, 'contact the mod author for help with world that previously already had this mod installed.')

  surface = game.create_surface(mod_surface_name)
  surface.generate_with_lab_tiles = true
end)
