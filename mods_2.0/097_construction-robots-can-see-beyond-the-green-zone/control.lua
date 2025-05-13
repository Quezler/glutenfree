require("shared")

local mod = {}

mod.on_created_entity_filters = {
  {filter = "name", name = mod_prefix .. "roboport"},
}

function mod.on_created_entity(event)
  local entity = event.entity or event.destination
  entity.energy = 0
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  -- defines.events.on_entity_cloned,
}) do
  script.on_event(event, mod.on_created_entity, mod.on_created_entity_filters)
end
