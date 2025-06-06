require("util")

local Shared = require("shared")

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  if player.cursor_stack and player.cursor_stack.valid_for_read and player.cursor_stack.name == "holmium-solution-quality-multiplier" then
    player.cursor_stack.clear()
  end
end)

local mod_surface_name = "holmium-chemical-plant"
local coin_item_name = "coupon-for-holmium-solution"

local function new_struct(table, struct)
  assert(struct.id, serpent.block(struct))
  assert(table[struct.id] == nil)
  table[struct.id] = struct
  return struct
end

local Handler = {}

script.on_init(function()
  storage.version = 1
  storage.x_offset = 0
  storage.structs = {}
  storage.deathrattles = {}

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

  if (storage.version or 0) == 0 then
    storage.version = 1
    for _, struct in pairs(storage.structs) do
      if struct.linked_chest_a then -- prevent the new structs from showing up here as we iterate
        struct.linked_chest_a.destroy()
        struct.linked_chest_b.destroy()
        struct.linked_chest_c.destroy()
        struct.inserter_3.destroy()
        if struct.holmium_chemical_plant.valid then -- what? how?
          struct.position = {"N", "O"} -- skip find_preexisting_struct
          local clone = struct.holmium_chemical_plant.clone{
            position = struct.holmium_chemical_plant.position,
          }

          local invalid = game.create_inventory(0)
          invalid.destroy()

          struct.proxy_container_a = invalid
          struct.proxy_container_b = invalid

          struct.holmium_chemical_plant.destroy()
        end
      end
    end
  end
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

function Handler.find_preexisting_struct(surface, position)
  for _, struct in pairs(storage.structs) do
    if struct.surface.index == surface.index then
      if struct.position.x == position.x and struct.position.y == position.y then
        return struct
      end
    end
  end
end

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  local old_struct = Handler.find_preexisting_struct(entity.surface, entity.position)
  if old_struct then
    storage.deathrattles[old_struct.registration_number] = nil
    storage.structs[old_struct.id] = nil
    old_struct.id = entity.unit_number
    storage.structs[old_struct.id] = old_struct
    old_struct.registration_number = script.register_on_object_destroyed(entity)
    old_struct.holmium_chemical_plant = entity
    storage.deathrattles[old_struct.registration_number] = {type = "holmium-chemical-plant", struct_id = old_struct.id}
    Handler.on_holmium_chemical_plant_changed_quality(old_struct)
    return
  end

  local struct = new_struct(storage.structs, {
    id = entity.unit_number,
    registration_number = script.register_on_object_destroyed(entity),
    holmium_chemical_plant = entity,

    surface = entity.surface,
    position = entity.position,

    -- linked_chest_a = nil,
    -- linked_chest_b = nil,
    proxy_container_a = nil,
    inserter_1 = nil,
    infinity_chest_1 = nil,
    inserter_2 = nil,
    -- linked_chest_c = nil,
    proxy_container_b = nil,
    arithmetic_1 = nil,
    arithmetic_2 = nil,
    arithmetic_3 = nil,
    -- inserter_3 = nil,
    assembler = nil,
  })

  storage.deathrattles[struct.registration_number] = {type = "holmium-chemical-plant", struct_id = struct.id}

  struct.proxy_container_a = game.surfaces[mod_surface_name].create_entity{
    name = "proxy-container",
    force = "neutral",
    position = {0.5 + storage.x_offset, -0.5},
  }
  struct.proxy_container_a.proxy_target_entity = struct.holmium_chemical_plant
  struct.proxy_container_a.proxy_target_inventory = defines.inventory.crafter_output

  struct.inserter_1 = game.surfaces[mod_surface_name].create_entity{
    name = "holmium-chemical-plant-inserter",
    force = "neutral",
    position = {0.5 + storage.x_offset, -1.5},
    direction = defines.direction.south,
  }
  assert(struct.inserter_1)
  struct.inserter_1.use_filters = true
  struct.inserter_1.inserter_filter_mode = "blacklist"
  struct.inserter_1.set_filter(1, {
    comparator = "=",
    name = coin_item_name,
    quality = "normal"
  })
  struct.inserter_1.inserter_stack_size_override = 1

  struct.inserter_1_cb = struct.inserter_1.get_or_create_control_behavior() --[[@as LuaInserterControlBehavior]]
  struct.inserter_1_cb.circuit_read_hand_contents = true
  struct.inserter_1_cb.circuit_hand_read_mode = defines.control_behavior.inserter.hand_read_mode.pulse

  struct.infinity_chest_1 = game.surfaces[mod_surface_name].create_entity{
    name = "infinity-chest",
    force = "neutral",
    position = {0.5 + storage.x_offset, -2.5},
  }
  struct.infinity_chest_1.remove_unfiltered_items = true
  struct.infinity_chest_1.infinity_container_filters = {
    {
      count = 1,
      index = 1,
      mode = "at-least",
      name = coin_item_name,
    }
  }

  struct.inserter_2 = game.surfaces[mod_surface_name].create_entity{
    name = "holmium-chemical-plant-inserter",
    force = "neutral",
    position = {0.5 + storage.x_offset, -3.5},
    direction = defines.direction.south,
  }
  assert(struct.inserter_2)
  inserter_2_cb = struct.inserter_2.get_or_create_control_behavior() --[[@as LuaInserterControlBehavior]]
  inserter_2_cb.circuit_read_hand_contents = true
  inserter_2_cb.circuit_hand_read_mode = defines.control_behavior.inserter.hand_read_mode.pulse
  inserter_2_cb.circuit_enable_disable = true
  inserter_2_cb.circuit_condition = {
    comparator = "<",
    constant = 0,
    first_signal = {
      name = coin_item_name
    }
  }
  struct.inserter_2.inserter_stack_size_override = 1

  struct.proxy_container_b = game.surfaces[mod_surface_name].create_entity{
    name = "proxy-container",
    force = "neutral",
    position = {0.5 + storage.x_offset, -4.5},
  }

  -- takes in the quality signal and determines the multiplier amount
  struct.arithmetic_1 = game.surfaces[mod_surface_name].create_entity{
    name = "arithmetic-combinator",
    force = "neutral",
    position = {0.5 + storage.x_offset, -6.0},
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
      green = false,
      red = true
    },
    operation = "*",
    output_signal = {
      name = coin_item_name
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

  local green_in = struct.arithmetic_1.get_wire_connector(defines.wire_connector_id.combinator_input_green, false)
  local red_in = struct.arithmetic_1.get_wire_connector(defines.wire_connector_id.combinator_input_red, false)

  assert(green_in.connect_to(storage.constant_combinator.get_wire_connector(defines.wire_connector_id.circuit_green, false), false))
  assert(red_in.connect_to(struct.inserter_1.get_wire_connector(defines.wire_connector_id.circuit_red, false), false))

  -- turns the multiplier signal negative, so the inserter's posive pulse can subtract from it
  struct.arithmetic_2 = game.surfaces[mod_surface_name].create_entity{
    name = "arithmetic-combinator",
    force = "neutral",
    position = {0.5 + storage.x_offset, -8.0},
    direction = defines.direction.north,
  }
  assert(struct.arithmetic_2)
  arithmetic_2_cb = struct.arithmetic_2.get_control_behavior() --[[@as LuaArithmeticCombinatorControlBehavior]]
  arithmetic_2_cb.parameters = {
    first_signal = {
      name = coin_item_name
    },
    first_signal_networks = {
      green = true,
      red = true
    },
    operation = "*",
    output_signal = {
      name = coin_item_name
    },
    second_constant = -1,
    second_signal_networks = {
      green = true,
      red = true
    }
  }

  struct.arithmetic_2_red_in = struct.arithmetic_2.get_wire_connector(defines.wire_connector_id.combinator_input_red, false)
  assert(struct.arithmetic_2_red_in.connect_to(struct.arithmetic_1.get_wire_connector(defines.wire_connector_id.combinator_output_red, false)))

  -- memory cell
  struct.arithmetic_3 = game.surfaces[mod_surface_name].create_entity{
    name = "arithmetic-combinator",
    force = "neutral",
    position = {0.5 + storage.x_offset, -10.0},
    direction = defines.direction.north,
  }
  assert(struct.arithmetic_3)
  arithmetic_3_cb = struct.arithmetic_3.get_control_behavior() --[[@as LuaArithmeticCombinatorControlBehavior]]
  arithmetic_3_cb.parameters = {
    first_signal = {
      name = coin_item_name
    },
    first_signal_networks = {
      green = true,
      red = true
    },
    operation = "+",
    output_signal = {
      name = coin_item_name
    },
    second_constant = 0,
    second_signal_networks = {
      green = true,
      red = true
    }
  }

  local arithmetic_3_red_in = struct.arithmetic_3.get_wire_connector(defines.wire_connector_id.combinator_input_red, false)
  assert(arithmetic_3_red_in.connect_to(struct.arithmetic_2.get_wire_connector(defines.wire_connector_id.combinator_output_red, false)))
  assert(arithmetic_3_red_in.connect_to(struct.arithmetic_3.get_wire_connector(defines.wire_connector_id.combinator_output_red, false)))

  local arithmetic_3_red_out = struct.arithmetic_3.get_wire_connector(defines.wire_connector_id.combinator_output_red, false)
  assert(arithmetic_3_red_out.connect_to(struct.inserter_2.get_wire_connector(defines.wire_connector_id.circuit_red, false)))

  storage.x_offset = storage.x_offset + 1

  struct.assembler = entity.surface.create_entity{
    name = "holmium-chemical-plant-assembling-machine",
    force = entity.force, -- for production statistics
    position = entity.position,
  }
  struct.assembler.destructible = false
  struct.proxy_container_b.proxy_target_entity = struct.assembler
  struct.proxy_container_b.proxy_target_inventory = defines.inventory.crafter_input

  Handler.on_holmium_chemical_plant_changed_quality(struct)
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

function Handler.on_holmium_chemical_plant_changed_quality(struct)
  struct.holmium_chemical_plant.fluidbox.add_linked_connection(3, struct.assembler, 1)
  struct.holmium_chemical_plant.fluidbox.add_linked_connection(4, struct.assembler, 2)
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil

    if deathrattle.type == "holmium-chemical-plant" then
      local struct = assert(storage.structs[deathrattle.struct_id])
      -- struct.linked_chest_a.destroy()
      -- struct.linked_chest_b.destroy()
      struct.proxy_container_a.destroy()
      struct.inserter_1.destroy()
      struct.infinity_chest_1.destroy()
      struct.inserter_2.destroy()
      -- struct.linked_chest_c.destroy()
      struct.proxy_container_b.destroy()
      struct.arithmetic_1.destroy()
      struct.arithmetic_2.destroy()
      struct.arithmetic_3.destroy()
      -- struct.inserter_3.destroy()
      struct.assembler.destroy()
      storage.structs[deathrattle.struct_id] = nil
    else
      error(serpent.block(deathrattle))
    end

  end
end)
