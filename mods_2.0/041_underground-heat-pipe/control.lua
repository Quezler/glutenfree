local Handler = {}

local function get_tile_distance_inclusive(a, b)
  return math.abs(a.position.x - b.position.x) + math.abs(a.position.y - b.position.y) + 1
end

local function get_position_between(a, b)
  return {x = (a.position.x + b.position.x) / 2, y = (a.position.y + b.position.y) / 2}
end

local direction_to_axis = {
  [defines.direction.north] = "vertical",
  [defines.direction.south] = "vertical",
  [defines.direction.east] = "horizontal",
  [defines.direction.west] = "horizontal",
}

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  local other = entity.neighbours[1][1]
  if other == nil then return end

  local zero_padded_length_string = string.format("%02d", get_tile_distance_inclusive(entity, other))
  entity.surface.create_entity{
    name = string.format("underground-heat-pipe-long-%s-%s", direction_to_axis[entity.direction], zero_padded_length_string),
    force = entity.force,
    position = get_position_between(entity, other)
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
  script.on_event(event, Handler.on_created_entity, {
    {filter = "name", name = "underground-heat-pipe"},
  })
end
