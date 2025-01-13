local Handler = {}

script.on_init(function()
  storage.surface = game.planets["greedy-inserter"].create_surface()
  storage.surface.generate_with_lab_tiles = true

  storage.next_x_offset = 0
  storage.greedy_inserters = {}

  storage.deathrattles = {}
end)

local function new_struct(table, struct)
  assert(struct.id, serpent.block(struct))
  assert(table[struct.id] == nil)
  table[struct.id] = struct
  return struct
end

local function arm_struct(struct)
  struct.hand_is_empty = not struct.hand_is_empty
  local input_itemstack = struct.hand_is_empty and struct.input_itemstack_1 or struct.input_itemstack_2

  input_itemstack.set_stack({name = "repair-pack", count = 1})
  storage.deathrattles[script.register_on_object_destroyed(input_itemstack.item)] = {struct.id, "1-2"}
end

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination -- todo: handle cloning

  entity.inserter_stack_size_override = 1

  local inserter_cb = entity.get_or_create_control_behavior() --[[@as LuaInserterControlBehavior]]
  inserter_cb.circuit_read_hand_contents = true
  inserter_cb.circuit_hand_read_mode = defines.control_behavior.inserter.hand_read_mode.hold

  local struct = new_struct(storage.greedy_inserters, {
    id = entity.unit_number,

    inserter = entity,
    container = nil,

    assembler_1 = nil,
    assembler_2 = nil,
    assembler_3 = nil,

    input_itemstack_1 = nil,
    input_itemstack_2 = nil,
    input_itemstack_3 = nil,

    hand_is_empty = true, -- assembling machine 1 will still be active in the tick it got placed, so we will give the item to assembling machine 2 first
  })

  struct.assembler_1 = storage.surface.create_entity{
    name = "greedy-inserter--assembling-machine",
    force = "neutral",
    position = {storage.next_x_offset + 1.5, -1.5},
  }

  struct.assembler_2 = storage.surface.create_entity{
    name = "greedy-inserter--assembling-machine",
    force = "neutral",
    position = {storage.next_x_offset + 1.5, -4.5},
  }

  struct.assembler_3 = storage.surface.create_entity{
    name = "greedy-inserter--assembling-machine",
    force = "neutral",
    position = {storage.next_x_offset + 1.5, -7.5},
  }

  local inserter_circuit_wire = entity.get_wire_connector(defines.wire_connector_id.circuit_red, true)
  assert(inserter_circuit_wire.connect_to(struct.assembler_1.get_wire_connector(defines.wire_connector_id.circuit_red, true), false, defines.wire_origin.script))
  assert(inserter_circuit_wire.connect_to(struct.assembler_2.get_wire_connector(defines.wire_connector_id.circuit_red, true), false, defines.wire_origin.script))

  local cb_1 = struct.assembler_1.get_or_create_control_behavior() --[[@as LuaAssemblingMachineControlBehavior]]
  local cb_2 = struct.assembler_2.get_or_create_control_behavior() --[[@as LuaAssemblingMachineControlBehavior]]
  local cb_3 = struct.assembler_3.get_or_create_control_behavior() --[[@as LuaAssemblingMachineControlBehavior]]

  cb_1.circuit_enable_disable = true
  cb_2.circuit_enable_disable = true
  cb_3.circuit_enable_disable = true

  ---@diagnostic disable-next-line: missing-fields
  cb_1.circuit_condition = {
    comparator = "≠",
    constant = 0,
    first_signal = {
      name = "signal-anything",
      type = "virtual"
    }
  }

  ---@diagnostic disable-next-line: missing-fields
  cb_2.circuit_condition = {
    comparator = "=",
    constant = 0,
    first_signal = {
      name = "signal-everything",
      type = "virtual"
    }
  }

  ---@diagnostic disable-next-line: missing-fields
  cb_3.circuit_condition = {
    comparator = "≠",
    constant = 0,
    first_signal = {
      name = "signal-anything",
      type = "virtual"
    }
  }

  struct.input_itemstack_1 = struct.assembler_1.get_inventory(defines.inventory.assembling_machine_input)[1]
  struct.input_itemstack_2 = struct.assembler_2.get_inventory(defines.inventory.assembling_machine_input)[1]
  struct.input_itemstack_3 = struct.assembler_3.get_inventory(defines.inventory.assembling_machine_input)[1]

  struct.container = entity.surface.create_entity{
    name = "greedy-inserter--container",
    force = "neutral",
    position = entity.drop_position,
  }
  struct.container.destructible = false
  entity.drop_target = struct.container

  local container_circuit_wire = struct.container.get_wire_connector(defines.wire_connector_id.circuit_red, true)
  assert(container_circuit_wire.connect_to(struct.assembler_3.get_wire_connector(defines.wire_connector_id.circuit_red, true), false, defines.wire_origin.script))

  storage.next_x_offset = storage.next_x_offset + 3

  arm_struct(struct)

  struct.input_itemstack_3.set_stack({name = "repair-pack", count = 2})
  storage.deathrattles[script.register_on_object_destroyed(struct.input_itemstack_3.item)] = {struct.id, "3"}
  storage.deathrattles[script.register_on_object_destroyed(entity                       )] = {struct.id, "3"}
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
  storage.greedy_inserters[struct.id] = nil
  if struct.inserter.valid then struct.inserter.die() end
  struct.container.destroy()
  struct.assembler_1.destroy()
  struct.assembler_2.destroy()
  struct.assembler_3.destroy()
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil

    local struct = storage.greedy_inserters[deathrattle[1]]
    if struct then
      if deathrattle[2] == "1-2" then
        arm_struct(struct)
        -- game.print(serpent.line({hand_is_empty = struct.hand_is_empty}))

        if struct.hand_is_empty then
          struct.inserter.drop_target = struct.container
        else
          struct.inserter.drop_target = nil
        end
      elseif deathrattle[2] == "3" then
        -- game.print("ohno")
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
    local struct = storage.greedy_inserters[entity.unit_number]
    struct.container.teleport(entity.drop_position)
    if struct.hand_is_empty then
      entity.drop_position = struct.container
    end
  end
end

-- there is no way to listen for "allow_custom_vectors", but the player can just rotate them.
script.on_event(defines.events.on_player_rotated_entity, on_player_rotated_or_flipped_entity)
script.on_event(defines.events.on_player_flipped_entity, on_player_rotated_or_flipped_entity)
