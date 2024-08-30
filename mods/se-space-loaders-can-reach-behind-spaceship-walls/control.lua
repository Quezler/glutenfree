local human_direction = {
  [defines.direction.north] = 'north',
  [defines.direction.east] = 'east',
  [defines.direction.south] = 'south',
  [defines.direction.west] = 'west',
}

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
  table.insert(surfacedata.loaders_pointed_at[wall_key], loader)
end

function Handler.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  local surface = entity.surface
  local surfacedata = global.surfacedata[surface.index]

  if entity.name == 'se-spaceship-wall' then
    local loaders = surfacedata.loaders_pointed_at[util.positiontostr(entity.position)]
    if loaders == nil then return end
    loaders = {table.unpack(loaders)}
    for _, loader in ipairs(loaders or {}) do
      if loader.valid then
        Handler.on_created_entity({entity = loader})
      end
    end
    return
  end

  local wall_position = Handler.get_wall_position(entity)

  rendering.draw_circle{
    color = {1, 1, 1},
    radius = 0.2,
    filled = true,
    surface = surface,
    target = wall_position,
    time_to_live = 60 * 2.5,
  }

  if entity.name == 'kr-se-loader-spaceship' then
    local wall_entity = surface.find_entity('se-spaceship-wall', wall_position)
    if wall_entity then
      global.deathrattles[script.register_on_entity_destroyed(wall_entity)] = {
        wall_entity = wall_entity,
        loader_entity = entity,
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
        loader_entity = loader_entity,
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
    log('deathrattle')
    local loader_entity = deathrattle.loader_entity
    if loader_entity.valid then
      Handler.on_created_entity({entity = loader_entity})
      -- Handler.on_created_entity({entity = Handler.fast_replace_loader(loader_entity, 'kr-se-loader')})
      -- local new_loader = Handler.fast_replace_loader(loader_entity, 'kr-se-loader')
      -- Handler.point_loader_at(global.surfacedata[new_loader.surface.index], new_loader, Handler.get_wall_position(new_loader))
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
-- script.on_event(defines.events.script_raised_teleported, Handler.script_raised_teleported) -- picker dollies is blocked from moving walls anyways

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
