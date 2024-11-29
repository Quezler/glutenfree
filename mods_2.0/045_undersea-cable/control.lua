require("util")

local Handler = {}

script.on_init(function()
  storage.side_a = nil
  storage.side_b = nil
end)

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  if storage.side_a == nil then
    storage.side_a = entity
    return
  end

  storage.side_b = entity

  local uint = entity.surface.request_path{
    bounding_box = {{-1.5, -1.5}, {1.5, 1.5}},
    collision_mask = {layers={ground_tile=true, is_lower_object=true}},
    start = util.moveposition({storage.side_a.position.x, storage.side_a.position.y}, storage.side_a.direction, 3),
    goal = util.moveposition({storage.side_b.position.x, storage.side_b.position.y}, storage.side_b.direction, 3),
    force = "neutral",
    pathfind_flags = {low_priority = true, no_break = true},
  }

  game.print(uint .. " " .. event.tick)

  storage.side_a = nil
  storage.side_b = nil
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
    -- {filter = "name", name = "undersea-cable-landing-point"},
    {filter = "name", name = "offshore-pump"},
  })
end

local function positions_are_adjacent(position_a, position_b)
  return position_a.x == position_b.x or position_a.y == position_b.y
end

local function position_to_connect(position_a, position_b)
  local result = {x = position_a.x, y = position_a.y}

  -- Adjust x or y to make the result adjacent to position_b
  if position_a.x ~= position_b.x then
    result.x = position_a.x + (position_b.x > position_a.x and 1 or -1)
  elseif position_a.y ~= position_b.y then
    result.y = position_a.y + (position_b.y > position_a.y and 1 or -1)
  end

  return result
end

script.on_event(defines.events.on_script_path_request_finished, function(event)
  assert(event.try_again_later == false)
  game.print(serpent.block(event))

  local surface = game.surfaces["fulgora"]
  local last_waypoint = nil
  for _, waypoint in ipairs(event.path or {}) do
    surface.create_entity{
      name = "undersea-cable",
      force = "neutral",
      position = waypoint.position,
    }

    if last_waypoint and positions_are_adjacent(waypoint.position, last_waypoint.position) == false then
      surface.create_entity{
        name = "undersea-cable",
        force = "neutral",
        position = position_to_connect(waypoint.position, last_waypoint.position),
      }
    end

    last_waypoint = waypoint
  end
end)
