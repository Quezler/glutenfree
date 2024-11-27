local Handler = {}

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  game.print(string.format("%s got placed with %s quality.", entity.name, entity.quality.name))
end

local filters = {}

for _, quality in pairs(prototypes.quality) do
  if quality.name == "normal" then
    table.insert(filters, {filter = "name", name = "holmium-chemical-plant"})
  else
    table.insert(filters, {filter = "name", name = quality.name .. "-holmium-chemical-plant"})
  end
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
