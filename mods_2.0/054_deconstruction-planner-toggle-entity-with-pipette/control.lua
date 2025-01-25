local mod_prefix = "deconstruction-planner-toggle-entity-with-pipette--"

-- script.on_event(mod_prefix .. "clear-cursor", function(event)
--   game.print(string.format("%d clear cursor", event.tick))
-- end)

script.on_init(function()
  storage.inventories = {}
end)

script.on_load(function()
  local count = table_size(storage.inventories)
  assert(count == 0, string.format("expected 0 but found %d lingering inventories.", count))
end)

local function toggle_filter(itemstack, filter)
  assert(table_size(filter) == 2) -- name & quality

  local entity_filters = itemstack.entity_filters

  for i, old_filter in ipairs(entity_filters) do
    if old_filter.name == filter.name and old_filter.quality == filter.quality then
      entity_filters[i] = {}
      itemstack.entity_filters = entity_filters
      return
    end
  end

  table.insert(entity_filters, filter)
  itemstack.entity_filters = entity_filters
end

script.on_event(mod_prefix .. "pipette", function(event)
--game.print(string.format("%d pipette", event.tick))

  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local cursor_stack = player.cursor_stack

  if cursor_stack == nil then return end
  if cursor_stack.valid_for_read == false then return end
  if cursor_stack.is_deconstruction_item == false then return end

  local selected_prototype = assert(event.selected_prototype)
  if selected_prototype.base_type ~= "entity" then return end

  -- game.print("decon planner! " .. serpent.line(event))

  toggle_filter(cursor_stack, {
    name = selected_prototype.name,
    quality = selected_prototype.quality,
  })

  storage.inventories[player.index] = game.create_inventory(1)
  storage.inventories[player.index][1].swap_stack(cursor_stack)
end)

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local cursor_stack = player.cursor_stack

  local inventory = storage.inventories[player.index]

  if inventory and cursor_stack.valid_for_read == false then
    inventory[1].swap_stack(cursor_stack)
    inventory.destroy()
    storage.inventories[player.index] = nil
  end
end)
