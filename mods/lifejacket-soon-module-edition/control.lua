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
  -- log(item_name .. ' ' .. inserted)
  assert(inserted > 0)

  -- log('i am requesting ' .. item_requests[item_name])
  -- log('i will now remove ' .. inserted)

  item_requests[item_name] = item_requests[item_name] - inserted
  -- log('this leaves me with ' .. item_requests[item_name])
  assert(item_requests[item_name] >= 0)

  proxy.item_requests = item_requests -- proxies die when all requests are 0
  -- log('but i keep requesting ' .. proxy.item_requests[item_name])

  return inserted
end

-- control.lua:24: i am requesting 5
-- control.lua:25: i will now remove 1
-- control.lua:28: this leaves me with 4
-- control.lua:32: but i keep requesting 5

local function try_to_take_modules_from(entity, wishlist)
  local inventory = entity.get_inventory(module_inventory_for_type[entity.type])
  assert(inventory, string.format("%s (%s) has no module inventory.", entity.name, entity.type))

  for item_name, item_count in pairs(inventory.get_contents()) do
    if wishlist[item_name] then
      for proxy_unit_number, proxy in pairs(wishlist[item_name]) do
        local inserted = offer_proxy(proxy, item_name, item_count)
        local removed = inventory.remove({name = item_name, count = inserted})
        assert(removed == inserted)

        log(proxy.item_requests[item_name])
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

  -- module name to an array of proxies
  local wishlist = {}

  -- avoid taking modules out of anywhere in the current selection
  local in_selection = {}

  for _, proxy in ipairs(event.entities) do
    assert(proxy.proxy_target)
    assert(proxy.proxy_target.unit_number)

    in_selection[proxy.proxy_target.unit_number] = true

    for module_name, module_count in pairs(proxy.item_requests) do
      wishlist[module_name] = wishlist[module_name] or {}
      wishlist[module_name][proxy.unit_number] = proxy -- this proxy wants 1+ of this module
    end
  end


  local player = assert(game.get_player(event.player_index))
  for _, surface in pairs(game.surfaces) do
    local entities = surface.find_entities_filtered{
      type = entity_types_with_module_slots,
      force = player.force,
    }

    for _, entity in ipairs(entities) do
      assert(entity.unit_number)
      if not in_selection[entity.unit_number] then
        try_to_take_modules_from(entity, wishlist)
      end
    end
  end

end)
