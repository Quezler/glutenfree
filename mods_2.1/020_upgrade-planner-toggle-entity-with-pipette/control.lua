local mod_prefix = "upgrade-planner-toggle-entity-with-pipette--"

local bring_your_own_keybind = settings.startup[mod_prefix .. "bring-your-own-keybind"].value

-- script.on_event(mod_prefix .. "clear-cursor", function(event)
--   game.print(string.format("%d clear cursor", event.tick))
-- end)

script.on_init(function()
  storage.inventories = {}
  storage.cursor_stack_temporary = {}
  storage.held_planner_got_used = {}
end)

script.on_configuration_changed(function()
  storage.cursor_stack_temporary = storage.cursor_stack_temporary or {}
  storage.held_planner_got_used = storage.held_planner_got_used or {}
end)

script.on_load(function()
  local count = table_size(storage.inventories)
  assert(count == 0, string.format("expected 0 but found %d lingering inventories.", count))
end)

local function toggle_filter(itemstack, filter)
  assert(table_size(filter) == 2) -- name & quality

  for i = 1, itemstack.mapper_count do
    local from = itemstack.get_mapper(i, "from")
    if from.name == filter.name and (from.quality or "normal") == filter.quality then
      local to = itemstack.get_mapper(i, "to")
      itemstack.set_mapper(i, "from", nil)
      itemstack.set_mapper(i, "to", nil)
      if to then
        assert(to.name) -- https://forums.factorio.com/128645
        return {"",
        string.format("- [entity=%s,quality=%s] ", filter.name, filter.quality),
        prototypes.entity[filter.name].localised_name,
        string.format(" -> [entity=%s,quality=%s] ", to.name, to.quality),
        prototypes.entity[to.name].localised_name}
      else
        return {"",
        string.format("- [entity=%s,quality=%s] ", filter.name, filter.quality),
        prototypes.entity[filter.name].localised_name}
      end
    end
  end

  local next_upgrade = prototypes.entity[filter.name].next_upgrade
  if not next_upgrade then
    next_upgrade = prototypes.entity[filter.name] -- make a 1-1 planner for like modules and stuff
  end

  local free_mapper_index = itemstack.mapper_count+1
  itemstack.set_mapper(free_mapper_index, "from", {
    type = "entity",
    name = filter.name,
    quality = filter.quality,
    comparator = "=",
  })
  itemstack.set_mapper(free_mapper_index, "to", {
    type = "entity",
    name = next_upgrade.name,
    quality = filter.quality,
  })
  return {"",
    string.format("+ [entity=%s,quality=%s] ", filter.name, filter.quality),
    prototypes.entity[filter.name].localised_name,
    string.format(" -> [entity=%s,quality=%s] ", next_upgrade.name, filter.quality),
    next_upgrade.localised_name}
end

script.on_event(mod_prefix .. "pipette", function(event)
  -- game.print(string.format("%d pipette", event.tick))

  if bring_your_own_keybind == false then
    if storage.held_planner_got_used[event.player_index] then
      return
    end
  end

  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local cursor_stack = player.cursor_stack

  if cursor_stack == nil then return end
  if cursor_stack.valid_for_read == false then return end
  if cursor_stack.is_upgrade_item == false then return end

  local selected_prototype = event.selected_prototype
  if not selected_prototype then return end -- latency? #darkmoment
  if selected_prototype.base_type ~= "entity" then return end
  if selected_prototype.derived_type == "resource" then return end

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
    storage.held_planner_got_used[event.player_index] = nil
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

script.on_event(defines.events.on_marked_for_upgrade, function(event)
  if event.player_index then
    storage.held_planner_got_used[event.player_index] = true
  end
end)
