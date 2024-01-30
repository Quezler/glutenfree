script.on_init(function(event)
  global.known_zones = {}
  for _, force in pairs(game.forces) do
    local known_zones = remote.call("space-exploration", "get_known_zones", {force_name = force.name})
    global.known_zones[force.name] = known_zones
  end
end)

local function get_threat(zone)
  if zone.is_homeworld and zone.surface_index then
    local surface = game.get_surface(zone.surface_index)
    local mapgen = surface.map_gen_settings
    if mapgen.autoplace_controls["enemy-base"] and mapgen.autoplace_controls["enemy-base"].size then
      return math.max(0, math.min(1, mapgen.autoplace_controls["enemy-base"].size / 3)) -- 0-1
    end
  end
  if zone.controls and zone.controls["enemy-base"] and zone.controls["enemy-base"].size then
    local threat = math.max(0, math.min(1, zone.controls["enemy-base"].size / 3)) -- 0-1
    -- if Zone.is_biter_meteors_hazard(zone) then
    --   return math.max(threat, 0.01)
    -- end
    return threat
  end
end

local research_can_trigger_zone_unlock = {
  ['se-zone-discovery-random'] = true,
  ['se-zone-discovery-targeted'] = true,
  ['se-zone-discovery-deep'] = true,
}
script.on_event(defines.events.on_research_finished, function(event)
  game.print(event.research.name)
  if research_can_trigger_zone_unlock[event.research.name] then
    
    local force = event.research.force
    local old_known_zones = global.known_zones[force.name]
    local new_known_zones = remote.call("space-exploration", "get_known_zones", {force_name = force.name})

    -- this should prevent newly created forces from being spammed with everything already unlocked i suppose?
    if old_known_zones == nil then
      global.known_zones[force.name] = new_known_zones
      return
    end

    local description = {}

    for zone_index, _ in pairs(new_known_zones) do
      if old_known_zones[zone_index] == nil then
        local zone = remote.call("space-exploration", "get_zone_from_zone_index", {zone_index = tonumber(zone_index)})
        game.print(zone.name)

        -- local surface = game.get_surface(zone.surface_index)

        table.insert(description, string.format('radius: %d', zone.radius and (string.format("%.0f", zone.radius)) or "-"))
        table.insert(description, 'resource: ' .. ((zone.primary_resource and zone.type ~= "orbit") and "[img=entity/".. zone.primary_resource.."]" or "-"))
        table.insert(description, string.format('threat: %d%%', get_threat(zone) * 100))
        -- table.insert(description, string.format('img=item/solar-panel] %d', surface.solar_power_multiplier))
        -- zone.description = description
        -- game.print(string.format('%s, %d', zone.primary_resource, zone.radius))
        game.print(table.concat(description, ' '))
      end
    end

    global.known_zones[force.name] = new_known_zones
  end
end)
