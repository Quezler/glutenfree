local Handler = {}

function Handler.on_init(event)
  storage.structs = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{type = "display-panel"}) do
      Handler.on_created_entity({entity = entity})
    end
  end
end

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  storage.structs[entity.unit_number] = {
    entity = entity,
  }
end

local function tick_display_panel(entity)
  local struct = storage.structs[entity.unit_number]
  assert(struct)

  game.print(string.format("@%d ticked display panel #%d", game.tick, entity.unit_number))

  local cb = entity.get_control_behavior()
  if cb == nil then return end -- entity never had a wire connected yet
  game.print(serpent.line(cb)) -- fulfilled is never present

  for i, message in ipairs(cb.messages) do
    game.print(serpent.line(message))
  end
end

script.on_init(Handler.on_init)

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = "type", type = "display-panel"},
  })
end

script.on_event(defines.events.on_selected_entity_changed, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local entity = player.selected
  if entity and entity.type == "display-panel" then
    tick_display_panel(entity)
  end
end)
