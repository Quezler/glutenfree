local increases_harvester_platform_size = {
  ["warptorio-harvester-west-1"] = true,
  ["warptorio-harvester-west-2"] = true,
  ["warptorio-harvester-west-3"] = true,
  ["warptorio-harvester-west-4"] = true,
  ["warptorio-harvester-west-5"] = true,

  ["warptorio-harvester-east-1"] = true,
  ["warptorio-harvester-east-2"] = true,
  ["warptorio-harvester-east-3"] = true,
  ["warptorio-harvester-east-4"] = true,
  ["warptorio-harvester-east-5"] = true,
}

local west_center = {-86.5, -0.5}
local east_center = { 85.5, -0.5}

local function thats_right_it_goes_in_the(surface, tiles)
  for _, tile in ipairs(tiles) do
    surface.create_entity{
      name = "square-hole",
      position = tile,
      amount = 1,
    }
  end
end

local function where_does_the_circle_go()
  local surface = game.surfaces["warptorio_harvester"]
  thats_right_it_goes_in_the(surface, surface.get_connected_tiles(west_center, {"warptorio-red-concrete"}))
  thats_right_it_goes_in_the(surface, surface.get_connected_tiles(east_center, {"warptorio-red-concrete"}))
end

script.on_init(where_does_the_circle_go)

script.on_event(defines.events.on_research_finished, function(event)
  -- game.print(event.research.name)
  if increases_harvester_platform_size[event.research.name] then
    where_does_the_circle_go()
  end
end)

-- harvesters can be deployed while the mod is installed or research is completed (why wouldn't they)
script.on_load(function(event)
  local eventdefs = remote.call("warptorio", "get_events")
  script.on_event(eventdefs["on_post_warp"], where_does_the_circle_go)
end)
