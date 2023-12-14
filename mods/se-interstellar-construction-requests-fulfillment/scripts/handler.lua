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

  global.alert_targets = {}
  global.alert_targets_per_tick = 1

  global.children_to_kill = {}
  
  Handler.regenerate_item_request_proxy_whitelist()
  global.rich_text_name_for_destination_surface = {}

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

function Handler.on_configuration_changed(event)
  global.alert_targets = global.alert_targets or {}
  global.alert_targets_per_tick = global.alert_targets_per_tick or 1

  global.children_to_kill = global.children_to_kill or {}

  for unit_number, struct in pairs(global.structs) do
    if struct.entity.valid and not struct.buffer_chest then
      Handler.create_buffer_chest_for(struct)
    end
  end

  Handler.regenerate_item_request_proxy_whitelist()
  global.rich_text_name_for_destination_surface = {}
end

function Handler.regenerate_item_request_proxy_whitelist()
  global.item_request_proxy_whitelist = {}
  local module_prototypes = game.get_filtered_item_prototypes({{filter = "type", type = "module"}})
  for module_name, module_prototype in pairs(module_prototypes) do
    global.item_request_proxy_whitelist[module_name] = true
  end
end

function Handler.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination

  entity.active = false

  local struct = {
    unit_number = entity.unit_number,
    entity = entity,
    barrel = 0,
    proxy = nil, -- entity occupied if present and valid
    updated_at = game.tick,
  }

  Handler.create_buffer_chest_for(struct)
  global.structs[entity.unit_number] = struct
  table.insert(global.pile, entity.unit_number)
end

function Handler.create_buffer_chest_for(struct)
  local chest = struct.entity.surface.create_entity{
    name = 'se-interstellar-construction-requests-fulfillment--buffer-chest',
    force = struct.entity.force,
    position = struct.entity.position,
  }

  chest.destructible = false
  struct.buffer_chest = chest

  global.children_to_kill[script.register_on_entity_destroyed(struct.entity)] = chest
end

function Handler.shuffle_array_in_place(t)
  for i = #t, 2, -1 do
    local j = math.random(i)
    t[i], t[j] = t[j], t[i]
  end
end

function Handler.draw_random_card(already)
  while true do
    if #global.deck == 0 then
      if already.shuffled or #global.pile == 0 then return nil end

      Handler.shuffle_array_in_place(global.pile)
      global.deck = global.pile
      global.pile = {}

      already.shuffled = true
    end

    local struct = global.structs[table.remove(global.deck)]
    if struct then
      if not struct.entity.valid then
        global.structs[struct.unit_number] = nil
      else
        table.insert(global.pile, struct.unit_number)
        return struct
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

local supported_names = {["entity-ghost"] = true, ["item-request-proxy"] = true}
function Handler.handle_construction_alert(alert_target)
  if not supported_names[alert_target.name] and not alert_target.get_upgrade_target() then return end -- can be "item-request-proxy" or "tile-ghost"

  local handled_alert = global.handled_alerts[alert_target.unit_number]
  if handled_alert and handled_alert.entity.valid and handled_alert.proxy.valid then return end

  -- determine & cache the name and icon for the destination zone
  local rich_text_name_for_destination_surface = global.rich_text_name_for_destination_surface[alert_target.surface.index]
  if rich_text_name_for_destination_surface == nil then
    local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = alert_target.surface.index})
    if not zone then
      global.rich_text_name_for_destination_surface[alert_target.surface.index] = false
      return
    end
    rich_text_name_for_destination_surface = Zone._get_rich_text_name(zone)
    global.rich_text_name_for_destination_surface[alert_target.surface.index] = rich_text_name_for_destination_surface
  elseif global.rich_text_name_for_destination_surface[alert_target.surface.index] == false then
    return
  end

  local items_to_place_this = {}
  if alert_target.name == "entity-ghost" then items_to_place_this = alert_target.ghost_prototype.items_to_place_this
  elseif alert_target.name == "item-request-proxy" then
    if alert_target.proxy_target.name == Handler.entity_name then return end -- avoid recursion by trying to satisfy proxies from this mod
    for name, count in pairs(alert_target.item_requests) do
      if global.item_request_proxy_whitelist[name] then
        table.insert(items_to_place_this, {name = name, count = 1})
      end
    end
  elseif alert_target.get_upgrade_target() then items_to_place_this = alert_target.get_upgrade_target().items_to_place_this end

  for _, item_to_place_this in ipairs(items_to_place_this) do
    if item_to_place_this.count == 1 then -- no support for e.g. curved rails (which need 4) yet

      local already = {shuffled = false}
      while true do
        local struct = Handler.draw_random_card(already)
        if not struct then break end

        if alert_target.force == struct.entity.force then
          if struct.entity.energy >= Handler.get_energy_per_shot() then
            if not struct.proxy or not struct.proxy.valid then
              if struct.buffer_chest.logistic_network then

                if struct.buffer_chest.logistic_network.can_satisfy_request(item_to_place_this.name, item_to_place_this.count, true) then
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
                    text = rich_text_name_for_destination_surface,
                    surface = proxy.surface,
                    target = proxy,
                    target_offset = {0, 0.5},
                    use_rich_text = true,
                  }

                  global.handled_alerts[alert_target.unit_number] = {
                    struct_unit_number = struct.unit_number,
                    unit_number = alert_target.unit_number,
                    entity = alert_target,
                    proxy = proxy,
                    itemstack = item_to_place_this,
                  }

                  struct.proxy = proxy -- the struct doesn't need a reference to the handled alert right?
                  struct.updated_at = game.tick

                  global.deathrattles[script.register_on_entity_destroyed(proxy)] = alert_target.unit_number
                  global.deathrattles[script.register_on_entity_destroyed(alert_target)] = alert_target.unit_number
                  return
                end
              end -- network

            end
          end
        end -- force

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
        
        if handled_alert.entity.name == "entity-ghost" then
          local colliding_items, revived_entity = handled_alert.entity.revive{raise_revive = true}
          if colliding_items and table_size(colliding_items) > 0 then
            game.print(serpent.line(colliding_items))
          end
          if revived_entity then
            cargo.remove(handled_alert.itemstack)
            Handler.shoot(struct)
            return
          end
        elseif handled_alert.entity.name == "item-request-proxy" then
          if Handler.item_request_proxy_still_wants(handled_alert.entity, handled_alert.itemstack) then
            if handled_alert.entity.proxy_target.insert(handled_alert.itemstack) then
              Handler.item_request_proxy_subtract(handled_alert.entity, handled_alert.itemstack)
              cargo.remove(handled_alert.itemstack)
              Handler.shoot(struct)
              return
            end
          end
        elseif handled_alert.entity.get_upgrade_target() then
          for _, network in ipairs(handled_alert.entity.surface.find_logistic_networks_by_construction_area(handled_alert.entity.position, handled_alert.entity.force)) do
            if network.insert(cargo[1]) > 0 then -- technically should check if all of it got inserter or otherwise abort, but it shoudln't be more than 1 right?
              cargo.remove(handled_alert.itemstack)
              Handler.shoot(struct)
              return
            end
          end
        end

      end

    end
  end

  local child = global.children_to_kill[event.registration_number]
  if child then global.children_to_kill[event.registration_number] = nil
    if child.valid then
      child.destroy()
    end
  end
end

function Handler.item_request_proxy_still_wants(item_request_proxy, itemstack)
  for name, count in pairs(item_request_proxy.item_requests) do
    if name == itemstack.name then return true end
  end

  return false
end

function Handler.item_request_proxy_subtract(item_request_proxy, itemstack)
  local item_requests = item_request_proxy.item_requests
  for name, count in pairs(item_requests) do
    if name == itemstack.name then
      count = count - itemstack.count
      if 0 >= count then
        if 0 > count then
          error('could not remove enough of this item from the proxy.')
        end
        item_requests[name] = nil
      else
        item_requests[name] = count
      end
      item_request_proxy.item_requests = item_requests
      return
    end
  end

  error('proxy did not request that item anymore already.')
end

function Handler.on_tick(event)
  -- log('#alert_targets = ' .. table_size(global.alert_targets))
  local i = 1
  for unit_number, alert_target in pairs(global.alert_targets) do
    global.alert_targets[unit_number] = nil
    if alert_target.valid then
      Handler.handle_construction_alert(alert_target)
      i = i + 1
      if i > global.alert_targets_per_tick then return end
    end
  end
end

function Handler.gc(event)
  for unit_number, struct in pairs(global.structs) do
    if not struct.entity.valid then
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
    if struct.proxy and struct.proxy.valid and (game.tick + 60 * 60 * 10) > struct.updated_at then -- 10 minutes
      log('struct proxy expired #' .. unit_number)
      struct.proxy.destroy()
    end
  end
end

return Handler
