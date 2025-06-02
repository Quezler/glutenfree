local Combinators = {}

function Combinators.create_for_struct(struct)
  struct.proxy_container = storage.surface.create_entity{
    name = "proxy-container",
    force = "neutral",
    position = {0.5 + struct.index, 0.5},
  }
  struct.proxy_container.proxy_target_entity = struct.container
  struct.proxy_container.proxy_target_inventory = defines.inventory.chest

  struct.arithmetic_1 = storage.surface.create_entity{
    name = "arithmetic-combinator",
    force = "neutral",
    position = {0.5 + struct.index, -1.0},
    direction = defines.direction.north,
  }
  assert(struct.arithmetic_1)
  arithmetic_1_cb = struct.arithmetic_1.get_control_behavior() --[[@as LuaArithmeticCombinatorControlBehavior]]
  arithmetic_1_cb.parameters = {
    first_signal = {
      name = "signal-each",
      type = "virtual"
    },
    first_signal_networks = {
      green = true,
      red = true
    },
    operation = "+",
    output_signal = {
      name = "signal-S",
      type = "virtual"
    },
    second_constant = 0,
    second_signal_networks = {
      green = true,
      red = true
    }
  }

  do
    local red_out = struct.proxy_container.get_wire_connector(defines.wire_connector_id.circuit_red, true) --[[@as LuaWireConnector]]
    local red_in = struct.arithmetic_1.get_wire_connector(defines.wire_connector_id.combinator_input_red, false) --[[@as LuaWireConnector]]
    assert(red_out.connect_to(red_in, false, defines.wire_origin.player))
  end

  struct.arithmetic_2 = storage.surface.create_entity{
    name = "arithmetic-combinator",
    force = "neutral",
    position = {0.5 + struct.index, -3.0},
    direction = defines.direction.north,
  }
  assert(struct.arithmetic_2)
  arithmetic_2_cb = struct.arithmetic_2.get_control_behavior() --[[@as LuaArithmeticCombinatorControlBehavior]]
  arithmetic_2_cb.parameters = {
    first_signal = {
      name = "signal-S",
      type = "virtual"
    },
    first_signal_networks = {
      green = true,
      red = true
    },
    operation = "+",
    output_signal = {
      name = "signal-S",
      type = "virtual"
    },
    second_constant = 0,
    second_signal_networks = {
      green = true,
      red = true
    }
  }

  do
    local red_out = struct.arithmetic_1.get_wire_connector(defines.wire_connector_id.combinator_output_red, false) --[[@as LuaWireConnector]]
    local red_in = struct.arithmetic_2.get_wire_connector(defines.wire_connector_id.combinator_input_red, false) --[[@as LuaWireConnector]]
    assert(red_out.connect_to(red_in, false, defines.wire_origin.player))
  end

  struct.decider_1 = storage.surface.create_entity{
    name = "decider-combinator",
    force = "neutral",
    position = {0.5 + struct.index, -5.0},
    direction = defines.direction.north,
  }
  assert(struct.decider_1)
  decider_1_cb = struct.decider_1.get_control_behavior() --[[@as LuaDeciderCombinatorControlBehavior]]
  decider_1_cb.parameters = {
    conditions = {
      {
        comparator = "≠",
        compare_type = "or",
        first_signal = {
          name = "signal-S",
          type = "virtual"
        },
        first_signal_networks = {
          green = false,
          red = true
        },
        second_signal = {
          name = "signal-S",
          type = "virtual"
        },
        second_signal_networks = {
          green = true,
          red = false
        }
      }
    },
    outputs = {
      {
        copy_count_from_input = false,
        networks = {
          green = true,
          red = true
        },
        signal = {
          name = "signal-R",
          type = "virtual"
        }
      }
    }
  }

  do
    local red = struct.arithmetic_2.get_wire_connector(defines.wire_connector_id.combinator_output_red, false) --[[@as LuaWireConnector]]
    local green = struct.arithmetic_1.get_wire_connector(defines.wire_connector_id.combinator_output_green, false) --[[@as LuaWireConnector]]
    local red_in = struct.decider_1.get_wire_connector(defines.wire_connector_id.combinator_input_red, false) --[[@as LuaWireConnector]]
    local green_in = struct.decider_1.get_wire_connector(defines.wire_connector_id.combinator_input_green, false) --[[@as LuaWireConnector]]
    assert(red.connect_to(red_in, false, defines.wire_origin.player))
    assert(green.connect_to(green_in, false, defines.wire_origin.player))
  end

  struct.decider_2 = storage.surface.create_entity{
    name = "decider-combinator",
    force = "neutral",
    position = {0.5 + struct.index, -7.0},
    direction = defines.direction.north,
  }
  assert(struct.decider_2)
  decider_2_cb = struct.decider_2.get_control_behavior() --[[@as LuaDeciderCombinatorControlBehavior]]
  decider_2_cb.parameters = {
    conditions = {
      {
        comparator = "=",
        compare_type = "or",
        constant = 0,
        first_signal = {
          name = "signal-R",
          type = "virtual"
        },
        first_signal_networks = {
          green = true,
          red = true
        },
        second_signal_networks = {
          green = true,
          red = true
        }
      }
    },
    outputs = {
      {
        copy_count_from_input = true,
        networks = {
          green = true,
          red = true
        },
        signal = {
          name = "signal-T",
          type = "virtual"
        }
      },
      {
        copy_count_from_input = false,
        networks = {
          green = true,
          red = true
        },
        signal = {
          name = "signal-T",
          type = "virtual"
        }
      }
    }
  }

  do
    local red = struct.decider_1.get_wire_connector(defines.wire_connector_id.combinator_output_red, false) --[[@as LuaWireConnector]]
    local red_in = struct.decider_2.get_wire_connector(defines.wire_connector_id.combinator_input_red, false) --[[@as LuaWireConnector]]
    assert(red.connect_to(red_in, false, defines.wire_origin.player))

    local green = struct.decider_2.get_wire_connector(defines.wire_connector_id.combinator_output_green, false) --[[@as LuaWireConnector]]
    local green_in = struct.decider_2.get_wire_connector(defines.wire_connector_id.combinator_input_green, false) --[[@as LuaWireConnector]]
    assert(green.connect_to(green_in, false, defines.wire_origin.player))
  end

  do -- idle timer to crafter
    local green_out = struct.decider_2.get_wire_connector(defines.wire_connector_id.combinator_output_green, false) --[[@as LuaWireConnector]]
    local green_in = struct.entity.get_wire_connector(defines.wire_connector_id.circuit_green, true) --[[@as LuaWireConnector]]
    assert(green_out.connect_to(green_in, false, defines.wire_origin.player))
  end

  local entity_cb = struct.entity.get_or_create_control_behavior() --[[@as LuaAssemblingMachineControlBehavior]]
  entity_cb.circuit_read_recipe_finished = true
  entity_cb.circuit_recipe_finished_signal = {type = "virtual", name = "signal-F"}
  entity_cb.circuit_enable_disable = true
  entity_cb.circuit_condition = {
    comparator = "≥",
    constant = 60 * 2.5,
    first_signal = {
      name = "signal-T",
      type = "virtual"
    },
    fulfilled = false
  }

  struct.inserter_1 = storage.surface.create_entity{
    name = "inserter",
    force = "neutral",
    position = {0.5 + struct.index, -9.5},
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
end

return Combinators
