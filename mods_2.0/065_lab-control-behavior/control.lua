require("shared")
local mod = {}

script.on_init(function()
  storage.deathrattles = {}
  storage.structs = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({type = "lab"})) do
      mod.on_created_entity({entity = entity})
    end
  end
end)

function mod.on_created_entity(event)
  local entity = event.entity or event.destination

  local struct = new_struct(storage.structs, {
    id = entity.unit_number,
    entity = entity,
  })

  game.print("new lab registered: " .. tostring(entity))

  entity.surface.create_entity{
    name = mod_prefix .. entity.name .. "-control-behavior",
    force = entity.force,
    position = {entity.position.x, entity.position.y + 1},
  }
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
    {filter = "type", type = "lab"},
  })
end
