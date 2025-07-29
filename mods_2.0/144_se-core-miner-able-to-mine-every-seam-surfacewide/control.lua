local mod = {}

--- @return number
mod.get_core_seams_for_radius = function(radius)
  return 5 + math.floor(95 * radius / 10000)
end

--- @return string?
mod.get_core_fragment_name = function(zone)
  if not (zone.type == "planet" or zone.type == "moon") then return end -- Zone.is_solid(zone)
  if zone.fragment_name then return zone.fragment_name end
  return "se-core-fragment-" .. zone.primary_resource
end

mod.get_core_fragment_mining_time = function(fragment_name)
  return prototypes.entity[fragment_name].mineable_properties.mining_time
end

mod.get_core_fragments_per_second = function(fragment_name, zone_radius, mining_productivity, core_miners)
  return ((100 / mod.get_core_fragment_mining_time(fragment_name)) * ((zone_radius + 5000) / 5000) * mining_productivity * core_miners) / math.sqrt(core_miners)
end

script.on_event(defines.events.on_gui_opened, function(event)
  local entity = event.entity
  if entity and entity.name == "se-core-miner-drill" then
    local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = entity.surface.index})
    if not zone then return end -- how did you even place this outside a zone?

    local fragment_name = mod.get_core_fragment_name(zone)
    if not fragment_name then return end -- how did you even place this outside of a planet or moon?

    local mining_productivity = 1 + entity.force.mining_drill_productivity_bonus
    local core_miners = mod.get_core_seams_for_radius(zone.radius)
    local surface_output = mod.get_core_fragments_per_second(fragment_name, zone.radius, mining_productivity, core_miners)

    log(surface_output) -- core miners on every seam with diminishing returns
    if script.active_mods["se-core-miner-no-diminishing-returns"] then
      surface_output = mod.get_core_fragments_per_second(fragment_name, zone.radius, mining_productivity, 1) * core_miners
      log(surface_output) -- core miners on every seam without diminishing returns
    end
  end
end)
