require("shared")

script.on_init(function()
  storage.structs = {}
end)

local function on_created_entity(event)
  local entity = event.entity or event.destination

  if entity.name == mod_prefix .. "infinity-pipe" then
    entity.destroy()
    return
  end

  local struct = new_struct(storage.structs, {
    id = entity.unit_number,
    entity = entity,

    fuel_pipe = nil,
    oxidizer_pipe = nil,
  })

  struct.fuel_pipe = entity.surface.create_entity{
    name = mod_prefix .. "infinity-pipe",
    force = entity.force,
    position = {entity.position.x - 0.5, entity.position.y}
  }
  struct.fuel_pipe.destructible = false
  struct.fuel_pipe.set_infinity_pipe_filter({name = "thruster-fuel", percentage = 1})
  struct.fuel_pipe.fluidbox.add_linked_connection(0, entity, 1)

  struct.oxidizer_pipe = entity.surface.create_entity{
    name = mod_prefix .. "infinity-pipe",
    force = entity.force,
    position = {entity.position.x + 0.5, entity.position.y}
  }
  struct.oxidizer_pipe.destructible = false
  struct.oxidizer_pipe.set_infinity_pipe_filter({name = "thruster-oxidizer", percentage = 1})
  struct.oxidizer_pipe.fluidbox.add_linked_connection(0, entity, 3)
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, on_created_entity, {
    {filter = "name", name = mod_name},
    {filter = "name", name = mod_prefix .. "infinity-pipe"},
  })
end
