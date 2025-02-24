local mod_prefix = "deconstruction-planner-toggle-entity-with-pipette--"

local bring_your_own_keybind = settings.startup[mod_prefix .. "bring-your-own-keybind"].value

-- script.on_event(mod_prefix .. "clear-cursor", function(event)
--   game.print(string.format("%d clear cursor", event.tick))
-- end)

script.on_init(function()
  storage.inventories = {}
  storage.cursor_stack_temporary = {}
end)

script.on_configuration_changed(function()
  storage.cursor_stack_temporary = storage.cursor_stack_temporary or {}
end)

script.on_load(function()
  local count = table_size(storage.inventories)
  assert(count == 0, string.format("expected 0 but found %d lingering inventories.", count))
end)

local function toggle_filter(itemstack, filter)
  assert(table_size(filter) == 2) -- name & quality

  local entity_filters = itemstack.entity_filters

  for i, old_filter in pairs(entity_filters) do
    if old_filter.name == filter.name and old_filter.quality == filter.quality then
      entity_filters[i] = {}
      itemstack.entity_filters = entity_filters
      return {"", string.format("- [entity=%s,quality=%s] ", filter.name, filter.quality), prototypes.entity[filter.name].localised_name}
    end
  end

  table.insert(entity_filters, filter)
  itemstack.entity_filters = entity_filters
  return {"", string.format("+ [entity=%s,quality=%s] ", filter.name, filter.quality), prototypes.entity[filter.name].localised_name}
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

  local success, result = pcall(toggle_filter, cursor_stack, {
    name = selected_prototype.name,
    quality = selected_prototype.quality,
  })
  player.create_local_flying_text{
    text = result,
    create_at_cursor = true
  }
  -- game.print(serpent.line({success, result}))

  if bring_your_own_keybind == true then return end
  storage.inventories[player.index] = game.create_inventory(1)
  storage.cursor_stack_temporary[player.index] = player.cursor_stack_temporary -- BEFORE swap stack
  storage.inventories[player.index][1].swap_stack(cursor_stack)
end)

-- i was a little worried this listener might break if the inventory is full,
-- but during initial testing it did not seem to cause any issues when i tried.

if bring_your_own_keybind == false then
  script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    local cursor_stack = player.cursor_stack

    local inventory = storage.inventories[player.index]

    -- game.print(serpent.line(cursor_stack.valid_for_read))
    if inventory and cursor_stack.valid_for_read == false then
      inventory[1].swap_stack(cursor_stack)
      inventory.destroy()
      storage.inventories[player.index] = nil

      player.cursor_stack_temporary = storage.cursor_stack_temporary[player.index] -- AFTER swap stack
      storage.cursor_stack_temporary[player.index] = nil
    end
  end)
end
