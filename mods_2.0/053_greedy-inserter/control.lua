local Handler = {}

script.on_init(function()
  storage.structs = {}
  storage.deathrattles = {}
end)

local function new_struct(table, struct)
  assert(struct.id, serpent.block(struct))
  assert(table[struct.id] == nil)
  table[struct.id] = struct
  return struct
end

local function tick_struct(struct)
  if struct.marked_for_deconstruction then return end

  struct.itemstack_burner.set_stack({name = "greedy-inserter--fuel"})
  storage.deathrattles[script.register_on_object_destroyed(struct.itemstack_burner.item)] = {struct.id, "fuel"}

  if struct.itemstack_hand.valid_for_read then
    struct.inserter.drop_target = nil
  else
    struct.inserter.drop_target = struct.container
  end
end

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination -- todo: handle cloning

  local struct = new_struct(storage.structs, {
    id = entity.unit_number,

    inserter = entity,
    container = nil,

    itemstack_hand = entity.held_stack,
    -- itemstack_burner = entity.get_inventory(defines.inventory.fuel)[1],

    state = "empty",
    state_switched_at = event.tick,
  })

  struct.container = entity.surface.create_entity{
    name = "greedy-inserter--container",
    force = "neutral",
    position = entity.drop_position,
  }
  struct.container.destructible = false
  entity.drop_target = struct.container

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {struct.id, "inserter"}
  -- tick_struct(struct)

  game.print(event.tick)
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = "name", name = "greedy-inserter"},
  })
end

local function purge_struct(struct)
  storage.structs[struct.id] = nil
  struct.container.destroy()
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil

    -- game.print(event.tick .. serpent.line(deathrattle))

    local struct = storage.structs[deathrattle[1]]
    if struct then
      if deathrattle[2] == "fuel" then
        tick_struct(struct)
      elseif deathrattle[2] == "inserter" then
        purge_struct(struct)
      else
        error(serpent.block(deathrattle))
      end
    end
  end
end)

local function on_player_rotated_or_flipped_entity(event)
  local entity = event.entity

  if entity.name == "greedy-inserter" then
    local struct = storage.structs[entity.unit_number]
    struct.container.teleport(entity.drop_position)

    if struct.itemstack_hand.valid_for_read then
      struct.inserter.drop_target = nil
    else
      struct.inserter.drop_target = struct.container
    end
  end
end

-- there is no way to listen for "allow_custom_vectors", but the player can just rotate them.
script.on_event(defines.events.on_player_rotated_entity, on_player_rotated_or_flipped_entity)
script.on_event(defines.events.on_player_flipped_entity, on_player_rotated_or_flipped_entity)

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local cursor_stack = player.cursor_stack
  if cursor_stack and cursor_stack.valid_for_read and cursor_stack.name == "greedy-inserter--fuel" then
    cursor_stack.clear() -- no touchy my monkey!
  end
end)

script.on_event(defines.events.on_player_main_inventory_changed, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local inventory = player.get_inventory(defines.inventory.character_main) --[[@as LuaInventory]]
  inventory.remove({name = "greedy-inserter--fuel"}) -- shift transfer stole it from the fuel slot :o
end)

script.on_event(defines.events.on_marked_for_deconstruction, function(event)
  local struct = storage.structs[event.entity.unit_number]
  struct.marked_for_deconstruction = true
  struct.itemstack_burner.clear()
end, {
  {filter = "name", name = "greedy-inserter"},
})

script.on_event(defines.events.on_cancelled_deconstruction, function(event)
  local struct = storage.structs[event.entity.unit_number]
  struct.marked_for_deconstruction = nil
  tick_struct(struct)
end, {
  {filter = "name", name = "greedy-inserter"},
})

local states = {
  ["empty"] = function(struct, tick)
    if struct.itemstack_hand.valid_for_read then
      struct.state = "items"
      struct.state_switched_at = tick
      struct.inserter.drop_target = nil
    end
  end,
  ["items"] = function(struct, tick)
    if struct.itemstack_hand.valid_for_read == false then
      struct.state = "empty"
      struct.state_switched_at = tick
      struct.inserter.drop_target = struct.container
    end
  end,
}

script.on_event(defines.events.on_tick, function(event)
  for unit_number, struct in pairs(storage.structs) do
    -- game.print(event.tick .. " " .. unit_number .. " " .. serpent.line(struct.itemstack_hand.valid_for_read))
    game.print(string.format("%d %s %s for %d", event.tick, unit_number, struct.state, event.tick - struct.state_switched_at))
    states[struct.state](struct, event.tick)
  end
end)
