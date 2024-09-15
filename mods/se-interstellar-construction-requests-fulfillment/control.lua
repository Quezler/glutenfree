local Handler = require('scripts.handler')

script.on_init(Handler.on_init)
script.on_configuration_changed(Handler.on_configuration_changed)

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = 'name', name = 'interstellar-construction-turret--buffer-chest'},
  })
end

script.on_event(defines.events.on_entity_destroyed, Handler.on_entity_destroyed)

script.on_nth_tick(600, function(event) -- no_material_for_construction expires after 10 seconds
  local force_checked_for_missing = {}
  local force_checked_for_repair = {}

  for _, player in ipairs(game.connected_players) do

    if not force_checked_for_missing[player.force.index] then
      if player.is_alert_enabled(defines.alert_type.no_material_for_construction) then
        force_checked_for_missing[player.force.index] = true
        local alerts = player.get_alerts{
          type = defines.alert_type.no_material_for_construction,
        }

        for surface_index, surface_alerts in pairs(alerts) do
          for _, surface_alert in ipairs(surface_alerts[defines.alert_type.no_material_for_construction]) do
            if surface_alert.target and surface_alert.target.valid then

              local unit_number = surface_alert.target.unit_number
              if unit_number == nil and surface_alert.target.type == "cliff" then
                unit_number = 'cliff-' .. script.register_on_entity_destroyed(surface_alert.target)
              --   global.alert_targets[unit_number] = {
              --     type = surface_alert.target.type,
              --     name = surface_alert.target.name,
              --     force = player.force,
              --     valid = true,
              --     get_upgrade_target = function ()
              --       return nil
              --     end
              --   }
              -- else
              --   assert(unit_number)
              --   global.alert_targets[unit_number] = surface_alert.target
              end

              assert(unit_number)
              global.alert_targets[unit_number] = surface_alert.target
            end
          end
        end
      else
        player.enable_alert(defines.alert_type.no_material_for_construction)
        -- command response for `/alerts enable no_material_for_construction`
        player.print('Alert type no_material_for_construction has been enabled.')
      end
    end -- if

    if not force_checked_for_repair[player.force.index] then
      if player.is_alert_enabled(defines.alert_type.not_enough_repair_packs) then
        force_checked_for_repair[player.force.index] = true
        local alerts = player.get_alerts{
          type = defines.alert_type.not_enough_repair_packs,
        }

        for surface_index, surface_alerts in pairs(alerts) do
          for _, surface_alert in ipairs(surface_alerts[defines.alert_type.not_enough_repair_packs]) do
            if surface_alert.target and surface_alert.target.valid and surface_alert.target.unit_number then
              global.alert_targets[surface_alert.target.unit_number] = surface_alert.target
            end
          end
        end
      else
        player.enable_alert(defines.alert_type.not_enough_repair_packs)
        -- command response for `/alerts enable not_enough_repair_packs`
        player.print('Alert type not_enough_repair_packs has been enabled.')
      end
    end -- if

  end -- for

  global.missing_items = {}
  global.alert_targets_emptied = false
  global.alert_targets_per_tick = math.ceil(table_size(global.alert_targets) / 600)
  -- log('global.alert_targets_per_tick = ' .. global.alert_targets_per_tick)

  -- todo: sort struct keys in order from networks with the most diverse amount of items to the lowest
end)

script.on_event(defines.events.on_tick, Handler.on_tick)

commands.add_command('se-interstellar-construction-requests-fulfillment', nil, function(command)
  local item_request_proxy_whitelist = {}
  for item_name, bool in pairs(global.item_request_proxy_whitelist) do
    table.insert(item_request_proxy_whitelist, item_name)
  end

  local player = game.get_player(command.player_index)
  player.print(serpent.block({
    table_size(global.v1_structs),
    'global.alert_targets = ' .. table_size(global.alert_targets),
    'global.alert_targets_per_tick = ' .. global.alert_targets_per_tick,
    'global.item_request_proxy_whitelist = ' .. table.concat(item_request_proxy_whitelist, ', '),
  }))
end)
