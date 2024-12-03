local decider_combinator_parameters = require("scripts.decider_combinator_parameters")
local TickHandler = require("scripts.tick-handler")

local mod_surface_name = "upcycler"

local Handler = {}

local function reset_items_per_next_quality()
  storage.items_per_next_quality = {
    upcycler = settings.global["upcycling-items-per-next-quality"].value,
  }
end

function Handler.init()
  storage.structs = {}
  storage.struct_ids = {}
  storage.deathrattles = {}
  storage.next_x_offset = 0
  reset_items_per_next_quality()
  storage.decider_control_behaviors_to_override = {}
  storage.observed_structs = {}

  local mod_surface = game.planets[mod_surface_name].create_surface()
  mod_surface.generate_with_lab_tiles = true
  mod_surface.create_global_electric_network()
  mod_surface.create_entity{
    name = "electric-energy-interface",
    force = "neutral",
    position = {-1, -1},
  }
end

function Handler.on_configuration_changed()
  if game.planets[mod_surface_name].surface == nil then
    game.planets[mod_surface_name].associate_surface(game.surfaces[mod_surface_name])
  end

  reset_items_per_next_quality()
end

script.on_init(Handler.init)
script.on_configuration_changed(Handler.on_configuration_changed)

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  entity.custom_status = {
    diode = defines.entity_status_diode.green,
    label = {"upcycler.status"},
  }

  -- skip giving a dummy item if the upcycler animation has already started (aka when the machine got upgraded in quality)
  if entity.crafting_progress == 0 then
    local inserted = entity.get_inventory(defines.inventory.furnace_source).insert({name = "upcycle-any-quality", count = 1})
    assert(inserted > 0)
  end

  -- game.print('i fire first @' .. game.tick)
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
    quality = entity.quality,
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
    surface = entity.surface,
    position = entity.position,
    entities = {
      upcycler = entity,
      upcycler_input = upcycler_input,
      upcycler_output = upcycler_output,
      inserter = inserter,
      trash = trash,
      decider = decider,
    },
    last_held_stack = nil,
  }
  TickHandler.invalidate_struct_ids()

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {struct_id = entity.unit_number}

  storage.next_x_offset = storage.next_x_offset + 1
end

local function reset_on_created_entity_listeners()
  local filters = {}

  for entity_name, _ in pairs(storage.items_per_next_quality) do
    table.insert(filters, {filter = "name", name = entity_name})
  end

  for _, event in ipairs({
    defines.events.on_built_entity,
    defines.events.on_robot_built_entity,
    defines.events.on_space_platform_built_entity,
    defines.events.script_raised_built,
    defines.events.script_raised_revive,
    defines.events.on_entity_cloned,
  }) do
    script.on_event(event, Handler.on_created_entity, filters)
  end
end

script.on_load(function()
  reset_on_created_entity_listeners()
end)

function Handler.get_or_create_linkedchest_then_move(entity)
  local linked_chest = entity.surface.find_entities_filtered{
    name = "upcycler-input",
    area = entity.bounding_box,
    quality = entity.quality.name,
    limit = 1,
  }

  linked_chest = #linked_chest and linked_chest[1] or nil

  if linked_chest == nil then
    linked_chest = entity.surface.create_entity{
      name = "upcycler-input",
      force = "neutral",
      position = entity.position,
      quality = entity.quality.name,
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
  if storage.items_per_next_quality[event.entity.name] ~= nil then
    Handler.get_or_create_linkedchest_then_move(event.entity)
  end
end)

script.on_event(defines.events.on_player_flipped_entity, function(event)
  if storage.items_per_next_quality[event.entity.name] ~= nil then
    Handler.get_or_create_linkedchest_then_move(event.entity)
  end
end)

-- originally i planned to store the pending counts inside item metadata but eh effort,
-- this will technically allow cheesing by storing all the things that can spoil or are damaged in here until you need them.
function Handler.spill(struct)
  local control_behavior = struct.entities.decider.get_control_behavior()
  local green_network = struct.entities.decider.get_circuit_network(defines.wire_connector_id.combinator_output_green)

  for _, signal_and_count in ipairs(green_network.signals or {}) do
    struct.surface.spill_item_stack{
      position = struct.position,
      stack = {name=signal_and_count.signal.name, count=signal_and_count.count, quality=signal_and_count.signal.quality},
      force = struct.force,
      allow_belts = false,
    }
  end
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    local struct = storage.structs[deathrattle.struct_id]
    if struct then storage.structs[deathrattle.struct_id] = nil
      -- game.print('i fire second @' .. game.tick)
      Handler.spill(struct)
      for _, entity in pairs(struct.entities) do
        entity.destroy()
      end
      TickHandler.invalidate_struct_ids()
      storage.observed_structs[struct.id] = nil
    end
  end
end)

script.on_event(defines.events.on_tick, TickHandler.on_tick)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if event.setting_type == "runtime-global" then
    if event.setting == "upcycling-items-per-next-quality" then
      storage.items_per_next_quality["upcycler"] = settings.global["upcycling-items-per-next-quality"].value
    end
  end
end)

script.on_event(defines.events.on_selected_entity_changed, TickHandler.on_selected_entity_changed)
script.on_event(defines.events.on_gui_opened, TickHandler.on_gui_opened)

remote.add_interface("upcycler", {
  set_items_per_next_quality = function(data)
    assert(data.name ~= "upcycler") -- this would desync what is shown in the settings of this mod
    assert(prototypes.entity[data.name])
    assert(data.items > 0)
    storage.items_per_next_quality[data.name] = data.items
    reset_on_created_entity_listeners()
  end,
})
