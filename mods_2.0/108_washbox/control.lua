require("shared")

local mod = {}

mod.on_created_entity = function(event)
  local entity = event.entity or event.destination

  -- only this mod may place the hidden entities
  if entity.name ~= "washbox" then
    return entity.destroy()
  end

  local valve_in = entity.surface.create_entity{
    name = mod_prefix .. "valve-in",
    force = entity.force,
    position = entity.position,
    create_build_effect_smoke = false,
  }
  valve_in.teleport(-1, 0)

  local valve_out = entity.surface.create_entity{
    name = mod_prefix .. "valve-out",
    force = entity.force,
    position = entity.position,
    create_build_effect_smoke = false,
  }

  entity.fluidbox.add_linked_connection(1, valve_in, 1)
  entity.fluidbox.add_linked_connection(0, valve_out, 0)
  valve_in.fluidbox.add_linked_connection(0, valve_out, 1)
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
    {filter = "name", name = "washbox"},
    {filter = "name", name = mod_prefix .. "valve-in"},
    {filter = "name", name = mod_prefix .. "valve-out"},
  })
end
