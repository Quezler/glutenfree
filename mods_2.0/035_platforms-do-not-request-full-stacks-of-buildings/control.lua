require("util")

script.on_init(function()
  storage.structs = {}
end)

script.on_event(defines.events.on_rocket_launch_ordered, function(event)
  local cargo_pod = event.rocket.cargo_pod --[[@as LuaEntity]]

  local contents = cargo_pod.get_inventory(defines.inventory.cargo_unit).get_contents()
  if #contents ~= 1 then return end -- cargo pod has no items (perhaps a player?) or contains a manual/mixed set of items.

  storage.structs[cargo_pod.unit_number] = {
    silo = event.rocket_silo,
    cargo_pod = cargo_pod,
  }
end)

local function filter_matches_item(filter, item)
  return filter.value and filter.value.name == item.name and filter.value.quality == item.quality
end

local function section_get_filter_for_item(section, item)
  for _, filter in ipairs(section.filters) do
    if filter_matches_item(filter, item) then
      return filter
    end
  end
end

local function section_is_requests_for_construction(section)
  return section.type == defines.logistic_section_type.request_missing_materials_controlled
end

-- you can have a construction request for 0 foundation + a normal one for 50+,
-- if we only look at "oh construction doesn't need this anymore" the rocket will remain in a supply loop,
-- so we'll have to check if any of the other sections are requesting something we've also recently built.
local function get_minimum_request_count_for_this_item(planet_name, sections, item)
  local min = 0

  for _, section in ipairs(sections) do
    if section.active then
      for _, filter in ipairs(section.filters) do
        if filter_matches_item(filter, item) then
          -- note that whilst construction requests have an import_from, the game ignores it for building
          if filter.import_from.name == planet_name or section_is_requests_for_construction(section) then
            min = min + filter.min * section.multiplier
          end
        end
      end
    end
  end

  return min
end

script.on_event(defines.events.on_script_trigger_effect, function(event)
  if event.effect_id ~= "cargo-pod-created" then return end
  local entity = event.target_entity --[[@as LuaEntity]]
  assert(entity.name == "cargo-pod")
  assert(entity.type == "cargo-pod")

  local struct = storage.structs[entity.unit_number]
  if struct == nil then return end

  local inventory = entity.get_inventory(defines.inventory.cargo_unit) --[[@as LuaInventory]]
  local contents = inventory.get_contents()
  assert(#contents == 1)
  local item = contents[1]

  local platform = entity.surface.platform --[[@as LuaSpacePlatform]]
  local sections = platform.hub.get_logistic_sections().sections
  if sections[1] == nil then return end -- construction checkbox is off, and there are no other sections at all
  if section_is_requests_for_construction(sections[1]) == false then return end -- construction checkbox is off

  local filter = section_get_filter_for_item(sections[1], item)
  if filter == nil then return end -- when this pod transitioned surfaces there wasn't even a construction request with 0

  local drop_down = item.count - get_minimum_request_count_for_this_item(platform.space_location.name, sections, item)
  if 0 >= drop_down then return end -- the platform actually needed this entire stack (and possibly more)

  log(string.format("'%s' delivered %s × %d but '%s' only requested %d", platform.space_location.name, item.name, item.count, platform.name, filter.min))

  if struct.silo.valid then
    local silo_trash = struct.silo.get_inventory(defines.inventory.rocket_silo_trash)
    local inserted = silo_trash.insert({name = item.name, quality = item.quality, count = drop_down})
    if inserted > 0 then
      local removed = inventory.remove({name = item.name, quality = item.quality, count = inserted})
      assert(removed == inserted)

      local rocket_parts_required = prototypes.entity[struct.silo.name].rocket_parts_required
      local can_fit_in_rocket = 1 * tons / prototypes.item[item.name].weight
      local parts_to_refund = rocket_parts_required / can_fit_in_rocket * removed

      log(string.format("%d items were put back in the silo, as well as %d / %d * %d = %f rocket parts", removed, rocket_parts_required, can_fit_in_rocket, removed, parts_to_refund))

      parts_to_refund = math.floor(parts_to_refund)
      local old_rocket_parts = struct.silo.rocket_parts
      local new_rocket_parts = old_rocket_parts + parts_to_refund
      struct.silo.rocket_parts = new_rocket_parts
      assert(struct.silo.rocket_parts == new_rocket_parts or struct.silo.rocket_parts + rocket_parts_required == new_rocket_parts, string.format("changed %d to %d but it read as %d.", old_rocket_parts, new_rocket_parts, struct.silo.rocket_parts))
    end
  else
    log(string.format("0 items were put back in the silo, are the trash slots full?"))
  end
end)

-- script.on_event(defines.events.on_tick, function(event) -- confirmed with on_tick that it doesn't delete the struct before the cargo pod transitions surface
script.on_nth_tick(60 * 60 * 10, function(event)
  for struct_id, struct in pairs(storage.structs) do
    if struct.cargo_pod.valid == false or struct.silo == false then
      storage.structs[struct_id] = nil
    end
  end
end)
