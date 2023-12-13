function on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  global.structs[entity.unit_number] = {
    unit_number = entity.unit_number,
    entity = entity,
    opened = false,
    id = nil,
  }

  for _, player in ipairs(entity.force.connected_players) do
    if not player.opened then
      player.opened = entity
      player.opened = nil
      return
    end
  end
end

script.on_init(function(event)
  global.structs = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = {'aai-signal-sender', 'aai-signal-receiver'}})) do
      on_created_entity({entity = entity})
    end
  end
end)

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, on_created_entity, {
    {filter = 'name', name = 'aai-signal-sender'},
    {filter = 'name', name = 'aai-signal-receiver'},
  })
end

function update_text(unit_number, channel)
  local struct = global.structs[unit_number]
  if not struct then return end
  struct.opened = true
  -- if struct.id then rendering.destroy(id) end
  if struct.id == nil then
    local entity = struct.entity
    struct.id = rendering.draw_text{
      text = channel,
      color = {1, 1, 1},
      surface = entity.surface,
      position = entity.position,
      target = entity,
      target_offset = {0, -1.5},
      alignment = "center",
      use_rich_text = true,
    }
  else
    rendering.set_text(struct.id, channel)
  end
end

script.on_event(defines.events.on_gui_opened, function(event)
  local player = game.get_player(event.player_index)
  local opened = player.opened

  if not opened then return end
  if opened.name ~= "aai-signal-sender" then return end

  if not opened.children[2] then return end -- first time this element shows up its empty, so wait for the 2nd time.
  local unit_number = tonumber(opened.children[1].children[1].name)
  local channel = opened.children[2].children[2].children[1].children[1].caption

  update_text(unit_number, channel)
end)

remote.add_interface('aai-signal-transmission-luarendered-channel-label', {update_text = update_text})

commands.add_command('aai-signal-transmission-luarendered-channel-label', nil, function(command)
  local player = game.get_player(command.player_index)
  for unit_number, struct in pairs(global.structs) do
    player.opened = struct.entity
  end
  player.opened = nil
end)

-- script.on_event(defines.events.on_gui_confirmed, function(event)
--   game.print('s' .. event.element.name)
-- end)

-- script.on_event(defines.events.on_gui_click, function(event)
--   game.print('s' .. event.element.name)
-- end)
