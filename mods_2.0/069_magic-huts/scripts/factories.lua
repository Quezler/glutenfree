local Factories = {}

Factories.add = function (factory)
  table.insert(storage.factories, 1, {
    index = mod.next_index_for("factory"),
    export = factory,
    count = math.random(0, 10),
  })
  Factories.refresh_list()
end

Factories.refresh_list = function ()
  for _, playerdata in pairs(storage.playerdata) do
    local scroll_pane = playerdata.player.gui.relative[mod.relative_frame_left_name]["inner"]["scroll-pane"]
    scroll_pane.clear()

    for _, factory in ipairs(storage.factories) do
      local flow = scroll_pane.add{
        type = "flow",
        style = "horizontal_flow",
      }
      flow.style.minimal_width = 280
      flow.style.maximal_height = 24
      flow.style.vertical_align = "center"
      flow.style.horizontal_spacing = 0
      flow.style.horizontally_stretchable = true

      local button = flow.add{
        type = "button",
        style = "list_box_item",
      }

      local factory_name = button.add{
        type = "label",
        caption = factory.export.name,
      }

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
    for i = #storage.factories, 1, -1 do
      local factory = storage.factories[i]
      if factory.index == event.element.tags.factory_index then
        table.remove(storage.factories, i)
        Factories.refresh_list()
        return
      end
    end
  end
end

return Factories
