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
    bounding_box = {{-0.25, -0.25}, {0.25, 0.25}},
    collision_mask = {layers={ground_tile=true, is_lower_object=true}},
    start = util.moveposition({storage.side_a.position.x, storage.side_a.position.y}, storage.side_a.direction, 2),
    goal = util.moveposition({storage.side_b.position.x, storage.side_b.position.y}, storage.side_b.direction, 2),
    force = "neutral",
    pathfind_flags = {low_priority = true, no_break = true, prefer_straight_paths = true},
    -- path_resolution_modifier = 2,
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

script.on_event(defines.events.on_script_path_request_finished, function(event)
  assert(event.try_again_later == false)
  game.print(serpent.block(event))

  local surface = game.surfaces["fulgora"]
  for _, waypoint in ipairs(event.path or {}) do
    surface.create_entity{
      name = "undersea-cable",
      force = "neutral",
      position = waypoint.position,
    }
  end
end)
