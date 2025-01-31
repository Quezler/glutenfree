local mod_prefix = "quality-disruptor--"

local function new_struct(table, struct)
  assert(struct.id, serpent.block(struct))
  assert(table[struct.id] == nil)
  table[struct.id] = struct
  return struct
end

local Handler = {}

script.on_init(function()
  storage.surface = game.planets["quality-disruptor"].create_surface()
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

function Handler.on_created_entity(event)
  local entity = event.entity

  local struct = new_struct(storage.structs, {
    id = entity.unit_number,
    entity = entity,

    container = nil,
    arithmetic_1 = nil, -- each + 0 = S
    arithmetic_2 = nil, -- each + 0 = each
    decider_1 = nil, -- red T != green T | R 1
    decider_2 = nil, -- R == 0 | T = T + 1
  })

  struct.container = entity.surface.create_entity{
    name = mod_prefix .. "container",
    force = entity.force,
    position = entity.position,
    quality = entity.quality,
  }
  struct.container.destructible = false

  struct.arithmetic_1 = storage.surface.create_entity{
    name = "arithmetic-combinator",
    force = "neutral",
    position = {0.5 + storage.index, -1.0},
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
    local red_out = struct.container.get_wire_connector(defines.wire_connector_id.circuit_red, true) --[[@as LuaWireConnector]]
    local red_in = struct.arithmetic_1.get_wire_connector(defines.wire_connector_id.combinator_input_red, false) --[[@as LuaWireConnector]]
    assert(red_out.connect_to(red_in, false, defines.wire_origin.script))
  end

  struct.arithmetic_2 = storage.surface.create_entity{
    name = "arithmetic-combinator",
    force = "neutral",
    position = {0.5 + storage.index, -3.0},
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
    position = {0.5 + storage.index, -5.0},
    direction = defines.direction.north,
  }
  assert(struct.decider_1)
  decider_1_cb = struct.decider_1.get_control_behavior() --[[@as LuaArithmeticCombinatorControlBehavior]]
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
    position = {0.5 + storage.index, -7.0},
    direction = defines.direction.north,
  }
  assert(struct.decider_2)
  decider_2_cb = struct.decider_2.get_control_behavior() --[[@as LuaArithmeticCombinatorControlBehavior]]
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

  storage.index = storage.index + 1
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  -- defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = "name", name = mod_prefix .. "crafter"},
  })
end
