local Handler = {}

local function get_tile_distance_inclusive(a, b)
  return math.abs(a.position.x - b.position.x) + math.abs(a.position.y - b.position.y) + 1
end

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  local other = entity.neighbours[1][1]
  if other == nil then return end

  game.print(get_tile_distance_inclusive(entity, other))
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = "name", name = "underground-heat-pipe"},
  })
end
