local mod_prefix = 'glutenfree-se-spaceship-juicebox-'
local se_util = require('__space-exploration__.scripts.util')

--

local Juicebox = {}

-- manual alignment
Juicebox.offset = {
  x = 32 - 31.0234375,
  y = 13 - 13.015625,
}

function Juicebox.on_init()
  global.deathrattles = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = 'se-spaceship-console'})) do
      Juicebox.on_created_entity({tick = game.tick, entity = entity})
    end
  end
end

-- when the spaceship console is initially placed
function Juicebox.on_created_entity(event)
  local entity = event.created_entity or event.entity -- or event.destination
  -- game.print(event.tick .. ' creating a new juicebox')

  local juicebox = entity.surface.create_entity({
    name = mod_prefix .. 'storage',
    position = {entity.position.x - Juicebox.offset.x, entity.position.y - Juicebox.offset.y},
    force = entity.force,
  })

  global.deathrattles[script.register_on_entity_destroyed(entity)] = {console = entity, juicebox = juicebox}
end

function Juicebox.on_entity_destroyed(event)
  local deathrattle = global.deathrattles[event.registration_number]
  if deathrattle then global.deathrattles[event.registration_number] = nil
    -- game.print(event.tick .. ' deathrattled')
    if deathrattle.juicebox.valid then

      local inventory = deathrattle.juicebox.get_inventory(defines.inventory.chest)
--       game.print('is_empty = ' .. serpent.line(inventory.is_empty()))
      if not inventory.is_empty() then
        for slot = 1, #inventory do
          if inventory[slot].valid_for_read then
            deathrattle.juicebox.surface.spill_item_stack(deathrattle.juicebox.position, inventory[slot], false, deathrattle.juicebox.force, false)
          end
        end
      end

      deathrattle.juicebox.destroy()
    end

  end
end

function Juicebox.on_entity_cloned(event)
  -- game.print(event.tick .. ' ' .. event.destination.name)

  -- the juicebox has been cloned/moved, empty the old
  if event.source.name == mod_prefix .. 'storage' then
    event.source.destroy()
    return
  end

  if event.source.name == 'se-spaceship-console' then

    local position = {event.destination.position.x - Juicebox.offset.x, event.destination.position.y - Juicebox.offset.y}
    local juicebox = nil
      or event.destination.surface.find_entity(mod_prefix .. 'storage', position)
      or event.destination.surface.find_entity(mod_prefix .. 'active-provider', position)

    local juicebox_mode = mod_prefix .. 'storage'
    local logistic_network = event.destination.surface.find_logistic_network_by_position(position, event.destination.force)
    if logistic_network and Juicebox.logistic_network_has_available_storages_other_than_just_juiceboxes(logistic_network) then
      juicebox_mode = mod_prefix .. 'active-provider'
    end
    -- game.print('juicebox_mode = ' .. juicebox_mode)

    if juicebox.name ~= juicebox_mode then
      local old_juicebox = juicebox -- fast replace doesn't work, presumably because there are no collision layers

      juicebox = juicebox.surface.create_entity({
        name = juicebox_mode,
        force = event.source.force, -- use the force of the console, in case of capture changes and such
        position = position,
        -- fast_replace = true
      })

      se_util.swap_inventories(old_juicebox.get_inventory(defines.inventory.chest), juicebox.get_inventory(defines.inventory.chest))
      old_juicebox.destroy()
    end

    global.deathrattles[script.register_on_entity_destroyed(event.destination)] = {console = event.destination, juicebox = juicebox}
  end
end

function Juicebox.logistic_network_has_available_storages_other_than_just_juiceboxes(logistic_network)
  for _, storage in ipairs(logistic_network.storages) do
    if storage.name ~= mod_prefix .. 'storage' and storage.storage_filter == nil then
      return true
    end
  end

  return false
end

return Juicebox
