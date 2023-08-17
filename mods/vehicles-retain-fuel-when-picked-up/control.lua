script.on_init(function(event)
  global.vehicles = {}
end)

local function percentage_left(vehicle_entity)
  return vehicle_entity.burner.remaining_burning_fuel / vehicle_entity.burner.currently_burning.fuel_value
end

script.on_event(defines.events.on_player_mined_entity, function(event)
  -- game.print(serpent.block( event.entity.burner.currently_burning.name ))
  -- game.print(serpent.block( event.entity.burner.remaining_burning_fuel ))
  -- game.print(serpent.block( event.buffer[1].name ))

  if event.entity.type ~= "car" then return end
  if event.entity.burner.currently_burning == nil then return end

  local player = game.get_player(event.player_index)
  local vehicle_itemstack = event.buffer[1]

  -- should technically use event.entity.prototype.minable_properties.products[1]
  if vehicle_itemstack.name ~= event.entity.name then return game.print("Failed to locate the picked up vehicle item") end

  -- game.print(vehicle_itemstack.item_number)
  -- game.print(vehicle_itemstack.type)
  -- vehicle_itemstack.tags.set_tag("burner.currently_burning.name", event.entity.burner.currently_burning.name)
  -- vehicle_itemstack.tags.set_tag("burner.remaining_burning_fuel", event.entity.burner.remaining_burning_fuel)

  -- local percentage_left = event.entity.burner.remaining_burning_fuel / event.entity.burner.currently_burning.fuel_value
  -- game.print(percentage_left)

  -- player.create_local_flying_text{
  --   text = "[item=".. event.entity.burner.currently_burning.name .."] " .. math.max(1, math.floor(percentage_left(event.entity) * 100)) .. "% left",
  --   position = event.entity.position,
  -- }

  global.vehicles[vehicle_itemstack.item_number] = {
    -- can't save an item stack reference for GC purposes since it points to a slot
    ["burner.currently_burning.name"] = event.entity.burner.currently_burning.name,
    ["burner.remaining_burning_fuel"] = event.entity.burner.remaining_burning_fuel,
  }
end)

script.on_event(defines.events.on_built_entity, function(event)
  if event.created_entity.type ~= "car" then return end

  local vehicle = global.vehicles[event.stack.item_number]
  if vehicle then global.vehicles[event.stack.item_number] = nil
    event.created_entity.burner.currently_burning = game.item_prototypes[vehicle["burner.currently_burning.name"]]
    event.created_entity.burner.remaining_burning_fuel = vehicle["burner.remaining_burning_fuel"]

    game.get_player(event.player_index).create_local_flying_text{
      text = "[item=".. event.created_entity.burner.currently_burning.name .."] " .. math.max(1, math.floor(percentage_left(event.created_entity) * 100)) .. "% left",
      position = event.created_entity.position,
    }
  end
end)
