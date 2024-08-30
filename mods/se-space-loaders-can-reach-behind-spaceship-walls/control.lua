local util = require('util')

local Handler = {}

function Handler.on_init()
  global.surfacedata = {}
  global.deathrattles = {}

  for _, surface in pairs(game.surfaces) do
    Handler.on_surface_created({surface_index = surface.index})

    for _, entity in pairs(surface.find_entities_filtered{name = {'kr-se-loader', 'kr-se-loader-spaceship'}}) do
      Handler.on_created_entity({entity = entity})
    end
  end
end

script.on_init(Handler.on_init)

script.on_load(function() -- todo: remove before launch
  if global.surfacedata == nil then
    script.on_nth_tick(1, function(event)
      Handler.on_init()
      script.on_nth_tick(1, nil)
    end)
  end
end)

function Handler.on_surface_created(event)
  global.surfacedata[event.surface_index] = {
    loaders_pointed_at = {},
  }
end

function Handler.on_surface_deleted(event)
  global.surfacedata[event.surface_index] = nil
end

script.on_event(defines.events.on_surface_created, Handler.on_surface_created)
script.on_event(defines.events.on_surface_deleted, Handler.on_surface_deleted)

function Handler.get_wall_position(loader_entity)
  local direction = loader_entity.loader_type == "input" and loader_entity.direction or util.oppositedirection(loader_entity.direction)
  local wall_position = util.moveposition({loader_entity.position.x, loader_entity.position.y}, direction, 1)

  return wall_position
end

function Handler.point_loader_at(surfacedata, loader, wall_position)
  local wall_key = util.positiontostr(wall_position)
  surfacedata.loaders_pointed_at[wall_key] = surfacedata.loaders_pointed_at[wall_key] or {}
  surfacedata.loaders_pointed_at[wall_key][loader.unit_number] = loader
end

function Handler.wakeup_loaders_pointed_at(surfacedata, position)
  local loaders = surfacedata.loaders_pointed_at[util.positiontostr(position)]
  if loaders == nil then return end

  for _, loader in pairs(loaders) do
    if loader.valid then
      Handler.on_created_entity({entity = loader})
    end
  end
end

function Handler.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  local surface = entity.surface
  local surfacedata = global.surfacedata[surface.index]

  if entity.name == 'se-spaceship-wall' then
    return Handler.wakeup_loaders_pointed_at(surfacedata, entity.position)
  end

  local wall_position = Handler.get_wall_position(entity)

  if entity.name == 'kr-se-loader-spaceship' then
    local wall_entity = surface.find_entity('se-spaceship-wall', wall_position)
    if wall_entity then
      global.deathrattles[script.register_on_entity_destroyed(wall_entity)] = {
        wall_entity = wall_entity,
        wall_surface = wall_entity.surface,
        wall_position = wall_position,
      }

      Handler.point_loader_at(surfacedata, entity, wall_position)
    else
      local loader_entity = Handler.fast_replace_loader(entity, 'kr-se-loader')
      Handler.point_loader_at(surfacedata, loader_entity, wall_position)
    end
  elseif entity.name == 'kr-se-loader' then
    local wall_entity = surface.find_entity('se-spaceship-wall', wall_position)
    if wall_entity then
      local loader_entity = Handler.fast_replace_loader(entity, 'kr-se-loader-spaceship')
      Handler.point_loader_at(surfacedata, loader_entity, wall_position)

      global.deathrattles[script.register_on_entity_destroyed(wall_entity)] = {
        wall_entity = wall_entity,
        wall_surface = wall_entity.surface,
        wall_position = wall_position,
      }
    else
      Handler.point_loader_at(surfacedata, entity, wall_position)
    end
  end
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = 'name', name = 'kr-se-loader'},
    {filter = 'name', name = 'kr-se-loader-spaceship'},
    {filter = 'name', name = 'se-spaceship-wall'},
  })
end

function Handler.on_entity_destroyed(event)
  local deathrattle = global.deathrattles[event.registration_number]
  if deathrattle then global.deathrattles[event.registration_number] = nil
    local wall_surface = deathrattle.wall_surface
    if wall_surface.valid then
      Handler.wakeup_loaders_pointed_at(global.surfacedata[wall_surface.index], deathrattle.wall_position)
    end
  end
end

function Handler.fast_replace_loader(loader, new_name)
  return loader.surface.create_entity{
    name = new_name,
    force = loader.force,
    position = loader.position,
    direction = loader.direction,
    type = loader.loader_type,
    fast_replace = true, spill = false,
    create_build_effect_smoke = false,
  }
end

script.on_event(defines.events.on_entity_destroyed, Handler.on_entity_destroyed)

-- loaders cannot teleport because they have a belt
-- spaceship walls should not ever be teleported by other mods
-- (its on the blacklist for picker dollies, so lets ignore teleporting)
-- script.on_event(defines.events.script_raised_teleported, Handler.script_raised_teleported)

script.on_event(defines.events.on_player_setup_blueprint, function(event)
  local player = assert(game.get_player(event.player_index))
  local item = player.blueprint_to_setup

  local entities = item.get_blueprint_entities()
  if entities == nil then return end

  for _, entity in ipairs(entities) do
    if entity.name == 'kr-se-loader-spaceship' then
      entity.name = 'kr-se-loader'
    end
  end

  item.set_blueprint_entities(entities)
end)

function Handler.garbage_collection(event)
  local stale_loaders = 0

  for surface_index, surfacedata in pairs(global.surfacedata) do
    for wall_key, loaders_pointed_at in pairs(surfacedata.loaders_pointed_at) do
      for unit_number, loader in pairs(loaders_pointed_at) do
        if loader.valid == false then
          stale_loaders = stale_loaders + 1
          loaders_pointed_at[unit_number] = nil
        end
      end

      if table_size(loaders_pointed_at) == 0 then
        log('no loaders pointing here anymore: ' .. wall_key)
        surfacedata.loaders_pointed_at[wall_key] = nil
      end
    end
  end

  log('stale_loaders: ' .. stale_loaders)
end

script.on_nth_tick(60 * 60 * 10, Handler.garbage_collection)
