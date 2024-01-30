script.on_init(function(event)
  global.known_zones = {}
  for _, force in pairs(game.forces) do
    local known_zones = remote.call("space-exploration", "get_known_zones", {force_name = force.name})
    global.known_zones[force.name] = known_zones
  end
end)

local function get_threat(zone)
  if zone.controls and zone.controls["enemy-base"] and zone.controls["enemy-base"].size then
    local threat = math.max(0, math.min(1, zone.controls["enemy-base"].size / 3)) -- 0-1
    return threat
  end
  return 0
end

local research_can_trigger_zone_unlock = {
  ['se-zone-discovery-random'] = true,
  ['se-zone-discovery-targeted'] = true,
  ['se-zone-discovery-deep'] = true,
}
script.on_event(defines.events.on_research_finished, function(event)
  -- game.print(event.research.name)
  if research_can_trigger_zone_unlock[event.research.name] then
    
    local force = event.research.force
    local old_known_zones = global.known_zones[force.name]
    local new_known_zones = remote.call("space-exploration", "get_known_zones", {force_name = force.name})

    -- this should prevent newly created forces from being spammed with everything already unlocked i suppose?
    if old_known_zones == nil then
      global.known_zones[force.name] = new_known_zones
      return
    end

    local to_print = nil

    for zone_index, _ in pairs(new_known_zones) do
      if old_known_zones[zone_index] == nil then
        local zone = remote.call("space-exploration", "get_zone_from_zone_index", {zone_index = tonumber(zone_index)})

        if to_print then goto skip end
        to_print = {"", string.format("[img=entity/%s] ", zone.primary_resource), {"entity-name." .. zone.primary_resource}, " is the primary resource, and the threat level is ", string.format('%d%%', get_threat(zone) * 100), "."}
      end
    end

    force.print(to_print)

    ::skip::
    global.known_zones[force.name] = new_known_zones
  end
end)
