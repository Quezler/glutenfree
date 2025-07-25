-- step 1
local old_mod_prefix = mod_prefix
mod_prefix = "se-"
Event = {addListener = function() end}

-- step 2
local Zone = require("__space-exploration__.scripts.zone")

-- step 3
Event = nil
mod_prefix = old_mod_prefix

-- step 4

--- @since 2.0.0
function Zone.parent(zone)
  return remote.call("space-exploration", "get_zone_from_zone_index", {zone_index = zone.parent_index})
end

--- @since 2.0.0
function Zone.get_signal_name(zone)
  if zone.type == "orbit" and Zone.parent(zone).type == "star" then
    return "se-star"
  elseif zone.type == "orbit" and Zone.parent(zone).type == "planet" then
    return "se-planet-orbit"
  elseif zone.type == "orbit" and Zone.parent(zone).type == "moon" then
    return "se-moon-orbit"
  else
    return "se-" .. zone.type
  end
end

--- @since 2.0.0
function Zone._get_rich_text_name(zone)
  -- use universe exporer icon by default
  local rich_text = "[img=" .. Zone.get_icon(zone) .. "]"

  -- assume that for these 3 types you care about the primary resource
  if zone.type == "planet" or zone.type == "moon" or zone.type == "asteroid-belt" then
    rich_text = "[img=entity/" .. zone.primary_resource .. "]"
  end

  -- because these make sense to me personally
  if zone.name == "Nauvis"       then rich_text = "[item=landfill]"  end
  if zone.name == "Nauvis Orbit" then rich_text = "[item=satellite]" end

  return rich_text .. " " .. zone.name
end

-- function Zone.from_surface_index(surface_index)
--   return remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = surface_index})
-- end

--- @since 2.0.0
return Zone
