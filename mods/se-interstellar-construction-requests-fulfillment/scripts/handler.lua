local Util = require('__space-exploration-scripts__.util')
local Meteor = require('scripts.meteor')
local Handler = {}

Handler.entity_name = 'se-interstellar-construction-requests-fulfillment--turret'

function Handler.on_init(event)
  global.structs = {}

  global.deck = {} -- array, holds randomized unit numbers to pick from
  global.pile = {} -- array, holds all new and already drawn unit numbers

  -- log('items_to_place_this')
  -- for _, entity_prototype in pairs(game.entity_prototypes) do
  --   for _, item_to_place_this in pairs(entity_prototype.items_to_place_this or {}) do
  --     if item_to_place_this.count > 1 then
  --       log(entity_prototype.name .. serpent.block(item_to_place_this))
  --     end
  --   end
  -- end
  -- {curved-rail, se-space-curved-rail, concrete-wall-ruin, steel-wall-ruin, stone-wall-ruin}
end

function Handler.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination

  entity.active = false

  global.structs[entity.unit_number] = {
    unit_number = entity.unit_number,
    entity = entity,
    barrel = 0,
  }
  table.insert(global.pile, entity.unit_number)
end

function Handler.shuffle_array_in_place(t)
  for i = #t, 2, -1 do
    local j = math.random(i)
    t[i], t[j] = t[j], t[i]
  end
end

function Handler.draw_random_card()
  local already_shuffled = false

  while true do
    if #global.deck == 0 then
      if already_shuffled or #global.pile == 0 then return nil end

      Handler.shuffle_array_in_place(global.pile)
      global.deck = global.pile
      global.pile = {}

      already_shuffled = true
    end

    local struct = global.structs[table.remove(global.deck)]
    if struct then
      if not struct.entity.valid then
        global.structs[unit_number] = nil
      else
        table.insert(global.pile, struct.unit_number)

        if struct.entity.energy > Handler.get_max_energy() - 1 then
          return struct
        end

      end
    end
  end
end

function Handler.get_max_energy()
  if not Handler.max_energy then
    Handler.max_energy = game.entity_prototypes[Handler.entity_name].electric_energy_source_prototype.buffer_capacity
  end
  return Handler.max_energy
end

function Handler.tick(event)
  local struct = Handler.draw_random_card()

  if not struct then return end
  struct.entity.energy = 0

  struct.barrel = struct.barrel % 4 + 1
  struct.entity.surface.create_entity{
    name = Meteor.name_meteor_point_defence_beam,
    position = Util.vectors_add(struct.entity.position, Meteor.name_meteor_point_defence_beam_offsets[struct.barrel]),
    target = Util.vectors_add(struct.entity.position, {x = 0, y = -Meteor.meteor_swarm_altitude})
  }
end

function Handler.handle_construction_alert(alert)
  if alert.target.name ~= "entity-ghost" then return end -- can be "item-request-proxy" or "tile-ghost"
  -- log(alert.target.unit_number)

  -- game.print(serpent.block(alert.target.ghost_prototype.items_to_place_this))
  for _, item_to_place_this in ipairs(alert.target.ghost_prototype.items_to_place_this) do
    if item_to_place_this.count == 1 then
      log(item_to_place_this.name)

      for unit_number, struct in pairs(global.structs) do
        if not struct.entity.valid then
          global.structs[unit_number] = nil
        else
          if alert.target.force == struct.entity.force then
            -- we're gonna check for orange coverage for now, instead of green venn diagrams and filtering out personal roboports
            local network = struct.entity.surface.find_logistic_network_by_position(struct.entity.position, struct.entity.force)
            if network then
              local proxy = struct.entity.surface.find_entity('item-request-proxy', struct.entity.position)
              if not proxy then
                proxy = struct.entity.surface.create_entity{
                  name = 'item-request-proxy',
                  force = struct.entity.force,
                  target = struct.entity,
                  position = {0,0},
                  modules = {[item_to_place_this.name] = item_to_place_this.count}
                }
  
                rendering.draw_text{
                  color = {1,1,1},
                  alignment = 'center',
                  text = proxy.surface.name,
                  surface = proxy.surface,
                  target = proxy,
                  target_offset = {0, 0.5},
                  use_rich_text = true,
                }
              end
            end
          end
        end
      end
    end
  end

end

return Handler
