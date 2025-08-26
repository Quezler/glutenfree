local Util = require("__space-exploration-scripts__.util")
local Meteor = require("__space-exploration-scripts__.meteor")

return function(mod)
  local Turret = {}

  Turret.fire_next_barrel = function(struct)
    struct.barrel = struct.barrel % 4 + 1
    struct.entity.surface.create_entity{
      name = Meteor.name_meteor_point_defence_beam,
      position = Util.vectors_add(struct.entity.position, Meteor.name_meteor_point_defence_beam_offsets[struct.barrel]),
      target = Util.vectors_add(struct.entity.position, {x = 0, y = -Meteor.meteor_swarm_altitude})
    }
  end

  return Turret
end
