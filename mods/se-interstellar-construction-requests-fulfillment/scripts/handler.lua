local Util = require('__space-exploration-scripts__.util')
local Zone = require('__space-exploration-scripts__.zone')
local Meteor = require('scripts.meteor')
local Handler = {}

Handler.entity_name = 'se-interstellar-construction-requests-fulfillment--turret'

function Handler.on_init(event)
  global.structs = {}

  global.deck = {} -- array, holds randomized unit numbers to pick from
  global.pile = {} -- array, holds all new and already drawn unit numbers

  global.handled_alerts = {}

  global.deathrattles = {}

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
        global.structs[struct.unit_number] = nil
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

  Handler.shoot(struct)
end

function Handler.shoot(struct)
  struct.entity.energy = 0

  struct.barrel = struct.barrel % 4 + 1
  struct.entity.surface.create_entity{
    name = Meteor.name_meteor_point_defence_beam,
    position = Util.vectors_add(struct.entity.position, Meteor.name_meteor_point_defence_beam_offsets[struct.barrel]),
    target = Util.vectors_add(struct.entity.position, {x = 0, y = -Meteor.meteor_swarm_altitude})
  }
end

function Handler.handle_construction_alert(alert)
  if alert.target.valid then return end -- ghost might have been removed or revived already
  if alert.target.name ~= "entity-ghost" then return end -- can be "item-request-proxy" or "tile-ghost"

  local handled_alert = global.handled_alerts[alert.target.unit_number]
  if handled_alert and handled_alert.entity.valid and handled_alert.proxy.valid then return end

  local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = alert.target.surface.index})
  if not zone then return end

  -- game.print(serpent.block(alert.target.ghost_prototype.items_to_place_this))
  for _, item_to_place_this in ipairs(alert.target.ghost_prototype.items_to_place_this) do
    if item_to_place_this.count == 1 then
      log(item_to_place_this.name)

      local anti_infinite_loop = 0
      while true do
        local struct = Handler.draw_random_card()
        if not struct then return end

        if anti_infinite_loop > 100 then return end
        anti_infinite_loop = anti_infinite_loop + 1

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
                position = struct.entity.position,
                modules = {[item_to_place_this.name] = item_to_place_this.count}
              }

              rendering.draw_text{
                color = {1,1,1},
                alignment = 'center',
                text = Zone._get_rich_text_name(zone),
                surface = proxy.surface,
                target = proxy,
                target_offset = {0, 0.5},
                use_rich_text = true,
              }

              global.handled_alerts[alert.target.unit_number] = {
                struct_unit_number = struct.unit_number,
                unit_number = alert.target.unit_number,
                entity = alert.target,
                proxy = proxy,
                itemstack = item_to_place_this,
              }

              -- struct.handled_alert_id = alert.target.unit_number

              global.deathrattles[script.register_on_entity_destroyed(proxy)] = alert.target.unit_number

              return -- this alert has now been dealt with
            end
          end
        end

      end
    end
  end
end

function Handler.on_entity_destroyed(event)
  local unit_number = global.deathrattles[event.registration_number]
  if unit_number then global.deathrattles[event.registration_number] = nil

    local handled_alert = global.handled_alerts[unit_number]
    if not handled_alert then return end

    local struct = global.structs[handled_alert.struct_unit_number]
    if not struct then return end
    if not struct.entity.valid then return end

    local nearby_construction_robots = struct.entity.surface.find_entities_filtered{
      type = 'construction-robot',
      position = struct.entity.position,
      force = struct.entity.force,
    }

    for _, nearby_construction_robot in ipairs(nearby_construction_robots) do
      local cargo = nearby_construction_robot.get_inventory(defines.inventory.robot_cargo)
      if cargo.remove(handled_alert.itemstack) then
        Handler.shoot(struct)
        handled_alert.entity.revive()
        global.handled_alerts[handled_alert.unit_number] = nil
        return
      end
    end
  end
end

return Handler
