local loaders = require('scripts.loaders')

--

local function init()
  global = {}

  log("init()")

  loaders.init()
end

script.on_init(function()
  init()
end)

script.on_configuration_changed(function(event)
  init()
end)

--

local events = {
  [defines.events.on_built_entity] = loaders.on_created_entity,
  [defines.events.on_robot_built_entity] = loaders.on_created_entity,
  [defines.events.script_raised_built] = loaders.on_created_entity,
  [defines.events.script_raised_revive] = loaders.on_created_entity,
  [defines.events.on_entity_cloned] = loaders.on_created_entity,

  [defines.events.on_entity_died] = loaders.on_entity_removed,
  [defines.events.script_raised_destroy] = loaders.on_entity_removed,
  [defines.events.on_player_mined_entity] = loaders.on_entity_removed,
  [defines.events.on_robot_mined_entity] = loaders.on_entity_removed,

  [defines.events.on_gui_closed] = loaders.on_gui_closed,
  [defines.events.on_entity_settings_pasted] = loaders.on_entity_settings_pasted,

  [defines.events.on_player_rotated_entity] = loaders.on_player_rotated_entity,
}

for event, handler in pairs(events) do
  script.on_event(event, handler)
end

--

commands.add_command("reload-alt-mode-for-1x1-loaders", "- Deletes orphaned alt mode indicators.", function(event)
  local player = game.get_player(event.player_index)
  player.print(player.admin)
  if player.admin then
    init()
  end
end)
