require("namespace")

local blueprint = require("scripts.blueprint")

local mod = {}

script.on_init(function()
  storage.surface = game.planets[mod_name].create_surface()
  storage.surface.generate_with_lab_tiles = true

  storage.surface.create_global_electric_network()
  storage.surface.create_entity{
    name = "electric-energy-interface",
    force = "neutral",
    position = {-1, -1},
  }

  storage.x_offset = 0
  storage.deathrattles = {}
end)

mod.on_created_entity = function(event)
  local entity = event.entity or event.destination

  local json = helpers.json_to_table(blueprint) --[[@as table]]
  local entity_number = {}
  for _, blueprint_entity in ipairs(json.blueprint.entities) do
    blueprint_entity.position.x = blueprint_entity.position.x + storage.x_offset
    blueprint_entity.force = entity.force
    entity_number[blueprint_entity.entity_number] = storage.surface.create_entity(blueprint_entity)
  end
  for _, wire in ipairs(json.blueprint.wires) do
    local source = entity_number[wire[1]].get_wire_connector(wire[2], true)
    local destination = entity_number[wire[3]].get_wire_connector(wire[4], true)
    assert(source.connect_to(destination, false, defines.wire_origin.player))
  end

  -- connect the green wire on the combinator to the input side of the blueprint
  entity.get_wire_connector(defines.wire_connector_id.circuit_green).connect_to(entity_number[4].get_wire_connector(defines.wire_connector_id.combinator_input_green), false, defines.wire_origin.player)
  -- and the red output signal back to the constant combinator
  entity.get_wire_connector(defines.wire_connector_id.circuit_red).connect_to(entity_number[2].get_wire_connector(defines.wire_connector_id.combinator_output_red), false, defines.wire_origin.player)

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {children = entity_number}
  storage.x_offset = storage.x_offset + 2
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, mod.on_created_entity, {
    {filter = "name", name = "stack-constant-combinator"},
  })
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    for _, child in pairs(deathrattle.children) do
      child.destroy()
    end
  end
end)
