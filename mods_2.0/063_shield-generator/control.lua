require("shared")

local app = {}

script.on_init(function()
  storage.platformdata = {}
  storage.deathrattles = {}
end)

function app.listen_for_damage(boolean)
  assert(boolean ~= nil)
  if boolean then
    log("started listening for impact damage for every surface.")
    script.on_event(defines.events.on_entity_damaged, function (event)
      local entity = event.entity
      if not storage.platformdata[entity.surface.index] then return end

      if event.source and event.source.type == "asteroid" then
        event.entity.health = event.entity.health + event.final_damage_amount
      end
    end, {
      {filter = "damage-type", type = "impact"}
    })
  else
    log("stopped listening for impact damage for every surface.")
    script.on_event(defines.events.on_entity_damaged, nil)
  end
end

script.on_load(function()
  if next(storage.platformdata) then
    app.listen_for_damage(true)
  end
end)

function app.on_created_tile(event)
  if event.tile and event.tile.name ~= "space-platform-foundation" then return end -- raise_script_set_tiles has no event.tile

  local surface = game.get_surface(event.surface_index) --[[@as LuaSurface]]
  if not surface.platform then return end

  if not storage.platformdata[surface.index] then return end -- no shield generators yet

  for _, tile in ipairs(event.tiles) do
    if event.tile or tile.name == "space-platform-foundation" then
      local position = {tile.position.x + 0.5, tile.position.y + 0.5}
      local cover = surface.create_entity{
        name = mod_prefix .. "simple-entity",
        force = "neutral",
        position = position,
      }
    end
  end
end

for _, event in ipairs({
  defines.events.on_player_built_tile,
  defines.events.on_robot_built_tile,
  defines.events.on_space_platform_built_tile,
  defines.events.script_raised_set_tiles,
  -- todo: on_area_cloned.clone_tiles
}) do
  script.on_event(event, app.on_created_tile)
  -- script.on_event(event, on_created_tile, {
  --   {filter = "name", name = "space-platform-foundation"},
  -- })
end

function app.clear_simple_entities(surface)
  local simple_entities = surface.find_entities_filtered{
    name = mod_prefix .. "simple-entity",
  }
  for _, simple_entity in ipairs(simple_entities) do
    simple_entity.destroy()
  end
end

function app.on_created_entity(event)
  local entity = event.entity or event.destination

  if entity.name == mod_prefix .. "simple-entity" then
    return entity.destroy()
  end

  -- start listening if there were no platforms with a shield generator yet
  if not next(storage.platformdata) then
    app.listen_for_damage(true)
  end

  local platformdata = storage.platformdata[entity.surface.index]
  if not platformdata then
    platformdata = {
      surface = entity.surface,
      shield_generators = {},
    }
    storage.platformdata[entity.surface.index] = platformdata
  end

  platformdata.shield_generators[entity.unit_number] = entity
  storage.deathrattles[script.register_on_object_destroyed(entity)] = {"shield-generator", entity.surface.index}

  app.clear_simple_entities(entity.surface) -- simple way to prevent duplicates if someone ever places more per-platform
  for _, tile_position in ipairs(entity.surface.get_connected_tiles({0, 0}, {"space-platform-foundation"}, true)) do
    entity.surface.create_entity{
      name = mod_prefix .. "simple-entity",
      force = "neutral",
      position = {tile_position.x + 0.5, tile_position.y + 0.5},
    }
  end
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, app.on_created_entity, {
    {filter = "name", name = mod_name},
    {filter = "name", name = mod_prefix .. "simple-entity"},
  })
end

local deathrattles = {
  ["shield-generator"] = function (deathrattle)
    local platformdata = storage.platformdata[deathrattle[2]]
    if platformdata then

      for unit_number, entity in pairs(platformdata.shield_generators) do
        if not entity.valid then platformdata.shield_generators[unit_number] = nil end
      end

      if not next(platformdata.shield_generators) then
        storage.platformdata[deathrattle[2]] = nil
        log(string.format("platform #%d (%s) no longer has any shield generators.", platformdata.surface.index, platformdata.surface.name))
        app.clear_simple_entities(platformdata.surface)
      end

      if not next(storage.platformdata) then
        app.listen_for_damage(false)
      end

    end
  end,
}

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    deathrattles[deathrattle[1]](deathrattle)
  end
end)
