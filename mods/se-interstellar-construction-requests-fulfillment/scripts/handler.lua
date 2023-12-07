local Util = require('__space-exploration-scripts__.util')
local Meteor = require('scripts.meteor')
local Handler = {}

Handler.entity_name = 'se-interstellar-construction-requests-fulfillment--turret'

function Handler.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination

  entity.active = false

  global.structs[entity.unit_number] = {
    entity = entity,
    barrel = 0,
  }
end

function Handler.get_max_energy()
  if not Handler.max_energy then
    Handler.max_energy = game.entity_prototypes[Handler.entity_name].electric_energy_source_prototype.buffer_capacity
  end
  return Handler.max_energy
end

function Handler.tick(event)
  for unit_number, struct in pairs(global.structs) do
    if not struct.entity.valid then
      global.structs[unit_number] = nil
    else
      if struct.entity.energy > Handler.get_max_energy() - 1 then
        struct.entity.energy = 0

        struct.barrel = struct.barrel % 4 + 1
        struct.entity.surface.create_entity{
          name = Meteor.name_meteor_point_defence_beam,
          position = Util.vectors_add(struct.entity.position, Meteor.name_meteor_point_defence_beam_offsets[struct.barrel]),
          target = Util.vectors_add(struct.entity.position, {x = 0, y = -Meteor.meteor_swarm_altitude})
        }
      end
    end
  end
end

function Handler.handle_construction_alert(alert)
  if alert.target.name ~= "entity-ghost" then return end -- can be "item-request-proxy"
  log(alert.target.unit_number)

  -- game.print(serpent.block(alert.target.ghost_prototype.items_to_place_this))
  for _, item_to_place_this in ipairs(alert.target.ghost_prototype.items_to_place_this) do
    if item_to_place_this.count == 1 then
      game.print(item_to_place_this.name)

      for unit_number, struct in pairs(global.structs) do
        if not struct.entity.valid then
          global.structs[unit_number] = nil
        else
          if alert.target.force == struct.entity.force then
            -- we're gonna check for orange coverage for now, instead of green venn diagrams and filtering out personal roboports
            local network = struct.entity.surface.find_logistic_network_by_position(struct.entity.position, struct.entity.force)
            if network then
              struct.entity.surface.create_entity{
                name = 'item-request-proxy',
                force = struct.entity.force,
                target = struct.entity,
                position = {0,0},
                modules = {[item_to_place_this.name] = item_to_place_this.count}
              }
            end
          end
        end
      end
    end
  end

end

return Handler
