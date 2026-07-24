local Planet = {}

local connector = defines.wire_connector_id

local function connect(entity_a, connector_a, entity_b, connector_b)
  local wire_connector_a = entity_a.get_wire_connector(connector_a, true)
  local wire_connector_b = entity_b.get_wire_connector(connector_b, true)
  assert(wire_connector_a.connect_to(wire_connector_b, false, defines.wire_origin.player))
end
Planet.connect = connect

Planet.setup_combinators = function(building)
  if building.is_ghost then return end

  building.x_offset = mod.next_index_for("x_offset") * 3

  building.children.proxy_container_1 = storage.surface.create_entity{
    name = "proxy-container",
    force = "neutral",
    position = {-2.5 + building.x_offset, -0.5}
  }
  building.children.proxy_container_1.proxy_target_entity = building.entity
  building.children.proxy_container_1.proxy_target_inventory = defines.inventory.chest

  building.children.constant_combinator_1 = storage.surface.create_entity{
    name = "constant-combinator",
    force = "neutral",
    position = {-2.5 + building.x_offset, -1.5},
    direction = defines.direction.north,
  }
  Planet.update_constant_combinator_1(building)
  building.children.constant_combinator_2 = storage.surface.create_entity{
    name = "constant-combinator",
    force = "neutral",
    position = {-1.5 + building.x_offset, -1.5},
    direction = defines.direction.north,
  }
  Planet.update_constant_combinator_2(building)

  -- connect the item & fluid ingredients wire to the buildings & modules combinator of which only the green wire gets used
  connect(building.children.constant_combinator_1, connector.circuit_red, building.children.constant_combinator_2, connector.circuit_red)

  building.children.decider_combinator_1 = storage.surface.create_entity{
    name = "decider-combinator",
    force = "neutral",
    position = {-2.5 + building.x_offset, -3.0},
    direction = defines.direction.north,
  }
  -- /c log(serpent.block(game.player.selected.get_control_behavior().parameters, {sortkeys = false}))
  building.children.decider_combinator_1.get_control_behavior().parameters = {
    conditions = {
      {
        first_signal = {
          type = "virtual",
          name = "signal-everything"
        },
        constant = 0,
        comparator = ">",
        first_signal_networks = {
          red = true,
          green = true
        },
        second_signal_networks = {
          red = true,
          green = true
        },
        compare_type = "or"
      },
      {
        first_signal = {
          type = "virtual",
          name = "signal-anything"
        },
        constant = 0,
        comparator = "<",
        first_signal_networks = {
          red = false,
          green = true
        },
        second_signal_networks = {
          red = true,
          green = true
        },
        compare_type = "and"
      }
    },
    outputs = {
      {
        signal = {
          type = "virtual",
          name = "signal-check"
        },
        copy_count_from_input = false,
        networks = {
          red = true,
          green = true
        }
      }
    }
  }

  connect(building.children.proxy_container_1, connector.circuit_red, building.children.decider_combinator_1, connector.combinator_input_red)
  connect(building.children.constant_combinator_1, connector.circuit_green, building.children.decider_combinator_1, connector.combinator_input_green)
  connect(building.children.constant_combinator_1, connector.circuit_red, building.entity, connector.circuit_red)
  connect(building.children.decider_combinator_1, connector.combinator_output_green, building.children.crafter_a, connector.circuit_green)

  building.children.trigger_1 = storage.surface.create_entity{
    name = "assembling-machine-1",
    force = "neutral",
    position = {-1.5 + building.x_offset, -5.5}
  }
  building.children.trigger_1.set_recipe("wooden-chest")
  building.trigger_1_input_stack  = building.children.trigger_1.get_inventory(defines.inventory.crafter_input)[1]
  building.trigger_1_output_stack = building.children.trigger_1.get_inventory(defines.inventory.crafter_output)[1]
  local cb_1 = building.children.trigger_1.get_or_create_control_behavior() --[[@as LuaAssemblingMachineControlBehavior]]
  cb_1.circuit_enable_disable = true
  cb_1.circuit_condition = {
    comparator = "=",
    constant = 1,
    first_signal = {
      name = "signal-check",
      type = "virtual"
    },
  }
  connect(building.children.decider_combinator_1, connector.combinator_output_green, building.children.trigger_1, connector.circuit_green)

  building.children.trigger_2 = storage.surface.create_entity{
    name = "assembling-machine-1",
    force = "neutral",
    position = {-1.5 + building.x_offset, -8.5}
  }
  building.children.trigger_2.set_recipe("wooden-chest")
  building.trigger_2_input_stack  = building.children.trigger_2.get_inventory(defines.inventory.crafter_input)[1]
  building.trigger_2_output_stack = building.children.trigger_2.get_inventory(defines.inventory.crafter_output)[1]
  local cb_2 = building.children.trigger_2.get_or_create_control_behavior() --[[@as LuaAssemblingMachineControlBehavior]]
  cb_2.circuit_enable_disable = true
  cb_2.circuit_condition = {
    comparator = "=",
    constant = 0,
    first_signal = {
      name = "signal-check",
      type = "virtual"
    },
  }
  connect(building.children.decider_combinator_1, connector.combinator_output_green, building.children.trigger_2, connector.circuit_green)

  building.children.trigger_3 = storage.surface.create_entity{
    name = "assembling-machine-1",
    force = "neutral",
    position = {-1.5 + building.x_offset, -11.5}
  }
  building.children.trigger_3.set_recipe("wooden-chest")
  building.trigger_3_input_stack  = building.children.trigger_3.get_inventory(defines.inventory.crafter_input)[1]
  building.trigger_3_output_stack = building.children.trigger_3.get_inventory(defines.inventory.crafter_output)[1]
  local cb_3 = building.children.trigger_3.get_or_create_control_behavior() --[[@as LuaAssemblingMachineControlBehavior]]
  cb_3.circuit_enable_disable = true
  cb_3.circuit_condition = {
    comparator = ">",
    constant = 0,
    first_signal = {
      name = "signal-F",
      type = "virtual"
    },
  }
  connect(building.children.decider_combinator_1, connector.combinator_output_green, building.children.trigger_3, connector.circuit_green)

  local crafter_a_cb = building.children.crafter_a.get_or_create_control_behavior() --[[@as LuaAssemblingMachineControlBehavior]]
  crafter_a_cb.circuit_read_recipe_finished = true
  crafter_a_cb.circuit_recipe_finished_signal = {type = "virtual", name = "signal-F"}
  crafter_a_cb.circuit_enable_disable = true
  crafter_a_cb.circuit_condition = {
    comparator = "=",
    constant = 1,
    first_signal = {
      name = "signal-check",
      type = "virtual"
    },
  }

  Planet.arm_trigger_n(building, 1) -- working
  Planet.arm_trigger_n(building, 3) -- crafted
end

Planet.update_constant_combinator_1 = function(building)
  if building.is_ghost then return end

  local sections = building.children.constant_combinator_1.get_logistic_sections()
  while sections.remove_section(1) do end

  local factory = storage.factories[building.factory_index]
  if not factory then return end

  for _, key in ipairs({"entities", "modules"}) do
    local section = sections.add_section()
    section.multiplier = -1
    for i, item in ipairs(factory.export[key]) do
      section.set_slot(i, {
        value = item,
        min = math.ceil(item.count),
      })
    end
  end
end

Planet.update_constant_combinator_2 = function(building)
  if building.is_ghost then return end

  local sections = building.children.constant_combinator_2.get_logistic_sections()
  while sections.remove_section(1) do end

  local factory = storage.factories[building.factory_index]
  if not factory then return end

  for _, key in ipairs({"ingredients"}) do
    local section = sections.add_section()
    section.multiplier = -1
    for i, item in ipairs(factory.export[key]) do
      section.set_slot(i, {
        value = item,
        min = math.ceil(item.count),
      })
    end
  end
end

Planet.arm_trigger_n = function(building, n)
  building["trigger_" .. n .. "_output_stack"].clear()
  building["trigger_" .. n .. "_input_stack"].set_stack({
    name = "wood",
    count = 2,
    health = 0.5,
  })
  storage.deathrattles[script.register_on_object_destroyed(building["trigger_" .. n .. "_input_stack"].item)] = {name = "trigger", building_index = building.index, n = n}
end

return Planet
