local Util = require('__space-exploration-scripts__.util')
local Zone = require('__space-exploration-scripts__.zone')
local Meteor = require('__space-exploration-scripts__.meteor')
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
    proxy = nil, -- entity occupied if present and valid
    updated_at = game.tick,
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

        if struct.entity.energy >= Handler.get_energy_per_shot() then
          return struct
        end

      end
    end
  end
end

function Handler.get_energy_per_shot()
  if not Handler.energy_per_shot then
    Handler.energy_per_shot = game.entity_prototypes[Handler.entity_name].attack_parameters.ammo_type.energy_consumption
  end
  return Handler.energy_per_shot
end

function Handler.shoot(struct)
  struct.entity.energy = struct.entity.energy - Handler.get_energy_per_shot()

  struct.barrel = struct.barrel % 4 + 1
  struct.entity.surface.create_entity{
    name = Meteor.name_meteor_point_defence_beam,
    position = Util.vectors_add(struct.entity.position, Meteor.name_meteor_point_defence_beam_offsets[struct.barrel]),
    target = Util.vectors_add(struct.entity.position, {x = 0, y = -Meteor.meteor_swarm_altitude})
  }
end

function Handler.handle_construction_alert(alert)
  if not alert.target.valid then return end -- ghost might have been removed or revived already
  if alert.target.name ~= "entity-ghost" then return end -- can be "item-request-proxy" or "tile-ghost"

  local handled_alert = global.handled_alerts[alert.target.unit_number]
  if handled_alert and handled_alert.entity.valid and handled_alert.proxy.valid then return end

  local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = alert.target.surface.index})
  if not zone then return end

  for _, item_to_place_this in ipairs(alert.target.ghost_prototype.items_to_place_this) do
    if item_to_place_this.count == 1 then -- no support for e.g. curved rails (which need 4) yet

      local anti_infinite_loop = 0
      local anti_infinite_loop_max = #global.deck + #global.pile
      while true do
        local struct = Handler.draw_random_card()
        if not struct then return end

        if anti_infinite_loop > anti_infinite_loop_max then return end
        anti_infinite_loop = anti_infinite_loop + 1

        if alert.target.force == struct.entity.force then
          -- we're gonna check for orange coverage for now, instead of green venn diagrams and filtering out personal roboports
          local network = struct.entity.surface.find_logistic_network_by_position(struct.entity.position, struct.entity.force)
          if network and network.can_satisfy_request(item_to_place_this.name, item_to_place_this.count, true) then
            if not struct.proxy or not struct.proxy.valid then
              local proxy = struct.entity.surface.create_entity{
                name = 'item-request-proxy',
                force = struct.entity.force,
                target = struct.entity,
                position = struct.entity.position,
                modules = {[item_to_place_this.name] = item_to_place_this.count}
              }

              rendering.draw_text{
                color = {1, 1, 1},
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

              struct.proxy = proxy -- the struct doesn't need a reference to the handled alert right?
              struct.updated_at = game.tick

              global.deathrattles[script.register_on_entity_destroyed(proxy)] = alert.target.unit_number
              global.deathrattles[script.register_on_entity_destroyed(alert.target)] = alert.target.unit_number
              return
            end
          end
        end

      end
    end
  end
end

function Handler.get_cargo_of_overhead_construction_bot_holding(entity, itemstack)
  local nearby_construction_robots = entity.surface.find_entities_filtered{
    type = 'construction-robot',
    position = entity.position,
    force = entity.force,
  }

  for _, nearby_construction_robot in ipairs(nearby_construction_robots) do
    local cargo = nearby_construction_robot.get_inventory(defines.inventory.robot_cargo)
    if cargo.get_item_count(itemstack.name) >= itemstack.count then
      return cargo
    end
  end
end

function Handler.on_entity_destroyed(event)
  local unit_number = global.deathrattles[event.registration_number]
  if unit_number then global.deathrattles[event.registration_number] = nil

    local handled_alert = global.handled_alerts[unit_number]
    if handled_alert then global.handled_alerts[unit_number] = nil
      
      -- did the ghost die first? if so we remove the proxy and free up the struct
      if handled_alert.proxy.valid then
        handled_alert.proxy.destroy()
      end
      if not handled_alert.entity.valid then return end

      local struct = global.structs[handled_alert.struct_unit_number]
      if not struct then return end
      if not struct.entity.valid then return end
  
      local cargo = Handler.get_cargo_of_overhead_construction_bot_holding(struct.entity, handled_alert.itemstack)
      if cargo then
        cargo.remove(handled_alert.itemstack)
        Handler.shoot(struct)
        handled_alert.entity.revive{raise_revive = true}
      end

    end
  end
end

function Handler.gc(event)
  for unit_number, struct in pairs(global.structs) do
    if not struct.valid then
      log('garbage collected struct #' .. unit_number)
      global.structs[unit_number] = nil
    end
  end

  for unit_number, handled_alert in pairs(global.handled_alerts) do
    if not handled_alert.entity.valid or not handled_alert.proxy.valid then
      log('garbage collected alert #' .. unit_number)
      global.handled_alert[unit_number] = nil
    end
  end

  for _, player in ipairs(game.connected_players) do
    if not player.is_alert_enabled(defines.alert_type.no_material_for_construction) then
      player.enable_alert(defines.alert_type.no_material_for_construction)
      log('player ' .. player.name .. ' had construction alerts disabled')
    end
  end

  for unit_number, struct in pairs(global.structs) do
    if struct.proxy and struct.proxy.valid and struct.updated_at > game.tick + 60 * 60 * 10 then
      log('struct proxy expired #' .. unit_number)
      struct.proxy.destroy()
    end
  end
end

return Handler
