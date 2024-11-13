local circuit_red = defines.wire_connector_id.circuit_red
local circuit_green = defines.wire_connector_id.circuit_green

local Handler = {}

function Handler.on_init(event)
  storage.structs = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{type = "display-panel"}) do
      Handler.on_created_entity({entity = entity})
    end
  end

  storage.selected_struct_ids = {}
end

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  storage.structs[entity.unit_number] = {
    id = entity.unit_number,
    entity = entity,

    selected_by = nil,
  }
end

local function is_nil_or_number(string)
  return string == nil or tonumber(string, 10) ~= nil
end

local function tick_display_panel(struct)
  local entity = struct.entity
  game.print(string.format("@%d ticked display panel #%d", game.tick, entity.unit_number))

  local cb = entity.get_control_behavior()
  if cb == nil then return end -- entity never had a wire connected yet

  for i, message in ipairs(cb.messages) do
    if is_nil_or_number(message.text) then
      if message.condition and message.condition.first_signal then
        message.text = entity.get_signal(message.condition.first_signal, circuit_red, circuit_green)
      else
        message.text = ""
      end
      cb.set_message(i, message)
    end
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

local function mark_struct_as_selected(struct, player)
  storage.selected_struct_ids[struct.id] = true
  struct.selected_by = player
end

script.on_event(defines.events.on_selected_entity_changed, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local entity = player.selected
  if entity and entity.type == "display-panel" then
    tick_display_panel(storage.structs[entity.unit_number])
  end
end)

script.on_event(defines.events.on_tick, function(event)
  for _, struct in pairs(storage.structs) do
    if struct.entity.valid then
      tick_display_panel(struct)
    end
  end
end)
