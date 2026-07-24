local Beacon = {}

local get_entity_footprint_by_name = function(entity_name)
  local entity_prototype = prototypes.entity[entity_name]
  local collision_box = entity_prototype.collision_box

  local width = math.ceil(math.abs(collision_box.left_top.x) + collision_box.right_bottom.x)
  local height = math.ceil(math.abs(collision_box.left_top.y) + collision_box.right_bottom.y)
  assert(width >= 0)
  assert(height >= 0)
  return width, height
end

Beacon.get_machines_per_beacons = function(beacon_count, machine_name, beacon_name, beacon_quality)
  local beacon_range = prototypes.entity[beacon_name].get_supply_area_distance(beacon_quality)
  local beacon_width, beacon_height = get_entity_footprint_by_name(beacon_name)
  local machine_width, machine_height = get_entity_footprint_by_name(machine_name)

  return Beacon.beacon_can_reach_x_of(beacon_count, beacon_width, beacon_height, beacon_range, machine_width, machine_height)
end

-- this function should return how many buildings of a certain dimension are able to touch the beacon's range,
-- it should not care about input/output/inserters/belts, all it should care about is how many it can squeeze in.
Beacon.beacon_can_reach_x_of = function(beacon_c, beacon_w, beacon_h, beacon_r, machine_w, machine_h)
  local beacon_footprint = string.format("%sx%s", beacon_w, beacon_h)
  local machine_footprint = string.format("%sx%s", machine_w, machine_h)

  if beacon_c ~= 1 then
    return false, string.format("only 1 beacon per machine is supported. (was %d)", beacon_c)
  end

  if beacon_footprint ~= "3x3" then
    return false, string.format("only 3x3 beacons are supported. (was %s)", beacon_footprint)
  end

  if beacon_r ~= 3 then
    return false, string.format("only a beacon range of 3 is supported. (was %d)", beacon_r)
  end

  local map = {
    ["1x1"] = 72,
    ["2x2"] = 24,
    ["3x3"] = 12,
    ["4x4"] =  8,
    ["5x5"] =  8,
    ["6x6"] =  6,
    ["7x7"] =  6,

    ["2x3"] = 20,
    ["3x2"] = 20,
  }
  local in_map = map[machine_footprint]
  if in_map then
    return true, in_map
  end

  if machine_w ~= machine_h then
    return false, string.format("only square machines are supported. (was %s)", machine_footprint)
  end

  return true, 4 -- anything 8x8 or larger will always be 4
end

local tests = {
  {1, 3, 3, 3, 1, 1, 72}, -- 72 1x1 entities fit around 1 normal beacon
  {1, 3, 3, 3, 2, 2, 24}, -- 24 2x2 entities fit around 1 normal beacon
  {1, 3, 3, 3, 3, 3, 12}, -- 12 3x3 entities fit around 1 normal beacon
  {1, 3, 3, 3, 4, 4,  8}, --  8 4x4 entities fit around 1 normal beacon
  {1, 3, 3, 3, 5, 5,  8}, --  8 5x5 entities fit around 1 normal beacon
  {1, 3, 3, 3, 6, 6,  6}, --  6 6x6 entities fit around 1 normal beacon
  {1, 3, 3, 3, 7, 7,  6}, --  6 7x7 entities fit around 1 normal beacon
  {1, 3, 3, 3, 8, 8,  4}, --  4 8x8 entities fit around 1 normal beacon
  {1, 3, 3, 3, 9, 9,  4}, --  4 9x9 entities fit around 1 normal beacon

  {1, 3, 3, 3, 2, 3, 20}, -- 20 2x3 entities fit around 1 normal beacon (SE casting machine)
  {1, 3, 3, 3, 3, 2, 20}, -- 20 3x2 entities fit around 1 normal beacon (SE casting machine)
}

for _, test in ipairs(tests) do
  local success, x = Beacon.beacon_can_reach_x_of(test[1], test[2], test[3], test[4], test[5], test[6])
  local debug = serpent.line({test, success, x})
  assert(success, debug)
  assert(x == test[7], debug)
end

return Beacon
