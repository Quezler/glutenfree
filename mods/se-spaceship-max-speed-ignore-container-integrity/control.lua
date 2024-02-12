local Spaceship = require('__space-exploration-scripts__.spaceship')
Spaceship.name_spaceship_floor = Spaceship.names_spaceship_floors[1]

-- we need to know when the spaceship is done with the integrity check, since "stop" calls Spaceship.check_integrity_stress(spaceship),
-- the trick we will use is creating entities on created tiles that will be destroyed by the `entity.damage(150` detatched tiles mechanic,
-- once those entities get destoyed its a pretty fair bet that in the next tick the spaceship's integrity is valid and completely done.
local function register_on_integrity_check_passed_event(surface)
  local tiles = {}

  local engines = surface.find_entities_filtered{name = Spaceship.names_engines}
  if #engines == 0 then error('this mod currently cannot handle in-flight spaceships without engines.') end

  for _, entity in ipairs(engines) do
    local box = entity.bounding_box
    local engine_y = math.floor(box.right_bottom.y) + 1
    local engine_x = math.floor((box.left_top.x + box.right_bottom.x) / 2)

    -- 2 tiles under even width engines, and 1 tile under odd width engines
    if entity.position.x % 1 < 0.25 or entity.position.x % 1 > 0.75 then
      table.insert(tiles, {x = engine_x - 1, y = engine_y})
    end
    table.insert(tiles, {x = engine_x, y = engine_y})
  end

  local set_tiles = {}
  local lamps = {}

  for _, position in ipairs(tiles) do
    if surface.get_tile(position).name ~= Spaceship.name_spaceship_floor then -- if there is already spaceship floor here, the engine is likely inside/stacked
      local lamp = surface.create_entity{
        name = 'small-lamp',
        position = position,
      }

      table.insert(lamps, lamp)
      table.insert(set_tiles, {position = position, name = Spaceship.name_spaceship_floor})
    end
  end

  if #set_tiles > 0 then
    surface.set_tiles(set_tiles)
  else
    error('at least one engine must have space tiles below it.') -- supposedly also triggers if you try to register it twice
  end

  local index = global.on_integrity_check_passed_event_index
  global.on_integrity_check_passed_event_index = index + 1

  local struct = {
    surface = surface,
    lamps = {},
  }

  for _, lamp in ipairs(lamps) do
    local registration_number = script.register_on_entity_destroyed(lamp)
    global.on_integrity_check_passed_event[registration_number] = index

    table.insert(struct.lamps, {
      entity = lamp,
      position = lamp.position,
      registration_number = registration_number,
    })
  end

  global.on_integrity_check_passed_events[index] = struct
end

commands.add_command('se-spaceship-max-speed-ignore-container-integrity', nil, function(command)
  local player = game.get_player(command.player_index)
  local surface = player.surface
  game.print(surface.name)

  if string.find(surface.name, "spaceship-") then
    local containers = surface.find_entities_filtered{type = {"container", "logistic-container"}}

    local ghosts = {} -- not actual ghosts, just a singular/prular combo that makes sense to be used within create_entity

    for _, container in ipairs(containers) do

      local inventory = container.get_inventory(defines.inventory.chest)
      local ghost = {
        name = container.name,
        force = container.force,
        position = container.position,

        inventory = game.create_inventory(#inventory),
      }

      for slot = 1, #inventory do
        inventory[slot].swap_stack(ghost.inventory[slot])
      end
      
      -- todo: preserve wires
      -- todo: preserve signals

      container.destroy()
      table.insert(ghosts, ghost)
    end

    -- trigger Spaceship.on_entity_created(event)
    surface.create_entity{
      name = 'flying-text',
      position = {0, 0},
      text = {'achievement-name.so-long-and-thanks-for-all-the-fish'},
      raise_built = true,
    }

    register_on_integrity_check_passed_event(surface)
    global.surface_index_to_ghosts[surface.index] = ghosts
  end
end)

script.on_init(function(event)
  global.on_integrity_check_passed_event_index = 0
  global.on_integrity_check_passed_event = {} -- registration_number to index
  global.on_integrity_check_passed_events = {} -- index to struct

  global.surface_index_to_ghosts = {}
  global.surfaces_to_restore_at_tick = {}
end)

local function restore_ghosts(surface)
  local ghosts = global.surface_index_to_ghosts[surface.index]
  if ghosts then global.surface_index_to_ghosts[surface.index] = nil

    for _, ghost in ipairs(ghosts) do
      local container = surface.create_entity{
        name = ghost.name,
        force = ghost.force,
        position = ghost.position,
      }

      local inventory = container.get_inventory(defines.inventory.chest)

      for slot = 1, #inventory do
        inventory[slot].swap_stack(ghost.inventory[slot])
      end

      ghost.inventory.destroy()
    end

  end
end

script.on_event(defines.events.on_entity_destroyed, function(event)
  local struct_id = global.on_integrity_check_passed_event[event.registration_number]
  if struct_id then
    local struct = global.on_integrity_check_passed_events[struct_id]
    if struct then

      local set_tiles = {}

      for _, lamp in ipairs(struct.lamps) do
        lamp.entity.destroy()
        table.insert(set_tiles, {position = lamp.position, name = 'se-space'})
        global.on_integrity_check_passed_event[lamp.registration_number] = nil
      end

      if #set_tiles > 0 then
        struct.surface.set_tiles(set_tiles)
      end

      global.on_integrity_check_passed_events[struct_id] = nil

      game.print('integrity check done!')
      local at_tick = event.tick + 1
      global.surfaces_to_restore_at_tick[at_tick] = global.surfaces_to_restore_at_tick[at_tick] or {}
      global.surfaces_to_restore_at_tick[at_tick][struct.surface.index] = struct.surface
    end
  end
end)

script.on_event(defines.events.on_tick, function(event)
  local at_tick = event.tick
  local surfaces_to_restore = global.surfaces_to_restore_at_tick[at_tick]
  if surfaces_to_restore then global.surfaces_to_restore_at_tick[at_tick] = nil
    for surface_index, surface in pairs(surfaces_to_restore) do
      restore_ghosts(surface)
    end
  end
end)
