local decider_combinator_parameters = require("scripts.decider_combinator_parameters")
local arithmetic_combinator_parameters = require("scripts.arithmetic_combinator_parameters")

local mod_surface_name = "awesome-sink"

local Handler = {}

script.on_init(function ()
  storage.version = 0
  storage.surfacedata = {}
  storage.deathrattles = {}

  storage.assembler_to_arithmetic_map = {}

  local mod_surface = game.surfaces[mod_surface_name]
  assert(surface == nil, "contact the mod author for help with world that previously already had this mod installed.")

  mod_surface = game.create_surface(mod_surface_name)
  mod_surface.generate_with_lab_tiles = true

  for _, surface in pairs(game.surfaces) do
    Handler.on_surface_created({surface_index = surface.index})
  end
end)

function Handler.on_surface_created(event)
  storage.surfacedata[event.surface_index] = {
    force_to_decider_combinator = {},
    auto_increment = 0,
  }
end

function Handler.on_surface_deleted(event)
  for _, decider_combinator in pairs(storage.surfacedata[event.surface_index].force_to_decider_combinator) do
    decider_combinator.destroy()
  end

  storage.surfacedata[event.surface_index] = nil
end

script.on_event(defines.events.on_surface_created, Handler.on_surface_created)
script.on_event(defines.events.on_surface_deleted, Handler.on_surface_deleted)

function Handler.get_or_create_decider_combinator(surface_index, force_index)
  local decider_combinator = storage.surfacedata[surface_index].force_to_decider_combinator[force_index]
  if decider_combinator then return decider_combinator end

  local mod_surface = game.surfaces[mod_surface_name]

  local y_offset = 7 * (surface_index - 1)
  local position = {0.5 - force_index, 1.0 + y_offset}
  assert(mod_surface.find_entity("awesome-decider-combinator", position) == nil)

  decider_combinator = mod_surface.create_entity{
    name = "awesome-decider-combinator",
    force = "neutral",
    position = position,
    direction = defines.direction.north,
  }
  assert(decider_combinator)

  local green_out = decider_combinator.get_wire_connector(defines.wire_connector_id.combinator_output_green, false)
  local green_in  = decider_combinator.get_wire_connector(defines.wire_connector_id.combinator_input_green, false)
  assert(green_out.connect_to(green_in, false, defines.wire_origin.player))

  --- @diagnostic disable-next-line: inject-field
  decider_combinator.get_control_behavior().parameters = decider_combinator_parameters
  decider_combinator.combinator_description = string.format("surface %d (%s)\nforce %d (%s)",
    surface_index, game.surfaces[surface_index].name,
    force_index, game.forces[force_index].name
  )

  storage.surfacedata[surface_index].force_to_decider_combinator[force_index] = decider_combinator
  return decider_combinator
end

function Handler.register_awesome_sink(awesome_sink, awesome_sink_gui)
  local entity = awesome_sink
  local surfacedata = storage.surfacedata[entity.surface.index]

  local decider_combinator = Handler.get_or_create_decider_combinator(entity.surface.index, entity.force.index)

  local mod_surface = game.surfaces[mod_surface_name]
  local y_offset = 7 * (entity.surface.index - 1)

  local arithmetic_combinator = mod_surface.create_entity{
    name = "awesome-arithmetic-combinator",
    force = "neutral",
    position = {0.5 + surfacedata.auto_increment, 1.0 + y_offset},
    direction = defines.direction.south,
  }
  assert(arithmetic_combinator)
  --- @diagnostic disable-next-line: inject-field 
  arithmetic_combinator.get_control_behavior().parameters = arithmetic_combinator_parameters
  arithmetic_combinator.combinator_description = string.format("force %d (%s)\ngame.player.teleport({%d, %d}, %s)\n[gps=%d,%d,%s]",
    entity.force.index, game.forces[entity.force.index].name,
    entity.position.x, entity.position.y, entity.surface.name,
    entity.position.x, entity.position.y, entity.surface.name
  )

  local red_out = arithmetic_combinator.get_wire_connector(defines.wire_connector_id.combinator_output_red, false)
  local red_in  = decider_combinator.get_wire_connector(defines.wire_connector_id.combinator_input_red, false)
  assert(red_out.connect_to(red_in, false, defines.wire_origin.player))

  local awesome_sink_out = mod_surface.create_entity{
    name = "awesome-sink",
    force = "neutral",
    position = {0.5 + surfacedata.auto_increment, -1.0 + y_offset},
    direction = defines.direction.south,
  }
  assert(awesome_sink_out, "did auto increment break and did this get placed over an existing transportbelt connectable?")
  awesome_sink_out.linked_belt_type = "output"
  awesome_sink_out.connect_linked_belts(entity)

  local transport_belt = mod_surface.create_entity{
    name = "transport-belt",
    force = "neutral",
    position = {0.5 + surfacedata.auto_increment, -2.0 + y_offset},
    direction = defines.direction.north,
  }
  assert(transport_belt)

  local red2_out = transport_belt.get_wire_connector(defines.wire_connector_id.circuit_red, true)
  local red2_in  = arithmetic_combinator.get_wire_connector(defines.wire_connector_id.combinator_input_red, false)
  assert(red2_out.connect_to(red2_in, false, defines.wire_origin.player))

  local transport_belt_control = assert(transport_belt.get_control_behavior())
  --- @diagnostic disable-next-line: inject-field
  transport_belt_control.read_contents = true
  --- @diagnostic disable-next-line: undefined-field
  assert(transport_belt_control.read_contents_mode == defines.control_behavior.transport_belt.content_read_mode.pulse )

  local loader_1_1 = mod_surface.create_entity{
    name = "loader-1x1",
    force = "neutral",
    position = {0.5 + surfacedata.auto_increment, -3.0 + y_offset},
    direction = defines.direction.south,
  }
  assert(loader_1_1)
  loader_1_1.loader_type = "input"

  local infinity_chest = mod_surface.create_entity{
    name = "infinity-chest",
    force = "neutral",
    position = {0.5 + surfacedata.auto_increment, -4.0 + y_offset},
    direction = defines.direction.north,
  }
  assert(infinity_chest)
  infinity_chest.remove_unfiltered_items = true

  local deathrattle = {
    entities_to_destroy = {
      awesome_sink,
      awesome_sink_gui,

      arithmetic_combinator,
      awesome_sink_out,
      transport_belt,
      loader_1_1,
      infinity_chest,
    },

    assembler_to_arithmetic_map_key_to_clear = awesome_sink_gui.unit_number,
  }

  storage.deathrattles[script.register_on_object_destroyed(awesome_sink)] = deathrattle
  storage.deathrattles[script.register_on_object_destroyed(awesome_sink_gui)] = deathrattle

  storage.assembler_to_arithmetic_map[awesome_sink_gui.unit_number] = {
    assembler = awesome_sink_gui,
    assembler_unit_number = awesome_sink_gui.unit_number,

    arithmetic = arithmetic_combinator,
    arithmetic_unit_number = arithmetic_combinator.unit_number,

    last_points = 0,
  }

  surfacedata.auto_increment = surfacedata.auto_increment + 1
end

function Handler.findentity_or_reviveentity_or_createentity(surface, force, position, name, quality_in_case_of_create)
  local entities = surface.find_entities_filtered{
    name = name,
    force = force,
    position = position,
    limit = 1,
  }

  if entities[1] then return entities[1] end

  local ghosts = surface.find_entities_filtered{
    ghost_name = name,
    force = force,
    position = position,
    limit = 1,
  }

  if entities[1] then return entities[1] end

  if ghosts[1] then
    local _, entity = ghosts[1].revive({})
    if entity then return entity end
  end

  return surface.create_entity{
    name = name,
    force = force,
    position = position,
    quality = quality_in_case_of_create,
  }
end

function Handler.create_at_position(surface, force, position, direction, quality)
  local awesome_sink     = Handler.findentity_or_reviveentity_or_createentity(surface, force, position, "awesome-sink", quality)
  local awesome_sink_gui = Handler.findentity_or_reviveentity_or_createentity(surface, force, position, "awesome-sink-gui", quality)

  assert(awesome_sink.quality.name == awesome_sink_gui.quality.name)

  awesome_sink    .direction = direction
  awesome_sink_gui.direction = direction

  Handler.register_awesome_sink(awesome_sink, awesome_sink_gui)
end

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  if entity.name == "awesome-sink" then
    Handler.create_at_position(entity.surface, entity.force, entity.position, entity.direction, entity.quality)
  elseif entity.name == "awesome-sink-gui" then
    Handler.create_at_position(entity.surface, entity.force, entity.position, entity.direction, entity.quality)
  elseif entity.name == "awesome-shop" then
    entity.link_id = entity.surface.index
  else
    error(string.format("%s (%s)", entity.name, entity.type))
  end
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = "name", name = "awesome-sink"},
    {filter = "name", name = "awesome-shop"},
    {filter = "name", name = "awesome-sink-gui"},
  })
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    for _, entity in pairs(deathrattle.entities_to_destroy) do
      entity.destroy()
    end

    storage.assembler_to_arithmetic_map[deathrattle.assembler_to_arithmetic_map_key_to_clear] = nil
  end
end)

function Handler.sync_module_qualities_with_arithmetic_combinators()
  for key, map in pairs(storage.assembler_to_arithmetic_map) do
    -- converts two place decimal into nearest full number
    local points = math.floor((map.assembler.effects["quality"] or 0) * 100 + 0.5)
    if map.last_points ~= points then
      map.last_points = points

      local cb = map.arithmetic.get_control_behavior()
      local parameters = cb.parameters
      parameters.second_constant = points
      cb.parameters = parameters

      log(string.format("each item sunk in #%d now counts as %d points", key, points))
    end
  end
end

-- local next_quality = {}
-- for _, quality_prototype in pairs(prototypes.quality) do
--   next_quality[quality_prototype.name] = quality_prototype.next
-- end

function get_next_quality(quality_name)
  return prototypes.quality[quality_name or "normal"].next
end

function get_spoil_result(item_name)
  local prototype = prototypes.item[item_name]

  local spoils = prototype.get_spoil_ticks() > 0
  if spoils == false then return item_name end

  local spoil_result = prototype.spoil_result
  if spoil_result then return get_spoil_result(spoil_result.name) end -- in case of spoilage chains

  -- if we got here the item spoils but into nothing, we'll decrement the counter and give nothing

  -- but, what if the item does something when it spoils? we'll get there eventually and fix it
  assert(prototype.spoil_to_trigger_result == nil, "items that e.g. spawn entities are not supported atm.")
end

function Handler.handle_signal(surface_index, force_index, cb, signal_and_count)
  local payout = math.floor(signal_and_count.count / 1000)
  if payout == 0 then return end

  local next_quality = get_next_quality(signal_and_count.signal.quality)
  if next_quality == nil then return end

  local item_to_insert = get_spoil_result(signal_and_count.signal.name)
  if item_to_insert == nil then return end

  local inventory = game.forces[force_index].get_linked_inventory("awesome-shop", surface_index)
  if inventory == nil then return end

  local inserted = inventory.insert({name =item_to_insert, count=payout, quality=next_quality})
  if inserted == 0 then return end

  -- this output will be removed again in the next tick, effectively subtracting the signal
  cb.add_output({
    signal = {
      type = "item",
      name = signal_and_count.signal.name,
      quality = signal_and_count.signal.quality,
    },
    constant = -(payout * 1000),
    copy_count_from_input = false,
  })
end

function Handler.flash_decider_combinator_outputs()
  for surface_index, surfacedata in pairs(storage.surfacedata) do
    for force_index, decider_combinator in pairs(surfacedata.force_to_decider_combinator) do
      local control_behavior = decider_combinator.get_control_behavior()
      local green_network = decider_combinator.get_circuit_network(defines.wire_connector_id.combinator_output_green)

      for _, signal_and_count in ipairs(green_network.signals or {}) do
        Handler.handle_signal(surface_index, force_index, control_behavior, signal_and_count)
      end

    end
  end
end

function Handler.reset_decider_combinator_outputs()
  for _, surfacedata in pairs(storage.surfacedata) do
    for _, decider_combinator in pairs(surfacedata.force_to_decider_combinator) do
      decider_combinator.get_control_behavior().parameters = decider_combinator_parameters
    end
  end
end

script.on_event(defines.events.on_tick, function(event)
  if (event.tick + 2) % 60 == 0 then Handler.sync_module_qualities_with_arithmetic_combinators() end
  if (event.tick + 1) % 60 == 0 then Handler.flash_decider_combinator_outputs() end
  if (event.tick + 0) % 60 == 0 then Handler.reset_decider_combinator_outputs() end
end)

script.on_event(defines.events.on_player_rotated_entity, function(event)
  assert(event.entity)

  if event.entity.name == "awesome-sink-gui" then
    event.entity.surface.find_entity("awesome-sink", event.entity.position).direction = event.entity.direction
  end
end)

script.on_event(defines.events.on_player_flipped_entity, function(event)
  assert(event.entity)

  if event.entity.name == "awesome-sink-gui" then
    event.entity.surface.find_entity("awesome-sink", event.entity.position).direction = event.entity.direction
  end
end)
