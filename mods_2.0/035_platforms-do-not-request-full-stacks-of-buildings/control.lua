script.on_init(function()
  storage.structs = {}
end)

-- if the construction request get canceled and it vanished from the "request for construction" we won't know if it was a delivery or building.
-- local function platforms_requesting_this_for_construction(surface, force, item)
--   local platforms = {}
--   local planet_name = surface.planet.name

--   for _, platform in pairs(force.platforms) do
--     if platform.space_location and platform.space_location.name == planet_name then
      -- local section = platform.hub.get_logistic_sections().sections[1]
      -- if section.type == defines.logistic_section_type.request_missing_materials_controlled then
        -- for _, filter in ipairs(section.filters) do
        --   if filter.value.name == item.name and filter.value.quality == item.quality then
        --     assert(filter.min >= 1)
        --     platforms[platform.surface.index] = true
        --   end
        -- end
      -- end
--     end
--   end

--   assert(table_size(platforms) > 0)
--   game.print(serpent.line(platforms))
--   return platforms
-- end

script.on_event(defines.events.on_rocket_launch_ordered, function(event)
  local cargo_pod = event.rocket.cargo_pod --[[@as LuaEntity]]

  local contents = cargo_pod.get_inventory(defines.inventory.cargo_unit).get_contents()
  if #contents ~= 1 then return end -- cargo pod has no items (perhaps a player?) or contains a manual/mixed set of items.

  storage.structs[cargo_pod.unit_number] = {
    silo = event.rocket_silo,
    cargo_pod = cargo_pod,
    -- potential_destinations = platforms_requesting_this_for_construction(cargo_pod.surface, cargo_pod.force, contents[1])
  }
end)

-- local function automatic_requests_from_space_platforms(entity)
--   return entity.get_logistic_sections().sections[1].active
-- end

local function section_get_filter_for_item(section, item)
  for _, filter in ipairs(section.filters) do
    if filter.value.name == item.name and filter.value.quality == item.quality then
      return filter
    end
  end
end

script.on_event(defines.events.on_script_trigger_effect, function(event)
  if event.effect_id ~= "cargo-pod-created" then return end
  local entity = event.target_entity --[[@as LuaEntity]]
  assert(entity.name == "cargo-pod")
  assert(entity.type == "cargo-pod")

  local struct = storage.structs[entity.unit_number]
  if struct == nil then return end

  local contents = entity.get_inventory(defines.inventory.cargo_unit).get_contents()
  assert(#contents == 1)

  local section = entity.surface.platform.hub.get_logistic_sections().sections[1]
  if section.type ~= defines.logistic_section_type.request_missing_materials_controlled then return end

  local filter = section_get_filter_for_item(section, contents[1])
  if filter == nil then return end -- when this pod transitioned surfaces there wasn't even a construction request with 0

  game.print(string.format("delivered %d %s but only required %d", contents[1].count, contents[1].name, filter.min))

  -- -- game.print(string.format("new cargo pod: %d @ %s", entity.unit_number, entity.surface.name))

  -- -- the inventory is empty when:
  -- -- A) the cargo pod got created underground in the silo (exists before rocket launch)
  -- -- B) the cargo pod got launched from a platform (trigger fires before inventory insertion)
  -- -- C) there is a player traveling in the cargo pod
  -- local inventory = event.target_entity.get_inventory(defines.inventory.cargo_unit) --[[@as LuaInventory]]
  -- if inventory.is_empty() then return end

  -- local platform = entity.surface.platform
  -- local flow_surface = get_flow_surface(platform and platform.space_location.name or entity.surface.planet.name)
  -- local statistics = entity.force.get_item_production_statistics(flow_surface)
  -- local multiplier = platform and 1 or -1 -- production = send up, consumption = requesting

  -- for _, item in ipairs(inventory.get_contents()) do
  --   statistics.on_flow({name = item.name, quality = item.quality}, item.count * multiplier)
  -- end
end)
