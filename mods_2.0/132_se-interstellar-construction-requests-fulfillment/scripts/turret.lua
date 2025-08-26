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

  Turret.on_nth_tick = function()
    for _, turret in pairs(storage.turrets) do
      local logistic_network = turret.entity.logistic_network
      if logistic_network then
        for item_name, ghosts in pairs(storage.item_to_entities_map) do
          local available = logistic_network.get_item_count({name = item_name, quality = "normal"})
          log(available)
        end
      end
    end
  end

  return Turret
end
