local se_util = require('__space-exploration__.scripts.util')

local inventory_types = {defines.inventory.character_main, defines.inventory.character_trash}

local check_for_passengers = {
  ['se-space-capsule-_-vehicle'] = true,
  ['se-character-_-seat'] = true,
}

--

local Capsule = {}

function Capsule.on_init()
  global.enderchests = {}
  global.containers = {}
  global.emergency_burns = {}
end

function Capsule.on_load()
  if table_size(global.enderchests) > 0 then script.on_event(defines.events.on_tick, Capsule.on_tick) end
end

-- require('__space-exploration__.control.lua')
function gui_element_or_parent(element, name)
  if not (element and element.valid) then return end
  if element.name == name then
    return element
  elseif element.parent then
    return gui_element_or_parent(element.parent, name)
  end
end

function Capsule.on_gui_selection_state_changed(event)
  if not event.element then return end
  local element = event.element
  if element.name == 'space-capsule-list-zones' then
    local root = gui_element_or_parent(element, 'se-space-capsule-gui')
    if root then      
      local emergency_burn = element.items[element.selected_index][1] == 'space-exploration.space_jump_emergency_burn'

      -- assume the container was created right before the vehicle (unless there's clone crap going on)
      container_unit_number = root.tags['unit_number'] - 1
      global.emergency_burns[container_unit_number] = emergency_burn
    end
  end
end

function Capsule.on_gui_opened(event)
  if not event.entity then return end
  if event.entity.name ~= 'se-space-capsule' then return end
  
  local player = game.get_player(event.player_index)
  local root = player.gui.relative['se-space-capsule-gui']
  local element = se_util.find_first_descendant_by_name(root, 'space-capsule-list-zones')

  local emergency_burn = element.items[element.selected_index][1] == 'space-exploration.space_jump_emergency_burn'
  container_unit_number = root.tags['unit_number'] - 1
  global.emergency_burns[container_unit_number] = emergency_burn
end

-- We do not know which characters that are currently in the process of an emergency burn are in this,
-- i decided not to count how many ticks players were in their burn, in case timings change mid migration.
-- Therefore this function restores each inventory of each character currently in emergency burn transit.
-- Any players who were still in the launch sequence should have their inventory saved again by on_tick.
-- (and the players that did switch orbit at that moment will no longer have a valid passenger anyways)
function Capsule.script_raised_built(event)
  -- game.print(event.tick .. ' scorched capsule created.')

  for unit_number, enderchest in pairs(global.enderchests) do
    if enderchest.passenger.valid then

      for _, inventory_type in ipairs(inventory_types) do
        local from = enderchest.inventories[inventory_type]
        local to = enderchest.passenger.get_inventory(inventory_type)
    
        se_util.swap_inventories(from, to) -- already sorted & merged
      end

      enderchest.passenger.character_personal_logistic_requests_enabled = enderchest.character_personal_logistic_requests_was_enabled
    end
  end
end

-- se-space-capsule-_-vehicle
-- se-character-_-seat

-- Listen to when a player enters a capsule in order to register it,
-- since we cannot guarantee each capsule in existance raised build.
function Capsule.on_player_driving_changed_state(event)
  -- game.print(event.tick .. 'on_player_driving_changed_state')

  local player = game.get_player(event.player_index)
  if player.vehicle and player.vehicle.name == 'se-space-capsule-_-vehicle' then

    local container = player.vehicle.surface.find_entity('se-space-capsule', player.vehicle.position)
    if not container then return end -- currently landing in a normal capsule?

    global.containers[script.register_on_entity_destroyed(container)] = {
      -- container = container, -- why even bother, it'll be invalid when this triggers anyways
      position = container.position,
      surface = container.surface,
    }

  end
end

-- triggers when a capsule starts launching
function Capsule.on_entity_destroyed(event)
  local container = global.containers[event.registration_number]
  if container then global.containers[event.registration_number] = nil

    local emergency_burn = global.emergency_burns[event.unit_number]
    global.emergency_burns[event.unit_number] = nil -- used one time
    if emergency_burn == nil then error('could not determine if this capsule launch was an emergency or not.') end
    if emergency_burn == false then return end -- no need to save the inventory, and there would be no raised scorched to restore at anyways.

    -- > Depending on when a given entity is destroyed, this event will be fired at the end of the current tick or at the end of the next tick.
    -- Therefore we can't know for sure if they're in the _-vehicle or a _-seat at this point in time, so check both to find any passengers.
    local vehicles = container.surface.find_entities({container.position, container.position})
    for _, vehicle in ipairs(vehicles) do
      if check_for_passengers[vehicle.name] then
        for _, passenger in ipairs({vehicle.get_driver(), vehicle.get_passenger()}) do

          local struct = {
            passenger = passenger,
            inventories = {},
            character_personal_logistic_requests_was_enabled = passenger.character_personal_logistic_requests_enabled,
          }

          -- prevent logistic bots resupplying the now empty inventories
          passenger.character_personal_logistic_requests_enabled = false

          for _, inventory_type in ipairs(inventory_types) do
            local from = passenger.get_inventory(inventory_type)
            local to = game.create_inventory(#from)
      
            -- print(serpent.block( from.get_contents() ))
      
            se_util.swap_inventories(from, to)
            struct.inventories[inventory_type] = to
          end

          global.enderchests[passenger.unit_number] = struct
          script.on_event(defines.events.on_tick, Capsule.on_tick)

        end
      end
    end

  end
end

-- bots & mods can still put items into the character's inventory while launching, so keep checking for new stuff
function Capsule.on_tick(event)
  for unit_number, enderchest in pairs(global.enderchests) do
    if not enderchest.passenger.valid then

      -- game.print(event.tick .. ' passenger no longer valid.')
      global.enderchests[unit_number] = nil

      for inventory_type, inventory in pairs(enderchest.inventories) do
        inventory.destroy()
      end

    else
      for _, inventory_type in ipairs(inventory_types) do
        local from = enderchest.passenger.get_inventory(inventory_type)
        if not from.is_empty() then
          -- game.print(event.tick .. ' items added to character: ' .. serpent.line( from.get_contents() ))
          local to = enderchest.inventories[inventory_type]

          for i = 1, #from do
            if from[i].valid_for_read then
              local stack = to.find_empty_stack(from[i].name)

              if not stack or not stack.transfer_stack(from[i]) then
                -- spill what couldn't fit into this inventory_type anymore (logistic bots oversending? constr. drones?)
                enderchest.passenger.surface.spill_item_stack(enderchest.passenger.position, from[i], false, nil, false)
                from[i].clear()
              else
                to.sort_and_merge()
              end

            end
          end

        end
      end
    end
  end

  if table_size(global.enderchests) == 0 then script.on_event(defines.events.on_tick, nil) end
end

return Capsule
