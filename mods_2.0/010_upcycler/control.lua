local decider_combinator_parameters = require("scripts.decider_combinator_parameters")
local TickHandler = require("scripts.tick-handler")

local mod_surface_name = "upcycler"

local Handler = {}

function Handler.init()
  storage.structs = {}
  storage.struct_ids = {}
  storage.deathrattles = {}
  storage.next_x_offset = 0
  storage.items_per_next_quality = 100
  storage.decider_control_behaviors_to_override = {}

  local mod_surface = game.surfaces[mod_surface_name]
  if mod_surface then mod_surface.clear() end
  if mod_surface == nil then
    mod_surface = game.create_surface(mod_surface_name)
    mod_surface.generate_with_lab_tiles = true
  end

  mod_surface.create_global_electric_network()
  mod_surface.create_entity{
    name = "electric-energy-interface",
    force = "neutral",
    position = {-1, -1},
  }
end

script.on_init(Handler.init)

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  entity.custom_status = {
    diode = defines.entity_status_diode.green,
    label = {"upcycler.status"},
  }

  local inserted = entity.get_inventory(defines.inventory.furnace_source).insert({name = "upcycle-any-quality", count = 1})
  assert(inserted > 0)

  local upcycler_input = Handler.get_or_create_linkedchest_then_move(entity)

  local mod_surface = game.surfaces[mod_surface_name]
  local upcycler_output = mod_surface.create_entity{
    name = "upcycler-input",
    force = "neutral",
    position = {storage.next_x_offset, -0.5},
  }
  local inserter = mod_surface.create_entity{
    name = "fast-inserter",
    force = "neutral",
    position = {storage.next_x_offset, -1.5},
    direction = defines.direction.south,
  }
  local trash = mod_surface.create_entity{
    name = "infinity-chest",
    force = "neutral",
    position = {storage.next_x_offset, -2.5},
  }
  local decider = mod_surface.create_entity{
    name = "decider-combinator",
    force = "neutral",
    position = {storage.next_x_offset, -4.0},
  }

  upcycler_input.link_id = storage.next_x_offset
  upcycler_output.link_id = storage.next_x_offset

  local inserter_cb = inserter.get_or_create_control_behavior()
  inserter_cb.circuit_read_hand_contents = true
  inserter_cb.circuit_hand_read_mode = defines.control_behavior.inserter.hand_read_mode.pulse
  -- inserter.inserter_stack_size_override = 1 -- this disables the gui entirely :|

  trash.remove_unfiltered_items = true

  decider.get_control_behavior().parameters = decider_combinator_parameters

  local green_out = decider.get_wire_connector(defines.wire_connector_id.combinator_output_green, false)
  local green_in  = decider.get_wire_connector(defines.wire_connector_id.combinator_input_green, false)
  assert(green_out.connect_to(green_in, false, defines.wire_origin.player))

  local red_out = inserter.get_wire_connector(defines.wire_connector_id.circuit_red, false)
  local red_in  = decider.get_wire_connector(defines.wire_connector_id.combinator_input_red, false)
  assert(red_out.connect_to(red_in, false, defines.wire_origin.player))

  storage.structs[entity.unit_number] = {
    id = entity.unit_number,
    force = entity.force,
    entities = {
      upcycler = entity,
      upcycler_input = upcycler_input,
      upcycler_output = upcycler_output,
      inserter = inserter,
      trash = trash,
      decider = decider,
    }
  }
  TickHandler.invalidate_struct_ids()

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {struct_id = entity.unit_number}

  storage.next_x_offset = storage.next_x_offset + 1
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = "name", name = "upcycler"},
  })
end

function Handler.get_or_create_linkedchest_then_move(entity)
  local linked_chest = entity.surface.find_entities_filtered{
    name = "upcycler-input",
    area = entity.bounding_box,
    limit = 1,
  }

  linked_chest = #linked_chest and linked_chest[1] or nil

  if linked_chest == nil then
    linked_chest = entity.surface.create_entity{
      name = "upcycler-input",
      force = "neutral",
      position = entity.position,
    }
  end

  entity.destructible = false

  if entity.mirroring then
    if entity.direction == defines.direction.north then
      linked_chest.teleport({entity.position.x - 1, entity.position.y + 1})
    elseif entity.direction == defines.direction.east then
      linked_chest.teleport({entity.position.x - 2, entity.position.y - 1})
    elseif entity.direction == defines.direction.south then
      linked_chest.teleport({entity.position.x, entity.position.y - 2})
    elseif entity.direction == defines.direction.west then
      linked_chest.teleport({entity.position.x + 1, entity.position.y})
    end
  else
    if entity.direction == defines.direction.north then
      linked_chest.teleport({entity.position.x, entity.position.y + 1})
    elseif entity.direction == defines.direction.east then
      linked_chest.teleport({entity.position.x - 2, entity.position.y})
    elseif entity.direction == defines.direction.south then
      linked_chest.teleport({entity.position.x - 1, entity.position.y - 2})
    elseif entity.direction == defines.direction.west then
      linked_chest.teleport({entity.position.x + 1, entity.position.y - 1})
    end
  end

  return linked_chest
end

script.on_event(defines.events.on_player_rotated_entity, function(event)
  if event.entity.name == "upcycler" then
    Handler.get_or_create_linkedchest_then_move(event.entity)
  end
end)

script.on_event(defines.events.on_player_flipped_entity, function(event)
  if event.entity.name == "upcycler" then
    Handler.get_or_create_linkedchest_then_move(event.entity)
  end
end)

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    local struct = storage.structs[deathrattle.struct_id]
    if struct then storage.structs[deathrattle.struct_id] = nil
      for _, entity in pairs(struct.entities) do
        entity.destroy()
      end
      TickHandler.invalidate_struct_ids()
    end
  end
end)

script.on_event(defines.events.on_tick, TickHandler.on_tick)
