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
  storage.periodically_toggle = {}

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

    local entity2 = surface.create_entity{
      name = name,
      force = force,
      position = {x, -6 - highest_tile_height - 1},
    }
    storage.periodically_toggle[entity2.unit_number] = entity2

    local entity3 = surface.create_entity{
      name = name,
      force = force,
      position = {x, -6 - highest_tile_height - 1 - highest_tile_height - 1},
    }
    entity3.disabled_by_script = true

    x = x + (prototype.tile_width / 2) + 1
  end
end)

script.on_nth_tick(60, function(event)
  for unit_number, entity in pairs(storage.periodically_toggle) do
    if entity.valid then
      entity.disabled_by_script = not entity.disabled_by_script
    else
      storage.periodically_toggle[unit_number] = nil
    end
  end
end)
