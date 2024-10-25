local is_mining_drill = {}
for _, item in pairs(prototypes.item) do
  local place_result = item.place_result
  if place_result and place_result.type == "mining-drill" then
    is_mining_drill[item.name] = true
  end
end

script.on_event(defines.events.on_player_changed_position, function(event)
  local player = game.get_player(event.player_index)
  assert(player)

  -- game.print(serpent.line(player.position))
  -- game.print(serpent.line(player.cursor_ghost))

  local item_prototype = player.cursor_ghost and player.cursor_ghost.name or nil
  if item_prototype == nil then
    if player.cursor_stack.valid_for_read then
      item_prototype = player.cursor_stack.prototype
    end
  end

  -- game.print(serpent.line(item_prototype))
  -- game.print(serpent.line(is_mining_drill))
  -- game.print(serpent.line(item_prototype.name))

  if item_prototype == nil then return end -- player is holding neither an item or ghost
  if not is_mining_drill[item_prototype.name] then return end

  game.print("drill held @ " .. serpent.line(player.position))
end)
