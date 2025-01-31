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
    arithmetic_1 = nil,
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
      name = "signal-T", -- T for total of all combined signals
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
