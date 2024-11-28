local Update = require("scripts.update")

local Handler = {}

function Handler.on_init()
  storage.surfacedata = {}
  storage.surfaces_to_update = {}

  for _, surface in pairs(game.surfaces) do
    Handler.on_surface_created({surface_index = surface.index})
    -- todo: comment out after development
    for _, entity in pairs(surface.find_entities_filtered({name = {'fulgoran-construction-hub'}})) do
      Handler.on_created_entity({entity = entity})
    end
  end

  Handler.on_configuration_changed()
end

function Handler.on_configuration_changed()
  for _, surface in pairs(game.surfaces) do
    if storage.surfacedata[surface.index] == nil then
      ---@diagnostic disable-next-line: param-type-mismatch, missing-fields
      script.get_event_handler(defines.events.on_surface_created){surface_index = surface.index}
    end
  end
end

script.on_init(Handler.on_init)
script.on_configuration_changed(Handler.on_configuration_changed)

function Handler.on_surface_created(event)
  storage.surfacedata[event.surface_index] = {
    old_alerts = {}, old_alerts_empty = true,
    new_alerts = {},
    hubs = {}, total_hubs = 0,

    requests = {},
  }
end

-- tbh could also listen for on_object_deleted instead of on_surface_deleted
function Handler.on_surface_deleted(event)
  storage.surfacedata[event.surface_index] = nil
end

script.on_event(defines.events.on_surface_created, Handler.on_surface_created)
script.on_event(defines.events.on_surface_deleted, Handler.on_surface_deleted)

function Handler.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  entity.get_logistic_point(defines.logistic_member_index.logistic_container).trash_not_requested = true

  local surfacedata = storage.surfacedata[entity.surface.index]

  surfacedata.hubs[entity.unit_number] = {
    entity = entity,
  }

  surfacedata.total_hubs = surfacedata.total_hubs + 1
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = 'name', name = 'fulgoran-construction-hub'},
  })
end

function Handler.handle_surface_alerts(surface_index, force_index, surface_alerts)
  local surfacedata = storage.surfacedata[surface_index]
  if surfacedata.total_hubs == 0 then return end

  -- update the surface (again) until the update script determines it is done.
  -- storage.surfaces_to_update[surface_index] = true

  -- game.print(game.surfaces[surface_index].name)

  for _, surface_alert in ipairs(surface_alerts[defines.alert_type.no_material_for_construction]) do
    if surface_alert.target and surface_alert.target.valid then
      local registration_number = script.register_on_object_destroyed(surface_alert.target)

      storage.surfaces_to_update[surface_index] = true
      surfacedata.new_alerts[registration_number] = {
        target = surface_alert.target,
      }
    end
  end
end

function Handler.on_nth_tick(event)
  local force_checked = {}

  for _, player in ipairs(game.connected_players) do
    local force_index = player.force.index
    if not force_checked[force_index] then
      if player.is_alert_enabled(defines.alert_type.no_material_for_construction) == false then
        player.enable_alert(defines.alert_type.no_material_for_construction)
        player.print('Alert type no_material_for_construction has been enabled.')
      else
        force_checked[force_index] = true

        local alerts = player.get_alerts{
          type = defines.alert_type.no_material_for_construction,
          -- todo: maybe filter on surface in here as well?
        }

        for surface_index, surface_alerts in pairs(alerts) do
          Handler.handle_surface_alerts(surface_index, force_index, surface_alerts)
        end
      end
    end
  end
end

-- commands.add_command('fulgoran-construction-hub', nil, function(command)
--   Handler.on_nth_tick({tick = game.tick})
-- end)

script.on_nth_tick(600, Handler.on_nth_tick) -- construction materials missing alert lasts for 10 seconds.
script.on_event(defines.events.on_tick, Update.on_tick)
