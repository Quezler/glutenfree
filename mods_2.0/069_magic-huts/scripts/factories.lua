local Factories = {}

Factories.add = function (factory)
  table.insert(storage.factories, 1, {
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
      }
    end
  end
end

return Factories
