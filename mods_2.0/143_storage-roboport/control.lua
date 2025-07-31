local defines_control_behavior_roboport_read_items_mode_none = defines.control_behavior.roboport.read_items_mode.none

require("namespace")
local mod = {}

script.on_init(function()
  storage.surface = game.planets[mod_name].create_surface()
  storage.surface.generate_with_lab_tiles = true

  storage.x_offset = 0
  storage.structs = {}
end)

mod.on_created_entity = function(event)
  local entity = event.entity or event.destination
  entity.backer_name = ""

  local cb = entity.get_or_create_control_behavior() --[[@as LuaRoboportControlBehavior]]
  cb.read_items_mode = defines_control_behavior_roboport_read_items_mode_none

  local combinator = storage.surface.create_entity{
    name = "constant-combinator",
    force = "neutral",
    position = {0.5 + storage.x_offset, 0.5},
  }
  assert(combinator)
  local combinator_section = combinator.get_logistic_sections().get_section(1)

  local red_out = combinator.get_wire_connector(defines.wire_connector_id.circuit_red, true)
  local green_out = combinator.get_wire_connector(defines.wire_connector_id.circuit_green, true)
  local red_in = entity.get_wire_connector(defines.wire_connector_id.circuit_red, true)
  local green_in = entity.get_wire_connector(defines.wire_connector_id.circuit_green, true)

  assert(red_out.connect_to(red_in, false, defines.wire_origin.player))
  assert(green_out.connect_to(green_in, false, defines.wire_origin.player))

  storage.structs[entity.unit_number] = {
    entity = entity,
    entity_cb = cb,

    combinator = combinator,
    combinator_section = combinator_section,
  }
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
  script.on_event(event, mod.on_created_entity, {
    {filter = "name", name = "storage-roboport"},
  })
end

local function get_filters(logistic_network)
  local filters = {}

  for i, item in ipairs(logistic_network.get_contents("storage")) do
    filters[i] = {
      value = {type = "item", name = item.name, quality = item.quality},
      min = item.count,
    }
  end

  return filters
end

script.on_nth_tick(60 * 2.5, function()
  local filters_for_network_id = {}
  for unit_number, struct in pairs(storage.structs) do
    if struct.entity.valid then
      struct.entity_cb.read_items_mode = defines_control_behavior_roboport_read_items_mode_none
      local logistic_network = struct.entity.logistic_network
      if logistic_network then
        if not filters_for_network_id[logistic_network.network_id] then
          filters_for_network_id[logistic_network.network_id] = get_filters(struct.entity.logistic_network)
        end
        struct.combinator_section.filters = filters_for_network_id[logistic_network.network_id]
      else
        struct.combinator_section.filters = {}
      end
    else
      struct.combinator.destroy()
      storage.structs[unit_number] = nil
    end
  end
end)
