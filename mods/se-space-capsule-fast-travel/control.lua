local price = "se-space-capsule"

script.on_event("se--targeter", function(event)
  local player = game.get_player(event.player_index)
  local cursor_item = player.cursor_stack

  if not (cursor_item and cursor_item.valid_for_read) then return end
  if cursor_item.name ~= "se-space-capsule-fast-travel-targeter" then return end

  -- local inventory = player.get_main_inventory()
  local inventory = remote.call("space-exploration", "get_player_character", {player = player}).get_main_inventory()
  if inventory.get_item_count(price) == 0 then return player.create_local_flying_text({
    text = string.format("Fast travel requires a [item=%s]", price),
    create_at_cursor = true,
  }) end
  inventory.remove({name = price, count = 1})
  local left = inventory.get_item_count(price)

  local container = player.surface.create_entity({
    name = "se-space-capsule-scorched",
    position = event.cursor_position,
    force = player.force,
    raise_built = true, -- uncomment to create a vehicle too (uncommented for the shadow, did it have any side-effects?)
  })

  remote.call("space-exploration", "remote_view_stop", {player = player})
  remote.call("jetpack", "stop_jetpack_immediate", {character = player.character})
  player.driving = false
  player.teleport({event.cursor_position.x - 2, event.cursor_position.y}, player.surface)
  -- player.driving = true -- having to exit the vehicle is not fast enough
  -- player.character.direction = defines.direction.south -- look down away from the capsule ladder

  -- if we force the player to enter and then exit, they're on the left side (same as all other vehicles)
  -- player.driving = true
  -- player.driving = false

  -- container.order_deconstruction(player.force, player) -- a bit too quick, and i don't feel like complicating the mod with a delay

  player.create_local_flying_text({
    text = string.format("%d [item=%s]'s left", left, price),
    position = event.cursor_position,
  })
end)
