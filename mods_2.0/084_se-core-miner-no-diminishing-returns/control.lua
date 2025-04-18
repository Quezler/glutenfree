local function ends_with(str, ending)
  return str:sub(-#ending) == ending
end

function on_efficiency_updated(event)
  local zone = remote.call("space-exploration", "get_zone_from_zone_index", {zone_index = event.zone_index})
  if zone.core_seam_resources == nil then return end -- 50x50 worlds?

  for _, resource_set in pairs(zone.core_seam_resources) do
    local resource = resource_set.resource
    resource.amount = event.new_amount_for_one

    for _, render_object in ipairs(rendering.get_all_objects("space-exploration")) do
      if render_object.type == "text" and render_object.target.entity == resource then
        render_object.text = "100% effective"
      end
    end
  end
end

local function register_events(event)
  script.on_event(remote.call("se-core-miner-efficiency-updated-event", "on_efficiency_updated"), on_efficiency_updated)
end

script.on_init(register_events)
script.on_load(register_events)
