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

  input_itemstack.set_stack({name = "deconstruction-planner", count = 1})
  storage.deathrattles[script.register_on_object_destroyed(input_itemstack.item)] = struct.id
end

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination -- todo: handle cloning

  local inserter_cb = entity.get_or_create_control_behavior() --[[@as LuaInserterControlBehavior]]
  inserter_cb.circuit_read_hand_contents = true
  inserter_cb.circuit_hand_read_mode = defines.control_behavior.inserter.hand_read_mode.hold

  local struct = new_struct(storage.greedy_inserters, {
    id = entity.unit_number,
    inserter = entity,

    container = nil,

    children = {
      ["assembling-machine-1"] = nil,
      ["assembling-machine-2"] = nil,
    },

    input_itemstack_1 = nil,
    input_itemstack_2 = nil,

    hand_is_empty = true, -- assembling machine 1 will still be active in the tick it got placed, so we will give the item to assembling machine 2 first
  })

  struct.children["assembling-machine-1"] = storage.surface.create_entity{
    name = "greedy-inserter--assembling-machine",
    force = "neutral",
    position = {storage.next_x_offset + 1.5, -1.5},
  }

  struct.children["assembling-machine-2"] = storage.surface.create_entity{
    name = "greedy-inserter--assembling-machine",
    force = "neutral",
    position = {storage.next_x_offset + 1.5, -4.5},
  }

  local inserter_circuit_wire = entity.get_wire_connector(defines.wire_connector_id.circuit_red, true)
  assert(inserter_circuit_wire.connect_to(struct.children["assembling-machine-1"].get_wire_connector(defines.wire_connector_id.circuit_red, true), false, defines.wire_origin.script))
  assert(inserter_circuit_wire.connect_to(struct.children["assembling-machine-2"].get_wire_connector(defines.wire_connector_id.circuit_red, true), false, defines.wire_origin.script))

  local cb_1 = struct.children["assembling-machine-1"].get_or_create_control_behavior() --[[@as LuaAssemblingMachineControlBehavior]]
  local cb_2 = struct.children["assembling-machine-2"].get_or_create_control_behavior() --[[@as LuaAssemblingMachineControlBehavior]]

  cb_1.circuit_enable_disable = true
  cb_2.circuit_enable_disable = true

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

  struct.input_itemstack_1 = struct.children["assembling-machine-1"].get_inventory(defines.inventory.assembling_machine_input)[1]
  struct.input_itemstack_2 = struct.children["assembling-machine-2"].get_inventory(defines.inventory.assembling_machine_input)[1]

  struct.container = entity.surface.create_entity{
    name = "greedy-inserter--container",
    force = "neutral",
    position = entity.drop_position,
  }
  struct.container.destructible = false
  entity.drop_target = struct.container

  storage.next_x_offset = storage.next_x_offset + 3

  arm_struct(struct)
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

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil

    local struct = assert(storage.greedy_inserters[deathrattle])
    arm_struct(struct)
    game.print(serpent.line({hand_is_empty = struct.hand_is_empty}))

    if struct.hand_is_empty then
      struct.inserter.drop_target = struct.container
    else
      struct.inserter.drop_target = nil
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
