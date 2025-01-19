local Handler = {}

script.on_init(function()
  storage.surface = game.planets["greedy-inserter"].create_surface()
  storage.surface.generate_with_lab_tiles = true

  storage.surface.create_global_electric_network()
  storage.surface.create_entity{
    name = "electric-energy-interface",
    force = "neutral",
    position = {-1, -1},
  }

  storage.samples = nil

  storage.structs = {}
  storage.deathrattles = {}

  storage.at_tick = {}
end)

local function new_struct(table, struct)
  assert(struct.id, serpent.block(struct))
  assert(table[struct.id] == nil)
  table[struct.id] = struct
  return struct
end

local function at_tick(tick, struct_id)
  local at_tick = storage.at_tick[tick]
  if at_tick == nil then
    at_tick = {}
    storage.at_tick[tick] = at_tick
  end
  at_tick[struct_id] = true
end

local function tick_struct(struct)
  if struct.marked_for_deconstruction then return end

  struct.itemstack_burner.set_stack({name = "greedy-inserter--fuel"})
  storage.deathrattles[script.register_on_object_destroyed(struct.itemstack_burner.item)] = {struct.id, "fuel"}

  if struct.held_stack.valid_for_read then
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

    held_stack = entity.held_stack,
    held_stack_position = {x = 0, y = 0}, -- will break if you place it there :D
    -- itemstack_burner = entity.get_inventory(defines.inventory.fuel)[1],

    burner = assert(entity.burner, string.format("%s is not using a burner energy source.", entity.name)),

    state = "empty",
    state_switched_at = event.tick,
    inserter_rotation_speed_str = string.format("%.3f", entity.prototype.get_inserter_rotation_speed(entity.quality)) -- todo: update in on_configuration_changed
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

  -- game.print(event.tick)
  at_tick(event.tick + 1, struct.id)

  game.print(serpent.line(struct.inserter_rotation_speed_str))
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

    if struct.held_stack.valid_for_read then
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

-- the amount of ticks for the inserter to reach the dropoff position again after grabbing items optimally from a container
local initial_sleep_ticks = {
  ["0.040"] = 23, -- normal
  ["0.052"] = 17, -- uncommon
  ["0.064"] = 13, -- rare
  ["0.076"] = 11, -- epic
  ["0.100"] = 07, -- legendary
}

local states = {
  ["empty"] = function(struct, tick)
    if struct.held_stack.valid_for_read then
      struct.state = "items"
      -- struct.state_switched_at = tick
      struct.inserter.drop_target = nil
    end

    local held_stack_position = struct.inserter.held_stack_position

    -- log(serpent.block({struct.held_stack_position, held_stack_position}))
    if struct.held_stack_position.x == held_stack_position.x and struct.held_stack_position.y == held_stack_position.y then
      -- log("match!")
      struct.burner.remaining_burning_fuel = 1
    end

    return 1
  end,
  ["items"] = function(struct, tick)
    if struct.held_stack.valid_for_read == false then
      struct.state = "empty"
      -- struct.state_switched_at = tick
      struct.inserter.drop_target = struct.container
      -- game.print(struct.inserter_rotation_speed_str)
      return initial_sleep_ticks[struct.inserter_rotation_speed_str]
    end
    return 1
  end,
}

script.on_event(defines.events.on_tick, function(event)
  -- game.print(event.tick)
  -- for unit_number, struct in pairs(storage.structs) do
  --   -- game.print(event.tick .. " " .. unit_number .. " " .. serpent.line(struct.held_stack.valid_for_read))
    -- game.print(string.format("%d %s %s for %d", event.tick, unit_number, struct.state, event.tick - struct.state_switched_at))
    -- states[struct.state](struct, event.tick)
  -- end

  local tasks = storage.at_tick[event.tick]
  if tasks then storage.at_tick[event.tick] = nil
    for struct_id, _ in pairs(tasks) do
      local struct = storage.structs[struct_id]
      if struct then
        game.get_player(1).create_local_flying_text{
          text = "-",
          position = struct.inserter.position,
        }
        -- game.print(serpent.line(struct.inserter.held_stack_position))
        local tick_offset = states[struct.state](struct, event.tick) -- this does the update
        struct.held_stack_position = struct.inserter.held_stack_position
        game.print(string.format("%d %s %s +%d", event.tick, struct_id, struct.state, tick_offset))
        at_tick(event.tick + tick_offset, struct_id)
      end
    end
  end

  if storage.samples then
    for quality_name, sample in pairs(storage.samples) do
      if sample.item_grabbed_at == nil then
        if sample.inserter.held_stack.valid_for_read == true then
          sample.item_grabbed_at = event.tick
        end
      elseif sample.item_dropped_at == nil then
        if sample.inserter.held_stack.valid_for_read == false then
          sample.item_dropped_at = event.tick
        end
      elseif sample.second_item_grabbed_at == nil then
        if sample.inserter.held_stack.valid_for_read == true then
          sample.second_item_grabbed_at = event.tick
        end
      else
        if sample.inserter.held_stack.valid_for_read == false then
          game.print(string.format("%s %d", quality_name, event.tick - sample.item_dropped_at))
          storage.samples[quality_name] = nil
        end
      end
    end
  end
end)


commands.add_command("greedy-inserter", nil, function(command)
  storage.samples = {}

  local i = 0
  for _, quality in pairs(prototypes.quality) do
    local chest_out = storage.surface.create_entity{
      name = "infinity-chest",
      force = "neutral",
      position = {0.5 + i, 0.5},
    }
    chest_out.infinity_container_filters = {{name = "iron-plate", count = 100, index = 1}}

    local inserter = storage.surface.create_entity{
      name = "greedy-inserter",
      force = "neutral",
      quality = quality,
      position = {0.5 + i, 1.5},
    }

    local chest_in = storage.surface.create_entity{
      name = "infinity-chest",
      force = "neutral",
      position = {0.5 + i, 2.5},
    }
    chest_in.remove_unfiltered_items = true

    storage.samples[quality.name] = {
      chest_out = chest_out,
      inserter = inserter,
      chest_in = chest_in,

      first_item_grabbed_at = nil,
      first_item_dropped_at = nil,
      second_item_grabbed_at = nil,
    }

    i = i + 1
  end
end)
