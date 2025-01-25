local mod_prefix = "deconstruction-planner-toggle-entity-with-pipette--"

-- script.on_event(mod_prefix .. "clear-cursor", function(event)
--   game.print(string.format("%d clear cursor", event.tick))
-- end)


script.on_event(mod_prefix .. "pipette", function(event)
  game.print(string.format("%d pipette", event.tick))

  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local cursor_stack = player.cursor_stack

  if cursor_stack == nil then return end
  if cursor_stack.valid_for_read == false then return end
  if cursor_stack.is_deconstruction_item == false then return end

  local selected_prototype = assert(event.selected_prototype)
  if selected_prototype.base_type ~= "entity" then return end

  game.print("decon planner! " .. serpent.line(event))

  local entity_filters = cursor_stack.entity_filters
  table.insert(entity_filters, {
    name = selected_prototype.name,
    quality = selected_prototype.quality,
  })
  cursor_stack.entity_filters = entity_filters
end)
