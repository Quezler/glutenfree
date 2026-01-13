local is_supported_type = {
  ["car"] = true,
  ["locomotive"] = true,
  ["spider-vehicle"] = true,
}

script.on_init(function(event)
  storage.vehicles = {}
end)

script.on_event(defines.events.on_player_mined_entity, function(event)
  if not is_supported_type[event.entity.type] then return end
  if event.entity.burner == nil then return end
  if event.entity.burner.currently_burning == nil then return end

  local itemstack = event.buffer[1]
  assert(itemstack.prototype.place_result, itemstack.prototype.name)
  assert(itemstack.prototype.place_result.name == event.entity.name, itemstack.prototype.place_result.name .. " ~= " .. event.entity.name)

  script.register_on_object_destroyed(itemstack.item)
  storage.vehicles[itemstack.item_number] = {
    currently_burning = event.entity.burner.currently_burning,
    remaining_burning_fuel = event.entity.burner.remaining_burning_fuel,
  }
end)

script.on_event(defines.events.on_object_destroyed, function(event)
  if event.type == defines.target_type.item and storage.vehicles[event.useful_id] then
    storage.vehicles[event.useful_id] = nil
  end
end)

script.on_event(defines.events.on_built_entity, function(event)
  if not is_supported_type[event.entity.type] then return end

  for slot = 1, #event.consumed_items do
    local stack = event.consumed_items[slot]

    if stack.valid_for_read and stack.item_number and storage.vehicles[stack.item_number] then
      local vehicle = storage.vehicles[stack.item_number]

      if vehicle.currently_burning.name.valid then
        if not vehicle.currently_burning.quality.valid then
          vehicle.currently_burning.quality = nil
        end
        event.entity.burner.currently_burning = vehicle.currently_burning
        event.entity.burner.remaining_burning_fuel = vehicle.remaining_burning_fuel -- not a %, potential but impractical fuel value change exploit.
      end
    end
  end
end)
