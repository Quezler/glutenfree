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

  local i = 0
  for name, _ in pairs(is_hurricane_entity) do
    i = i + 1
    surface.create_entity{
      name = name,
      force = force,
      position = {10 * i, 0},
    }
  end
end)
