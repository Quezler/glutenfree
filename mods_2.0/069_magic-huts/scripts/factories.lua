local Factories = {}

Factories.add = function (export)
  -- delete unused factories of the same name for the same planet
  for _, factory in pairs(storage.factories) do
    if factory.count == 0 and factory.export.name == export.name and factory.export.space_location == export.space_location then
      Factories.delete_by_index(factory.index)
    end
  end

  local struct = new_struct(storage.factories, {
    index = mod.next_index_for("factory"),
    export = export,
    count = 0,
  })
  log(string.format("creating factory #%d (%s)", struct.index, struct.export.name))

  Factories.refresh_list()
  return struct
end

Factories.delete_by_index = function(index)
  assert(index)

  local factory = storage.factories[index]
  storage.factories[index] = nil
  log(string.format("removing factory #%d (%s)", factory.index, factory.export.name))

  for _, building in pairs(storage.buildings) do
    if building.factory_index == index then
      building.factory_index = nil
      Buildings.set_status_not_configured(building)
    end
  end

  Factories.refresh_list()
end

Factories.refresh_list = function ()
  for _, playerdata in pairs(storage.playerdata) do
    local scroll_pane = playerdata.player.gui.relative[mod.relative_frame_left_name]["inner"]["scroll-pane"]
    scroll_pane.clear()

    for _, factory in pairs(storage.factories) do
      local flow = scroll_pane.add{
        type = "flow",
        style = "horizontal_flow",
        index = 1,
      }
      flow.style.minimal_width = 340
      flow.style.maximal_height = 24
      flow.style.vertical_align = "center"
      flow.style.horizontal_spacing = 0
      flow.style.horizontally_stretchable = true

      local button = flow.add{
        type = "button",
        style = "list_box_item",
        tags = {
          action = mod_prefix .. "select-factory",
          factory_index = factory.index,
        }
      }
      -- button.auto_toggle = true
      -- button.style.hovered_font_color = {0, 0, 0}
      -- button.style.clicked_font_color = {0, 0, 0}
      -- button.style.disabled_font_color = {0, 0, 0}
      -- button.style.selected_font_color = {0, 0, 0}
      -- button.style.selected_hovered_font_color = {0, 0, 0}
      -- button.style.selected_clicked_font_color = {0, 0, 0}

      local factory_name = button.add{
        type = "label",
        caption = string.format("[space-location=%s] %s", factory.export.space_location, factory.export.name),
      }
      factory_name.style.maximal_width = flow.style.minimal_width - 60
      -- factory_name.style.font_color = {0, 0, 0}

      local piston = button.add{
        type = "flow",
      }
      piston.style.horizontally_stretchable = true -- the piston is still needed even though it does jack shit

      local factory_count = button.add{
        type = "label",
        caption = tostring(factory.count),
      }
      factory_count.style.minimal_width = flow.style.minimal_width - 50
      factory_count.style.horizontal_align = "right"

      local trash = flow.add{
        type = "sprite-button",
        style = "tool_button_red",
        sprite = "utility/trash",
        tooltip = "Delete factory",
        tags = {
          action = mod_prefix .. "delete-factory",
          factory_index = factory.index,
        }
      }
    end
  end
end

Factories.on_gui_click = function (event)
  if not event.element.tags.action then return end

  if event.element.tags.action == mod_prefix .. "delete-factory" then
    Factories.delete_by_index(event.element.tags.factory_index)
  elseif event.element.tags.action == mod_prefix .. "select-factory" then
    local factory = storage.factories[event.element.tags.factory_index]
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    if player.opened_gui_type == defines.gui_type.entity then
      if mod.container_names_map[player.opened.name] then
        local building = storage.buildings[player.opened.unit_number]

        if building.factory_index == factory.index then
          factory.count = factory.count - 1
          building.factory_index = nil
          Buildings.set_status_not_configured(building)
        else
          local old_factory = storage.factories[building.factory_index]
          if old_factory then
            old_factory.count = old_factory.count - 1
          end

          Buildings.set_factory(building, factory)
      end
        Factories.refresh_list()
      end
    end
  end
end

return Factories
