local entity_types_with_module_slots = {"mining-drill", "furnace", "assembling-machine", "lab", "beacon", "rocket-silo"}

local module_inventory_for_type = {
  ["furnace"           ] = defines.inventory.furnace_modules,
  ["assembling-machine"] = defines.inventory.assembling_machine_modules,
  ["lab"               ] = defines.inventory.lab_modules,
  ["mining-drill"      ] = defines.inventory.mining_drill_modules,
  ["rocket-silo"       ] = defines.inventory.rocket_silo_modules,
  ["beacon"            ] = defines.inventory.beacon_modules,
}

script.on_init(function(event)
  -- global.entity_queue = {}
  -- global.do_not_take_from = {}
end)

local function offer_proxy(proxy, item_name, item_count)
  local item_requests = proxy.item_requests
  local to_insert = math.min(assert(item_requests[item_name]), item_count)

  local inserted = proxy.proxy_target.get_inventory(module_inventory_for_type[proxy.proxy_target.type]).insert({name = item_name, count = to_insert})
  assert(inserted > 0)

  item_requests[item_name] = item_requests[item_name] - inserted
  assert(item_requests[item_name] >= 0)

  proxy.item_requests = item_requests -- proxies die when all requests are 0
  return inserted
end

local function add_to_proxy_for(entity, item_name, item_count)
  local proxy = entity.surface.find_entity("item-request-proxy", entity.position)
  if proxy then
    assert(proxy.proxy_target == entity)
    local item_requests = proxy.item_requests
    item_requests[item_name] = (item_requests[item_name] or 0) + item_count
    proxy.item_requests = item_requests
  else
    proxy = entity.surface.create_entity{
      name = "item-request-proxy",
      force = entity.force,
      position = entity.position,
      modules = {[item_name] = item_count},
      target = entity,
    }
  end
end

local function try_to_take_modules_from(entity, wishlist)
  local inventory = entity.get_inventory(module_inventory_for_type[entity.type])
  assert(inventory, string.format("%s (%s) has no module inventory.", entity.name, entity.type))

  for item_name, item_count in pairs(inventory.get_contents()) do
    if wishlist[item_name] then
      for proxy_unit_number, proxy in pairs(wishlist[item_name]) do
        local inserted = offer_proxy(proxy, item_name, item_count)
        local removed = inventory.remove({name = item_name, count = inserted})
        assert(removed == inserted)
        add_to_proxy_for(entity, item_name, removed)

        -- if proxy died or the request for this item reached zero (nilled)
        if proxy.valid == nil or proxy.item_requests[item_name] == nil then
          wishlist[item_name][proxy_unit_number] = nil
        end

        item_count = item_count - removed
        assert(item_count >= 0)
        if item_count == 0 then goto continue end
      end
    end
    ::continue::
  end
end

script.on_event(defines.events.on_player_selected_area, function(event)
  if event.item ~= "lifejacket-soon" then return end

  local player = assert(game.get_player(event.player_index))

  -- module name to an array of proxies
  local wishlist = {}

  for _, proxy in ipairs(event.entities) do
    assert(proxy.proxy_target)
    assert(proxy.proxy_target.unit_number)

    for module_name, module_count in pairs(proxy.item_requests) do
      wishlist[module_name] = wishlist[module_name] or {}
      wishlist[module_name][proxy.unit_number] = proxy -- this proxy wants 1+ of this module
    end
  end

  local skip_unit_number = {}

  -- instead of manually checking the bounding boxes we'll just piggyback on searching the selected again area ourselves.
  local selected_entities = event.surface.find_entities_filtered{
    type = entity_types_with_module_slots,
    force = player.force,
  }
  for _, selected_entity in ipairs(selected_entities) do
    skip_unit_number[assert(selected_entity.unit_number)] = true
  end


  for _, surface in pairs(game.surfaces) do
    local entities = surface.find_entities_filtered{
      type = entity_types_with_module_slots,
      force = player.force,
    }

    for _, entity in ipairs(entities) do
      if not skip_unit_number[assert(entity.unit_number)] then
        try_to_take_modules_from(entity, wishlist)
      end
    end
  end

end)
