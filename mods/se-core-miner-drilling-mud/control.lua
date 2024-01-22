local function ends_with(str, ending)
  return ending == "" or str:sub(-#ending) == ending
end

local function on_efficiency_updated(event)
  local zone = remote.call("space-exploration", "get_zone_from_zone_index", {zone_index = event.zone_index})

  for _, resource_set in pairs(zone.core_seam_resources) do
    local resource = resource_set.resource

    if ends_with(resource.name, '-sealed') == false then
      local drilling_mud = resource.surface.find_entity(resource.name .. '-drilling-mud', resource.position)
      if drilling_mud == nil then
        drilling_mud = resource.surface.create_entity{
          name = resource.name .. '-drilling-mud',
          position = resource.position,
        }
      end

      drilling_mud.amount = resource.amount * 5 -- drill switches between the normal & this one (i think?)
    end
  end
end

local function register_events(event)
  script.on_event(remote.call("se-core-miner-efficiency-updated-event", "on_efficiency_updated"), on_efficiency_updated)
end

script.on_init(register_events)
script.on_load(register_events)
