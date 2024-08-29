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

  for _, surface in pairs(game.surfaces) do
    Handler.on_surface_created({surface_index = surface.index})

    for _, entity in pairs(surface.find_entities_filtered{name = {'kr-se-loader', 'kr-se-loader-spaceship'}}) do
      Handler.on_created_entity({entity = entity})
    end
  end

  game.print(serpent.line(global.loader_pointed_at))
end

script.on_init(Handler.on_init)

function Handler.on_surface_created(event)
  global.surfacedata[event.surface_index] = {
    loader_pointed_at = {},
  }
end

function Handler.on_surface_deleted(event)
  global.surfacedata[event.surface_index] = nil
end

script.on_event(defines.events.on_surface_created, Handler.on_surface_created)
script.on_event(defines.events.on_surface_deleted, Handler.on_surface_deleted)

function Handler.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  local surface = entity.surface

  local direction = entity.loader_type == "input" and entity.direction or util.oppositedirection(entity.direction)
  local wall_position = util.moveposition({entity.position.x, entity.position.y}, direction, 1)

  rendering.draw_circle{
    color = {1, 1, 1},
    radius = 0.2,
    filled = true,
    surface = surface,
    target = wall_position,
    time_to_live = 60 * 2.5,
  }

  global.surfacedata[surface.index].loader_pointed_at[util.positiontostr(wall_position)] = entity

  if entity.name == 'kr-se-loader' then
    if surface.find_entity('se-spaceship-wall', wall_position) then
      surface.create_entity{
        name = 'kr-se-loader-spaceship',
        force = entity.force,
        position = entity.position,
        direction = entity.direction,
        type = entity.loader_type,
        fast_replace = true, spill = false,
        create_build_effect_smoke = false,
      }
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
    -- {filter = 'name', name = 'kr-se-loader-spaceship'},
    -- {filter = 'name', name = 'se-spaceship-wall'},
  })
end

-- todo: script_raised_teleported on walls

commands.add_command('loader-through-spaceship-wall', nil, function(command)
  local player = assert(game.get_player(command.player_index))

  -- local selected = player.selected
  -- if selected == nil then return end
  -- if selected.name ~= 'kr-se-loader-spaceship' then return end

  Handler.on_init()
end)

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
