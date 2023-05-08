local kr_air_purifier = {}

function kr_air_purifier.init()
  local on_nth_ticks = global.on_nth_ticks or {}

  global = {}
  global.entries = {}
  global.on_nth_ticks = on_nth_ticks

  global.proxy_deathrattles = {}

  global.standard_recipe_duration = game.recipe_prototypes['kr-air-cleaning'  ].energy / game.entity_prototypes['kr-air-purifier'].crafting_speed * 60 -- 28800t = 480s =  8m
  global.improved_recipe_duration = game.recipe_prototypes['kr-air-cleaning-2'].energy / game.entity_prototypes['kr-air-purifier'].crafting_speed * 60 -- 36000t = 600s = 10m

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = 'kr-air-purifier'})) do
      local leftover_proxy = entity.surface.find_entity("item-request-proxy", entity.position)
      if leftover_proxy then leftover_proxy.destroy() end

      kr_air_purifier.register_purifier(entity)
      kr_air_purifier.update_unit_number_at_tick(entity.unit_number, game.tick + 1)
    end
  end
end

function kr_air_purifier.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  if entity.name ~= 'kr-air-purifier' then return end

  kr_air_purifier.register_purifier(entity)
  kr_air_purifier.update_unit_number_at_tick(entity.unit_number, game.tick + 60) -- deliver the initial filter after a second
  -- game.print(game.tick .. ' -> ' .. game.tick + 60)
end

function kr_air_purifier.register_purifier(entity)
  global.entries[entity.unit_number] = {
    unit_number = entity.unit_number,
    purifier = entity,
    proxy = nil,
  }
end

function kr_air_purifier.update_unit_number_at_tick(unit_number, tick)
  -- if game.tick >= tick then error(game.tick .. ' >= ' .. tick) end

  global.on_nth_ticks[tick] = global.on_nth_ticks[tick] or {}
  global.on_nth_ticks[tick][unit_number] = true
  script.on_nth_tick(tick, kr_air_purifier.on_nth_tick)
end

function kr_air_purifier.on_nth_tick(event)
  local unit_numbers = global.on_nth_ticks[event.tick]
  if not unit_numbers then return end

  for unit_number, _ in pairs(unit_numbers) do
    kr_air_purifier.update_by_unit_number(unit_number)
  end

  global.on_nth_ticks[event.tick] = nil
  script.on_nth_tick(event.tick, nil)
end

function kr_air_purifier.update_by_unit_number(unit_number)
  local entry = global.entries[unit_number]
  if not entry then return end

  -- since we update by unit_number, we can erase it from inside here just fine
  if not entry.purifier.valid then global.entries[unit_number] = nil return end

  -- ensure the next update either via proxy deathrattle, or on_nth_tick scheduling
  if entry.purifier.get_inventory(defines.inventory.furnace_source).is_empty() then

    local count = 1
    -- try to keep the above amount in input, but if idle add one more:
    if entry.purifier.crafting_progress == 0 then count = count + 1 end

    entry.proxy = entry.purifier.surface.create_entity({
      name = "item-request-proxy",
      target = entry.purifier,
      modules = {["pollution-filter"] = count},
      position = entry.purifier.position,
      force = entry.purifier.force,
    })

    global.proxy_deathrattles[script.register_on_entity_destroyed(entry.proxy)] = entry.unit_number
  else
    local done_in_ticks = global.standard_recipe_duration

    if entry.purifier.get_recipe() then
      done_in_ticks = math.ceil(entry.purifier.get_recipe().energy / entry.purifier.crafting_speed * 60 * (1 - entry.purifier.crafting_progress))

      -- not (yet) connected or completely out of power, if so fall back to default recipe energy
      if not entry.purifier.is_connected_to_electric_network() or entry.purifier.energy == 0 then
        done_in_ticks = global.standard_recipe_duration
      else
        local effectivity = entry.purifier.energy / entry.purifier.electric_buffer_size
        if effectivity < 1 then done_in_ticks = math.ceil(done_in_ticks / effectivity) end
      end
    end

    kr_air_purifier.update_unit_number_at_tick(entry.unit_number, game.tick + done_in_ticks + 1)
  end

end

-- to be called the tick a construction bot delivered filters
function kr_air_purifier.try_to_take_out_used_filters(entity)
  local dirty_filters = entity.get_inventory(defines.inventory.furnace_result)
  if dirty_filters.is_empty() then return end

  local nearby_construction_robots = entity.surface.find_entities_filtered{
    type = 'construction-robot',
    position = entity.position,
    force = entity.force,
    limit = 1,
  }
  if #nearby_construction_robots == 0 then return end

  local cargo = nearby_construction_robots[1].get_inventory(defines.inventory.robot_cargo)
  if not cargo.is_empty() then return end

  -- either a standard or improved filter, but handles both
  for name, count in pairs(dirty_filters.get_contents()) do
    local taken = cargo.insert({name = name, count = count})
    dirty_filters.remove({name = name, count = taken})
  end
end

function kr_air_purifier.on_entity_destroyed(event)
  -- the item request proxy has disappeared, mined or received the package
  local unit_number = global.proxy_deathrattles[event.registration_number]
  if unit_number then global.proxy_deathrattles[event.registration_number] = nil

    -- try to take out any used ones now ...
    local entry = global.entries[unit_number]
    if entry and entry.purifier.valid then kr_air_purifier.try_to_take_out_used_filters(entry.purifier) end

    -- ... and schedule the next update in a second
    kr_air_purifier.update_unit_number_at_tick(unit_number, event.tick + 60)
  end
end

return kr_air_purifier
