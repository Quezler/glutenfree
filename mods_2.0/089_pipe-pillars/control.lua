require("shared")

local render_layer = 144 -- elevated rails use "elevated-higher-object", which at the time of writing uses 143, we sit above it.

function new_struct(table, struct)
  assert(struct.id, serpent.block(struct))
  assert(table[struct.id] == nil)
  table[struct.id] = struct
  return struct
end

local mod = {}

script.on_init(function()
  storage.deathrattles = {}

  storage.surfacedata = {}
  mod.refresh_surfacedata()
  storage.dirty_surfaces = {}
end)

script.on_configuration_changed(function()
  mod.refresh_surfacedata()
end)

script.on_load(function()
  if next(storage.dirty_surfaces) then
    script.on_event(defines.events.on_tick, mod.on_tick)
  end
end)

function mod.on_created_entity(event)
  local entity = event.entity or event.destination
  local surfacedata = storage.surfacedata[entity.surface.index]

  local struct = new_struct(surfacedata.structs, {
    id = entity.unit_number,
    entity = entity,
    connections = {},
    occluder_top = nil,
    occluder_tip = nil,
  })

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {
    name = "pipe-pillar",
    surface_index = entity.surface_index,
    unit_number = entity.unit_number,
  }

  struct.occluder_top = rendering.draw_sprite{
    sprite = "pipe-pillar-occluder-top",
    scale = 0.5,
    surface = surfacedata.surface,
    target = {
      entity = struct.entity,
    },
    render_layer = render_layer + 0,
  }

  struct.occluder_tip = rendering.draw_sprite{
    sprite = "pipe-pillar-occluder-tip",
    scale = 0.5,
    surface = surfacedata.surface,
    target = {
      entity = struct.entity,
    },
    render_layer = render_layer + 2,
  }

  mod.mark_surface_dirty(surfacedata.surface)
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, mod.on_created_entity, {
    {filter = "name", name = "pipe-pillar"},
  })
end

function mod.refresh_surfacedata()
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
      structs = {},
    }
  end
end

script.on_event(defines.events.on_surface_created, mod.refresh_surfacedata)
script.on_event(defines.events.on_surface_deleted, mod.refresh_surfacedata)

function mod.on_tick(event)
  for surface_index, _ in pairs(storage.dirty_surfaces) do
    local surfacedata = storage.surfacedata[surface_index]
    if surfacedata then mod.update_elevated_pipes_for_surface(surfacedata) end
  end
  storage.dirty_surfaces = {}
  script.on_event(defines.events.on_tick, nil)
end

function mod.mark_surface_dirty(surface)
  if not next(storage.dirty_surfaces) then
    script.on_event(defines.events.on_tick, mod.on_tick)
  end

  storage.dirty_surfaces[surface.index] = true
end

local deathrattles = {
  ["pipe-pillar"] = function (deathrattle)
    local surfacedata = storage.surfacedata[deathrattle.surface_index]
    if surfacedata then
      local struct = surfacedata.structs[deathrattle.unit_number]
      if struct then surfacedata.structs[deathrattle.unit_number] = nil
        for _, connection in pairs(struct.connections) do
          for _, sprite in ipairs(connection.sprites) do
            sprite.destroy()
          end
        end
      end
      mod.mark_surface_dirty(surfacedata.surface)
    end
  end,
}

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    deathrattles[deathrattle.name](deathrattle)
  end
end)

function mod.update_elevated_pipes_for_surface(surfacedata)
  local tick = game.tick

  for unit_number, struct in pairs(surfacedata.structs) do
    local position = struct.entity.position
    for _, neighbour in ipairs(struct.entity.neighbours[1]) do -- warning: if they are adjacent both the underground & normal connections show up
      if neighbour.name == "pipe-pillar" then

        local connection = struct.connections[neighbour.unit_number]
        if connection then -- mark as up-to-date, then continue on
          connection.updated_at = tick
          goto continue
        end

        local x_diff = position.x - neighbour.position.x
        local y_diff = position.y - neighbour.position.y


        -- only one side becomes the sprite parent
        local any_diff = x_diff > 1 or y_diff > 1
        if any_diff then

          connection = {
            updated_at = tick,
            sprites = {},
          }

          if x_diff > 1 then
            for x_offset = 1, x_diff -1 do
              table.insert(connection.sprites, rendering.draw_sprite{
                sprite = "pipe-pillar-straight-horizontal",
                surface = surfacedata.surface,
                target = {
                  entity = struct.entity,
                  offset = {-x_offset, -3.5},
                },
                render_layer = render_layer + 1,
              })
            end
          else
            for y_offset = 1, y_diff -1 do
              table.insert(connection.sprites, rendering.draw_sprite{
                sprite = "pipe-pillar-straight-vertical",
                surface = surfacedata.surface,
                target = {
                  entity = struct.entity,
                  offset = {0, -y_offset -3.5},
                },
                render_layer = render_layer + 1,
              })
            end
          end

          struct.connections[neighbour.unit_number] = connection
        end -- any_diff

      end
      ::continue::
    end
  end

  -- connections we did not come across stopped existing
  for unit_number, struct in pairs(surfacedata.structs) do
    for other_unit_number, connection in pairs(struct.connections) do
      if connection.updated_at ~= tick then
        for _, sprite in ipairs(connection.sprites) do
          sprite.destroy()
        end
        struct.connections[other_unit_number] = nil
      end
    end
  end
end
