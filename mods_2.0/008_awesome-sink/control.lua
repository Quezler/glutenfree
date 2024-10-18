local decider_combinator_parameters = require("scripts.decider_combinator_parameters")
local arithmetic_combinator_parameters = require("scripts.arithmetic_combinator_parameters")

local mod_surface_name = "awesome-sink"

local Handler = {}

script.on_init(function ()
  storage.version = 0
  storage.surfacedata = {}

  local surface = game.surfaces[mod_surface_name]
  assert(surface == nil, "contact the mod author for help with world that previously already had this mod installed.")

  surface = game.create_surface(mod_surface_name)
  surface.generate_with_lab_tiles = true

  for surface_index, surface in pairs(game.surfaces) do
    Handler.on_surface_created({surface_index = surface_index})
  end
end)

function Handler.on_surface_created(event)
  local surface = assert(game.get_surface(event.surface_index))
  local surfacedata = {}

  local mod_surface = game.surfaces[mod_surface_name]

  local y_offset = 7 * (surface.index - 1)

  surfacedata["awesome-shop"] = mod_surface.create_entity{
    name = "awesome-shop",
    force = "player",
    position = {-1.5, 0.5 + y_offset},
  }
  surfacedata["awesome-shop"].link_id = surface.index

  surfacedata["display-panel"] = mod_surface.create_entity{
    name = "display-panel",
    force = "player",
    position = {-1.5, 1.5 + y_offset},
  }
  -- local display_panel_control = surfacedata["display-panel"].get_control_behavior()
  -- display_panel_control.set_message()

  surfacedata["awesome-decider-combinator"] = mod_surface.create_entity{
    name = "awesome-decider-combinator",
    force = "player",
    position = {-0.5, 1.0 + y_offset},
    direction = defines.direction.north,
  }

  local green_out = surfacedata["awesome-decider-combinator"].get_wire_connector(defines.wire_connector_id.combinator_output_green)
  local green_in  = surfacedata["awesome-decider-combinator"].get_wire_connector(defines.wire_connector_id.combinator_input_green)
  green_out.connect_to(green_in, false)

  surfacedata["awesome-decider-combinator"].get_control_behavior().parameters = decider_combinator_parameters

  storage.surfacedata[surface.index] = surfacedata
end

script.on_event(defines.events.on_surface_created, Handler.on_surface_created)
script.on_event(defines.events.on_surface_deleted, Handler.on_surface_deleted) -- todo

function Handler.register_awesome_sink(entity)
end

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  assert(entity.force.name == "player", "due to hidden surface entity positioning this mod currently supports 1 force.")

  if entity.name == "awesome-sink" then
    Handler.register_awesome_sink(entity)
  elseif entity.name == "awesome-shop" then
    entity.link_id = entity.surface.index
  end
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, on_created_entity, {
    {filter = 'name', name = 'awesome-sink'},
    {filter = 'name', name = 'awesome-shop'},
  })
end
