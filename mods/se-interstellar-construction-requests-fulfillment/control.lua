local Handler = require('scripts.handler')

script.on_init(function(event)
  global.structs = {}

  -- log('items_to_place_this')
  -- for _, entity_prototype in pairs(game.entity_prototypes) do
  --   for _, item_to_place_this in pairs(entity_prototype.items_to_place_this or {}) do
  --     if item_to_place_this.count > 1 then
  --       log(entity_prototype.name .. serpent.block(item_to_place_this))
  --     end
  --   end
  -- end
  -- {curved-rail, se-space-curved-rail, concrete-wall-ruin, steel-wall-ruin, stone-wall-ruin}
end)

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = 'name', name = 'se-interstellar-construction-requests-fulfillment--turret'},
  })
end

script.on_nth_tick(60, Handler.tick)

script.on_nth_tick(600, function(event)

  for _, player in ipairs(game.connected_players) do
    local alerts = player.get_alerts{
      type = defines.alert_type.no_material_for_construction,
    }

    for surface_index, surface_alerts in pairs(alerts) do
      for _, surface_alert in ipairs(surface_alerts[defines.alert_type.no_material_for_construction]) do
        Handler.handle_construction_alert(surface_alert)
        -- {
        --   {
        --     count = 1,
        --     name = "industrial-furnace"
        --   }
        -- ...
        -- }
        -- {
        --   {
        --     count = 1,
        --     name = "storage-tank"
        --   }
        -- }
      end
    end
  end

end)
