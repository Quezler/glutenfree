local Update = {}

local function override_quality(items, quality_name)
  if quality_name == "normal" then
    quality_name = nil
  end

  for _, item in ipairs(items) do
    item.quality = quality_name
  end

  return items
end

-- {count = number, name = string, quality = string}
function Update.get_missing_items_for(target)
  local target_name = target.name

  if target_name == "entity-ghost" or target_name == "tile-ghost" then
    return override_quality(target.ghost_prototype.items_to_place_this, target.quality.name)
  elseif target_name == "item-request-proxy" then
    return target.item_requests
  elseif target.to_be_upgraded() then
    local entity_prototype, quality_prototype = target.get_upgrade_target()
    return override_quality(entity_prototype.items_to_place_this, quality_prototype.name)
  elseif target.type == "cliff" then
    return {{name = "cliff-explosives", count = 1}}
  end

  game.print(string.format("[fulgoran-construction-hub] entity %s (%s) is in the queue with no clear task, someone cancel an upgrade?", target_name, target.type))
end

-- shouldn't be too expensive, generally if you have missing stuff its a lot of the same, so name lookup is fine.
function Update.add_item(surfacedata, item)
  for _, request in ipairs(surfacedata.requests) do
    -- if request.name == item.name and (request.quality or "normal") == (item.quality or "normal") then
    if request.name == item.name and request.quality == item.quality then -- i suppose a nil == nil works here too.
      request.count = request.count + item.count
      return
    end
  end

  table.insert(surfacedata.requests, item)
end

-- find the first hub in this network (each network should only have one)
local function find_hub_in_network(surfacedata, network)
  for unit_number, hub in pairs(surfacedata.hubs) do
    if hub.entity.valid and hub.entity.logistic_network and hub.entity.logistic_network == network then
      return hub
    end
  end
end

function find_item_stack(inventory, item)
  for slot = 1, #inventory do
    local itemstack = inventory[slot]
    if itemstack.valid_for_read and itemstack.name == item.name and itemstack.quality.name == (item.quality or "normal") then
      return itemstack, slot
    end
  end
end

function Update.deliver_or_request_item(surfacedata, target, item)
  local target_force = target.force
  if target.type == "cliff" then target_force = game.forces["player"] end
  assert(target_force.name ~= "neutral")

  local networks = target.surface.find_logistic_networks_by_construction_area(target.position, target_force)
  if #networks == 0 then goto request_it end

  for _, network in ipairs(networks) do
    local destination_hub = find_hub_in_network(surfacedata, network)
    if destination_hub == nil then goto next_network end

    -- and yes i know the destination will try to feed itself from its own trash, not harmful tho.
    local destination_inventory = destination_hub.entity.get_inventory(defines.inventory.chest)
    local destination_stack = destination_inventory.find_empty_stack()
    if destination_stack == nil then
      destination_inventory = destination_hub.entity.get_inventory(defines.inventory.logistic_container_trash)
      destination_stack = destination_inventory.find_empty_stack()
    end
    if destination_stack == nil then goto request_it end

    for unit_number, hub in pairs(surfacedata.hubs) do
      if hub.entity.valid and hub.entity ~= destination_hub.entity then
        local inventory = hub.entity.get_inventory(defines.inventory.chest)
        local itemstack = find_item_stack(inventory, item)

        -- if they match just give it all we have, better than calling remove & insert for thing that have data.
        -- in either case there will be a bunch of overdelivery, but it should not matter other than for autism.
        if itemstack then
          assert(itemstack.swap_stack(destination_stack))
          return
        end
      end
    end

    ::next_network::
  end

  ::request_it::
  Update.add_item(surfacedata, item)
end

function Update.on_tick(event)
  for surface_index, _ in pairs(storage.surfaces_to_update) do
    local surfacedata = storage.surfacedata[surface_index]
    assert(surfacedata, 'surface got deleted?')

    if surfacedata.old_alerts_empty then
      assert(table_size(surfacedata.new_alerts) > 0, 'how can there be 0 new alerts?')
      surfacedata.old_alerts = surfacedata.new_alerts
      surfacedata.old_alerts_empty = false

      surfacedata.new_alerts = {}
      surfacedata.requests = {}
    end

    -- todo: check if this skip causes no side effects
    if surfacedata.total_hubs == 0 then
      goto next_surface
    end

    -- for now this checks one alert target per tick per surface
    for registration_number, surface_alert in pairs(surfacedata.old_alerts) do
      local target = surface_alert.target
      if target.valid then
        local missing_items = Update.get_missing_items_for(target) or {}
        -- override_quality(missing_items, target.quality.name)
        for _, item in ipairs(missing_items) do
          Update.deliver_or_request_item(surfacedata, target, item)
        end
      end
      surfacedata.old_alerts[registration_number] = nil
      goto next_surface
    end

    assert(table_size(surfacedata.old_alerts) == 0, 'goto has forsaken thou.')
    surfacedata.old_alerts_empty = true

    -- log(serpent.block(surfacedata.requests))

    for unit_number, hub in pairs(surfacedata.hubs) do
      if hub.entity.valid == false then
        surfacedata.hubs[unit_number] = nil
        goto next_hub
      end

      local logistic_point = hub.entity.get_logistic_point(defines.logistic_member_index.logistic_container)
      logistic_point.trash_not_requested = true
      logistic_point.remove_section(1) -- remove the old section (also, the player might have named it)
      logistic_point.remove_section(1) -- remove any sections a player might have added (-1 each cycle)
      local section = logistic_point.add_section()

      for i, request in pairs(surfacedata.requests) do
        section.set_slot(i, {
          value = {type = "item", name = request.name, quality = request.quality or "normal", comparator = '='},
          min = request.count,
        })
      end

      ::next_hub::
    end

    -- log('updated ' .. game.surfaces[surface_index].name)

    -- cease updating if there aren't already new alerts waiting
    if table_size(surfacedata.new_alerts) == 0 then
      storage.surfaces_to_update[surface_index] = nil
    end

    ::next_surface::
  end
end

return Update
