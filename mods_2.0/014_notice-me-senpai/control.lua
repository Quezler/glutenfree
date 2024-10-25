local is_mining_drill = {}
for _, item in pairs(prototypes.item) do
  local place_result = item.place_result
  if place_result and place_result.type == "mining-drill" then
    is_mining_drill[item.name] = true
  else
    is_mining_drill[item.name] = false -- not strictly needed
  end
end

-- true, false, nil
local function is_player_holding_drill(player)
  if player.cursor_ghost then
    return is_mining_drill[player.cursor_ghost.name.name]
  end

  if player.cursor_stack.valid_for_read then
    return is_mining_drill[player.cursor_stack.prototype.name]
  end
end

script.on_init(function()
  storage.playerdata = {}
end)

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
  local player = game.get_player(event.player_index)
  assert(player)

  game.print(event.tick .. ' ' .. serpent.line( is_player_holding_drill(player) ))
end)


script.on_event(defines.events.on_player_changed_position, function(event)
  --
end)
