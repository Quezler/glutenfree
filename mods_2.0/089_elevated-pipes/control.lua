require("shared")

local render_layer = 132 -- "under-elevated"

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

function mod.foreach_struct(callback)
  for _, surfacedata in pairs(storage.surfacedata) do
    for _, struct in pairs(surfacedata.structs) do
      callback(struct)
    end
  end
end

script.on_configuration_changed(function()
  mod.refresh_surfacedata()

  for _, surface in pairs(game.surfaces) do
    mod.mark_surface_dirty(surface)
  end

  mod.foreach_struct(function(struct)
    for other_unit_number, connection in pairs(struct.connections) do
      if connection.sprites then -- pre 1.2.0
        for _, sprite in ipairs(connection.sprites) do
          sprite.destroy()
        end
        connection.sprites = nil
      end
    end
  end)
end)

script.on_load(function()
  if next(storage.dirty_surfaces) then
    script.on_event(defines.events.on_tick, mod.on_tick)
  end
end)

function mod.on_created_entity(event)
  local entity = event.entity or event.destination
  local surfacedata = storage.surfacedata[entity.surface.index]

  if entity.name == "elevated-pipe-alt-mode" then
    return entity.destroy()
  end

  -- if bottleneck is installed we have no choice but to hide it from all the mods
  if script.active_mods["Bottleneck"] then
    local new_entity = entity.surface.create_entity{
      name = entity.name,
      force = entity.force,
      position = entity.position,
      create_build_effect_smoke = false,
    }
    entity.destroy()
    entity = new_entity
  end

  entity.custom_status = {
    diode = defines.entity_status_diode.green,
    label = {"entity-status.working"}
  }

  local struct = new_struct(surfacedata.structs, {
    id = entity.unit_number,
    entity = entity,
    connections = {},
    alt_mode = nil,
    occluder_tip = nil,
  })

  struct.alt_mode = entity.surface.create_entity{
    name = "elevated-pipe-alt-mode",
    force = entity.force,
    position = entity.position,
    create_build_effect_smoke = false,
  }
  struct.alt_mode.destructible = false
  struct.alt_mode.fluidbox.add_linked_connection(0, entity, 0)

  struct.occluder_tip = rendering.draw_sprite{
    sprite = "elevated-pipe-occluder-top",
    scale = 0.5,
    surface = surfacedata.surface,
    target = {
      entity = struct.entity,
    },
    render_layer = tostring(render_layer + 1),
  }

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {
    name = "elevated-pipe",
    surface_index = entity.surface_index,
    unit_number = entity.unit_number,
  }

  if script.active_mods["factorissimo-2-notnotmelon"] then
    struct.gingarou_hotel_planned_hotspring_site = entity.surface.create_entity{
      name = mod_prefix .. "gingarou-hotel-planned-hotspring-site",
      force = entity.force,
      position = entity.position,
      create_build_effect_smoke = false,
      raise_built = true,
    }
  end

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
    {filter = "name", name = "elevated-pipe"},
    {filter = "name", name = "elevated-pipe-alt-mode"},
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

  -- if paused we skip debounce and just render it right away
  if game.tick_paused then
    mod.on_tick()
  end
end

local deathrattles = {
  ["elevated-pipe"] = function (deathrattle)
    local surfacedata = storage.surfacedata[deathrattle.surface_index]
    if surfacedata then
      local struct = surfacedata.structs[deathrattle.unit_number]
      if struct then surfacedata.structs[deathrattle.unit_number] = nil
        struct.alt_mode.destroy()
        for _, connection in pairs(struct.connections) do
          for player_index, sprites in pairs(connection.player_sprites) do
            for _, sprite in ipairs(sprites) do
              sprite.destroy()
            end
          end
        end
        if struct.gingarou_hotel_planned_hotspring_site then
          script.raise_event(defines.events.script_raised_destroy, {entity = struct.gingarou_hotel_planned_hotspring_site})
          struct.gingarou_hotel_planned_hotspring_site.destroy()
        end
      end
      mod.mark_surface_dirty(surfacedata.surface)
    end
  end,
}

function mod.on_object_destroyed(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    deathrattles[deathrattle.name](deathrattle)
  end
end

script.on_event(defines.events.on_object_destroyed, mod.on_object_destroyed)

-- script.on_event(defines.events.on_player_mined_entity, function(event)
--   if game.tick_paused then -- remove floating pipes in paused editor mode
--     local registration_number = script.register_on_object_destroyed(event.entity)
--     mod.on_object_destroyed({registration_number = registration_number})
--   end
-- end, {
--   {filter = "name", name = "elevated-pipe"},
-- })

-- note to self: we render render upwards and leftwards

local function elevated_pipe_sprites(x_or_y, max)
  local prefix = x_or_y == "x" and "elevated-pipe-horizontal" or "elevated-pipe-vertical"

  if max == 1 then -- if the distance is just 1 tile there is not enough space for both a start and end sprite
    return {prefix .. "-single"}
  end

  local suffix_start = x_or_y == "x" and "-left" or "-top"
  local suffix_end = x_or_y == "x" and "-right" or "-bottom"
  local sprites = {}

  table.insert(sprites, prefix .. suffix_end)
  for i = 2, max -1 do
    table.insert(sprites, prefix .. "-center")
  end
  table.insert(sprites, prefix .. suffix_start)

  return sprites
end

function mod.update_elevated_pipes_for_surface(surfacedata)
  local tick = game.ticks_played

  local players = game.players

  for unit_number, struct in pairs(surfacedata.structs) do
    if not struct.entity.valid then
      goto next_struct
    end
    local position = struct.entity.position
    for _, neighbour in ipairs(struct.entity.fluidbox.get_connections(1)) do
      neighbour = neighbour.owner -- remnant from using neighbours instead of fluidbox
      if neighbour.name == "elevated-pipe" then

        local connection = struct.connections[neighbour.unit_number]
        if connection then -- mark as up-to-date, then continue on
          connection.updated_at = tick
          goto next_connection
        end

        local x_diff = position.x - neighbour.position.x
        local y_diff = position.y - neighbour.position.y

        -- only one side becomes the sprite parent
        local any_diff = x_diff > 1 or y_diff > 1
        if any_diff then

          connection = {
            updated_at = tick,
            render_configs = {},
            player_sprites = {},
          }

          if x_diff > 1 then
            local sprites = elevated_pipe_sprites("x", x_diff -1)
            for x_offset = 1, x_diff -1 do
              table.insert(connection.render_configs, {
                sprite = sprites[x_offset],
                surface = surfacedata.surface,
                target = {
                  entity = struct.entity,
                  offset = {-x_offset, 0},
                },
                render_layer = tostring(render_layer + 0),
              })
            end
          else
            local sprites = elevated_pipe_sprites("y", y_diff -1)
            for y_offset = 1, y_diff -1 do
              table.insert(connection.render_configs, {
                sprite = sprites[y_offset],
                surface = surfacedata.surface,
                target = {
                  entity = struct.entity,
                  offset = {0, -y_offset},
                },
                render_layer = tostring(render_layer + 0),
              })
            end
          end

          for player_index, player in pairs(players) do
            mod.render_connection_to(connection, player_index)
          end

          struct.connections[neighbour.unit_number] = connection
        end -- any_diff

      end
      ::next_connection::
    end
    ::next_struct::
  end

  -- connections we did not come across stopped existing
  for unit_number, struct in pairs(surfacedata.structs) do
    for other_unit_number, connection in pairs(struct.connections) do
      if connection.updated_at ~= tick then
        for player_index, sprites in pairs(connection.player_sprites) do
          for _, sprite in ipairs(sprites) do
            sprite.destroy()
          end
        end
        struct.connections[other_unit_number] = nil
      end
    end
  end
end

function mod.render_connection_to(connection, player_index)
  assert(type(player_index) == "number")
  connection.player_sprites[player_index] = {}
  for i, render_config in ipairs(connection.render_configs) do
    connection.player_sprites[player_index][i] = rendering.draw_sprite(render_config)
    connection.player_sprites[player_index][i].players = {player_index}
  end
end

script.on_event(defines.events.on_player_created, function(event)
  mod.foreach_struct(function(struct)
    for _, connection in pairs(struct.connections) do
      mod.render_connection_to(connection, event.player_index)
    end
  end)
end)

script.on_event(defines.events.on_player_removed, function(event)
  mod.foreach_struct(function(struct)
    for _, connection in pairs(struct.connections) do
      local player_sprites = connection.player_sprites[event.player_index]
      if player_sprites then
        for _, sprite in ipairs(player_sprites) do
          sprite.destroy()
        end
        connection.player_sprites[event.player_index] = nil
      end
    end
  end)
end)
