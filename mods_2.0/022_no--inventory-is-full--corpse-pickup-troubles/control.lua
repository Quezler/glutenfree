local function is_better_armor(old_stack, new_stack)
  if old_stack == nil then return true end
  if new_stack.prototype.get_inventory_size_bonus(new_stack.quality) > old_stack.prototype.get_inventory_size_bonus(old_stack.quality) then return true end

  -- todo: if both the inventory stack size bonuses match and space exploration is installed, pick normal or spacesuit?
  -- todo: if both the inventory stack size bonuses match, determine which suit has better resistances/equipment in it.

  return false
end

script.on_event(defines.events.on_pre_player_mined_item, function(event)
  local player = game.get_player(event.player_index)
  assert(player)
  local armor = player.get_inventory(defines.inventory.character_armor)
  assert(armor)

  if not armor.is_empty() then return end
  -- game.print(event.entity.name)

  local best_armor = nil

  local corpse = event.entity.get_inventory(defines.inventory.character_corpse)
  assert(corpse)
  for i = 1, #corpse do
    local stack = corpse[i]
    if stack.valid_for_read and stack.is_armor then
      best_armor = is_better_armor(best_armor, stack) and stack or best_armor
    end
  end

  if best_armor then
    -- game.print(best_armor.name)
    best_armor.swap_stack(armor[1])
  else
    -- game.print('nil')
    -- corpse had no armor
  end
end, {
  {filter = "type", type = "character-corpse"},
})
