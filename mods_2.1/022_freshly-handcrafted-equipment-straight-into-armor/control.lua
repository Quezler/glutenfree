local place_as_equipment_result = {}
for _, item in pairs(prototypes.get_item_filtered{{filter = "placed-as-equipment-result"}}) do
  place_as_equipment_result[item.name] = item.place_as_equipment_result.name
end

script.on_event(defines.events.on_player_crafted_item, function(event)
  local stack = event.item_stack
  local equipment_name = place_as_equipment_result[stack.name]
  if not equipment_name then return end

  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]

  local character = player.character
  if not character then return end

  local grid = character.grid
  if not grid then return end

  for _, equipment in ipairs(grid.equipment) do
    if equipment.type == "equipment-ghost" and equipment.ghost_name == equipment_name and equipment.quality.name == stack.quality.name then
      grid.revive(equipment)
      stack.count = stack.count - 1
      if not stack.valid_for_read then return end
    end
  end
end)
