require("util")
require("shared")

local is_hurricane_entity = {}
for _, prototype in pairs(prototypes.entity) do
  if util.string_starts_with(prototype.name, mod_prefix) then
    is_hurricane_entity[prototype.name] = true
  end
end

script.on_init(function()
  local surface = game.get_surface("nauvis") --[[@as LuaSurface]]
  local force = game.forces["player"]

  local x = 3
  for name, _ in pairs(is_hurricane_entity) do
    local prototype = prototypes.entity[name]
    x = x + (prototype.tile_width / 2)
    local entity = surface.create_entity{
      name = name,
      force = force,
      position = {x, -6},
    }
    x = x + (prototype.tile_width / 2) + 1
  end
end)
