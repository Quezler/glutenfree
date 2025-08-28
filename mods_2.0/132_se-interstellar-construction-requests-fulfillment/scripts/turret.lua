local Util = require("__space-exploration-scripts__.util")
local Meteor = require("__space-exploration-scripts__.meteor")

return function(mod)
  local Turret = {}

  Turret.fire_next_barrel = function(turret)
    local entity = turret.entity
    turret.barrel = turret.barrel % 4 + 1
    entity.surface.create_entity{
      name = Meteor.name_meteor_point_defence_beam,
      position = Util.vectors_add(entity.position, Meteor.name_meteor_point_defence_beam_offsets[turret.barrel]),
      target = Util.vectors_add(entity.position, {x = 0, y = -Meteor.meteor_swarm_altitude})
    }
  end

  Turret.tick_turret = function(turret)
    if not turret.entity.valid then return end

    local logistic_network = turret.entity.logistic_network
    if logistic_network then
      for item_name, ghosts in pairs(storage.item_to_entities_map) do
        local available = logistic_network.get_item_count({name = item_name, quality = "normal"})
        -- log(available)
        for unit_number, _ in pairs(ghosts) do
          local ghost = storage.all_ghosts[unit_number]
          if ghost.entity.valid and (not ghost.lock) then
            local wants = ghost.item_name_map[item_name]
            if available >= wants then
              local removed = logistic_network.remove_item({name = item_name, count = wants, quality = "normal"})
              assert(removed == wants)
              ghost.lock = true -- prevent other turrets/ticks from working on this ghost
              Turret.fire_next_barrel(turret)
              local response = remote.call("space-platform-entity-build-animation-lib", "legacy", ghost.entity)
              mod.add_task_at_tick(response.all_scaffolding_up_at, {name = "revive", unit_number = ghost.unit_number})

              available = available - removed -- todo: grab a fresh item count in case of mod compatibility issues
            end
          end
        end
      end
    end
  end

  Turret.tick_turrets = function()
    for _, turret in pairs(storage.turrets) do
      Turret.tick_turret(turret)
    end
  end

  Turret.revive_ghost = function(ghost)
  end

  return Turret
end
