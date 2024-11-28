require("util")

local Shared = require("shared")

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  if player.cursor_stack and player.cursor_stack.valid_for_read and player.cursor_stack.name == "holmium-solution-quality-multiplier" then
    player.cursor_stack.clear()
  end
end)

local mod_surface_name = "holmium-chemical-plant"

local Handler = {}

script.on_init(function()
  storage.x_offset = 0

  local mod_surface = game.planets[mod_surface_name].create_surface()
  mod_surface.generate_with_lab_tiles = true
  mod_surface.create_global_electric_network()

  storage.electric_energy_interface = mod_surface.create_entity{
    name = "electric-energy-interface",
    force = "neutral",
    position = {-1, -1},
  }

  storage.constant_combinator = mod_surface.create_entity{
    name = "constant-combinator",
    force = "neutral",
    position = {-0.5, -5.5},
    direction = defines.direction.south,
  }

  Handler.update_constant_combinator()
end)

script.on_configuration_changed(function()
  Handler.update_constant_combinator()
end)

function Handler.update_constant_combinator()
  local cb = storage.constant_combinator.get_control_behavior() --[[@as LuaConstantCombinatorControlBehavior]]
  cb.remove_section(1)
  local section = cb.add_section() --[[@as LuaLogisticSection]]
  for _, quality in pairs(prototypes.quality) do
    if not quality.hidden then
      section.set_slot(section.filters_count + 1, {
        value = {type = "item", name = "holmium-solution-quality-based-productivity", quality = quality.name, comparator = "="},
        min = Shared.get_multiplier_for_quality(quality) - 1,
      })
    end
  end
end

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  local linked_chest_a = entity.surface.create_entity{
    name = "holmium-chemical-plant-chest",
    force = "neutral",
    position = util.moveposition({entity.position.x, entity.position.y}, entity.direction, -1),
  }
  linked_chest_a.destructible = false
  linked_chest_a.link_id = storage.x_offset

  local linked_chest_b = game.surfaces[mod_surface_name].create_entity{
    name = "holmium-chemical-plant-chest",
    force = "neutral",
    position = {0.5 + storage.x_offset, -0.5},
  }
  linked_chest_b.link_id = storage.x_offset

  local inserter_1 = game.surfaces[mod_surface_name].create_entity{
    name = "fast-inserter",
    force = "neutral",
    position = {0.5 + storage.x_offset, -1.5},
    direction = defines.direction.south,
  }
  assert(inserter_1)
  inserter_1.use_filters = true
  inserter_1.inserter_filter_mode = "blacklist"
  inserter_1.set_filter(1, {
    comparator = "=",
    name = "coin", -- todo
    quality = "normal"
  })

  local inserter_1_cb = inserter_1.get_or_create_control_behavior() --[[@as LuaInserterControlBehavior]]
  inserter_1_cb.circuit_read_hand_contents = true
  inserter_1_cb.circuit_hand_read_mode = defines.control_behavior.inserter.hand_read_mode.pulse

  local infinity_chest_1 = game.surfaces[mod_surface_name].create_entity{
    name = "infinity-chest",
    force = "neutral",
    position = {0.5 + storage.x_offset, -2.5},
  }
  infinity_chest_1.remove_unfiltered_items = true
  infinity_chest_1.infinity_container_filters = {
    {
      count = 1,
      index = 1,
      mode = "at-least",
      name = "coin" -- todo: holmium solution coupon
    }
  }

  local inserter_2 = game.surfaces[mod_surface_name].create_entity{
    name = "fast-inserter",
    force = "neutral",
    position = {0.5 + storage.x_offset, -3.5},
    direction = defines.direction.south,
  }
  assert(inserter_2)

  local linked_chest_c = game.surfaces[mod_surface_name].create_entity{
    name = "holmium-chemical-plant-chest",
    force = "neutral",
    position = {0.5 + storage.x_offset, -4.5},
  }
  linked_chest_c.link_id = storage.x_offset

  -- takes in the quality signal and determines the multiplier amount
  local arithmetic_1 = game.surfaces[mod_surface_name].create_entity{
    name = "arithmetic-combinator",
    force = "neutral",
    position = {0.5 + storage.x_offset, -6.0},
    direction = defines.direction.north,
  }
  assert(arithmetic_1)
  arithmetic_1_cb = arithmetic_1.get_control_behavior() --[[@as LuaArithmeticCombinatorControlBehavior]]
  arithmetic_1_cb.parameters = {
    first_signal = {
      name = "signal-each",
      type = "virtual"
    },
    first_signal_networks = {
      green = false,
      red = true
    },
    operation = "*",
    output_signal = {
      name = "coin"
    },
    second_signal = {
      name = "signal-each",
      type = "virtual"
    },
    second_signal_networks = {
      green = true,
      red = false
    }
  }

  local green_in = arithmetic_1.get_wire_connector(defines.wire_connector_id.combinator_input_green, false)
  local red_in = arithmetic_1.get_wire_connector(defines.wire_connector_id.combinator_input_red, false)

  assert(green_in.connect_to(storage.constant_combinator.get_wire_connector(defines.wire_connector_id.circuit_green, false), false))
  assert(red_in.connect_to(inserter_1.get_wire_connector(defines.wire_connector_id.circuit_red, false), false))

  -- turns the multiplier signal negative, so the inserter's posive pulse can subtract from it
  local arithmetic_2 = game.surfaces[mod_surface_name].create_entity{
    name = "arithmetic-combinator",
    force = "neutral",
    position = {0.5 + storage.x_offset, -8.0},
    direction = defines.direction.north,
  }
  assert(arithmetic_2)
  arithmetic_2_cb = arithmetic_2.get_control_behavior() --[[@as LuaArithmeticCombinatorControlBehavior]]
  arithmetic_2_cb.parameters = {
    first_signal = {
      name = "coin"
    },
    first_signal_networks = {
      green = true,
      red = true
    },
    operation = "*",
    output_signal = {
      name = "coin"
    },
    second_constant = -1,
    second_signal_networks = {
      green = true,
      red = true
    }
  }

  local arithmetic_2_red_in = arithmetic_2.get_wire_connector(defines.wire_connector_id.combinator_input_red, false)
  assert(arithmetic_2_red_in.connect_to(arithmetic_1.get_wire_connector(defines.wire_connector_id.combinator_output_red, false)))

  -- memory cell
  local arithmetic_3 = game.surfaces[mod_surface_name].create_entity{
    name = "arithmetic-combinator",
    force = "neutral",
    position = {0.5 + storage.x_offset, -10.0},
    direction = defines.direction.north,
  }
  assert(arithmetic_3)
  arithmetic_3_cb = arithmetic_3.get_control_behavior() --[[@as LuaArithmeticCombinatorControlBehavior]]
  arithmetic_3_cb.parameters = {
    first_signal = {
      name = "coin"
    },
    first_signal_networks = {
      green = true,
      red = true
    },
    operation = "+",
    output_signal = {
      name = "coin"
    },
    second_constant = 0,
    second_signal_networks = {
      green = true,
      red = true
    }
  }

  local arithmetic_3_red_in = arithmetic_3.get_wire_connector(defines.wire_connector_id.combinator_input_red, false)
  assert(arithmetic_3_red_in.connect_to(arithmetic_2.get_wire_connector(defines.wire_connector_id.combinator_output_red, false)))
  assert(arithmetic_3_red_in.connect_to(arithmetic_3.get_wire_connector(defines.wire_connector_id.combinator_output_red, false)))

  storage.x_offset = storage.x_offset + 1
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
    {filter = "name", name = "holmium-chemical-plant"},
  })
end
