local Handler = {}

script.on_init(function()
  storage.surface = game.planets["greedy-inserter"].create_surface()
  storage.surface.generate_with_lab_tiles = true

  storage.next_x_offset = 0
  storage.greedy_inserters = {}
end)

local function new_struct(table, struct)
  assert(struct.id, serpent.block(struct))
  assert(table[struct.id] == nil)
  table[struct.id] = struct
  return struct
end

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination -- todo: handle cloning

  local inserter_cb = entity.get_or_create_control_behavior() --[[@as LuaInserterControlBehavior]]
  inserter_cb.circuit_read_hand_contents = true
  inserter_cb.circuit_hand_read_mode = defines.control_behavior.inserter.hand_read_mode.hold

  local struct = new_struct(storage.greedy_inserters, {
    id = entity.unit_number,
    entity = entity,

    children = {},
  })

  struct.children["assembling-machine-1"] = storage.surface.create_entity{
    name = "greedy-inserter--assembling-machine",
    force = "neutral",
    position = {storage.next_x_offset + 1.5, -1.5},
    direction = defines.direction.south,
  }

  struct.children["assembling-machine-2"] = storage.surface.create_entity{
    name = "greedy-inserter--assembling-machine",
    force = "neutral",
    position = {storage.next_x_offset + 1.5, -4.5},
    direction = defines.direction.north,
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

  storage.next_x_offset = storage.next_x_offset + 3
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
