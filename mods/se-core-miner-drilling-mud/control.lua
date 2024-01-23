local function ends_with(str, ending)
  return ending == "" or str:sub(-#ending) == ending
end

local function on_efficiency_updated(event)
  local zone = remote.call("space-exploration", "get_zone_from_zone_index", {zone_index = event.zone_index})

  for _, resource_set in pairs(zone.core_seam_resources or {}) do
    local resource = resource_set.resource

    if ends_with(resource.name, '-sealed') == false then
      local drilling_mud_position = {resource.position.x, resource.position.y + 1}

      local drilling_mud = resource.surface.find_entity(resource.name .. '-drilling-mud', drilling_mud_position)
      if drilling_mud == nil then
        drilling_mud = resource.surface.create_entity{
          name = resource.name .. '-drilling-mud',
          position = drilling_mud_position,
        }
      end

      if game.active_mods['se-core-miner-no-diminishing-returns'] then
        drilling_mud.amount = event.new_amount_for_one * 2.5
      else
        drilling_mud.amount = event.new_amount * 2.5
      end
    end
  end
end

local function register_events(event)
  script.on_event(remote.call("se-core-miner-efficiency-updated-event", "on_efficiency_updated"), on_efficiency_updated)
end

script.on_init(register_events)
script.on_load(register_events)
