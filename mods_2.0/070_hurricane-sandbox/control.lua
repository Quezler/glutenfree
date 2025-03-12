require("util")
require("shared")

local highest_tile_height = 0
local is_hurricane_entity = {}
for _, prototype in pairs(prototypes.entity) do
  if util.string_starts_with(prototype.name, mod_prefix) then
    is_hurricane_entity[prototype.name] = true

    if prototype.tile_height > highest_tile_height then
      highest_tile_height = prototype.tile_height
    end
  end
end

script.on_init(function()
  local surface = game.get_surface("nauvis") --[[@as LuaSurface]]
  local force = game.forces["player"]

  local x = 3
  for name, _ in pairs(is_hurricane_entity) do
    local prototype = prototypes.entity[name]
    x = x + (prototype.tile_width / 2)

    local entity1 = surface.create_entity{
      name = name,
      force = force,
      position = {x, -6},
    }
    entity1.disabled_by_script = true

    local entity2 = surface.create_entity{
      name = name,
      force = force,
      position = {x, -6 - highest_tile_height - 1},
    }

    x = x + (prototype.tile_width / 2) + 1
  end
end)
