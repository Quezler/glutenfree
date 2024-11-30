require("util")

local Handler = {}

local function refresh_surfacedata()
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
    }
  end
end

script.on_init(function()
  storage.surfacedata = {}
  refresh_surfacedata()

  storage.surface = game.planets["undersea-data-cable"].create_surface()
  storage.surface.generate_with_lab_tiles = true
end)

script.on_configuration_changed(function()
  refresh_surfacedata()
end)

script.on_event(defines.events.on_surface_created, refresh_surfacedata)
script.on_event(defines.events.on_surface_deleted, refresh_surfacedata)

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  local position = {x = math.floor(entity.position.x), y = math.floor(entity.position.y)}
  game.print(serpent.line(position))

  -- if a player visits the hidden surface then the chunks start actually generating, and overriding any already set tiles,
  -- so we request that chunk to generate and then force the game or the current set tile is very likely to get overwritten.
  -- storage.surface.request_to_generate_chunks(position, 0)
  -- storage.surface.force_generate_chunk_requests()

  -- game.print(event.tick)

  -- storage.surface.set_tiles{
  --   tiles = {
  --     {position = entity.position, name = "concrete"},
  --   },
  --   correct_tiles = false,
  --   remove_colliding_entities = false,
  --   remove_colliding_decoratives = false,
  -- }

  -- game.print(storage.surface.get_tile(position).name)
  storage.surface.set_tiles(
    {
      {position = position, name = "concrete"},
    }
  )
  game.print(storage.surface.get_tile(position).name)
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = "name", name = "undersea-data-cable"},
  })
end

-- *new 50x50 world*
-- /c game.create_surface("lab")
-- /c game.surfaces["lab"].generate_with_lab_tiles = true
-- /c game.print(game.surfaces["lab"].get_tile(0, 0).name) -- luatile invalid
-- /c game.surfaces["lab"].request_to_generate_chunks({0, 0}, 0)
-- /c game.surfaces["lab"].force_generate_chunk_requests()
-- /c game.print(game.surfaces["lab"].get_tile(0, 0).name) -- lab dark 1
-- /c game.surfaces["lab"].set_tiles({{position = {0, 0}, name = "concrete"}})
-- /c game.print(game.surfaces["lab"].get_tile(0, 0).name) -- concrete
-- /c game.player.teleport({0, 0}, "lab")
-- /c game.print(game.surfaces["lab"].get_tile(0, 0).name) -- concrete

-- *new 50x50 world*
-- /c game.create_surface("lab").generate_with_lab_tiles = true
-- /c game.print(game.surfaces["lab"].get_tile(0, 0).name) -- luatile invalid
-- /c game.surfaces["lab"].request_to_generate_chunks({0, 0}, 0) game.surfaces["lab"].force_generate_chunk_requests() game.surfaces["lab"].set_tiles({{position = {0, 0}, name = "concrete"}})
-- /c game.print(game.surfaces["lab"].get_tile(0, 0).name) -- lab dark 1
