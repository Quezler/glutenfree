local Util = require("__aai-signal-transmission__.scripts.util")
require("scripts.luagui-pretty-print")

function try_open_gui_with_someone(entity)
  for _, player in ipairs(entity.force.connected_players) do
    if not player.opened then
      player.opened = entity
      player.opened = nil
      return
    end
  end
end

function on_created_entity(event)
  local entity = event.entity or event.destination
  storage.structs[entity.unit_number] = {
    entity = entity,
    text = nil,
  }

  try_open_gui_with_someone(entity)
end

script.on_init(function()
  storage.structs = {}
  storage.deathrattles = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = {"aai-signal-sender", "aai-signal-receiver"}})) do
      on_created_entity({entity = entity})
    end
  end
end)

script.on_configuration_changed(function()
  storage.deathrattles = storage.deathrattles or {}
end)

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, on_created_entity, {
    {filter = "name", name = "aai-signal-sender"},
    {filter = "name", name = "aai-signal-receiver"},
  })
end

function update_text(unit_number, channel)
  local struct = storage.structs[unit_number]
  if not struct then return end

  if Util.string_trim(channel) == "" then channel = "Default" end

  -- if struct.text then text.destroy() end
  if struct.text == nil then
    local entity = struct.entity
    struct.text = rendering.draw_text{
      text = channel,
      color = {1, 1, 1},
      surface = entity.surface,
      position = entity.position,
      target = {entity = entity, offset = {0, -1.5}},
      alignment = "center",
      use_rich_text = true,
    }
  else
    struct.text.text = channel
  end
end

local function raise_hover_events(root)
  local aai_change_channel = root.children[2].children[2].children[1]["aai-change_channel"]
  aai_change_channel.raise_hover_events = true
end

script.on_event(defines.events.on_gui_opened, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local opened = player.opened

  if not opened then return end
  if opened.object_name ~= "LuaGuiElement" then return end -- "LuaEquipmentGrid doesn't contain key name."
  if opened.name ~= "aai-signal-sender" then return end

  if not opened.children[2] then return end -- first time this element shows up its empty, so wait for the 2nd time.
  local unit_number = tonumber(opened.children[1].children[1].name)
  local channel = opened.children[2].children[2].children[1].children[1].caption

  local root = player.gui.screen["aai-signal-sender"]
  raise_hover_events(root)

  update_text(unit_number, channel)
end)

remote.add_interface("aai-signal-transmission-luarendered-channel-label", {update_text = update_text})

commands.add_command("aai-signal-transmission-luarendered-channel-label", nil, function(command)
  local player = game.get_player(command.player_index) --[[@as LuaPlayer]]
  for unit_number, struct in pairs(storage.structs) do
    if struct.entity.valid then
      player.opened = struct.entity
    end
  end
  player.opened = nil
end)

script.on_event(defines.events.on_entity_settings_pasted, function (event)
  if event.destination.name == "aai-signal-sender" or event.destination.name == "aai-signal-receiver" then
    try_open_gui_with_someone(event.destination)
  end
end)

script.on_event(defines.events.on_gui_click, function(event)
  log(LuaGuiPrettyPrint.path_to_element(event.element))
end)

script.on_event(defines.events.on_gui_selection_state_changed, function(event)
  game.print(event.element.name)
  if event.element.name == "aai-change_channel_dropdown" then -- dropdown opened or updated
    local channel = event.element.items[event.element.selected_index]
    local unit_number = tonumber(event.element.parent.parent.parent.children[1].children[1].name)
    remote.call("aai-signal-transmission-luarendered-channel-label", "update_text", unit_number, channel)
  end
end)

script.on_event(defines.events.on_gui_hover, function(event)
  if event.element.name == "aai-change_channel" then
    local root = event.element.parent.parent.parent.parent --[[@as LuaGuiElement]]
    assert(root.name)
    storage.deathrattles[script.register_on_object_destroyed(event.element)] = {
      name = "aai-change_channel",
      root = root,
    }
  end
end)

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    if deathrattle.name == "aai-change_channel" and deathrattle.root.valid then
      local aai_change_channel_confirm = deathrattle.root.children[2].children[2].children[1]["aai-change-channel-confirm"]
      if aai_change_channel_confirm then
        storage.deathrattles[script.register_on_object_destroyed(aai_change_channel_confirm)] = {
          name = "aai-change-channel-confirm",
          root = deathrattle.root,
        }
      end
    elseif deathrattle.name == "aai-change-channel-confirm" and deathrattle.root.valid then
      local name = deathrattle.root.children[2].children[2].children[1]["show-channel"]
      local unit_number = tonumber(deathrattle.root["unit_number"].children[1].name)
      update_text(assert(unit_number), assert(name.caption))
      raise_hover_events(deathrattle.root) -- in case the user wants to edit the channel again without closing the gui first
    end
    log(serpent.block(deathrattle))
  end
end)
