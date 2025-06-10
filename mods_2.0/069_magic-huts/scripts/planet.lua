local Planet = {}

local connector = defines.wire_connector_id

local function connect(entity_a, connector_a, entity_b, connector_b)
  local wire_connector_a = entity_a.get_wire_connector(connector_a, true)
  local wire_connector_b = entity_b.get_wire_connector(connector_b, true)
  assert(wire_connector_a.connect_to(wire_connector_b, false, defines.wire_origin.player))
end

Planet.setup_combinators = function(building)
  assert(building.is_ghost == false)

  building.children.proxy_container_1 = storage.surface.create_entity{
    name = "proxy-container",
    force = "neutral",
    position = {-0.5 + building.x_offset, -0.5}
  }
  building.children.proxy_container_1.proxy_target_entity = building.entity
  building.children.proxy_container_1.proxy_target_inventory = defines.inventory.chest

  building.children.constant_combinator_1 = storage.surface.create_entity{
    name = "constant-combinator",
    force = "neutral",
    position = {-0.5 + building.x_offset, -1.5},
    direction = defines.direction.north,
  }
  Planet.update_constant_combinator_1(building)

  building.children.decider_combinator_1 = storage.surface.create_entity{
    name = "decider-combinator",
    force = "neutral",
    position = {-0.5 + building.x_offset, -3.0},
    direction = defines.direction.north,
  }
  building.children.decider_combinator_1.get_control_behavior().parameters = {
    conditions = {
      {
        first_signal = {
          type = "virtual",
          name = "signal-everything"
        },
        constant = 0,
        comparator = "≥",
        first_signal_networks = {
          red = true,
          green = true
        },
        second_signal_networks = {
          red = true,
          green = true
        },
        compare_type = "or"
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
end

Planet.update_constant_combinator_1 = function(building)
  local sections = building.children.constant_combinator_1.get_logistic_sections()
  while sections.remove_section(1) do end

  local factory = storage.factories[building.factory_index]
  if not factory then return end

  for _, key in ipairs({"entities", "modules", "ingredients"}) do
    local section = sections.add_section()
    section.multiplier = -1
    for i, item in ipairs(factory.export[key]) do
      if item.type == "item" then
        section.set_slot(i, {
          value = item,
          min = item.count,
        })
      end
    end
  end
end

return Planet
