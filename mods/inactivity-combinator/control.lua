script.on_event(defines.events.on_selected_entity_changed, function(event)
  if event.last_entity == nil then return end
  if event.last_entity.name ~= "inactivity-combinator" then return end

  -- local input = event.last_entity.get_circuit_network(defines.wire_type.green, defines.circuit_connector_id.combinator_input)
  for _, connection in ipairs(event.last_entity.circuit_connection_definitions) do
    if connection.wire == defines.wire_type.green and connection.source_circuit_id ==defines.circuit_connector_id.combinator_input then
      event.last_entity.disconnect_neighbour(connection)
    end
  end

  local player = game.get_player(event.player_index)

  if player.cursor_stack and player.cursor_stack.valid_for_read and player.cursor_stack.name == "green-wire" then
    if player.drag_target and player.drag_target.target_circuit_id == defines.circuit_connector_id.combinator_input then
      player.clear_cursor() -- apparently this just cancels the wire, i do not need to re-add it to the player's hand :)
    end
  end

  -- game.print(serpent.line(player.drag_target))

  -- defines.circuit_connector_id.combinator_input
end)
