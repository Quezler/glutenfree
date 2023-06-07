local concrete_roboport_tile = {
  type = 'roboport',
  name = 'concrete-roboport-tile',

  base = util.empty_sprite(),
  base_animation = util.empty_sprite(),
  base_patch = util.empty_sprite(),

  charge_approach_distance = data.raw['roboport']['roboport'].charge_approach_distance,
  charging_energy = data.raw['roboport']['roboport'].charging_energy,

  construction_radius = 0,

  door_animation_up = util.empty_sprite(),
  door_animation_down = util.empty_sprite(),

  energy_source = {type = 'void'},
  energy_usage = data.raw['roboport']['roboport'].energy_usage,

  logistics_radius = 0.5,
  logistics_connection_distance = 0.5,

  material_slots_count = 0,

  recharge_minimum = data.raw['roboport']['roboport'].recharge_minimum,
  recharging_animation = util.empty_sprite(),

  request_to_open_door_timeout = 0,
  robot_slots_count = 0,

  spawn_and_station_height = 0,

  collision_mask = {},
  flags = {'not-on-map'},

  collision_box = {{-0.5, -0.5}, {0.5, 0.5}}
}

-- debug mode
if true then
  concrete_roboport_tile.base = {
    filename = "__core__/graphics/icons/unknown.png",
    priority = "extra-high",
    width = 64,
    height = 64,
    scale = 0.5,
  }
end

data:extend({concrete_roboport_tile})

-- data.raw['roboport']['roboport'].logistics_connection_distance = data.raw['roboport']['roboport'].logistics_radius
-- data.raw['roboport']['roboport'].logistics_radius = data.raw['roboport']['roboport'].logistics_radius / 2
-- data.raw['roboport']['roboport'].connection_mode = "logistics_connection_distance"
-- data.raw['roboport']['roboport'].connection_mode = "logistics_radius"

-- Currently roboports connect when their `logistics_connection_distance` squares touch.

-- Unfortunately this means that when you want a roboport that doesn't connect to lets say anything more than a few tiles away you can't just set _that_ roboport to `logistics_connection_distance` lets say `5` and have a roboport with a `logistics_connection_distance` of `15` a mere 10 tiles away since they connect by squares and not by having the smallest of the two touch the other roboport with pseudocode amonst the lines of: `math.min(a.logistics_connection_distance, b.logistics_connection_distance)`


-- Other properties i've considered but didn't stuck to include:
-- - `max_connection_mode = "logistics_connection_distance" / max_connection_mode = "logistics_radius"`
-- - `connection_mode = "logistics_connection_distance" / connection_mode = "logistics_radius"`

require("prototypes.entity.concrete-roboport")
require("prototypes.item")
require("prototypes.recipe")
require("prototypes.technology")

data.raw['roboport']['concrete-roboport'].logistics_radius = 2
data.raw['roboport']['concrete-roboport'].logistics_connection_distance = 2
data.raw['roboport']['concrete-roboport'].construction_radius = 0
