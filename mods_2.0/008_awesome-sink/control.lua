local decider_combinator_parameters = require("scripts.decider_combinator_parameters")
local arithmetic_combinator_parameters = require("scripts.arithmetic_combinator_parameters")

local mod_surface_name = "awesome-sink"

local Handler = {}

script.on_init(function ()
  storage.version = 0
  storage.surfacedata = {}

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
    force_to_constant_combinator = {},
  }
end

function Handler.on_surface_deleted(event)
  error("surface deletion not handled yet.")
end

script.on_event(defines.events.on_surface_created, Handler.on_surface_created)
script.on_event(defines.events.on_surface_deleted, Handler.on_surface_deleted)

function Handler.get_or_create_decider_combinator(surface_index, force_index)
  local decider_combinator = storage.surfacedata[surface_index].force_to_constant_combinator[force_index]
  if decider_combinator then return decider_combinator end

  local mod_surface = game.surfaces[mod_surface_name]

  local y_offset = 7 * (surface_index - 1)
  local position = {0.5 - force_index, 1.0 + y_offset}
  assert(mod_surface.find_entity("awesome-decider-combinator", position) == nil)

  decider_combinator = mod_surface.create_entity{
    name = "awesome-decider-combinator",
    force = force_index,
    position = position,
    direction = defines.direction.north,
  }
  assert(decider_combinator)

  local green_out = decider_combinator.get_wire_connector(defines.wire_connector_id.combinator_output_green, false)
  local green_in  = decider_combinator.get_wire_connector(defines.wire_connector_id.combinator_input_green, false)
  green_out.connect_to(green_in, false, defines.wire_origin.player)

  --- @diagnostic disable-next-line: inject-field
  decider_combinator.get_control_behavior().parameters = decider_combinator_parameters
  decider_combinator.combinator_description = string.format("surface %d (%s)\nforce %d (%s)",
    surface_index, game.surfaces[surface_index].name,
    force_index, game.forces[force_index].name
  )

  storage.surfacedata[surface_index].force_to_constant_combinator[force_index] = decider_combinator
  return decider_combinator
end

function Handler.register_awesome_sink(entity)
  local decider_combinator = Handler.get_or_create_decider_combinator(entity.surface.index, entity.force.index)
end

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  if entity.name == "awesome-sink" then
    Handler.register_awesome_sink(entity)
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
  })
end
