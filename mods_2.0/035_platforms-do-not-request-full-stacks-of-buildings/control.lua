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
  local item = contents[1]

  local platform = entity.surface.platform --[[@as LuaSpacePlatform]]
  local section = platform.hub.get_logistic_sections().sections[1]
  if section.type ~= defines.logistic_section_type.request_missing_materials_controlled then return end -- construction checkbox is off

  local filter = section_get_filter_for_item(section, item)
  if filter == nil then return end -- when this pod transitioned surfaces there wasn't even a construction request with 0

  game.print(string.format("'%s' delivered %s × %d but '%s' only requested %d", platform.space_location.name, item.name, item.count, platform.name, filter.min))
end)
