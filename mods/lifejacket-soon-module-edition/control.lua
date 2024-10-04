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
end)

script.on_event(defines.events.on_player_selected_area, function(event)
  if event.item ~= "lifejacket-soon" then return end

  -- table keyed by module name, value is an array of proxies wanting one or more of that module name
  -- table keyed by module name, value is an array of proxies wanting one of them, proxies may appear multiple times
  local routing = {}

  -- avoid taking modules out of anywhere in the current selection
  local skip_unit_number = {}

  for _, proxy in ipairs(event.entities) do
    assert(proxy.proxy_target)
    assert(proxy.proxy_target.unit_number)
    skip_unit_number[proxy.proxy_target.unit_number] = true

    for module_name, module_count in pairs(proxy.item_requests) do
      routing[module_name] = routing[module_name] or {}
      -- routing[module_name][proxy.unit_number] = proxy -- hmm, or maybe duplicate entries if a proxy wants more?
      table.insert(routing[module_name], proxy)
    end
    -- game.print(serpent.line(proxy.item_requests))
  end

  -- note to self: there's like only a super minor lag spike, tbh not worth if to optimize for the occasional usage
  -- local surface = event.surface
  -- for _, surface in pairs(game.surfaces) do
  --   local entities = surface.find_entities_filtered{
  --     type = entity_types_with_module_slots,
  --   }

  --   game.print(#entities)
  -- end

  local player = assert(game.get_player(event.player_index))
  for _, surface in pairs(game.surfaces) do
    local entities = surface.find_entities_filtered{
      type = entity_types_with_module_slots,
      force = player.force,
    }

    -- getting the inventory does slightly increase the spike, and that's without
    for _, entity in ipairs(entities) do
      assert(entity.unit_number)
      if skip_unit_number[entity.unit_number] then goto continue end

      local inventory = entity.get_inventory(module_inventory_for_type[entity.type])
      assert(inventory) -- does this crash if the entity has no module slots?
      for item_name, item_count in pairs(inventory.get_contents()) do

        if routing[item_name] then -- we want this module at all
          for i = #routing[item_name], 1, -1 do
            local proxy = routing[item_name][i]

            -- local inserted = proxy.insert({name = item_name, count = 1})
            local inserted = proxy.proxy_target.get_inventory(module_inventory_for_type[proxy.proxy_target.type]).insert({name = item_name, count = 1})
            assert(inserted > 0)
            if inserted > 0 then
              local removed = inventory.remove({name = item_name, count = 1})
              assert(removed > 0)
              table.remove(routing[item_name], i)

              item_count = item_count - 1
              if item_count == 0 then goto next_module end
            end
          end
        end

        ::next_module::
      end

      ::continue::
    end

    -- game.print(#entities)
  end

  game.print(serpent.line(routing))
end)
