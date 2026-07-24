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

      local tooltip = {""}

      table.insert(tooltip, "exporter: " .. factory.export.exported_by)

      local entities_string = "\nbuildings:"
      for _, entity in ipairs(factory.export.entities) do
        entities_string = entities_string .. string.format("\n[%s=%s] × %g", entity.type, entity.name, entity.count)
      end
      table.insert(tooltip, entities_string)

      local modules_string = "\nmodules:"
      for _, module in ipairs(factory.export.modules) do
        modules_string = modules_string .. string.format("\n[%s=%s] × %g", module.type, module.name, module.count)
      end
      if next(factory.export.modules) then
        table.insert(tooltip, modules_string)
      end

      local products_string = "\nproducts:"
      for _, product in ipairs(factory.export.products) do
        products_string = products_string .. string.format("\n[%s=%s] × %g", product.type, product.name, product.count)
      end
      table.insert(tooltip, products_string)

      local byproducts_string = "\nbyproducts:"
      for _, byproduct in ipairs(factory.export.byproducts) do
        byproducts_string = byproducts_string .. string.format("\n[%s=%s] × %g", byproduct.type, byproduct.name, byproduct.count)
      end
      if next(factory.export.byproducts) then
        table.insert(tooltip, byproducts_string)
      end

      local ingredients_string = "\ningredients:"
      for _, ingredient in ipairs(factory.export.ingredients) do
        ingredients_string = ingredients_string .. string.format("\n[%s=%s] × %g", ingredient.type, ingredient.name, ingredient.count)
      end
      table.insert(tooltip, ingredients_string)

      local button = flow.add{
        type = "button",
        style = "list_box_item",
        tags = {
          action = mod_prefix .. "select-factory",
          factory_index = factory.index,
        },
        tooltip = tooltip
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
        caption = string.format("[img=%s] %s", factory.export.space_location_icon, factory.export.name),
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
    if factory then
      local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
      if player.opened_gui_type == defines.gui_type.entity and mod.container_names_map[player.opened.name] then
        local building = storage.buildings[player.opened.unit_number]

        if building.factory_index == factory.index then
          Buildings.set_factory_index(building, nil) -- select active factory to unconfigure it
        else
          Buildings.set_factory_index(building, factory.index)
        end
      end
    end
  end
end

Factories.allowed_on_surface = function(factory, surface)
  -- allowed on the mod's special surface
  if surface == storage.surface then
    return true
  end

  -- exported when there were no different planets
  if factory.export.space_location == nil then
    return true
  end

  -- district matches the planet
  if surface.planet and surface.planet.name == factory.export.space_location then
    return true
  end

  -- space platforms match the space platform prototype
  if surface.platform and "space-platform" == factory.export.space_location then
    return true
  end

  return false
end

return Factories
