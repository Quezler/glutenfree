local price = "se-space-capsule"

script.on_event(defines.events.on_player_selected_area, function(event)
  if event.item ~= "se-space-capsule-fast-travel-targeter" then return end

  local player = game.get_player(event.player_index)
  assert(player)

  if player.force.technologies["se-space-capsule-navigation"].researched == false then
    player.create_local_flying_text({
      text = {"", {"technology-name.se-space-capsule-navigation"}, " not yet researched."},
      create_at_cursor = true,
    })
    return
  end

  -- local inventory = player.get_main_inventory()
  local inventory = remote.call("space-exploration", "get_player_character", {player = player}).get_main_inventory()
  if inventory.get_item_count(price) == 0 then
    player.create_local_flying_text({
      text = string.format("Fast travel requires a [item=%s]", price),
      create_at_cursor = true,
    })
    return
  end
  inventory.remove({name = price, count = 1})
  local left = inventory.get_item_count(price)

  local center = {
    x = (event.area.left_top.x + event.area.right_bottom.x) / 2,
    y = (event.area.left_top.y + event.area.right_bottom.y) / 2,
  }

  local container = event.surface.create_entity({
    name = "se-space-capsule-scorched",
    position = center,
    force = player.force,
    raise_built = true, -- uncomment to create a vehicle too (uncommented for the shadow, did it have any side-effects?)
  })

  remote.call("space-exploration", "remote_view_stop", {player = player})
  remote.call("jetpack", "stop_jetpack_immediate", {character = player.character})
  player.driving = false
  player.teleport({center.x - 2, center.y}, event.surface)
  -- player.driving = true -- having to exit the vehicle is not fast enough
  -- player.character.direction = defines.direction.south -- look down away from the capsule ladder

  -- if we force the player to enter and then exit, they're on the left side (same as all other vehicles)
  -- player.driving = true
  -- player.driving = false

  -- container.order_deconstruction(player.force, player) -- a bit too quick, and i don't feel like complicating the mod with a delay

  player.create_local_flying_text({
    text = string.format("%d [item=%s]'s left", left, price),
    position = center,
  })

  player.close_map()
end)

-- local technology_name = "se-space-capsule-navigation"

-- local function update_player(player)
--   player.set_shortcut_available("se-space-capsule-fast-travel", player.force.technologies[technology_name].researched)
-- end

-- script.on_init(function()
--   for i, player in pairs(game.players) do
--     update_player(player)
--   end
-- end)

-- script.on_event(defines.events.on_player_created, function(event)
--   update_player(game.get_player(event.player_index))
-- end)

-- script.on_event(defines.events.on_research_finished, function(event)
--   if event.research.name ~= technology_name then return end

--   for _, player in ipairs(event.research.force.players) do
--     update_player(player)
--   end
-- end)

-- script.on_event(defines.events.on_research_reversed, function(event)
--   if event.research.name ~= technology_name then return end

--   for _, player in ipairs(event.research.force.players) do
--     update_player(player)
--   end
-- end)
