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

  storage.index = 0
  storage.structs = {}
  storage.deathrattles = {}
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
  -- if struct.marked_for_deconstruction then return end

  -- struct.itemstack_burner.set_stack({name = "greedy-inserter--fuel"})
  -- storage.deathrattles[script.register_on_object_destroyed(struct.itemstack_burner.item)] = {struct.id, "fuel"}

  -- if struct.held_stack.valid_for_read then
  --   struct.inserter.drop_target = nil
  -- else
  --   struct.inserter.drop_target = struct.container
  -- end
end

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination -- todo: handle cloning

  local struct = new_struct(storage.structs, {
    id = entity.unit_number,

    inserter = entity,
    container = nil,
    assembler = nil,

    itemstack_inserter = entity.held_stack,
    itemstack_container = nil,
    itemstack_assembler = nil,
  })

  struct.container = entity.surface.create_entity{
    name = "greedy-container",
    force = "neutral",
    position = entity.drop_position,
  }
  struct.container.destructible = false
  entity.drop_target = struct.container

  struct.assembler = storage.surface.create_entity{
    name = "assembling-machine-1",
    force = "neutral",
    position = {storage.index + 1.5, -1.5},
    recipe = "greedy-repair-pack",
  }

  struct.itemstack_container = struct.container.get_inventory(defines.inventory.chest)[1]
  struct.itemstack_assembler = struct.assembler.get_inventory(defines.inventory.assembling_machine_input)[1]

  local cb_assembler = struct.assembler.get_or_create_control_behavior() --[[@as LuaAssemblingMachineControlBehavior]]
  cb_assembler.circuit_enable_disable = true
  ---@diagnostic disable-next-line: missing-fields
  cb_assembler.circuit_condition = {
    comparator = "≠",
    constant = 0,
    first_signal = {
      name = "signal-anything",
      type = "virtual"
    }
  }

  local container_connector = struct.container.get_wire_connector(defines.wire_connector_id.circuit_red, true)
  local assembler_connector = struct.assembler.get_wire_connector(defines.wire_connector_id.circuit_red, true)
  assert(container_connector.connect_to(assembler_connector, false))

  struct.itemstack_assembler.set_stack({name = "repair-pack", count = 2})

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {struct.id, "inserter"}
  storage.index = storage.index + 1
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

    if struct.itemstack_inserter.valid_for_read then
      struct.inserter.drop_target = nil
    else
      struct.inserter.drop_target = struct.container
    end
  end
end

-- there is no way to listen for "allow_custom_vectors", but the player can just rotate them.
script.on_event(defines.events.on_player_rotated_entity, on_player_rotated_or_flipped_entity)
script.on_event(defines.events.on_player_flipped_entity, on_player_rotated_or_flipped_entity)
