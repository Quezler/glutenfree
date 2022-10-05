-- Whilst i could have saved the icon from the dropdown for later use,
-- deriving it from the zone information was more practical at the time.
--
-- If you are a Space Exploration representative and wish this removed, contact me.

local Zone = {}

function Zone.parent(zone)
  return remote.call("space-exploration", "get_zone_from_zone_index", {zone_index = zone.parent_index})
end

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

function Zone.get_icon(zone)
  return "virtual-signal/" .. Zone.get_signal_name(zone)
end

return Zone
