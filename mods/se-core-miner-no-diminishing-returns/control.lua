local function ends_with(str, ending)
  return str:sub(-#ending) == ending
end

function on_efficiency_updated(event)
  local zone = remote.call("space-exploration", "get_zone_from_zone_index", {zone_index = event.zone_index})
  if zone.core_seam_resources == nil then return end -- 50x50 worlds?

  for _, resource_set in pairs(zone.core_seam_resources) do
    local resource = resource_set.resource
    resource.amount = event.new_amount_for_one

    local entities = resource.surface.find_entities_filtered{
      position = resource.position,
      name = 'flying-text',
    }

    for _, entity in ipairs(entities) do
      if ends_with(entity.text, ' effective') then
        entity.destroy()
      end
    end
  end
end

local function register_events(event)
  script.on_event(remote.call("se-core-miner-efficiency-updated-event", "on_efficiency_updated"), on_efficiency_updated)
end

script.on_init(register_events)
script.on_load(register_events)
