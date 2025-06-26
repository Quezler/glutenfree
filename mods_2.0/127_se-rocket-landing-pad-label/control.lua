require("scripts.luagui-pretty-print")

local mod = {}

function try_open_gui_with_someone(entity)
  for _, player in ipairs(entity.force.connected_players) do
    if not player.opened then
      player.opened = entity
      player.opened = nil
      return
    end
  end
end

script.on_init(function ()
  storage.structs = {}
  storage.deathrattles = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = "cargo-landing-pad"})) do
      mod.on_created_entity({entity = entity})
    end
  end
end)

mod.create_struct = function(entity)
  storage.structs[entity.unit_number] = {
    entity = entity,
    text = nil,
  }
end

mod.on_created_entity = function(event)
  local entity = event.entity or event.destination

  mod.create_struct(entity)
  try_open_gui_with_someone(entity) -- this does not seem to work, and if you remove the opened = nil it has no relative gui it seems
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, mod.on_created_entity, {
    {filter = "name", name = "cargo-landing-pad"},
  })
end

mod.update_text = function(unit_number, text)
  local struct = storage.structs[unit_number]
  if not struct then return end

  -- if struct.text then text.destroy() end
  if struct.text == nil then
    local entity = struct.entity
    struct.text = rendering.draw_text{
      text = text,
      color = {1, 1, 1},
      surface = entity.surface,
      target = {entity = entity, offset = {0, 2.25}},
      alignment = "center",
      use_rich_text = true,
    }
  else
    struct.text.text = text
  end
end

script.on_event(defines.events.on_gui_opened, function(event)
  if not event.entity then return end
  if event.entity.name ~= "cargo-landing-pad" then return end

  -- race condition, space exploration opens newly placed landing pads in their created hook
  if not storage.structs[event.entity.unit_number] then
    mod.create_struct(event.entity)
  end

  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local name = player.gui.relative["se-rocket-landing-pad-gui"]["landingpad-titlebar-flow"]["show-name"]
  mod.update_text(event.entity.unit_number, name.caption)

  local landingpad_rename = player.gui.relative["se-rocket-landing-pad-gui"]["landingpad-titlebar-flow"]["landingpad-rename"]
  landingpad_rename.raise_hover_events = true
end)

-- script.on_event(defines.events.on_gui_click, function(event)
--   log(LuaGuiPrettyPrint.path_to_element(event.element))
-- end)

-- mod.get_selected_(landingpads_dropdown)
--   local selected = landingpads_dropdown.items[landingpads_dropdown.selected_index]

--   if selected[1] == "space-exploration.none_general_vicinity" then selected = nil end

--   return selected
-- end

-- script.on_event(defines.events.on_gui_selection_state_changed, function(event)
--   game.print(event.element.name)
--   if event.element.name == "landingpad-list-landing-pad-names" then
--     local dropdown = event.element
--     local root = assert(dropdown.parent.parent.parent.parent)
--     local unit_number = root.tags.unit_number
--     local write_name = root["landingpad-gui-frame"]["landingpad-gui-frame-dark"]["landingpad-name-flow"].children[1]["se-write-name"]
--     game.print(unit_number)
--     game.print(serpent.line(dropdown.items[dropdown.selected_index]))
--     game.print(root.name)
--     game.print(write_name.text)
--     -- launchpad.update_by_unit_number(unit_number, nil, launchpad.get_position(event.element) or "None - General vicinity")
--   end
-- end)

-- all the buttons get removed as soon as they're clicked so the events do not propogate,
-- so we'll have to be sneaky and just detect when the buttons are about to be used,
-- this is done by listening to hover and by then listening to destroy we know when they might have been clicked.
script.on_event(defines.events.on_gui_hover, function(event)
  if event.element.name == "landingpad-rename" then
    storage.deathrattles[script.register_on_object_destroyed(event.element)] = {
      name = "landingpad-rename",
      root = event.element.parent.parent,
    }
  end
end)

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    if deathrattle.name == "landingpad-rename" and deathrattle.root.valid then
      local landingpad_stop_rename = deathrattle.root["landingpad-titlebar-flow"]["landingpad-stop-rename"]
      storage.deathrattles[script.register_on_object_destroyed(landingpad_stop_rename)] = {
        name = "landingpad-stop-rename",
        root = deathrattle.root,
      }
    elseif deathrattle.name == "landingpad-stop-rename" and deathrattle.root.valid then
      local name = deathrattle.root["landingpad-titlebar-flow"]["show-name"]
      mod.update_text(deathrattle.root.tags.unit_number, name.caption)
    end
    -- log(serpent.block(deathrattle))
  end
end)

script.on_event(defines.events.on_entity_settings_pasted, function (event)
  if event.destination.name == "cargo-landing-pad" then
    try_open_gui_with_someone(event.destination)
  end
end)
