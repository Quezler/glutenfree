local Combinators = {}

function Combinators.create_for_struct(struct)
  local entity_cb = struct.entity.get_or_create_control_behavior() --[[@as LuaAssemblingMachineControlBehavior]]
  entity_cb.circuit_read_recipe_finished = true
  entity_cb.circuit_recipe_finished_signal = {type = "virtual", name = "signal-F"}
  entity_cb.circuit_read_working = true
  entity_cb.circuit_working_signal = {type = "virtual", name = "signal-W"}

  struct.inserter_1 = storage.surface.create_entity{
    name = "inserter",
    force = "neutral",
    position = {0.5 + struct.index, -1.5},
    direction = defines.direction.south,
  }
  assert(struct.inserter_1)
  inserter_1_cb = struct.inserter_1.get_or_create_control_behavior() --[[@as LuaInserterControlBehavior]]
  inserter_1_cb.circuit_enable_disable = true
  inserter_1_cb.circuit_condition = {
    comparator = ">",
    constant = 0,
    first_signal = {
      name = "signal-F",
      type = "virtual"
    },
    fulfilled = false
  }

  do
    local green_out = struct.entity.get_wire_connector(defines.wire_connector_id.circuit_green, false) --[[@as LuaWireConnector]]
    local green_in = struct.inserter_1.get_wire_connector(defines.wire_connector_id.circuit_green, false) --[[@as LuaWireConnector]]
    assert(green_out.connect_to(green_in, false, defines.wire_origin.script))
  end

  struct.inserter_2 = storage.surface.create_entity{
    name = "inserter",
    force = "neutral",
    position = {0.5 + struct.index, -4.5},
    direction = defines.direction.south,
  }
  assert(struct.inserter_2)
  inserter_2_cb = struct.inserter_2.get_or_create_control_behavior() --[[@as LuaInserterControlBehavior]]
  inserter_2_cb.circuit_enable_disable = true
  inserter_2_cb.circuit_condition = {
    comparator = "=",
    constant = 0,
    first_signal = {
      name = "signal-W",
      type = "virtual"
    },
    fulfilled = false
  }

  do
    local green_out = struct.entity.get_wire_connector(defines.wire_connector_id.circuit_green, false) --[[@as LuaWireConnector]]
    local green_in = struct.inserter_2.get_wire_connector(defines.wire_connector_id.circuit_green, false) --[[@as LuaWireConnector]]
    assert(green_out.connect_to(green_in, false, defines.wire_origin.script))
  end
end

return Combinators
