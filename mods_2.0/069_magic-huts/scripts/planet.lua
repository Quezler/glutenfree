local Planet = {}

local connector = defines.wire_connector_id

local function connect(entity_a, connector_a, entity_b, connector_b)
  local wire_connector_a = entity_a.get_wire_connector(connector_a, true)
  local wire_connector_b = entity_b.get_wire_connector(connector_b, true)
  assert(wire_connector_a.connect_to(wire_connector_b, false, defines.wire_origin.player))
end

Planet.setup_combinators = function(building)
  assert(building.is_ghost == false)

  building.proxy_container_1 = storage.surface.create_entity{
    name = "proxy-container",
    force = "neutral",
    position = {-0.5 + building.x_offset, -0.5}
  }
  building.proxy_container_1.proxy_target_entity = building.entity
  building.proxy_container_1.proxy_target_inventory = defines.inventory.chest

  building.constant_combinator_1 = storage.surface.create_entity{
    name = "constant-combinator",
    force = "neutral",
    position = {-0.5 + building.x_offset, -1.5},
    direction = defines.direction.north,
  }

  building.decider_combinator_1 = storage.surface.create_entity{
    name = "decider-combinator",
    force = "neutral",
    position = {-0.5 + building.x_offset, -3.0},
    direction = defines.direction.north,
  }

  connect(building.proxy_container_1, connector.circuit_red, building.decider_combinator_1, connector.combinator_input_red)
  connect(building.constant_combinator_1, connector.circuit_green, building.decider_combinator_1, connector.combinator_input_green)
end

return Planet
