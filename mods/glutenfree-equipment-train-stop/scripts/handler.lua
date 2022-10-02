local mod_prefix = 'glutenfree-equipment-train-stop-'

local equipmentgrid = require('scripts.equipmentgrid')
local LTN = require('scripts.ltn')

--

local handler = {}

function handler.init()
  global.landmines = {}

  global.entries = {}

  global.tripwires_to_replace = {}

  global.deathrattles = {}
  global.deathrattle_to_entry = {}
end

function handler.on_configuration_changed()
  -- place for future global chances
end

function handler.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  if entity.name ~= mod_prefix .. 'station' then return end

  handler.register_train_stop(entity)
end

function handler.register_train_stop(entity)
  -- game.print(serpent.line(entity.position))

  -- entity.connected_rail sometimes nil polyfill
  local connected_rail_position = entity.position
  if entity.direction == defines.direction.north then
    connected_rail_position.x = connected_rail_position.x - 2
  elseif entity.direction == defines.direction.east then
    connected_rail_position.y = connected_rail_position.y - 2
  elseif entity.direction == defines.direction.south then
    connected_rail_position.x = connected_rail_position.x + 2
  elseif entity.direction == defines.direction.west then
    connected_rail_position.y = connected_rail_position.y + 2
  end

  local template_container = entity.surface.create_entity({
    name = mod_prefix .. 'template-container',
    position = LTN.multiblock_position_for(entity, 'combinator'),
    force = entity.force,
  })
  template_container.destructible = false

  local entry = {
    train_stop = entity,
    unit_number = entity.unit_number,
    connected_rail_position = connected_rail_position,
    template_container = template_container,

    station_registration_number = script.register_on_entity_destroyed(entity)
  }
  global.entries[entry.unit_number] = entry
  global.deathrattles[entry.station_registration_number] = {template_container} -- 1 = template container
  global.deathrattle_to_entry[entry.station_registration_number] = entry.unit_number

  global.tripwires_to_replace[entity.unit_number] = true
end

function handler.replace_tripwire(entity) -- station
  local entry = global.entries[entity.unit_number]

  local landmine = entity.surface.create_entity({
    name = mod_prefix .. 'tripwire',
    force = 'neutral',
    position = entry.connected_rail_position,
  })

  -- listen to when a train collides with the tripwire
  global.landmines[script.register_on_entity_destroyed(landmine)] = entity.unit_number

  -- remote the tripwire if the train stop ends up being removed
  global.deathrattles[entry.station_registration_number][2] = landmine -- 2 = tripwire
end

function handler.on_entity_destroyed(event)
  local deathrattle = global.deathrattles[event.registration_number]
  if deathrattle then
    for _, entity in ipairs(deathrattle) do

      if entity.valid then
        if entity.name == mod_prefix .. 'template-container' then
          local inventory = entity.get_inventory(defines.inventory.chest)
          for slot = 1, #inventory do
            local stack = inventory[slot]
            entity.surface.spill_item_stack(entity.position, stack, false, nil, false)
          end
        end
      end

      entity.destroy()
    end

    -- remove entry from the global table if this registration number refered to the station
    local entry = global.entries[global.deathrattle_to_entry[event.registration_number]]
    if entry then global.entries[entry.unit_number] = nil end
  
    global.deathrattles[event.registration_number] = nil
    return
  end

  local unit_number = global.landmines[event.registration_number]
  if not unit_number then return end

  global.landmines[event.registration_number] = nil

  local entry = global.entries[unit_number]
  if not entry then return end

  -- search center of tripwire + bounding box (.4) + safety margin (.1) 
  local entities = game.get_surface('nauvis').find_entities_filtered({
    area = {
    {entry.connected_rail_position.x - 0.5, entry.connected_rail_position.y - 0.5},
    {entry.connected_rail_position.x + 0.5, entry.connected_rail_position.y + 0.5},
    },
    type = {'locomotive', 'cargo-wagon', 'fluid-wagon', 'artillery-wagon'} -- all rolling stock
  })

  -- try to update any cairage present
  for _, entity in ipairs(entities) do
    -- game.print(_ .. ' ' .. entity.name)
    equipmentgrid.tick_rolling_stock(entry, entity)
  end

  global.tripwires_to_replace[entry.unit_number] = true
end

-- try to replace the tripwire each tick until it is able (aka: the cairage having passed)
function handler.on_tick()
  for unit_number, _ in pairs(global.tripwires_to_replace) do
    global.tripwires_to_replace[unit_number] = nil

    local entry = global.entries[unit_number]
    if entry and entry.train_stop.valid then -- todo: delete if not valid?

      local can_place_entity = entry.train_stop.surface.can_place_entity({
        name = mod_prefix .. 'tripwire',
        position = entry.connected_rail_position,
        force = 'neutral',
      })

      if can_place_entity then
        handler.replace_tripwire(entry.train_stop)
      else
        global.tripwires_to_replace[unit_number] = true -- try again next tick
      end

    end
  end
end

return handler
